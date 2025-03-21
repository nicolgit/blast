import 'dart:core';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:diacritic/diacritic.dart';
import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blastcard.g.dart';

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
  //late DateTime lastOpenedDateTime = DateTime.now();
  int usedCounter = 0;
  List<String> tags = List.empty(growable: true);
  List<BlastAttribute> rows = List.empty(growable: true);

  SearchResult seach(List<String> words, SearchOperator searchOperator, SearchWhere searchWhere) {
    // text must be lowercase AND without diacritics to work properly

    if (_searchForWordsInString(words, title, searchOperator)) {
      return SearchResult.foundInTitle;
    }

    String corpus = "";

    if (title != null) {
      corpus += "$title ";
    }

    if (searchWhere == SearchWhere.everywhere) {
      for (var tag in tags) {
        corpus += "$tag ";
      }

      if (notes != null) {
        corpus += "$notes ";
      }

      for (var row in rows) {
        switch (row.type) {
          case BlastAttributeType.typePassword:
            corpus += "${row.name} ";
            break;
          case BlastAttributeType.typeString:
          case BlastAttributeType.typeURL:
            corpus += "${row.name} ${row.value} ";
            break;
          case BlastAttributeType.typeHeader:
            corpus += "${row.name} ";
            break;
        }
      }
    }

    if (_searchForWordsInString(words, corpus, searchOperator)) {
      return searchWhere == SearchWhere.title ? SearchResult.foundInTitle : SearchResult.foundInBody;
    }

    return SearchResult.notFound;
  }

  void copyFrom(BlastCard card) {
    id = card.id;
    title = card.title;
    notes = card.notes;
    isFavorite = card.isFavorite;
    lastUpdateDateTime = card.lastUpdateDateTime;
    //lastOpenedDateTime = card.lastOpenedDateTime;
    usedCounter = card.usedCounter;
    tags = List.from(card.tags);
    rows = List.from(card.rows);
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
