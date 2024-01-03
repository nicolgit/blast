import 'dart:convert';

import 'package:blastmodel/blastcard.dart';
import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blastdocument.g.dart';

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

  factory BlastDocument.fromJson(Map<String, dynamic> json) =>
      _$BlastDocumentFromJson(json);

  Map<String, dynamic> _toJson() => _$BlastDocumentToJson(this);
}
