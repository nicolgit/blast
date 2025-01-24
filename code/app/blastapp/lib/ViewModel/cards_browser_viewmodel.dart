import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<bool> saveCommand() async {
    if (await fileService.saveFile(false)) {
      notifyListeners();
      return true;
    } else {
      // message box: file modified on another device - save or discard
      if (!context.mounted) return false;
      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('File Modified'),
            content: const Text(
                'The file has been modified on another device. Do you want to save your changes or discard them?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Discard changes
                },
                child: const Text('Discard'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true); // Save changes
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (result == true) {
        await fileService.saveFile(true);
        notifyListeners();

        return true;
      } else {
        return false;
      }
    }
  }

  bool isFileChanged() => fileService.currentFileDocument!.isChanged;
  Future<bool> isFileChangedAsync() async => fileService.currentFileDocument!.isChanged;

  Future addCard() async {
    await context.router.push(CardEditRoute());
  }

  deleteCard(BlastCard card) {
    fileService.currentFileDocument!.cards.remove(card);
    fileService.currentFileDocument!.isChanged = true;
    notifyListeners();
  }

  void exportCommand() async {
    if (!context.mounted) return;
    var checkPasswordResult = await context.router.push(const TypePasswordRoute());
    if (checkPasswordResult != true) {
      return;
    }

    String? path = await FilePicker.platform.getDirectoryPath();

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

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Data exported to $fileName.'),
    ));
  }

  clearSearchTextCommand() {
    searchText = "";
    sortType = SortType.none;
    searchOperator = SearchOperator.and;
    searchWhere = SearchWhere.everywhere;
    notifyListeners();
  }

  bool isFileNotEmpty() {
    return fileService.currentFileDocument!.cards.isNotEmpty;
  }

  void exportMasterKeyCommand() async {
    if (!context.mounted) return;
    var checkPasswordResult = await context.router.push(const TypePasswordRoute());
    if (checkPasswordResult != true) {
      return;
    }

    if (!context.mounted) return;
    context.router.push(const CardFileInfoRoute());
  }

  void changePasswordCommand() async {
    if (!context.mounted) return;
    var checkPasswordResult = await context.router.push(const TypePasswordRoute());
    if (checkPasswordResult != true) {
      return;
    }

    if (!context.mounted) return;
    var changePasswordResult = await context.router.push(const ChangePasswordRoute());
    if (changePasswordResult != true) {
      return;
    }

    fileService.currentFileDocument!.isChanged = true;

    if (!context.mounted) return;
    context.router.push(const CardFileInfoRoute());

    notifyListeners();
  }

  void goToSettings() {
    if (!context.mounted) return;
    context.router.push(const SettingsRoute());
  }
}
