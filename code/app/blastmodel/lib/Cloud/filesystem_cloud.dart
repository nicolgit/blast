import 'dart:io';
import 'dart:typed_data';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:path_provider/path_provider.dart';

class FileSystemCloud extends Cloud {
  @override
  String get name => 'local file system';

  @override
  Future<List<CloudObject>> getFiles(String path) async {
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();

    List<CloudObject> files = [];
    files.add(CloudObject(
        name: 'test',
        path: appDocumentsDir.path,
        size: 0,
        url: appDocumentsDir.path,
        lastModified: DateTime.now(),
        isDirectory: true));

    return files;
  }

  @override
  Future<Uint8List> getFile(String path) {
    // TODO: implement getFile
    throw UnimplementedError();
  }

  @override
  // TODO: implement rootpath
  String get rootpath => "c:\\";
}
