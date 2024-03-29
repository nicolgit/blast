import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'blastfile.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class BlastFile {
  final String cloudId;
  String fileName;
  String fileUrl;
  String? jsonCredentials;

  BlastFile({required this.cloudId, required this.fileName, required this.fileUrl, required this.jsonCredentials});

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  bool isEqualto(BlastFile other) {
    return cloudId == other.cloudId && fileName == other.fileName && fileUrl == other.fileUrl;
  }

  factory BlastFile.fromJson(Map<String, dynamic> json) => _$BlastFileFromJson(json);

  Map<String, dynamic> toJson() => _$BlastFileToJson(this);
}
