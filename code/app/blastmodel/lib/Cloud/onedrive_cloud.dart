import 'dart:convert';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:blastmodel/secrets.dart';
import 'package:flutter/foundation.dart';

import 'package:blastmodel/specific/blastoauth/blastoauth.dart';
import 'package:blastmodel/specific/blastoauth/blastoauth_stub.dart'
    if (dart.library.io) 'package:blastmodel/specific/blastoauth/blastoauth_mobile.dart'
    if (dart.library.html) 'package:blastmodel/specific/blastoauth/blastoauth_web.dart';
import 'package:oauth2/oauth2.dart';

class OneDriveCloud extends Cloud {
  OneDriveCloud() {
    var redirectUri = Uri();

    if (kIsWeb) {
      final currentUri = Uri.base;

      redirectUri = Uri(
        host: currentUri.host,
        scheme: currentUri.scheme,
        port: currentUri.port,
        path: '/auth-landing.html',
      );
    } else {
      redirectUri = Uri.parse('blastapp://auth');
    }

    _oauth = getBlastAuth().initialize(
        applicationId: clientId,
        authorizationEndpoint: Uri.parse('https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize'),
        tokenEndpoint: Uri.parse('https://login.microsoftonline.com/consumers/oauth2/v2.0/token'),
        redirectUri: redirectUri,
        scopes: ['openid', 'profile', 'Files.ReadWrite', 'offline_access'],
        logoutUrl: 'https://login.microsoftonline.com/common/oauth2/v2.0/logout?post_logout_redirect_uri=REDIRECT_URI');
  }

  late BlastOAuth _oauth;

  @override
  String get id => "MSONEDRIVE";
  @override
  String get name => 'OneDrive full access';
  @override
  String get description => 'Microsoft personal cloud storage, data stored in cloud, requires a Microsoft account';
  @override
  Future<String> get rootpath => Future.value('/drive/root');

  String get clientId => Secrets.oneDriveApplicationId;

  @override
  bool get hasCachedCredentials => true;

  @override
  String? get cachedCredentials {
    return _oauth.cachedCredentials;
  }

  @override
  set cachedCredentials(String? value) {
    _oauth.cachedCredentials = value;
  }

  @override
  Future<List<CloudObject>> getFiles(String path) async {
    List<CloudObject> files = List.empty(growable: true);

    //
    // API https://learn.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_list_children?view=odsp-graph-online
    //
    // https://graph.microsoft.com/v1.0/me/drive/root/children
    // https://graph.microsoft.com/v1.0/me/drive/root:/folde1/folder2/folder3:/children
    //
    if (path != await rootpath) {
      path = '$path:';
    }

    Client client;

    client = await _oauth.createClient();

    var response = await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me/$path/children'));

    final onedriveData = await json.decode(response.body);

    for (int i = 0; i < onedriveData['value'].length; i++) {
      var co = CloudObject(
        name: onedriveData['value'][i]['name'],
        path: onedriveData['value'][i]['parentReference']['path'] + '/${onedriveData['value'][i]['name']}',
        isDirectory: onedriveData['value'][i]['folder'] != null,
        url: onedriveData['value'][i]['folder'] == null
            ? onedriveData['value'][i]['id'] // onedriveData['value'][i]['@microsoft.graph.downloadUrl']
            : onedriveData['value'][i]['parentReference']['path'] + '/${onedriveData['value'][i]['name']}',
        lastModified: DateTime.now(),
        size: 0,
      );
      files.add(co);
    }

    if (kDebugMode) {
      print(response.body.toString());
    }

    return files;
  }

  @override
  Future<CloudFile> getFile(String id) async {
    var client = await _oauth.createClient();

    // /me/drive/items/{item-id}/content
    //var response = await client.get(Uri.parse(path));

    // get file lastModified datetime
    // https://learn.microsoft.com/en-us/graph/api/driveitem-get?view=graph-rest-1.0&tabs=http#optional-query-parameters
    final fileInfo = await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me/drive/items/$id'));
    final fileInfoDecoded = await json.decode(fileInfo.body);
    final lastmodified = fileInfoDecoded["lastModifiedDateTime"];
    final lastModifiedDateTime = DateTime.parse(lastmodified);

    //convert string to datetime

    var response = await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me/drive/items/$id/content'));

    final fileContent = Uint8List.fromList(response.bodyBytes);

    return CloudFile(data: fileContent, lastModified: lastModifiedDateTime, id: id);
  }

