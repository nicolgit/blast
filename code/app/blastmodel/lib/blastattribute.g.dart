// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blastattribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlastAttribute _$BlastAttributeFromJson(Map<String, dynamic> json) =>
    BlastAttribute()
      ..name = json['Name'] as String
      ..value = json['Value'] as String
      ..type = $enumDecode(_$BlastAttributeTypeEnumMap, json['Type']);

Map<String, dynamic> _$BlastAttributeToJson(BlastAttribute instance) =>
    <String, dynamic>{
      'Name': instance.name,
      'Value': instance.value,
      'Type': _$BlastAttributeTypeEnumMap[instance.type]!,
    };

const _$BlastAttributeTypeEnumMap = {
  BlastAttributeType.typeString: 1,
  BlastAttributeType.typePassword: 2,
  BlastAttributeType.typeURL: 3,
  BlastAttributeType.typeHeader: 4,
};
