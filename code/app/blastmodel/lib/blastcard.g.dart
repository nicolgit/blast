// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blastcard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlastCard _$BlastCardFromJson(Map<String, dynamic> json) => BlastCard()
  ..id = json['Id'] as String
  ..title = json['Title'] as String?
  ..notes = json['Notes'] as String?
  ..isFavorite = json['IsFavorite'] as bool
  ..lastUpdateDateTime = DateTime.parse(json['LastUpdateDateTime'] as String)
  ..usedCounter = (json['UsedCounter'] as num).toInt()
  ..tags = (json['Tags'] as List<dynamic>).map((e) => e as String).toList()
  ..rows = (json['Rows'] as List<dynamic>)
      .map((e) => BlastAttribute.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$BlastCardToJson(BlastCard instance) => <String, dynamic>{
      'Id': instance.id,
      'Title': instance.title,
      'Notes': instance.notes,
      'IsFavorite': instance.isFavorite,
      'LastUpdateDateTime': instance.lastUpdateDateTime.toIso8601String(),
      'UsedCounter': instance.usedCounter,
      'Tags': instance.tags,
      'Rows': instance.rows.map((e) => e.toJson()).toList(),
    };
