import 'dart:typed_data';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';

class OneDriveCloud extends Cloud {
  @override
  String get id => "ONEDRIVE";
  @override
  String get name => 'OneDrive';
  @override
  // TODO: implement getFiles
  Future<String> get rootpath => Future.value('http://onedrive.com/');

  @override
  Future<List<CloudObject>> getFiles(String path) {
    // TODO: implement getFiles
    throw UnimplementedError();
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
