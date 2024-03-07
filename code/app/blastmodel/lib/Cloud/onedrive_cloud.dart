import 'dart:convert';
import 'dart:typed_data';
import 'package:app_links/app_links.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/secrets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class OneDriveCloud extends Cloud {
  //final Uri oidcMetadataUrl =
  //    Uri.parse('https://login.microsoftonline.com/consumers/v2.0/.well-known/openid-configuration');

  final _authorizationEndpoint = Uri.parse('https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize');
  final _tokenEndpoint = Uri.parse('https://login.microsoftonline.com/consumers/oauth2/v2.0/token');
  final _applicationId = Secrets.oneDriveApplicationId;
  final _applicationSecret = Secrets.oneDriveSecret;
  final _redirectUrl = Uri.parse('blastapp://auth');
  final List<String> _scopes = ['openid', 'profile', 'User.Read', 'Files.Read'];
  final _appLinks = AppLinks();

  Future<oauth2.Client> _createClient() async {
    var grant = oauth2.AuthorizationCodeGrant(_applicationId, _authorizationEndpoint, _tokenEndpoint,
        secret: _applicationSecret);

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
    return grant.handleAuthorizationResponse(responseUrl.queryParameters);
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

    while (responseUri == null) {
      await Future.delayed(const Duration(seconds: 1));
      print("waiting...."); x
    }

    return responseUri!;
  }

  @override
  String get id => "ONEDRIVE";
  @override
  String get name => 'Microsoft OneDrive personal';
  @override
  // TODO: implement getFiles
  Future<String> get rootpath => Future.value('https://graph.microsoft.com/v1.0/me/drive/root');

  @override
  Future<List<CloudObject>> getFiles(String path) async {
    List<CloudObject> files = List.empty(growable: true);

    var client = await _createClient();
    var response = await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me/drive/root/children'));
    /*
    if (_credential != null) {
      var httpClient = _credential!.createHttpClient();

      var response = await httpClient.get(Uri.parse('https://graph.microsoft.com/v1.0/me/drive/root/children'));
      final onedriveData = await json.decode(response.body);

      for (int i = 0; i < onedriveData['@odata.count'] - 2; i++) {
        var co = CloudObject(
          name: onedriveData['value'][i]['name'],
          path: onedriveData['value'][i]['parentReference']['path'],
          isDirectory: onedriveData['value'][i]['folder'] != null,
          url: onedriveData['value'][i]['parentReference']['path'],
          lastModified: DateTime.now(),
          size: 0,
        );
        files.add(co);
        print(i);
      }

      print("********root");
      print(response.body.toString());
    }
    */

    return files;
  }

  @override
  Future<Uint8List> getFile(String path) {
    // TODO: implement getFile
    throw UnimplementedError();
  }

  @override
  Future<String> goToParentDirectory(String currentPath) {
    // TODO: implement goToParentDirectory
    throw UnimplementedError();
  }

  @override
  Future<bool> setFile(String path, Uint8List bytes) {
    // TODO: implement setFile
    throw UnimplementedError();
  }
}
