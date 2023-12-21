import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:flutter/material.dart';

class TypePasswordViewModel extends ChangeNotifier {
  BuildContext context;

  TypePasswordViewModel(this.context);

  String password = '';
  String errorMessage = '';

  Future<bool> isPasswordValid() async {
    return password.isNotEmpty;
  }

  checkPassword() {
    try {
      CurrentFileService().currentFileJsonString =
          CurrentFileService().decodeFile(CurrentFileService().currentFileEncrypted!, password);
      CurrentFileService().currentFileDocument =
          BlastDocument.fromJson(jsonDecode(CurrentFileService().currentFileJsonString!));
      errorMessage = '';
      notifyListeners();
      return;
    } on BlastWrongPasswordException {
      errorMessage = 'wrong password - please check again';
      notifyListeners();
      return;
    } catch (e) {
      errorMessage = 'sorry - unable to open your file';
      notifyListeners();
      return;
    }
  }

  setPassword(String value) {
    password = value;
    errorMessage = '';
    notifyListeners();
  }
}
