import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/importer.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImporterViewModel extends ChangeNotifier {
  final BuildContext context;
  final CurrentFileService fileService = CurrentFileService();

  ImporterViewModel(this.context);

  void closeCommand() {
    context.router.maybePop();
  }

  Future importBlastCommand() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      if (kIsWeb) {
        final fileBytes = result.files.first.bytes;
        fileService.currentFileJsonString = utf8.decode(fileBytes!);
      } else {
        File file = File(result.files.single.path!);
        fileService.currentFileJsonString = file.readAsStringSync();
      }

      fileService.currentFileDocument = Importer.importBlastJson(fileService.currentFileJsonString!);
    } else {
      throw Exception('User canceled the picker');
    }

    if (context.mounted) {
      context.router.maybePop();
    }
  }

  importKeepassXMLCommand() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      String xmlString = '';

      if (kIsWeb) {
        final fileBytes = result.files.first.bytes;
        xmlString = utf8.decode(fileBytes!);
      } else {
        File file = File(result.files.single.path!);
        xmlString = file.readAsStringSync();
      }

      fileService.currentFileDocument = Importer.importKeepassXML(xmlString);
    } else {
      throw Exception('User canceled the picker');
    }
  }

  importPwsafeXMLCommand() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      String xmlString = '';

      if (kIsWeb) {
        final fileBytes = result.files.first.bytes;
        xmlString = utf8.decode(fileBytes!);
      } else {
        File file = File(result.files.single.path!);
        xmlString = file.readAsStringSync();
      }

      fileService.currentFileDocument = Importer.importPwsafeXML(xmlString);
    } else {
      throw Exception('User canceled the picker');
    }
  }

  String importedCount() {
    return fileService.currentFileDocument!.cards.length.toString();
  }
}
