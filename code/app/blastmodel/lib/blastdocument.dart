import 'dart:convert';

import 'package:blastmodel/blastcard.dart';
import 'package:diacritic/diacritic.dart';
import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blastdocument.g.dart';

enum SortType { none, star, mostUsed, recentUsed }

enum SearchResult { notFound, foundInTitle, foundInBody }

enum SearchOperator { and, or }

enum SearchWhere { title, everywhere }

@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class BlastDocument {
  BlastDocument();

  String id = const Uuid().v4();
  int version = 1;

  List<BlastCard> cards = List<BlastCard>.empty(growable: true);

  @override
  String toString() {
    return jsonEncode(_toJson());
  }

  List<BlastCard> search(String searchText, SearchOperator searchOperator, SortType sortType, SearchWhere searchWhere) {
    final List<String> words = removeDiacritics(searchText).toLowerCase().split(" ");

    bool SkipWhereClause = false;
    // check for words empty list
    if (words.isEmpty) {
      SkipWhereClause = true;
    }
    if (words.where((element) => element.isNotEmpty).isEmpty) {
      SkipWhereClause = true;
    }

    switch (sortType) {
      case SortType.none:
        if (SkipWhereClause) {
          return cards;
        } else {
          return cards
              .where((element) => element.seach(words, searchOperator, searchWhere) != SearchResult.notFound)
              .toList();
        }
      case SortType.star:
        final List<BlastCard> starredCards = cards.where((element) => element.isFavorite).toList();

        if (SkipWhereClause) {
          return starredCards;
        } else {
          return starredCards
              .where((element) => element.seach(words, searchOperator, searchWhere) != SearchResult.notFound)
              .toList();
        }
      case SortType.mostUsed:
        var mostUserList = cards;

        if (!SkipWhereClause) {
          mostUserList = cards
              .where((element) => element.seach(words, searchOperator, searchWhere) != SearchResult.notFound)
              .toList();
        }

        mostUserList.sort((a, b) => a.usedCounter.compareTo(b.usedCounter));

        return mostUserList;
      case SortType.recentUsed:
        var recentUsedList = cards;

        if (!SkipWhereClause) {
          recentUsedList = cards
              .where((element) => element.seach(words, searchOperator, searchWhere) != SearchResult.notFound)
              .toList();
        }

        recentUsedList.sort((b, a) => a.lastOpenedDateTime.compareTo(b.lastOpenedDateTime));
        return recentUsedList;
    }
  }

  factory BlastDocument.fromJson(Map<String, dynamic> json) => _$BlastDocumentFromJson(json);

  Map<String, dynamic> _toJson() => _$BlastDocumentToJson(this);
}
