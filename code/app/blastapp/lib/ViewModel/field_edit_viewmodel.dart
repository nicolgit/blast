import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class FieldEditViewModel extends ChangeNotifier {
  FieldEditViewModel(this.attribute);

  final BlastAttribute attribute;

  bool get isSupported =>
      attribute.type == BlastAttributeType.typeHeader || canEditName;

  bool get canEditName =>
      attribute.type == BlastAttributeType.typeString || attribute.type == BlastAttributeType.typeURL;

  bool get canTestUrl => attribute.type == BlastAttributeType.typeURL;

  Future<bool> testUrl(String value) {
    final input = value.trim();
    if (input.isEmpty) {
      throw const FormatException('Enter a URL to test');
    }
    final lowerInput = input.toLowerCase();
    final url = Uri.tryParse(
      lowerInput.startsWith('http://') || lowerInput.startsWith('https://') || lowerInput.startsWith('mailto:')
          ? input
          : 'https://$input',
    );
    if (url == null ||
        input.contains(RegExp(r'\s')) ||
        (url.scheme == 'mailto' ? url.path.isEmpty : url.host.isEmpty)) {
      throw const FormatException('Enter a valid URL to test');
    }
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }

  String get initialValue {
    switch (attribute.type) {
      case BlastAttributeType.typeHeader:
        return attribute.name;
      case BlastAttributeType.typeString:
      case BlastAttributeType.typeURL:
        return attribute.value;
      case BlastAttributeType.typePassword:
        return '';
    }
  }

  String get labelText {
    switch (attribute.type) {
      case BlastAttributeType.typeHeader:
        return 'Header';
      case BlastAttributeType.typeString:
      case BlastAttributeType.typeURL:
        return 'Value';
      case BlastAttributeType.typePassword:
        return 'Unsupported attribute type';
    }
  }

  void save(String value, {required String name}) {
    switch (attribute.type) {
      case BlastAttributeType.typeHeader:
        attribute.name = value;
      case BlastAttributeType.typeString:
      case BlastAttributeType.typeURL:
        attribute.name = name;
        attribute.value = value;
      case BlastAttributeType.typePassword:
        throw UnsupportedError(
          'Editing ${attribute.type.name} attributes is not supported',
        );
    }
  }
}
