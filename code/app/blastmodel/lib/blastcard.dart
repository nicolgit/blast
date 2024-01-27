import 'dart:core';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:diacritic/diacritic.dart';
import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blastcard.g.dart';

enum SearchResult { notFound, foundInTitle, foundInBody }
enum SearchOperator { and, or }

@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class BlastCard {
  BlastCard();

  String id = const Uuid().v4();

  @JsonKey(includeIfNull: true)
  String? title = "";

  @JsonKey(includeIfNull: true)
  String? notes = "";

  bool isFavorite = false;
  late DateTime lastUpdateDateTime = DateTime.now();
  late DateTime lastOpenedDateTime = DateTime.now();
  int usedCounter = 0;
  List<String> tags = List.empty(growable: true);
  List<BlastAttribute> rows = List.empty(growable: true);

  SearchResult seach (List<String> words, SearchOperator searchOperator )
  {
    // text must be lowercase AND without diacritics to work properly

    if (_searchForWordsInString (words, title, searchOperator)) {
        return SearchResult.foundInTitle;
      }

    String corpus = "";

    if (title != null) {
      corpus += "$title ";
    }

    for (var tag in tags)
    {
      corpus += "$tag ";
    }

    if (notes != null) {
      corpus += "$notes ";
    }

    for (var row in rows) {
      switch (row.type)
      {
        case BlastAttributeType.typePassword:
          
          break;
        case BlastAttributeType.typeString:
        case BlastAttributeType.typeURL:
          corpus += "${row.value} "; 
          break;
        case BlastAttributeType.typeHeader:
          corpus += "${row.name} ";
          break;
      }
    }

    if (_searchForWordsInString(words, corpus, searchOperator)) {
      return SearchResult.foundInBody;
    }

    return SearchResult.notFound;

    for (var tag in tags)
    {
      if (_searchForWordsInString(words, tag, searchOperator)) {
        return SearchResult.foundInBody;
      }
    }

    if (_searchForWordsInString(words, notes, searchOperator)) {
      return SearchResult.foundInBody;
    }

    for (var row in rows) {
      switch (row.type)
      {
        case BlastAttributeType.typePassword:
          break;
        case BlastAttributeType.typeString:
        case BlastAttributeType.typeURL:
          if (_searchForWordsInString(words, row.value, searchOperator)) {
            return SearchResult.foundInBody;
          }  
          break;
        case BlastAttributeType.typeHeader:
          if (_searchForWordsInString(words, row.name, searchOperator)) {
            return SearchResult.foundInBody;
          } 
          break;
      }
    }

    return SearchResult.notFound;
  }

  bool _searchForWordsInString(List<String> words, String? text, SearchOperator searchOperator) {
    if (text == null) {
      return false;
    }

    text = text.toLowerCase();
    text = removeDiacritics(text);

    if (searchOperator == SearchOperator.and) {
      for (var word in words) {
        if (word.isNotEmpty) {
          if (!text.contains(word)) {
            return false;
          }
        }
      }
      return true;
    } else {
      for (var word in words) {
        if (word.isNotEmpty) {
          if (text.contains(word)) {
            return true;
          }
        }
      }
      return false;
    }
  }

  factory BlastCard.fromJson(Map<String, dynamic> json) => _$BlastCardFromJson(json);

  Map<String, dynamic> toJson() => _$BlastCardToJson(this);

}
