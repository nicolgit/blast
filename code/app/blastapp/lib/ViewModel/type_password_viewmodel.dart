import 'dart:convert';
import 'dart:typed_data';

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
    if (passwordType == PasswordType.password) {
      return password.isNotEmpty;
    } else {
      return recoveryKey.isNotEmpty && recoveryKey.length == 64;
    }
  }

  Future<PasswordType> getPasswordType() async {
    return passwordType;
  }

  Future<bool> checkPassword() async {
    bool isOk = false;

    _isCheckingPassword = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      if (passwordType == PasswordType.recoveryKey) {
        // convert string to Uint8List each 2 characters (hex) to 1 byte\
        Uint8List recoveryKeyBinaly = Uint8List(32);
        for (int i = 0; i < 32; i++) {
          recoveryKeyBinaly[i] = int.parse(recoveryKey.substring(i * 2, i * 2 + 2), radix: 16);
        }

        CurrentFileService().password = '';
        CurrentFileService().key = recoveryKeyBinaly;
        CurrentFileService().currentFileJsonString =
            CurrentFileService().decodeFile(CurrentFileService().currentFileEncrypted!, recoveryKey, PasskeyType.hexkey);
      } else { // password
        CurrentFileService().password = password;
        CurrentFileService().currentFileJsonString =
            CurrentFileService().decodeFile(CurrentFileService().currentFileEncrypted!, password, PasskeyType.password);
      }

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
      errorMessage = 'wrong password - please try again';
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
