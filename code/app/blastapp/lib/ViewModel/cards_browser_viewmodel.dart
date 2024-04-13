import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CardsBrowserViewModel extends ChangeNotifier {
  final BuildContext context;
  final CurrentFileService fileService = CurrentFileService();
  List<BlastCard> cardsView = [];
  BlastCard? selectedCard;

  SortType sortType = SortType.none;
  String searchText = "";
  SearchOperator searchOperator = SearchOperator.and;
  SearchWhere searchWhere = SearchWhere.everywhere;

  CardsBrowserViewModel(this.context);

  Future<List<BlastCard>>? getCards() async {
    return fileService.currentFileDocument!.search(searchText, searchOperator, sortType, searchWhere);
  }

  Future selectCard(BlastCard selectedCard) async {
    this.selectedCard = selectedCard;
    await context.router.push(CardRoute(card: selectedCard));
  }

  Future editCard(BlastCard selectedCard) async {
    this.selectedCard = selectedCard;
    await context.router.push(CardEditRoute(card: selectedCard));
  }

  void closeCommand() {
    context.router.replaceAll([const SplashRoute()]);
  }

  void refreshCardListCommand() {
    notifyListeners();
  }

  void saveCommand() {
    fileService.currentFileDocument!.isChanged = false;

    fileService.currentFileJsonString = fileService.currentFileDocument.toString();
    fileService.currentFileEncrypted = fileService.encodeFile(fileService.currentFileJsonString!, fileService.password);
    fileService.cloud!.setFile(fileService.currentFileInfo!.fileUrl, fileService.currentFileEncrypted!);
  }

  bool isFileChanged() => fileService.currentFileDocument!.isChanged;

  Future addCard() async {
    await context.router.push(CardEditRoute());
  }

  deleteCard(BlastCard card) {
    fileService.currentFileDocument!.cards.remove(card);
    fileService.currentFileDocument!.isChanged = true;
    notifyListeners();
  }

  void exportCommand() async {
    String? path = await FilePicker.platform.getDirectoryPath();

    if (path != null) {
      String name = 'blastapp-export';
      String fileName = '$path/$name.json';

      int i = 0;
      while (await File(fileName).exists()) {
        if (i == 0) {
          fileName = '$path/$name.json';
        } else {
          fileName = '$path/$name-$i.json';
        }

        if (i == 5) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Too many files with the same name. Please delete some files and try again.'),
          ));
          return;
        }

        i++;
      }

      File file = File(fileName);

      String jsonString = fileService.currentFileDocument!.toString();
      file.writeAsStringSync(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Data exported to $fileName.'),
      ));
    }
  }

  Future importCommand() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      if (kIsWeb) {
        final fileBytes = result.files.first.bytes;
        fileService.currentFileJsonString = utf8.decode(fileBytes!);
      } else {
        File file = File(result.files.single.path!);
        fileService.currentFileJsonString = file.readAsStringSync();
      }

      fileService.currentFileDocument = BlastDocument.fromJson(jsonDecode(CurrentFileService().currentFileJsonString!));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data imported successfully.'),
      ));
    } else {
      // User canceled the picker
    }

    notifyListeners();
  }
}
