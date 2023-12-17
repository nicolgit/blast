import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';

class FakeCloud extends Cloud {
  final _source =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum";
  late List<String> _words;

  FakeCloud() {
    _words = _source.split(" ");
  }

  @override
  String get name => 'Fake Cloud - for testing purposes only';

  @override
  Future<List<CloudObject>> getFiles(String path) {
    Random random = Random();
    List<CloudObject> files = [];
    int totalFiles = random.nextInt(20) + 1;
    for (int i = 0; i < totalFiles; i++) {
      String name = "";
      int fileNameLength = random.nextInt(20) + 3;
      for (int j = 0; j < fileNameLength; j++) {
        name += String.fromCharCode(random.nextInt(26) + 65);
      }

      bool isDirectory = random.nextInt(5) == 0;
      if (!isDirectory) {
        name += ".blast";
      }

      files.add(CloudObject(
          name: name,
          path: path,
          size: random.nextInt(1000000),
          lastModified:
              DateTime.now().subtract(Duration(days: random.nextInt(365))),
          url: '$path/$name',
          isDirectory: isDirectory));
    }

    return Future.value(files);
  }

  @override
  Future<Uint8List> getFile(String path) async {
    BlastDocument document = buildRandomBlastDocument();

    String jsonDocument = document.toString();

    var encodedFile = CurrentFileService().encodeFile(jsonDocument, "password");

  X
  
    Uint8List byteArray = Uint8List.fromList(utf8.encode(jsonDocument));

    return byteArray;
  }

  BlastDocument buildRandomBlastDocument() {
    Random random = Random();

    BlastDocument document = BlastDocument();

    int totalCards = random.nextInt(50);

    for (int i = 0; i < totalCards; i++) {
      BlastCard card = BlastCard();

      card.title = _randomStringGenerator(random.nextInt(5));
      card.notes = _randomStringGenerator(random.nextInt(20));
      card.isFavorite = random.nextInt(10) == 0;
      card.lastUpdateDateTime =
          DateTime.now().subtract(Duration(days: random.nextInt(365)));
      card.lastOpenedDateTime =
          DateTime.now().subtract(Duration(days: random.nextInt(365)));
      card.usedCounter = random.nextInt(100);
      card.tags = _randomTagsGenerator();

      int totalCards = random.nextInt(100);
      for (int i = 0; i < totalCards; i++) {
        BlastAttribute attribute = BlastAttribute();
        attribute.name = _randomStringGenerator(random.nextInt(4));
        attribute.value = _randomStringGenerator(random.nextInt(10));
        attribute.type = BlastAttributeType
            .values[random.nextInt(BlastAttributeType.values.length)];

        card.rows.add(attribute);
      }

      document.cards.add(card);
    }

    return document;
  }

  String _randomStringGenerator(int length) {
    Random random = Random();

    String result = "";

    for (int i = 0; i < length; i++) {
      result += _words[random.nextInt(_words.length)];
      result += " ";
    }

    return result;
  }

  List<String> _randomTagsGenerator() {
    Random random = Random();

    List<String> result = [];

    int length = random.nextInt(3);
    for (int i = 0; i < length; i++) {
      result.add(_words[random.nextInt(_words.length)]);
    }

    return result;
  }
}
