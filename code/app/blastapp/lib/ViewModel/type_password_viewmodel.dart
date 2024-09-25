import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

enum PasswordType {
  password,
  recoveryKey,
}

class TypePasswordViewModel extends ChangeNotifier {
  BuildContext context;

  TypePasswordViewModel(this.context);

  String get fileName => CurrentFileService().currentFileInfo!.fileName;
  String get cloudIcon => 'assets/storage/${CurrentFileService().currentFileInfo!.cloudId}.png';
  PasswordType passwordType = PasswordType.password;
  String password = '';
  String recoveryKey = '';
  String errorMessage = '';
  bool _isCheckingPassword = false;

  Future<bool> isPasswordValid() async {
    return password.isNotEmpty;
  }

  Future<bool> checkPassword() async {
    bool isOk = false;

    _isCheckingPassword = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      CurrentFileService().password = password;
      CurrentFileService().currentFileJsonString =
          CurrentFileService().decodeFile(CurrentFileService().currentFileEncrypted!, password, PasskeyType.password);
      CurrentFileService().currentFileDocument =
          BlastDocument.fromJson(jsonDecode(CurrentFileService().currentFileJsonString!));

      final file = CurrentFileService().currentFileInfo;
      if (file != null) {
        SettingService().addRecentFile(file);
      }
      errorMessage = '';

      context.router.push(const CardsBrowserRoute());
      isOk = true;
    } on BlastWrongPasswordException {
      errorMessage = 'wrong password - please check again';
      isOk = false;
    } on BlastUnknownFileVersionException {
      errorMessage = 'unknown file version - unable to open your file';
      isOk = false;
    } on FormatException {
      errorMessage = 'file format exception - unable to open your file';
      isOk = false;
    } catch (e) {
      errorMessage = 'unexpeceted error - unable to open your file - ${e.toString()}';
      isOk = false;
    }

    _isCheckingPassword = false;
    notifyListeners();

    return isOk;
  }

  setPassword(String value) {
    password = value;
    errorMessage = '';
    notifyListeners();
  }

  setRecoveryKey(String value) {
    recoveryKey = value;
    errorMessage = '';
    notifyListeners();
  }

  Future<bool> isCheckingPassword() async {
    return _isCheckingPassword;
  }
}
