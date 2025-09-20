import 'dart:io';
import 'dart:typed_data';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:path_provider/path_provider.dart';

class FileSystemCloud extends Cloud {
  @override
  String get id => "LOCAL";
  @override
  String get name => 'local file system';
  @override
  String get description => 'data stored on local disk, accessible only on this device';

  @override
  Future<String> get rootpath async => "${(await getApplicationDocumentsDirectory()).path}${Platform.pathSeparator}";

  @override
  Future<List<CloudObject>> getFiles(String path) async {
    List<CloudObject> files = [];

    var localFiles = Directory(path).listSync();
    for (var f in localFiles) {
      files.add(CloudObject(
          name: f.path.split(Platform.pathSeparator).last,
          path: f.parent.path,
          size: f.statSync().size,
          url: f.path,
          lastModified: DateTime.now(),
          isDirectory: f.statSync().type == FileSystemEntityType.directory));
    }

    return files;
  }

  @override
  Future<CloudFile> getFile(String id) async {
    final file = File(id);

    return CloudFile(data: await file.readAsBytes(), lastModified: file.lastModifiedSync(), id: id);
  }

  @override
  Future<CloudFile> setFile(String id, Uint8List bytes) async {
    final file = File(id);
    await file.writeAsBytes(bytes);

    final lastModified = file.lastModifiedSync();

    final CloudFile cf = CloudFile(data: bytes, lastModified: lastModified, id: id);

    return Future.value(cf);
  }

  @override
  Future<String> goToParentDirectory(String currentPath) async {
    // remove string after last \
    if (currentPath.endsWith(Platform.pathSeparator)) {
      currentPath = currentPath.substring(0, currentPath.length - 1);
    }

    int index = currentPath.lastIndexOf(Platform.pathSeparator);
    if (index > 0) {
      var newPath = currentPath.substring(0, index + 1);

      String path = await rootpath;
      if (newPath.length < path.length) {
        return rootpath;
      } else {
        return newPath;
      }
    } else {
      return currentPath;
    }
  }

  @override
  Future<CloudFile> createFile(String path, Uint8List bytes) async {
    final cf = await setFile(path, bytes);

    return cf;
  }

  @override
  Future<CloudFileInfo> getFileInfo(String id) {
    final file = File(id);

    final CloudFileInfo cfi = CloudFileInfo(id: id, lastModified: file.lastModifiedSync());

    return Future.value(cfi);
  }

  @override
  Future<bool> logOut() {
    return Future.value(true);
  }

  @override
  String? cachedCredentials;
}
