import 'dart:typed_data';
import 'package:blastmodel/Cloud/cloud_object.dart';

abstract class Cloud {
  String get id;
  String get name;
  String get description;
  String? cachedCredentials;
  Future<String> get rootpath;

  Future<List<CloudObject>> getFiles(String path);
  Future<String> createFile(String path, Uint8List bytes);
  Future<Uint8List> getFile(String id);
  Future<bool> setFile(String id, Uint8List bytes);
  Future<String> goToParentDirectory(String currentPath);
}
