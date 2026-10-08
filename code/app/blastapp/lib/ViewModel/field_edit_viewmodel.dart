import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:flutter/foundation.dart';

class FieldEditViewModel extends ChangeNotifier {
  FieldEditViewModel(this.attribute);

  final BlastAttribute attribute;

  bool get isSupported =>
      attribute.type == BlastAttributeType.typeHeader || attribute.type == BlastAttributeType.typeString;

  String get initialValue {
    switch (attribute.type) {
      case BlastAttributeType.typeHeader:
        return attribute.name;
      case BlastAttributeType.typeString:
        return attribute.value;
      case BlastAttributeType.typePassword:
      case BlastAttributeType.typeURL:
        return '';
    }
  }

  String get labelText {
    switch (attribute.type) {
      case BlastAttributeType.typeHeader:
        return 'Header';
      case BlastAttributeType.typeString:
        return 'Value';
      case BlastAttributeType.typePassword:
      case BlastAttributeType.typeURL:
        return 'Unsupported attribute type';
    }
  }

  void save(String value) {
    switch (attribute.type) {
      case BlastAttributeType.typeHeader:
        attribute.name = value;
      case BlastAttributeType.typeString:
        attribute.value = value;
      case BlastAttributeType.typePassword:
      case BlastAttributeType.typeURL:
        throw UnsupportedError(
          'Editing ${attribute.type.name} attributes is not supported',
        );
    }
  }
}
