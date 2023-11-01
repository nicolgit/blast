import 'package:shared_preferences/shared_preferences.dart';

enum BlaseAppTheme {
  auto,
  light,
  dark,
}

class SettingService {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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
    return BlaseAppTheme.values[prefs.getInt('appTheme') ?? BlaseAppTheme.auto.index];
  }

  Future<void> setAppTheme(BlaseAppTheme value) async {
    var prefs = await _prefs;
    await prefs.setInt('appTheme', value.index);
  }
  
}