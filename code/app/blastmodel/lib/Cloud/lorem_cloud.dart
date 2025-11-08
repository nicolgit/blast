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
  String get id => "LOREM";
  @override
  String get name => 'Lorem Cloud';
  @override
  String get description =>
      'fake storage, to use for testing purposes only, do not store any real data here (use "password" as password)';
  @override
  Future<String> get rootpath => Future.value('http://loremcloud.com/');

  @override
  Future<List<CloudObject>> getFiles(String path) async {
    Random random = Random();

    await Future.delayed(Duration(seconds: random.nextInt(5)));

    List<CloudObject> files = [];
    int totalFiles = random.nextInt(20) + 1;
    for (int i = 0; i < totalFiles; i++) {
      String name = _randomStringGenerator(random.nextInt(4) + 1, false, false);
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
  Future<CloudFile> getFile(String id) async {
    final random = Random();
    await Future.delayed(Duration(seconds: random.nextInt(5)));

    BlastDocument document = buildRandomBlastDocument();
    String jsonDocument = document.toString();

    CurrentFileService().newPassword("password");
    final encodedFile = CurrentFileService().encodeFile(jsonDocument);

    final file = CloudFile(data: encodedFile, lastModified: DateTime.now(), id: id);
    return file;
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

      card.title = _randomStringGenerator(random.nextInt(5) + 1, false, false);
      card.notes = _randomStringGenerator(random.nextInt(200) + 1, true, true);
      card.isFavorite = random.nextInt(5) == 0;
      card.lastUpdateDateTime = DateTime.now().subtract(Duration(days: random.nextInt(365)));
      //card.lastOpenedDateTime = DateTime.now().subtract(Duration(days: random.nextInt(365)));
      card.usedCounter = random.nextInt(100);
      card.tags = _randomTagsGenerator(random.nextInt(5));

      int totalCards = random.nextInt(100);
      for (int i = 0; i < totalCards; i++) {
        BlastAttribute attribute = BlastAttribute();
        attribute.name = _randomStringGenerator(random.nextInt(4) + 1, false, false);
        attribute.type = BlastAttributeType.values[random.nextInt(BlastAttributeType.values.length)];

        if (attribute.type == BlastAttributeType.typeURL) {
          attribute.value = _randomUrlGenerator();
        } else {
          attribute.value = _randomStringGenerator(random.nextInt(6), false, false);
        }

        card.rows.add(attribute);
      }

      document.cards.add(card);
    }

    return document;
  }

  String _randomStringGenerator(int length, bool includeNewLine, bool markdownStyle) {
    Random random = Random();

    String result = "";
    int nextNewLine = random.nextInt(50) + 5;
    for (int i = 0, nl = 0; i < length; i++, nl++) {
      var nextWord = _words[random.nextInt(_words.length)];

      if (markdownStyle) {
        var randomMarkdown = random.nextInt(10);
        if (randomMarkdown == 0) {
          nextWord = "**$nextWord**";
        }
        if (randomMarkdown == 1) {
          nextWord = "*${nextWord}*";
        }
      }
      result += nextWord;

      if (nl == nextNewLine && includeNewLine) {
        result += ".\n";
        nextNewLine = random.nextInt(50) + 5;
        nl = 0;
      } else {
        result += " ";
      }
    }

    return result.trim();
  }

  String _randomUrlGenerator() {
    Random random = Random();
    return "http://loremcloud.com/${_randomStringGenerator(random.nextInt(4), false, false).replaceAll(' ', '/')}";
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

  @override
  Future<CloudFile> setFile(String id, Uint8List bytes) {
    final CloudFile cf = CloudFile(data: bytes, lastModified: DateTime.now(), id: id);

    return Future.value(cf);
  }

  @override
  Future<CloudFile> createFile(String path, Uint8List bytes) {
    final CloudFile cf = CloudFile(data: bytes, lastModified: DateTime.now(), id: path);

    return Future.value(cf);
  }

  @override
  Future<CloudFileInfo> getFileInfo(String id) {
    CloudFileInfo cfi = CloudFileInfo(lastModified: DateTime.now(), id: id);

    return Future.value(cfi);
  }

  @override
  Future<bool> logOut() {
    return Future.value(true);
  }

  @override
  bool get hasCachedCredentials => false;

  @override
  String? cachedCredentials;

  @override
  Future<void> cancelAuthorization() {
    return Future.value();
  }
}
