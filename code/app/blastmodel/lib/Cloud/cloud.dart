import 'dart:typed_data';
import 'package:blastmodel/Cloud/cloud_object.dart';

abstract class Cloud {
  String get id;
  String get name;
  Future<String> get rootpath;

  Future<List<CloudObject>> getFiles(String path);
  Future<Uint8List> getFile(String path);
  Future<bool> setFile(String path, Uint8List bytes);
  Future<String> goToParentDirectory(String currentPath);
}
