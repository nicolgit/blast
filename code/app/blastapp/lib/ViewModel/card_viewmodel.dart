import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CardViewModel extends ChangeNotifier {
  final BuildContext context;
  final BlastCard currentCard;
  final _fileService = CurrentFileService();
  final _settingsService = SettingService();

  var cardHasBeenUsed = false;

  List<bool> showPasswordRow = [];
  late Timer _timer;

  CardViewModel(this.context, this.currentCard) {
    showPasswordRow = List.filled(currentCard.rows.length, false);
    _initializeTimer();
  }

  void _initializeTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  Future<List<BlastAttribute>> getRows() async {
    return currentCard.rows;
  }

  void closeCommand() {
    context.router.maybePop();
  }

  void copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    _markCardAsUsed();
    notifyListeners();
  }

  void toggleShowPassword(int cardRow) {
    showPasswordRow[cardRow] = !showPasswordRow[cardRow];

    if (showPasswordRow[cardRow]) {
      _markCardAsUsed();
    }

    notifyListeners();
  }

  bool isPasswordRowVisible(int row) {
    return showPasswordRow[row];
  }

  Future openUrl(String urlString) async {
    if (urlString.toLowerCase().startsWith('http://') ||
        urlString.toLowerCase().startsWith('https://') ||
        urlString.toLowerCase().startsWith('mailto:')) {
      // do nothing
    } else {
      urlString = 'https://$urlString';
    }

    final url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      _markCardAsUsed();
      notifyListeners();

      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future editCommand() async {
    await context.router
        .push(CardEditRoute(card: currentCard))
        .then((value) => {showPasswordRow = List.filled(currentCard.rows.length, false), notifyListeners()});

    return Future.value();
  }

  void refresh() {
    notifyListeners();
  }

  void _blastDocumentChanged() {
    currentCard.lastUpdateDateTime = DateTime.now();
    CurrentFileService().currentFileDocument?.isChanged = true;
  }

  void toggleFavorite() async {
    currentCard.isFavorite = !currentCard.isFavorite;
    CurrentFileService().currentFileDocument?.isChanged = true;

    notifyListeners();

    if (await _settingsService.autoSave) {
      await _fileService.saveFile(false);
    } else {
      _blastDocumentChanged();
    }

    notifyListeners();
  }

  void showFieldView(String value) async {
    _markCardAsUsed();
    notifyListeners();

    await context.router.push(FieldRoute(value: value));
  }

  void _markCardAsUsed() async {
    if (cardHasBeenUsed) return;

    cardHasBeenUsed = true;
    currentCard.usedCounter++;
    _blastDocumentChanged();

    if (await _settingsService.autoSave) {
      await _fileService.saveFile(false);
    }

    notifyListeners();
  }

  Future<bool> isFileChangedAsync() {
    return Future.value(CurrentFileService().currentFileDocument?.isChanged ?? false);
  }

  Future<bool> saveCommand() async {
    if (await _fileService.saveFile(false)) {
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
        await _fileService.saveFile(true);
        notifyListeners();

        return true;
      } else {
        return false;
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
