
import 'package:flutter/material.dart';
import 'package:blastmodel/settings_service.dart';

class SplashViewModel extends ChangeNotifier{

  Future<bool> eulaAccepted() async {
    return SettingService().eulaAccepted;
  }
}
