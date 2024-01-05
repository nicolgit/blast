// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blastfilelist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlastFileList _$BlastFileListFromJson(Map<String, dynamic> json) =>
    BlastFileList()
      ..list = (json['List'] as List<dynamic>)
          .map((e) => BlastFile.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$BlastFileListToJson(BlastFileList instance) =>
    <String, dynamic>{
      'List': instance.list.map((e) => e.toJson()).toList(),
    };
