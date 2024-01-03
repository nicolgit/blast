// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blastattribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlastAttribute _$BlastAttributeFromJson(Map<String, dynamic> json) =>
    BlastAttribute(
      type: $enumDecodeNullable(_$BlastAttributeTypeEnumMap, json['Type']) ??
          BlastAttributeType.typeString,
    )
      ..name = json['Name'] as String
      ..value = json['Value'] as String
      ..type = $enumDecodeNullable(_$BlastAttributeTypeEnumMap, json['Type']) ??
          BlastAttributeType.typeString;

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
