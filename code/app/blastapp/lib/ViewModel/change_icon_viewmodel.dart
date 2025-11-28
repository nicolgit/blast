import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ChangeIconViewModel extends ChangeNotifier {
  final BuildContext context;

  ChangeIconViewModel(this.context);

  void closeCommand() {
    context.router.maybePop('');
  }

  void selectIcon(String iconName) {
    context.router.maybePop(iconName);
  }
}
