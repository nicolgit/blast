import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class PasswordGeneratorViewModel extends ChangeNotifier {
  final BuildContext context;

  PasswordGeneratorViewModel(this.context);

  void closeCommand() {
    context.router.maybePop();
  }
}
