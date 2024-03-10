import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:blastmodel/secrets.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class OneDriveCloud extends Cloud {
  final _authorizationEndpoint = Uri.parse('https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize');
  final _tokenEndpoint = Uri.parse('https://login.microsoftonline.com/consumers/oauth2/v2.0/token');
  final _applicationId = Secrets.oneDriveApplicationId;
  final _redirectUrl = Uri.parse('blastapp://auth');
  final List<String> _scopes = ['openid', 'profile', 'User.Read', 'Files.Read'];
  final _appLinks = AppLinks();

  Future<oauth2.Client> _createClient() async {
    if (cachedCredentials != null) {
      var credentials = oauth2.Credentials.fromJson(cachedCredentials!);
      return oauth2.Client(credentials, identifier: _applicationId);
    }

    var grant = oauth2.AuthorizationCodeGrant(_applicationId, _authorizationEndpoint, _tokenEndpoint);

    // A URL on the authorization server (authorizationEndpoint with some
    // additional query parameters). Scopes and state can optionally be passed
    // into this method.
    var authorizationUrl = grant.getAuthorizationUrl(_redirectUrl, scopes: _scopes);

    // Redirect the resource owner to the authorization URL. Once the resource
    // owner has authorized, they'll be redirected to `redirectUrl` with an
    // authorization code. The `redirect` should cause the browser to redirect to
    // another URL which should also have a listener.
    //
    // `redirect` and `listen` are not shown implemented here.
    await _redirect(authorizationUrl);
    var responseUrl = await _listen(_redirectUrl);

    // Once the user is redirected to `redirectUrl`, pass the query parameters to
    // the AuthorizationCodeGrant. It will validate them and extract the
    // authorization code to create a new Client.
    var client = await grant.handleAuthorizationResponse(responseUrl.queryParameters);
    cachedCredentials = client.credentials.toJson();

    return client;
  }

  Future<void> _redirect(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<Uri> _listen(Uri url) async {
    Uri? responseUri;

    _appLinks.allUriLinkStream.listen((uri) async {
      if (uri.toString().startsWith(_redirectUrl.toString())) {
        responseUri = uri;
      }
    });

    //wait for authentication, max 30 seconds
    int counter = 0, timeout = 30;
    while (responseUri == null && counter++ < timeout) {
      await Future.delayed(const Duration(seconds: 1));

      if (kDebugMode) {
        print("waiting.... $counter of $timeout");
      }
    }

    if (responseUri == null) {
      throw BlastAuthenticationFailedException();
    }

    return responseUri!;
  }

  @override
  String get id => "ONEDRIVE";
  @override
  String get name => 'Microsoft OneDrive personal';
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

    var client = await _createClient();
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

    print(response.body.toString());

    return files;
  }

  @override
  Future<Uint8List> getFile(String id) async {
    var client = await _createClient();

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
  Future<bool> setFile(String path, Uint8List bytes) {
    // TODO: implement setFile
    throw UnimplementedError();
  }
}
