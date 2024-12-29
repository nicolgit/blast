import 'dart:typed_data';

class CloudObject {
  final String name;
  final String path;
  final String url;
  final DateTime lastModified;
  final int size;
  final bool isDirectory;

  CloudObject({
    required this.name,
    required this.path,
    required this.url,
    required this.lastModified,
    required this.size,
    required this.isDirectory,
  });
}

class CloudFileInfo {
  DateTime lastModified;
  String id;

  CloudFileInfo({required this.lastModified, required this.id});
}

class CloudFile extends CloudFileInfo {
  Uint8List data;

  CloudFile({required this.data, required super.lastModified, required super.id});
}
