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
    if (value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return '';
  }

  bool isPasswordValid() {
    return passwordError.isEmpty &&
        passwordConfirmError.isEmpty &&
        password == passwordConfirm;
  }

  acceptPassword() async {
    //notifyListeners();
    //context.router.pop();
  }
}
