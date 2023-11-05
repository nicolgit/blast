import 'package:flutter/material.dart';
import 'package:blastmodel/settings_service.dart';

class SplashViewModelXXX extends ChangeNotifier{
  BuildContext context;

  SplashViewModelXXX(this.context);

  Future<bool> eulaAccepted() async {
    return SettingService().eulaAccepted;
  }

  showEula() async {

  }
}
