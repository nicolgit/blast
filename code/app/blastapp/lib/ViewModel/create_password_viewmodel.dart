import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class CreatePasswordViewModel extends ChangeNotifier {
  BuildContext context;

  CreatePasswordViewModel(this.context);

  String password = '';
  String passwordConfirm = '';
  String passwordError = '';
  String passwordConfirmError = '';

  void setPassword(String value) {
    password = value;
    passwordError = validatePassword(value);
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    passwordConfirm = value;
    passwordConfirmError = validatePassword(value);
    notifyListeners();
  }

  String validatePassword(String value) {
    notifyListeners();

    if (value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return '';
  }

  Future<bool> isPasswordValid() async {
    return passwordError.isEmpty && passwordConfirmError.isEmpty;
  }

  Future<bool> passwordsMatch() async {
    return password == passwordConfirm;
  }

  Future<bool> isPasswordValidAndMatch() async {
    return await isPasswordValid() && await passwordsMatch();
  }

  acceptPassword() {
    notifyListeners();
    context.router.pop();
  }
}
