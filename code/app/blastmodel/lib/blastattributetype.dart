import 'package:json_annotation/json_annotation.dart';

enum BlastAttributeType {
  @JsonValue(1)
  typeString,

  @JsonValue(2)
  typePassword,

  @JsonValue(3)
  typeURL,

  @JsonValue(4)
  typeHeader
}
