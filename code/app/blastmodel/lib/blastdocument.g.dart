// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blastdocument.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlastDocument _$BlastDocumentFromJson(Map<String, dynamic> json) =>
    BlastDocument()
      ..id = json['Id'] as String
      ..version = (json['Version'] as num).toInt()
      ..cards = (json['Cards'] as List<dynamic>)
          .map((e) => BlastCard.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$BlastDocumentToJson(BlastDocument instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Version': instance.version,
      'Cards': instance.cards.map((e) => e.toJson()).toList(),
    };
