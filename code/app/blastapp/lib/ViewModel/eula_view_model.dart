import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

// https://dev.to/aseemwangoo/using-mvvm-in-flutter-2022-11bg
class EulaViewModel extends ChangeNotifier {
  BuildContext context;

  EulaViewModel(this.context);

  acceptEula() async {
    SettingService().setEulaAccepted(true);
    notifyListeners();
    context.router.pop();
  }

  denyEula() async {
    SettingService().setEulaAccepted(false);
    notifyListeners();
    context.router.pop(true);
  }
}
