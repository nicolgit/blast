import 'dart:convert';
import 'dart:html' as dartHtml;
import 'dart:html';
import 'dart:io' as dartIo;
import 'dart:typed_data';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/secrets.dart';
import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_browser.dart' as browser hide Platform;
import 'package:openid_client/openid_client_io.dart' as io;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OneDriveCloud extends Cloud {
  //final Uri oidcMetadataUrl =
  //    Uri.parse('https://login.microsoftonline.com/consumers/v2.0/.well-known/openid-configuration');
  final Uri _oidcMetadataUrl = Uri.parse('https://login.microsoftonline.com/consumers/v2.0/');
  final List<String> _scopes = ['openid', 'profile', 'User.Read', 'Files.Read'];

  Issuer? _issuer;
  Credential? _credential;

  @override
  String get id => "ONEDRIVE";
  @override
  String get name => 'Microsoft OneDrive personal';
  @override
  // TODO: implement getFiles
  Future<String> get rootpath => Future.value('https://graph.microsoft.com/v1.0/me/drive/root');

  @override
  Future<List<CloudObject>> getFiles(String path) async {
    await _authenticateIfNeeded();

    List<CloudObject> files = List.empty(growable: true);

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

  Future<bool> _authenticateIfNeeded() async {
    _issuer ??= await Issuer.discover(_oidcMetadataUrl);

    if (_credential == null) {
      // create a client
      var client = Client(_issuer!, Secrets.oneDriveApplicationId, clientSecret: Secrets.oneDriveSecret);
      _credential = await _authenticate(client, scopes: _scopes);
    }

    return true;
  }

  Future<Credential?> _authenticate(Client client, {List<String> scopes = const []}) async {
    // create a function to open a browser with an url
    urlLauncherApp(String url) async {
      var uri = Uri.parse(url);
      if (await canLaunchUrl(uri) || dartIo.Platform.isAndroid) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    }

    // create an authenticator
    if (kIsWeb) {
      var authenticator = browser.Authenticator(client, scopes: scopes);

      // starts the authentication
      var futureCredential = authenticator.credential;
      var credential = await futureCredential;

      if (credential != null) {
        Future<void> refresh() async {
          var userData = await credential!.getUserInfo();
        }

        await refresh();

        authenticator.logout();

        //document.querySelector('#refresh')!.onClick.listen((_) async {
        //  credential = await authenticator.trySilentRefresh();
        //  await refresh();
        //});
      } else {
        authenticator.authorize();
      }

      return credential;
    } else {
      var authenticator = io.Authenticator(client, port: 4000, scopes: scopes, urlLancher: urlLauncherApp);

      // close the webview when finished
      if (!kIsWeb && (dartIo.Platform.isAndroid || dartIo.Platform.isIOS)) {
        closeInAppWebView();
      }

      // starts the authentication
      var c = await authenticator.authorize();

      return c;
    }
  }
}
