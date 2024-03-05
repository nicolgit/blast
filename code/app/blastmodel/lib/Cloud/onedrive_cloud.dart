import 'dart:convert';
import 'dart:typed_data';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/secrets.dart';
import 'package:url_launcher/url_launcher.dart';

class OneDriveCloud extends Cloud {
  //final Uri oidcMetadataUrl =
  //    Uri.parse('https://login.microsoftonline.com/consumers/v2.0/.well-known/openid-configuration');
  final List<String> _scopes = ['openid', 'profile', 'User.Read', 'Files.Read'];

  @override
  String get id => "ONEDRIVE";
  @override
  String get name => 'Microsoft OneDrive personal';
  @override
  // TODO: implement getFiles
  Future<String> get rootpath => Future.value('https://graph.microsoft.com/v1.0/me/drive/root');

  @override
  Future<List<CloudObject>> getFiles(String path) async {
    //await _authenticateIfNeeded();

    List<CloudObject> files = List.empty(growable: true);

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
