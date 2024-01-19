import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class CreatePasswordViewModel extends ChangeNotifier {
  BuildContext context;

  CreatePasswordViewModel(this.context);

  String filename = '';
  String filenameError = '';
  String password = '';
  String passwordConfirm = '';
  String passwordError = '';
  String passwordConfirmError = '';

  void setPassword(String value) {
    password = value;
    passwordError = validatePassword(value);
    notifyListeners();
  }

  void setFilename(String value) {
    filename = value;
    filenameError = validateFilename(value);
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    passwordConfirm = value;
    passwordConfirmError = validatePassword(value);
    filenameError = validateFilename(value);
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

  String validateFilename(String value) {
    notifyListeners();

    if (value.isEmpty) {
      return 'Please enter a filename';
    }

    return '';
  }

  Future<bool> isPasswordValid() async {
    return passwordError.isEmpty && passwordConfirmError.isEmpty;
  }

  Future<bool> passwordsMatch() async {
    return password == passwordConfirm;
  }

  Future<bool> isFilenameValid() async {
    return filenameError.isEmpty;
  }

  Future<bool> isFormReadyToConfirm() async {
    return await isPasswordValid() && await passwordsMatch() && await isFilenameValid();
  }

  acceptPassword() async {
    final file = BlastFile(
        cloudId: CurrentFileService().cloud!.ID,
        fileName: "$filename.blast",
        filePath: await CurrentFileService().cloud!.rootpath);

    CurrentFileService().currentFileInfo = file;
    CurrentFileService().password = password;
    CurrentFileService().currentFileDocument = BlastDocument();

    CurrentFileService().currentFileJsonString = null;
    CurrentFileService().currentFileEncrypted = null;
    SettingService().addRecentFile(file);

    notifyListeners();
    context.router.push(const CardsBrowserRoute());
  }
}
