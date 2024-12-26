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

class CloudFile{
  Uint8List data;
  DateTime lastModified;
  String id;

  CloudFile({required this.data, required this.lastModified, required this.id});
}
