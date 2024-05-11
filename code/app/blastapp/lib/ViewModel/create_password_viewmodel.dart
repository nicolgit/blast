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
  String password = '';
  String passwordConfirm = '';

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setFilename(String value) {
    filename = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    passwordConfirm = value;
    notifyListeners();
  }

  String validateFilename(String value) {
    notifyListeners();

    if (value.isEmpty) {
      return 'Please enter a filename';
    }

    return '';
  }

  Future<bool> passwordsMatch() async {
    return password == passwordConfirm;
  }

  Future<bool> isFormReadyToConfirm() async {
    return await passwordsMatch() && await isPasswordsNotEmpty() && await isFilenameNotEmpty();
  }

  acceptPassword() async {
    if (filename.endsWith(".blast")) {
      filename = filename.substring(0, filename.length - 6);
    }

    final file = BlastFile(
        cloudId: CurrentFileService().cloud!.id,
        fileName: "$filename.blast",
        fileUrl: "${await CurrentFileService().cloud!.rootpath}$filename.blast",
        jsonCredentials: '');

    CurrentFileService().currentFileInfo = file;
    CurrentFileService().password = password;
    CurrentFileService().currentFileDocument = BlastDocument();
    CurrentFileService().currentFileJsonString = CurrentFileService().currentFileDocument.toString();
    CurrentFileService().currentFileEncrypted =
        CurrentFileService().encodeFile(CurrentFileService().currentFileJsonString!, password);

    var fileId = await CurrentFileService().cloud!.createFile(file.fileUrl, CurrentFileService().currentFileEncrypted!);
    file.fileUrl = fileId;

    SettingService().addRecentFile(file);

    notifyListeners();

    if (!context.mounted) return;
    context.router.push(const CardsBrowserRoute());
  }

  Future<bool> isPasswordsNotEmpty() async {
    return password.isNotEmpty && passwordConfirm.isNotEmpty;
  }

  Future<bool> isFilenameNotEmpty() async {
    return filename.isNotEmpty;
  }
}
