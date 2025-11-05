import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
part 'blastbiometricstorage.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class BlastBiometricStorageData {
  String password;
  String? cloudCredentials;

  BlastBiometricStorageData({required this.password, this.cloudCredentials});

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  factory BlastBiometricStorageData.fromJson(Map<String, dynamic> json) => _$BlastBiometricStorageDataFromJson(json);

  Map<String, dynamic> toJson() => _$BlastBiometricStorageDataToJson(this);
}
