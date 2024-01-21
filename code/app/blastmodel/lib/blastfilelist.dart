import 'dart:convert';
import 'package:blastmodel/blastfile.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blastfilelist.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class BlastFileList {
  List<BlastFile> list = List<BlastFile>.empty(growable: true);

  BlastFileList();

  @override
  String toString() {
    return jsonEncode(_toJson());
  }

  factory BlastFileList.fromJson(Map<String, dynamic> json) => _$BlastFileListFromJson(json);

  Map<String, dynamic> _toJson() => _$BlastFileListToJson(this);
}
