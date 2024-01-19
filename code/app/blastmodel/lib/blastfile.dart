import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'blastfile.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class BlastFile {
  final String cloudId;
  String fileName;
  String filePath;

  BlastFile({required this.cloudId, required this.fileName, required this.filePath});

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  bool isEqualto(BlastFile other) {
    return cloudId == other.cloudId && fileName == other.fileName && filePath == other.filePath;
  }

  factory BlastFile.fromJson(Map<String, dynamic> json) => _$BlastFileFromJson(json);

  Map<String, dynamic> toJson() => _$BlastFileToJson(this);
}
