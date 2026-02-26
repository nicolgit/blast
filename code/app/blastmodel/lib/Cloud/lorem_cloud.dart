import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';

class _Website {
  final String name;
  final String url;

  _Website({required this.name, required this.url});

  factory _Website.fromJson(Map<String, dynamic> json) {
    return _Website(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}

class LoremCloud extends Cloud {
  final _source =
      "Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur Excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum";

  final _popularWebsitesJson = '''[
  {"name": "Google", "url": "https://www.google.com"},
  {"name": "YouTube", "url": "https://www.youtube.com"},
  {"name": "Facebook", "url": "https://www.facebook.com"},
  {"name": "Wikipedia", "url": "https://www.wikipedia.org"},
  {"name": "Instagram", "url": "https://www.instagram.com"},
  {"name": "Bing", "url": "https://www.bing.com"},
  {"name": "Reddit", "url": "https://www.reddit.com"},
  {"name": "X (Twitter)", "url": "https://www.x.com"},
  {"name": "ChatGPT", "url": "https://www.chatgpt.com"},
  {"name": "Yandex", "url": "https://www.yandex.ru"},
  {"name": "WhatsApp", "url": "https://www.whatsapp.com"},
  {"name": "Amazon", "url": "https://www.amazon.com"},
  {"name": "Yahoo", "url": "https://www.yahoo.com"},
  {"name": "Yahoo Japan", "url": "https://www.yahoo.co.jp"},
  {"name": "Weather", "url": "https://www.weather.com"},
  {"name": "DuckDuckGo", "url": "https://www.duckduckgo.com"},
  {"name": "TikTok", "url": "https://www.tiktok.com"},
  {"name": "Temu", "url": "https://www.temu.com"},
  {"name": "Naver", "url": "https://www.naver.com"},
  {"name": "Microsoft Online", "url": "https://www.microsoftonline.com"},
  {"name": "Twitch", "url": "https://www.twitch.tv"},
  {"name": "Twitter", "url": "https://www.twitter.com"},
  {"name": "LinkedIn", "url": "https://www.linkedin.com"},
  {"name": "Live", "url": "https://www.live.com"},
  {"name": "Fandom", "url": "https://www.fandom.com"},
  {"name": "Microsoft", "url": "https://www.microsoft.com"},
  {"name": "MSN", "url": "https://www.msn.com"},
  {"name": "Netflix", "url": "https://www.netflix.com"},
  {"name": "Office", "url": "https://www.office.com"},
  {"name": "Pinterest", "url": "https://www.pinterest.com"},
  {"name": "Mail.ru", "url": "https://www.mail.ru"},
  {"name": "OpenAI", "url": "https://www.openai.com"},
  {"name": "AliExpress", "url": "https://www.aliexpress.com"},
  {"name": "PayPal", "url": "https://www.paypal.com"},
  {"name": "VK", "url": "https://www.vk.com"},
  {"name": "Canva", "url": "https://www.canva.com"},
  {"name": "GitHub", "url": "https://www.github.com"},
  {"name": "Spotify", "url": "https://www.spotify.com"},
  {"name": "Discord", "url": "https://www.discord.com"},
  {"name": "Apple", "url": "https://www.apple.com"},
  {"name": "IMDb", "url": "https://www.imdb.com"},
  {"name": "Globo", "url": "https://www.globo.com"},
  {"name": "Roblox", "url": "https://www.roblox.com"},
  {"name": "Amazon Japan", "url": "https://www.amazon.co.jp"},
  {"name": "Quora", "url": "https://www.quora.com"},
  {"name": "Bilibili", "url": "https://www.bilibili.com"},
  {"name": "Samsung", "url": "https://www.samsung.com"},
  {"name": "eBay", "url": "https://www.ebay.com"},
  {"name": "NY Times", "url": "https://www.nytimes.com"},
  {"name": "Walmart", "url": "https://www.walmart.com"},
  {"name": "Amazon Germany", "url": "https://www.amazon.de"},
  {"name": "ESPN", "url": "https://www.espn.com"},
  {"name": "Dailymotion", "url": "https://www.dailymotion.com"},
  {"name": "Google Brazil", "url": "https://www.google.com.br"},
  {"name": "BBC", "url": "https://www.bbc.com"},
  {"name": "Rakuten Japan", "url": "https://www.rakuten.co.jp"},
  {"name": "BBC UK", "url": "https://www.bbc.co.uk"},
  {"name": "Telegram", "url": "https://www.telegram.org"},
  {"name": "Indeed", "url": "https://www.indeed.com"},
  {"name": "CNN", "url": "https://www.cnn.com"},
  {"name": "Dzen", "url": "https://www.dzen.ru"},
  {"name": "Booking", "url": "https://www.booking.com"},
  {"name": "Google UK", "url": "https://www.google.co.uk"},
  {"name": "USPS", "url": "https://www.usps.com"},
  {"name": "Zoom", "url": "https://www.zoom.us"},
  {"name": "Amazon UK", "url": "https://www.amazon.co.uk"},
  {"name": "Adobe", "url": "https://www.adobe.com"},
  {"name": "UOL", "url": "https://www.uol.com.br"},
  {"name": "Etsy", "url": "https://www.etsy.com"},
  {"name": "Steam", "url": "https://store.steampowered.com"},
  {"name": "Marca", "url": "https://www.marca.com"},
  {"name": "Ozon", "url": "https://www.ozon.ru"},
  {"name": "Cricbuzz", "url": "https://www.cricbuzz.com"},
  {"name": "Prime Video", "url": "https://www.primevideo.com"},
  {"name": "Google Germany", "url": "https://www.google.de"},
  {"name": "AccuWeather", "url": "https://www.accuweather.com"},
  {"name": "Rutube", "url": "https://www.rutube.ru"},
  {"name": "Instructure", "url": "https://www.instructure.com"},
  {"name": "Disney+", "url": "https://www.disneyplus.com"},
  {"name": "The Guardian", "url": "https://www.theguardian.com"},
  {"name": "Infobae", "url": "https://www.infobae.com"},
  {"name": "Google Spain", "url": "https://www.google.es"},
  {"name": "Google Italy", "url": "https://www.google.it"},
  {"name": "Ya.ru", "url": "https://www.ya.ru"},
  {"name": "Ecosia", "url": "https://www.ecosia.org"},
  {"name": "Daily Mail", "url": "https://www.dailymail.co.uk"},
  {"name": "Amazon India", "url": "https://www.amazon.in"},
  {"name": "Google Japan", "url": "https://www.google.co.jp"},
  {"name": "Amazon Italy", "url": "https://www.amazon.it"},
  {"name": "Google France", "url": "https://www.google.fr"},
  {"name": "IKEA", "url": "https://www.ikea.com"},
  {"name": "Google India", "url": "https://www.google.co.in"},
  {"name": "Fox News", "url": "https://www.foxnews.com"},
  {"name": "Amazon France", "url": "https://www.amazon.fr"},
  {"name": "Max", "url": "https://www.max.com"},
  {"name": "Google Canada", "url": "https://www.google.ca"},
  {"name": "ILovePDF", "url": "https://www.ilovepdf.com"},
  {"name": "Avito", "url": "https://www.avito.ru"},
  {"name": "Outlook", "url": "https://www.outlook.com"},
  {"name": "Wildberries", "url": "https://www.wildberries.ru"}
]''';

  late List<String> _words;
  late List<_Website> _websites;

  LoremCloud() {
    _words = _source.split(" ");
    _loadWebsites();
  }

  void _loadWebsites() {
    final List<dynamic> jsonData = jsonDecode(_popularWebsitesJson);
    _websites = jsonData.map((json) => _Website.fromJson(json)).toList();
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

    int totalCards = random.nextInt(150);

    for (int i = 0; i < totalCards; i++) {
      BlastCard card = BlastCard();

      card.title = _randomStringGenerator(random.nextInt(5) + 1, false, false);
      card.notes = _randomStringGenerator(random.nextInt(200) + 1, true, true);
      card.isFavorite = random.nextInt(5) == 0;
      card.lastUpdateDateTime = DateTime.now().subtract(Duration(days: random.nextInt(365)));
      card.usedCounter = random.nextInt(100);
      card.tags = _randomTagsGenerator(random.nextInt(5));

      int totalAttributes = random.nextInt(15);
      for (int i = 0; i < totalAttributes; i++) {
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
          nextWord = "*$nextWord*";
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
    return _websites[random.nextInt(_websites.length)].url;
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
