import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FieldViewModel extends ChangeNotifier {
  final BuildContext context;
  final String currentField;

  FieldViewModel(this.context, this.currentField);

  void closeCommand() {
    context.router.maybePop();
  }

  void copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));

    notifyListeners();
  }
}