  @override
  Future<String> goToParentDirectory(String currentPath) async {
    var rootpath = await this.rootpath;

    if (currentPath == rootpath) {
      return rootpath;
    }

    var newPath = currentPath.substring(0, currentPath.lastIndexOf('/'));
    if (newPath == rootpath || newPath == '$rootpath:') {
      return rootpath;
    }

    return Future.value(newPath);
  }

  @override
  Future<CloudFile> setFile(String id, Uint8List bytes) async {
    // https://learn.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_put_content?view=odsp-graph-online
    // PUT /me/drive/items/{item-id}/contents

    var client = await _oauth.createClient();
    var response =
        await client.put(Uri.parse('https://graph.microsoft.com/v1.0/me/drive/items/$id/content'), body: bytes);

    if (response.statusCode != 200) {
      throw BlastRESTAPIException(response.statusCode, response.body);
    }

    final fileInfo = await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me/drive/items/$id'));
    final fileInfoDecoded = await json.decode(fileInfo.body);
    final lastmodified = fileInfoDecoded["lastModifiedDateTime"];
    final lastModifiedDateTime = DateTime.parse(lastmodified);

    final CloudFile cf = CloudFile(data: bytes, lastModified: lastModifiedDateTime, id: id);

    return cf;
  }

  @override
  Future<CloudFile> createFile(String path, Uint8List bytes) async {
    // https://learn.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_put_content?view=odsp-graph-online
    // PUT /me/drive/root:/FolderA/FileB.txt:/content

    //remove string xxx from begin of path
    if (path.startsWith(await rootpath)) {
      path = path.substring((await rootpath).length);
    }

    if (!path.startsWith('/')) {
      path = '/$path';
    }

    var client = await _oauth.createClient();

    // /me/drive/special/approot:/nomefile.txt:/content
    //final putUri = 'https://graph.microsoft.com/v1.0/me/drive/root:$path:/content';
    final stringRootPath = await rootpath;
    final putUri = 'https://graph.microsoft.com/v1.0/me$stringRootPath:$path:/content';
    var response = await client.put(Uri.parse(putUri), body: bytes);

    var jsonResponse = await json.decode(response.body);

    if (response.statusCode != 201) {
      // 201 Created
      throw BlastRESTAPIException(response.statusCode, response.body);
    }

    final fileId = jsonResponse['id'];
    final CloudFile cf = CloudFile(data: bytes, lastModified: DateTime.now(), id: fileId);
    return cf;
  }

  @override
  Future<CloudFileInfo> getFileInfo(String id) async {
    var client = await _oauth.createClient();
    final fileInfo = await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me/drive/items/$id'));
    final fileInfoDecoded = await json.decode(fileInfo.body);
    final lastmodified = fileInfoDecoded["lastModifiedDateTime"];
    final lastModifiedDateTime = DateTime.parse(lastmodified);

    final CloudFileInfo cfi = CloudFileInfo(lastModified: lastModifiedDateTime, id: id);
    return cfi;
  }

  @override
  Future<bool> logOut() async {
    return await _oauth.logout();
  }

  @override
  Future<void> cancelAuthorization() {
    _oauth.cancelAuthorization();
    return Future.value();
  }
}

class OneDriveFolderCloud extends OneDriveCloud {
  OneDriveFolderCloud() : super();

  @override
  String get name => 'OneDrive app folder (preview)';

  @override
  String get id => "MSONEDRIVEFOLDER";

  @override
  String get description =>
      'Microsoft OneDrive app folder access only. This is the most secure way to use OneDrive because Blast only has access to its own folder and not all your OneDrive files.';

  @override
  Future<String> get rootpath => Future.value('/drive/special/approot');

  @override
  String get clientId => Secrets.oneDriveFolderApplicationId;
}
