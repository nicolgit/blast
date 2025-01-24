import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class ThemeView {
  final String themeName;
  final ThemeMode themeMode;
  final IconData icon;

  ThemeView(this.themeName, this.themeMode, this.icon);
}

class QrCodeViewStyleView {
  final String viewName;
  final QrCodeViewStyle viewStyle;
  final IconData icon;

  QrCodeViewStyleView(this.viewName, this.viewStyle, this.icon);
}

class SettingsViewModel extends ChangeNotifier {
  final BuildContext context;
  final SettingService _settingService = SettingService();

  //autosave
  Future<bool> get autoSave async {
    return await _settingService.autoSave;
  }

  Future<void> setAutoSave(bool value) async {
    await _settingService.setAutoSave(value);
    notifyListeners();
  }

  Future<int> get autoLogoutAfter async {
    return await _settingService.autoLogoutAfter;
  }

  Future<void> setAutoLogoutAfter(int value) async {
    _settingService.setAutoLogoutAfter(value);
    notifyListeners();
  }

  Future<ThemeMode> get themeMode async {
    return await _settingService.appTheme;
  }

  Future<void> setThemeMode(ThemeMode value) async {
    await _settingService.setAppTheme(value);
    notifyListeners();
  }

  SettingsViewModel(this.context);

  Future<bool> get rememberLastQrCodeView async {
    return await _settingService.rememberLastQrCodeView;
  }

  Future<void> setRememberLastQrCodeView() async {
    bool value = await _settingService.rememberLastQrCodeView;
    await _settingService.setRememberLastQrCodeView(!value);
    notifyListeners();
  }

  Future<QrCodeViewStyle> get lastQrCodeView async {
    return await _settingService.defaultQrCodeView;
  }

  Future<void> setLastQrCodeView(QrCodeViewStyle qrCodeViewStyle) async {
    await _settingService.setDefaultQrCodeView(qrCodeViewStyle);
    notifyListeners();
  }

  void closeCommand() {
    context.router.maybePop();
  }

  List<ThemeView> getThemeSelectorItems() {
    return [
      ThemeView("  System  ", ThemeMode.system, Icons.auto_awesome),
      ThemeView("  Light  ", ThemeMode.light, Icons.light_mode),
      ThemeView("  Dark  ", ThemeMode.dark, Icons.dark_mode),
    ];
  }

  List<int>? getAutoLogoutAfterItems() {
    return [3, 5, 10, 15];
  }

  List<QrCodeViewStyleView> getQrCodeViewStyleItems() {
    return [
      QrCodeViewStyleView("  QR code  ", QrCodeViewStyle.qrcode, Icons.qr_code),
      QrCodeViewStyleView("  Barcode  ", QrCodeViewStyle.barcode, Icons.barcode_reader),
      QrCodeViewStyleView("  Text  ", QrCodeViewStyle.text, Icons.text_fields)
    ];
  }
}
