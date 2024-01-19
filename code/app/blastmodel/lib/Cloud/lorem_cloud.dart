import 'dart:math';
import 'dart:typed_data';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';

class LoremCloud extends Cloud {
  final _source =
      "Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur Excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum";
  late List<String> _words;

  LoremCloud() {
    _words = _source.split(" ");
  }

  @override
  String get ID => "LOREM";
  @override
  String get name => 'Lorem Cloud';
  @override
  Future<String> get rootpath => Future.value('http://loremcloud.com/');

  @override
  Future<List<CloudObject>> getFiles(String path) {
    Random random = Random();
    List<CloudObject> files = [];
    int totalFiles = random.nextInt(20) + 1;
    for (int i = 0; i < totalFiles; i++) {
      String name = _randomStringGenerator(random.nextInt(4) + 1);
      name = name.replaceAll(" ", "-");

      name += random.nextInt(1000).toString();

      bool isDirectory = random.nextInt(5) == 0;
      if (!isDirectory) {
        name += ".blast";
      } else {
        name += "/";
      }

      files.add(CloudObject(
          name: name,
          path: path,
          size: random.nextInt(1000000),
          lastModified: DateTime.now().subtract(Duration(days: random.nextInt(365))),
          url: '$path$name',
          isDirectory: isDirectory));
    }

    return Future.value(files);
  }

  @override
  Future<Uint8List> getFile(String path) async {
    BlastDocument document = buildRandomBlastDocument();
    String jsonDocument = document.toString();

    final encodedFile = CurrentFileService().encodeFile(jsonDocument, "password");
    return encodedFile;
  }

  @override
  Future<String> goToParentDirectory(String currentPath) async {
    // remove string after last /

    if (currentPath.endsWith("/")) {
      currentPath = currentPath.substring(0, currentPath.length - 1);
    }

    int index = currentPath.lastIndexOf("/");
    if (index > 0) {
      var newPath = currentPath.substring(0, index + 1);

      String path = await rootpath;
      if (newPath.length < path.length) {
        return rootpath;
      } else {
        return newPath;
      }
    } else {
      return currentPath;
    }
  }

  BlastDocument buildRandomBlastDocument() {
    Random random = Random();

    BlastDocument document = BlastDocument();

    int totalCards = random.nextInt(50);

    for (int i = 0; i < totalCards; i++) {
      BlastCard card = BlastCard();

      card.title = _randomStringGenerator(random.nextInt(5) + 1);
      card.notes = _randomStringGenerator(random.nextInt(20) + 1);
      card.isFavorite = random.nextInt(5) == 0;
      card.lastUpdateDateTime = DateTime.now().subtract(Duration(days: random.nextInt(365)));
      card.lastOpenedDateTime = DateTime.now().subtract(Duration(days: random.nextInt(365)));
      card.usedCounter = random.nextInt(100);
      card.tags = _randomTagsGenerator(random.nextInt(5));

      int totalCards = random.nextInt(100);
      for (int i = 0; i < totalCards; i++) {
        BlastAttribute attribute = BlastAttribute();
        attribute.name = _randomStringGenerator(random.nextInt(4));
        attribute.value = _randomStringGenerator(random.nextInt(10));
        attribute.type = BlastAttributeType.values[random.nextInt(BlastAttributeType.values.length)];

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

  List<String> _randomTagsGenerator(int tagsCount) {
    Random random = Random();

    List<String> result = [];

    int length = tagsCount;
    for (int i = 0; i < length; i++) {
      result.add(_words[random.nextInt(_words.length)]);
    }

    return result;
  }
}
