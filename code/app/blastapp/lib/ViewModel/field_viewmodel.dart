import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FieldViewModel extends ChangeNotifier {
  final BuildContext context;
  final String currentField;
  QrCodeViewStyle? qrCodeViewStyle;

  FieldViewModel(this.context, this.currentField);

  void closeCommand() {
    context.router.maybePop();
  }

  Future<QrCodeViewStyle> getCurrentQrCodeViewStyle() async {
    qrCodeViewStyle ??= await SettingService().defaultQrCodeView;
    return qrCodeViewStyle!;
  }

  void setCurrentQrCodeViewStyle(QrCodeViewStyle newValue) async {
    if (await SettingService().rememberLastQrCodeView) {
      await SettingService().setDefaultQrCodeView(newValue);
    }
    qrCodeViewStyle = newValue;

    notifyListeners();
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: currentField));
  }
}
