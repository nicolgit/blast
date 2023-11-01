import 'package:shared_preferences/shared_preferences.dart';

enum Theme {
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

  Future<Theme> get theme async {
    var prefs = await _prefs;
    return Theme.values[prefs.getInt('theme') ?? Theme.auto.index];
  }

  Future<void> setTheme(Theme value) async {
    var prefs = await _prefs;
    await prefs.setInt('theme', value.index);
  }
  
}