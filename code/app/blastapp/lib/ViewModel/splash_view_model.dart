import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/base.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class SplashViewModel extends BaseViewModel{
  BuildContext context;

  SplashViewModel(this.context);

  Future<bool> eulaAccepted() async {
    return SettingService().eulaAccepted;
  }

  showEula() async {
    return context.router.push(const EulaRoute());
  }
  
  @override
  FutureOr<void> init() {

  }
}
