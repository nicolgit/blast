import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class EulaViewModel extends ChangeNotifier{
  BuildContext context;

  EulaViewModel(this.context);

  acceptEula() async {
    SettingService().setEulaAccepted(true);
    context.router.pop();
  }

  denyEula() async {
    SettingService().setEulaAccepted(false);
    context.router.pop(true);
  }

}
