import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  BuildContext context;

  ChangePasswordViewModel(this.context);

  String password = '';
  String passwordConfirm = '';

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    passwordConfirm = value;
    notifyListeners();
  }

  Future<bool> passwordsMatch() async {
    return password == passwordConfirm;
  }

  Future<bool> isFormReadyToConfirm() async {
    return await passwordsMatch() && await isPasswordsNotEmpty();
  }

  acceptPassword() async {
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
