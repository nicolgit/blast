import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'blastfile.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class BlastFile {
  final String cloudName;
  final String fileName;
  final String filePath;

  BlastFile({required this.cloudName, required this.fileName, required this.filePath});

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  factory BlastFile.fromJson(Map<String, dynamic> json) => _$BlastFileFromJson(json);

  Map<String, dynamic> toJson() => _$BlastFileToJson(this);
}
