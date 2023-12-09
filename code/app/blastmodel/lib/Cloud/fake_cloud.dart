import 'dart:math';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';

class FakeCloud extends Cloud {
  @override
  String get name => 'Fake Cloud - for testing purposes only';

  @override
  Future<List<CloudObject>> getFiles(String path) {
    Random random = Random();
    List<CloudObject> files = [];
    int totalFiles = random.nextInt(20);
    for (int i = 0; i < totalFiles; i++) {
      String name = "";
      int fileNameLength = random.nextInt(20) + 3;
      for (int j = 0; j < fileNameLength; j++) {
        name += String.fromCharCode(random.nextInt(26) + 65);
      }

      bool isDirectory = random.nextInt(5) == 0;
      if (!isDirectory) {
        name += ".blast";
      }

      files.add(CloudObject(
          name: name,
          path: path,
          size: random.nextInt(1000000),
          lastModified:
              DateTime.now().subtract(Duration(days: random.nextInt(365))),
          url: '$path/$name',
          isDirectory: isDirectory));
    }

    return Future.value(files);
  }
}
