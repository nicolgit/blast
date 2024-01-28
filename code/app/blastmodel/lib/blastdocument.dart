import 'dart:convert';

import 'package:blastmodel/blastcard.dart';
import 'package:diacritic/diacritic.dart';
import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blastdocument.g.dart';

enum SortType { none, star, mostUsed, recentUsed}
enum SearchResult { notFound, foundInTitle, foundInBody }
enum SearchOperator { and, or }

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

  List<BlastCard> search(String searchText, SearchOperator searchOperator, SortType sortType) {
    final List<String> words = removeDiacritics(searchText).toLowerCase().split(" ");
    
    // check for words empty list
    if (words.isEmpty) {
      return cards;
    }
    if(words.where((element) => element.isNotEmpty).isEmpty) {
      return cards;
    }

    switch (sortType) {
      case SortType.none:
        return cards.where((element) => element.seach(words, searchOperator) != SearchResult.notFound).toList();
      case SortType.star:
        final List<BlastCard> starredCards = cards.where((element) => element.isFavorite).toList();

        return starredCards.where((element) => element.seach(words, searchOperator) != SearchResult.notFound).toList();
      case SortType.mostUsed:
        final List<BlastCard> filteredList = cards.where((element) => element.seach(words, searchOperator) != SearchResult.notFound).toList();
        filteredList.sort((a, b) => a.usedCounter.compareTo(b.usedCounter));

        return filteredList; 
      case SortType.recentUsed:
        final List<BlastCard> filteredList = cards.where((element) => element.seach(words, searchOperator) != SearchResult.notFound).toList();
        filteredList.sort((b, a) => a.lastOpenedDateTime.compareTo(b.lastOpenedDateTime));

        return filteredList;
    }
  }

  factory BlastDocument.fromJson(Map<String, dynamic> json) =>
      _$BlastDocumentFromJson(json);

  Map<String, dynamic> _toJson() => _$BlastDocumentToJson(this);
}
