import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

// https://dev.to/aseemwangoo/using-mvvm-in-flutter-2022-11bg
class EulaViewModel extends ChangeNotifier {
  BuildContext context;

  EulaViewModel(this.context);

  Future<void> acceptEula() async {
    await SettingService().setEulaAccepted(true);
    notifyListeners();

    if (context.mounted) {
      context.router.maybePop(true);
    }
  }

  Future<void> denyEula() async {
    await SettingService().setEulaAccepted(false);
    notifyListeners();

    if (context.mounted) {
      context.router.maybePop(true);
    }
  }
}
