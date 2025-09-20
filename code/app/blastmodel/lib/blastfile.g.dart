// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blastfile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlastFile _$BlastFileFromJson(Map<String, dynamic> json) => BlastFile(
      cloudId: json['CloudId'] as String,
      fileName: json['FileName'] as String,
      fileUrl: json['FileUrl'] as String,
    )..lastModified = json['LastModified'] == null
        ? null
        : DateTime.parse(json['LastModified'] as String);

Map<String, dynamic> _$BlastFileToJson(BlastFile instance) => <String, dynamic>{
      'CloudId': instance.cloudId,
      'FileName': instance.fileName,
      'FileUrl': instance.fileUrl,
      'LastModified': instance.lastModified?.toIso8601String(),
    };
