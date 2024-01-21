import 'dart:core';
import 'package:blastmodel/blastattribute.dart';
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
  late DateTime lastOpenedDateTime = DateTime.now();
  int usedCounter = 0;
  List<String> tags = List.empty(growable: true);
  List<BlastAttribute> rows = List.empty(growable: true);
  /*
  @override
  String toString() {
    StringBuffer sb = StringBuffer();

    sb.write(title);
    sb.write(" ");
    sb.write(notes);

    for (var tag in tags) {
      sb.write(tag);
      sb.write(" ");
    }

    for (var row in rows) {
      switch (row.type) {
        case BlastAttributeType.typePassword:
          // do not search by password value
          break;
        case BlastAttributeType.typeHeader:
          sb.write(row.name);
          break;
        case BlastAttributeType.typeURL:
          sb.write(row.value);
          break;
        case BlastAttributeType.typeString:
          sb.write("${row.name} ${row.value}");
          break;
        default:
          sb.write("${row.name} ${row.value}");
          break;
      }
      sb.write(" ");
    }

    return sb.toString();
  }
  */

  factory BlastCard.fromJson(Map<String, dynamic> json) => _$BlastCardFromJson(json);

  Map<String, dynamic> toJson() => _$BlastCardToJson(this);

  /*
  AdvancedSearchResult advancedSearch(String text) {
    var words = text.split(" ");
    var result = AdvancedSearchResult.NotFound;

    for (var word in words) {
      if (word.length > 0) {
        var tempResult = containsWord(word);

        if (tempResult == AdvancedSearchResult.NotFound) {
          return AdvancedSearchResult.NotFound;
        }

        if (tempResult == AdvancedSearchResult.InTitle ||
            result == AdvancedSearchResult.InTitle) {
          result = AdvancedSearchResult.InTitle;
        } else {
          result = AdvancedSearchResult.InBody;
        }
      }
    }

    return result;
  }

  AdvancedSearchResult containsWord(String s) {
    s = removeDiacritics(s);

    if (Title != null) {
      if (removeDiacritics(Title).contains(s, 0)) {
        return AdvancedSearchResult.InTitle;
      }
    }

    var me = removeDiacritics(toString());
    return me.contains(s, 0)
        ? AdvancedSearchResult.InBody
        : AdvancedSearchResult.NotFound;
  }
  */

  /*
  import 'dart:io';
  import 'package:diacritic/diacritic.dart';

  void main() {
    String input = 'Café au Lait';
    String result = _removeDiacritics(input);
    print(result); // Output: Cafe au Lait
  }

  String _removeDiacritics(String text) {
    String normalizedText = removeDiacritics(text);
    return normalizedText;
  }
  */
}
