import 'package:blastmodel/blastattributetype.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blastattribute.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal, explicitToJson: true)
class BlastAttribute {
  BlastAttribute({BlastAttributeType type = BlastAttributeType.typeString}) {
    type = type;
  }

  String name = "";
  String value = "";
  late BlastAttributeType type;

  factory BlastAttribute.fromJson(Map<String, dynamic> json) =>
      _$BlastAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$BlastAttributeToJson(this);
}
