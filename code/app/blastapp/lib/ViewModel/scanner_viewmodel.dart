import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ScannerViewModel extends ChangeNotifier {
  final BuildContext context;

  ScannerViewModel(this.context);

  void closeCommand() {
    if (!context.mounted) return;
    context.router.maybePop();
  }
}
