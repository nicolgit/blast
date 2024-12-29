import 'dart:typed_data';
import 'package:blastmodel/Cloud/cloud_object.dart';

abstract class Cloud {
  String get id;
  String get name;
  String get description;
  String? cachedCredentials;
  Future<String> get rootpath;

  Future<List<CloudObject>> getFiles(String path);
  Future<CloudFile> createFile(String path, Uint8List bytes);
  Future<CloudFile> getFile(String id);
  Future<CloudFileInfo> getFileInfo(String id);
  Future<CloudFile> setFile(String id, Uint8List bytes);
  Future<String> goToParentDirectory(String currentPath);
}
