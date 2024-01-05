// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blastfile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlastFile _$BlastFileFromJson(Map<String, dynamic> json) => BlastFile(
      cloudName: json['CloudName'] as String,
      fileName: json['FileName'] as String,
      filePath: json['FilePath'] as String,
    );

Map<String, dynamic> _$BlastFileToJson(BlastFile instance) => <String, dynamic>{
      'CloudName': instance.cloudName,
      'FileName': instance.fileName,
      'FilePath': instance.filePath,
    };
