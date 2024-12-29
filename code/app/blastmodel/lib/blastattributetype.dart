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

extension BlastAttributeTypeExtension on BlastAttributeType {
  String get description {
    switch (this) {
      case BlastAttributeType.typeString:
        return 'String attribute';
      case BlastAttributeType.typePassword:
        return 'Password attribute';
      case BlastAttributeType.typeURL:
        return 'URL attribute';
      case BlastAttributeType.typeHeader:
        return 'Header attribute';
    }
  }
}