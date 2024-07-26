import 'dart:convert';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:xml/xml.dart' as xml;

import 'package:blastmodel/blastdocument.dart';

class Importer {
  static BlastDocument importBlastJson(String jsonString) {
    return BlastDocument.fromJson(jsonDecode(jsonString));
  }

  // https://www.educative.io/answers/parse-and-display-xml-data-in-flutter
  static BlastDocument importKeepassXML(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    var blastDocument = BlastDocument();

    if (document.rootElement.localName != 'KeePassFile') {
      throw BlastImportException('Invalid KeePass XML file');
    }

    final entries = document.rootElement.findElements("Root").first.findElements('Group');

    for (var entry in entries) {
      var blastCard = BlastCard();

      blastCard.title =
          entry.findElements('String').firstWhere((element) => element.getAttribute('Key') == 'Title').value;
      blastCard.notes =
          entry.findElements('String').firstWhere((element) => element.getAttribute('Key') == 'Notes').value;

      //blastCard.addEntry('Username', entry.findElements('String').firstWhere((element) => element.getAttribute('Key') == 'UserName').text);
      //blastCard.addEntry('Password', entry.findElements('String').firstWhere((element) => element.getAttribute('Key') == 'Password').text);

      blastDocument.cards.add(blastCard);
    }

    return blastDocument;
  }

  static BlastDocument ImportPwsafeCSV(String csvString) {
    var blastDocument = BlastDocument();

    // to be continued

    // https://stuvel.eu/post/2014-07-30-moving-from-pwsafe-to-keepass/

    return blastDocument;
  }
}
