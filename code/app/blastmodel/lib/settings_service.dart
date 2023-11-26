import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/Cloud/fake_cloud.dart';
import 'package:blastmodel/Cloud/filesystem_cloud.dart';
import 'package:blastmodel/Cloud/onedrive_cloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum BlaseAppTheme {
  auto,
  light,
  dark,
}

class SettingService {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<RecentFile> recentFiles = [];
  List<Cloud> cloudStorages = [];

  static final SettingService _instance = SettingService._internal();

  factory SettingService() {
    return _instance;
  }

  SettingService._internal() {
    // init things inside this
  }

  // Add your methods and properties here
  Future<bool> get eulaAccepted async {
    var prefs = await _prefs;
    return prefs.getBool('eulaAccepted') ?? false;
  }

  Future<void> setEulaAccepted(bool value) async {
    var prefs = await _prefs;
    await prefs.setBool('eulaAccepted', value);
  }

  Future<BlaseAppTheme> get appTheme async {
    var prefs = await _prefs;
    return BlaseAppTheme
        .values[prefs.getInt('appTheme') ?? BlaseAppTheme.auto.index];
  }

  Future<void> setAppTheme(BlaseAppTheme value) async {
    var prefs = await _prefs;
    await prefs.setInt('appTheme', value.index);
  }

  Future<List<RecentFile>> getRecentFiles() async {
    if (recentFiles.isNotEmpty) {
      return recentFiles;
    } else {
      var prefs = await _prefs;
      var jsonRecent = prefs.getString('recentFiles') ?? '[]';

      recentFiles = jsonDecode(jsonRecent);

      return recentFiles;
    }
  }

  Future<void> setRecentFiles(List<RecentFile> value) async {
    recentFiles = value;

    var prefs = await _prefs;
    var jsonRecent = jsonEncode(value);
    await prefs.setString('recentFiles', jsonRecent);
  }


  Future<List<Cloud>> getCloudStoragelist() {
    if (cloudStorages.isNotEmpty) {
      return Future.value(cloudStorages);
    } else {
      cloudStorages.add(FakeCloud());
      cloudStorages.add(FileSystemCloud());
      cloudStorages.add(OneDriveCloud());

      return Future.value(cloudStorages);
    }
  }
}

class RecentFile {
  final String cloudName;
  final String fileName;
  final String filePath;

  RecentFile(
      {required this.cloudName,
      required this.fileName,
      required this.filePath});

  RecentFile.fromJson(Map<String, dynamic> json)
      : cloudName = json['cloudName'],
        fileName = json['fileName'],
        filePath = json['filePath'];

  Map<String, dynamic> toJson() => {
        'cloudName': cloudName,
        'fileName': fileName,
        'filePath': filePath,
      };
}
