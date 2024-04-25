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
        applicationId: Secrets.oneDriveApplicationId,
        authorizationEndpoint: Uri.parse('https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize'),
        tokenEndpoint: Uri.parse('https://login.microsoftonline.com/consumers/oauth2/v2.0/token'),
        redirectUri: redirectUri,
        scopes: ['openid', 'profile', 'Files.ReadWrite']);
  }

  late BlastOAuth _oauth;

  @override
  String get id => "MSONEDRIVE";
  @override
  String get name => 'OneDrive personal';
  @override
  String get description => 'Microsoft personal cloud storage, data stored in cloud, requires a Microsoft account';
  @override
  Future<String> get rootpath => Future.value('/drive/root');

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

    var client = await _oauth.createClient();
    var response = await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me/$path/children'));

    final onedriveData = await json.decode(response.body);

    for (int i = 0; i < onedriveData['@odata.count'] - 2; i++) {
      var co = CloudObject(
        name: onedriveData['value'][i]['name'],
        path: onedriveData['value'][i]['parentReference']['path'] + '/' + onedriveData['value'][i]['name'],
        isDirectory: onedriveData['value'][i]['folder'] != null,
        url: onedriveData['value'][i]['folder'] == null
            ? onedriveData['value'][i]['id'] // onedriveData['value'][i]['@microsoft.graph.downloadUrl']
            : onedriveData['value'][i]['parentReference']['path'] + '/' + onedriveData['value'][i]['name'],
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
  Future<Uint8List> getFile(String id) async {
    var client = await _oauth.createClient();

    // /me/drive/items/{item-id}/content
    //var response = await client.get(Uri.parse(path));
    var response = await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me/drive/items/$id/content'));

    return Uint8List.fromList(response.bodyBytes);
  }

  @override
  Future<String> goToParentDirectory(String currentPath) async {
    if (currentPath == ('${await rootpath}:')) {
      return rootpath;
    }

    var newPath = currentPath.substring(0, currentPath.lastIndexOf('/'));
    if (newPath == ('${await rootpath}:')) {
      return rootpath;
    }

    return Future.value(newPath);
  }

  @override
  Future<bool> setFile(String id, Uint8List bytes) async {
    // https://learn.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_put_content?view=odsp-graph-online
    // PUT /me/drive/items/{item-id}/content

    var client = await _oauth.createClient();
    var response =
        await client.put(Uri.parse('https://graph.microsoft.com/v1.0/me/drive/items/$id/content'), body: bytes);

    if (response.statusCode != 200) {
      throw BlastRESTAPIException(response.statusCode, response.body);
    }

    return true;
  }

  @override
  Future<String> createFile(String path, Uint8List bytes) async {
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
    var response =
        await client.put(Uri.parse('https://graph.microsoft.com/v1.0/me/drive/root:$path:/content'), body: bytes);

    var jsonResponse = await json.decode(response.body);

    if (response.statusCode != 201) {
      // 201 Created
      throw BlastRESTAPIException(response.statusCode, response.body);
    }

    return jsonResponse['id'];
  }
}
