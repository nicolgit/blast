import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class TypePasswordViewModel extends ChangeNotifier {
  BuildContext context;

  TypePasswordViewModel(this.context);

  String get fileName => CurrentFileService().currentFileInfo!.fileName;
  String password = '';
  String errorMessage = '';

  Future<bool> isPasswordValid() async {
    return password.isNotEmpty;
  }

  bool checkPassword() {
    try {
      CurrentFileService().currentFileJsonString =
          CurrentFileService().decodeFile(CurrentFileService().currentFileEncrypted!, password);
      CurrentFileService().currentFileDocument =
          BlastDocument.fromJson(jsonDecode(CurrentFileService().currentFileJsonString!));

      final file = CurrentFileService().currentFileInfo;
      if (file != null) {
        SettingService().addRecentFile(file);
      }

      errorMessage = '';
      notifyListeners();

      context.router.push(const CardsBrowserRoute());
      return true;
    } on BlastWrongPasswordException {
      errorMessage = 'wrong password - please check again';
      notifyListeners();
      return false;
    } on BlastUnknownFileVersionException {
      errorMessage = 'unknown file version - unable to open your file';
      notifyListeners();
      return false;
    } on FormatException {
      errorMessage = 'file format exception - unable to open your file';
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'unexpeceted error - unable to open your file - ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  setPassword(String value) {
    password = value;
    errorMessage = '';
    notifyListeners();
  }
}
