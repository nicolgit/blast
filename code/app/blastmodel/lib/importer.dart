import 'dart:convert';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:xml/xml.dart' as xml;

import 'package:blastmodel/blastdocument.dart';
import 'package:xml/xml.dart';

class Importer {
  static BlastDocument importBlastJson(String jsonString) {
    return BlastDocument.fromJson(jsonDecode(jsonString));
  }

  // https://www.educative.io/answers/parse-and-display-xml-data-in-flutter
  static BlastDocument importKeepassXML(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    var blastDocument = BlastDocument();

    if (document.rootElement.localName != 'KeePassFile') {
      throw Exception('Invalid KeePass XML file format (root element is not KeePassFile)');
    }

    final entries = document.rootElement.findElements("Root").first.findElements('Group');
    List<String> tags = [];

    for (var group in entries) {
      final groupName = group.findElements('Name').first.innerText;
      tags.add(groupName);

      _importKeepassGroup(group, tags, blastDocument);
    }

    blastDocument.isChanged = true;
    return blastDocument;
  }

  static void _importKeepassGroup(xml.XmlElement group, List<String> tags, BlastDocument blastDocument) {
    final groups = group.findElements('Group');

    for (var subGroup in groups) {
      String groupName = subGroup.findElements('Name').first.innerText;
      tags.add(groupName);

      _importKeepassGroup(subGroup, tags, blastDocument);

      tags.removeWhere((item) => item == groupName);
    }

    final entries = group.findElements('Entry');
    for (var entry in entries) {
      var blastCard = BlastCard();

      blastCard.tags = tags.toList();

      for (var child in entry.children) {
        if (child.children.isNotEmpty) {
          var key =
              child.findElements('Key').firstOrNull == null ? '' : child.findElements('Key').firstOrNull?.innerText;
          var value =
              child.findElements('Value').firstOrNull == null ? '' : child.findElements('Value').firstOrNull?.innerText;

          if (key != '' && value != '') {
            if (key == 'Title') {
              blastCard.title = value;
            } else if (key == 'Notes') {
              blastCard.notes = value;
            } else if (key == 'Password') {
              blastCard.rows.add(BlastAttribute.withParams(key!, value!, BlastAttributeType.typePassword));
            } else {
              blastCard.rows.add(BlastAttribute.withParams(key!, value!, BlastAttributeType.typeString));
            }
          }
        }
      }
      blastDocument.cards.add(blastCard);
    }
  }

  static BlastDocument importPwsafeXML(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    var blastDocument = BlastDocument();

    if (document.rootElement.localName != 'passwordsafe') {
      throw Exception('Invalid KeePass XML file format (root element is not passwordsafe)');
    }

    final entries = document.rootElement.findElements("entry");

    for (var entry in entries) {
      var blastCard = BlastCard();

      if (entry.findElements("group").firstOrNull != null) {
        blastCard.tags = entry.findElements("group").first.innerText.split('.');
      }

      blastCard.title = _safePwsafeFindElement(entry, "title");
      blastCard.notes = _safePwsafeFindElement(entry, "notes");
      blastCard.rows.add(BlastAttribute.withParams(
          'username', _safePwsafeFindElement(entry, "username"), BlastAttributeType.typeString));
      blastCard.rows.add(BlastAttribute.withParams(
          'password', _safePwsafeFindElement(entry, "password"), BlastAttributeType.typePassword));
      blastCard.rows
          .add(BlastAttribute.withParams('url', _safePwsafeFindElement(entry, "url"), BlastAttributeType.typeString));
      blastCard.rows.add(
          BlastAttribute.withParams('email', _safePwsafeFindElement(entry, "email"), BlastAttributeType.typeString));

      blastDocument.cards.add(blastCard);
    }

    blastDocument.isChanged = true;
    return blastDocument;
  }

  static String _safePwsafeFindElement(XmlElement entry, String elementName) {
    return entry.findElements(elementName).firstOrNull == null ? '' : entry.findElements(elementName).first.innerText;
  }
}
