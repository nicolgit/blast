import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  BuildContext context;

  ChangePasswordViewModel(this.context);

  static const List<int> iterationsList = [1000, 10000, 100000, 200000, 300000, 500000, 1000000];

  String password = '';
  String passwordConfirm = '';
  int iterationLevel = 2;

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    passwordConfirm = value;
    notifyListeners();
  }

  void setIterationLevel(int level) {
    iterationLevel = level;
    notifyListeners();
  }

  Future<bool> passwordsMatch() async {
    return password == passwordConfirm;
  }

  Future<bool> isFormReadyToConfirm() async {
    return await passwordsMatch() && await isPasswordsNotEmpty();
  }

  Future<void> acceptPassword() async {
    int selectedIterations = iterationsList[iterationLevel];

    CurrentFileService().iterations = selectedIterations;
    CurrentFileService().newPassword(password);
    CurrentFileService().currentFileJsonString = CurrentFileService().currentFileDocument.toString();
    CurrentFileService().currentFileEncrypted =
        CurrentFileService().encodeFile(CurrentFileService().currentFileJsonString!);

    notifyListeners();

    // return true if password is successfully changed
    if (!context.mounted) return;
    context.router.maybePop(true);
    return;
  }

  Future<bool> isPasswordsNotEmpty() async {
    return password.isNotEmpty && passwordConfirm.isNotEmpty;
  }
}
