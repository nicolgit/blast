import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class FieldViewModel extends ChangeNotifier {
  final BuildContext context;
  final String currentField;

  FieldViewModel(this.context, this.currentField);

  void closeCommand() {
    context.router.maybePop();
  }

  Future<QrCodeViewStyle> getCurrentQrCodeViewStyle() async {
    return await SettingService().defaultQrCodeView;
  }

  void setCurrentQrCodeViewStyle(QrCodeViewStyle first) async {
    await SettingService().setDefaultQrCodeView(first);
    notifyListeners();
  }
}
