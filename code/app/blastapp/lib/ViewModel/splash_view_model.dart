import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  BuildContext context;

  SplashViewModel(this.context);

  Future<bool> eulaAccepted() async {
    return SettingService().eulaAccepted;
  }

  Future<bool> eulaNotAccepted() async {
    return !await SettingService().eulaAccepted;
  }

  Future<List<BlastFile>> recentFiles() async {
    return SettingService().getRecentFiles();
  }

  showEula() async {
    return context.router.push(const EulaRoute());
  }

  chooseStorage() async {
    return context.router.push(const ChooseStorageRoute());
  }

  void refresh() {
    notifyListeners();
  }
}
