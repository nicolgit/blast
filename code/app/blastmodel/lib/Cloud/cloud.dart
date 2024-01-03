import 'dart:typed_data';
import 'package:blastmodel/Cloud/cloud_object.dart';

abstract class Cloud {
  String get name;

  Future<List<CloudObject>> getFiles(String path);
  Future<Uint8List> getFile(String path);
}
