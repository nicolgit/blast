import 'dart:typed_data';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';

class FileSystemCloud extends Cloud {
  @override
  String get name => 'local file system';

  @override
  Future<List<CloudObject>> getFiles(String path) {
    // TODO: implement getFiles
    throw UnimplementedError();
  }

  @override
  Uint8List getFile(String path) {
    // TODO: implement getFile
    throw UnimplementedError();
  }
}
