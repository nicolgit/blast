import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class TypePasswordViewModel extends ChangeNotifier {
  BuildContext context;

  TypePasswordViewModel(this.context);

  String password = '';

  Future<bool> isPasswordValid() async {
    return password.isNotEmpty;
  }

  checkPassword() {
    // TODO: Check password
    context.router.pop();
  }

  setPassword(String value) {
    password = value;
    notifyListeners();
  }
}
