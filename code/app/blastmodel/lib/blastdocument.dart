import 'dart:convert';

import 'package:blastmodel/blastcard.dart';
import 'package:diacritic/diacritic.dart';
import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blastdocument.g.dart';

enum SortType { mostUsed, recentUsed }

enum SearchResult { notFound, foundInTitle, foundInBody }

enum SearchOperator { and, or }

enum SearchWhere { title, everywhere }

@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class BlastDocument {
  BlastDocument();

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool isChanged = false;

  String id = const Uuid().v4();
  int version = 1;

  List<BlastCard> cards = List<BlastCard>.empty(growable: true);

  @override
  String toString() {
    return jsonEncode(_toJson());
  }

  List<BlastCard> search(String searchText, SearchOperator searchOperator, SortType sortType, SearchWhere searchWhere,
      bool favoritesOnly) {
    final List<String> words = removeDiacritics(searchText).toLowerCase().split(" ");

    bool skipWhereClause = false;
    // check for words empty list
    if (words.isEmpty) {
      skipWhereClause = true;
    }
    if (words.where((element) => element.isNotEmpty).isEmpty) {
      skipWhereClause = true;
    }

    switch (sortType) {
      case SortType.mostUsed:
        var mostUsedList = cards;

        if (!skipWhereClause) {
          mostUsedList = cards
              .where((element) => element.seach(words, searchOperator, searchWhere) != SearchResult.notFound)
              .toList();
        }

        if (favoritesOnly) {
          mostUsedList = mostUsedList.where((element) => element.isFavorite).toList();
        }

        mostUsedList.sort((b, a) => a.usedCounter.compareTo(b.usedCounter));
        return mostUsedList;
      case SortType.recentUsed:
        var recentUsedList = cards;

        if (!skipWhereClause) {
          recentUsedList = cards
              .where((element) => element.seach(words, searchOperator, searchWhere) != SearchResult.notFound)
              .toList();
        }

        if (favoritesOnly) {
          recentUsedList = recentUsedList.where((element) => element.isFavorite).toList();
        }

        recentUsedList.sort((a, b) => b.lastUpdateDateTime.compareTo(a.lastUpdateDateTime));
        return recentUsedList;
    }
  }

  List<String> getDefaultTags() {
    // TODO - make this list configurable
    final List<String> tags = <String>["personal", "work", "family", "money", "health", "hobby"];

    return tags;
  }

  List<String> getTags() {
    final List<String> tags = getDefaultTags();

    for (final BlastCard card in cards) {
      for (final String tag in card.tags) {
        if (!tags.contains(tag)) {
          tags.add(tag);
        }
      }
    }

    tags.sort();
    return tags;
  }

  factory BlastDocument.fromJson(Map<String, dynamic> json) => _$BlastDocumentFromJson(json);

  Map<String, dynamic> _toJson() => _$BlastDocumentToJson(this);
}
