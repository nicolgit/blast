import 'dart:typed_data';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';

class DropboxCloud extends Cloud {
  @override
  String get id => "DROPBOX";

  @override
  String get name => "Dropbox";

  @override
  String get description => "Dropbox cloud storage, data stored in cloud, requires a Dropbox account";

  @override
  Future<String> get rootpath => throw UnimplementedError();

  @override
  bool get hasCachedCredentials => throw UnimplementedError();

  @override
  String? get cachedCredentials => throw UnimplementedError();

  @override
  set cachedCredentials(String? value) => throw UnimplementedError();

  @override
  Future<List<CloudObject>> getFiles(String path) {
    throw UnimplementedError();
  }

  @override
  Future<CloudFile> createFile(String path, Uint8List bytes) {
    throw UnimplementedError();
  }

  @override
  Future<CloudFile> getFile(String id) {
    throw UnimplementedError();
  }

  @override
  Future<CloudFileInfo> getFileInfo(String id) {
    throw UnimplementedError();
  }

  @override
  Future<CloudFile> setFile(String id, Uint8List bytes) {
    throw UnimplementedError();
  }

  @override
  Future<String> goToParentDirectory(String currentPath) {
    throw UnimplementedError();
  }

  @override
  Future<bool> logOut() {
    throw UnimplementedError();
  }
}
