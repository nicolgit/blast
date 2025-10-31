import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class CardEditViewModel extends ChangeNotifier {
  final BuildContext context;
  bool isChanged = false;
  final BlastCard? _sourceCard;
  BlastCard currentCard = BlastCard();
  List<String> allTags = CurrentFileService().currentFileDocument!.getTags();

  final _settingsService = SettingService();

  CardEditViewModel(this.context, this._sourceCard) {
    if (_sourceCard != null) {
      currentCard.copyFrom(_sourceCard!);
    } else {
      currentCard = BlastCard();
    }
  }

  Future<bool> isFileChangedAsync() {
    return Future.value(CurrentFileService().currentFileDocument?.isChanged ?? false);
  }

  void cancelCommand() {
    context.router.maybePop();
  }

  void saveCommand({required bool saveAndExit}) async {
    if (_sourceCard == null) {
      CurrentFileService().currentFileDocument!.cards.insert(0, currentCard);
    } else {
      _sourceCard?.copyFrom(currentCard);
      _sourceCard?.lastUpdateDateTime = DateTime.now();
    }

    CurrentFileService().currentFileDocument!.isChanged = true;

    if (await _settingsService.autoSave) {
      CurrentFileService().saveFile(false);
      CurrentFileService().currentFileDocument!.isChanged = false;
      isChanged = false;
    }

    notifyListeners(); // Refresh UI to hide FileChangedBanner after save

    if (saveAndExit) {
      if (!context.mounted) return;
      context.router.maybePop();
    }
  }

  void updateTitle(String value) {
    isChanged = true;
    currentCard.title = value;
    CurrentFileService().currentFileDocument!.isChanged = true;
    notifyListeners();
  }

  void updateNotes(String value) {
    if (value != currentCard.notes) {
      isChanged = true;
      currentCard.notes = value;
      CurrentFileService().currentFileDocument!.isChanged = true;
      notifyListeners();
    }
  }

  void updateAttributeValue(int index, String newValue) {
    isChanged = true;
    currentCard.rows[index].value = newValue;
    CurrentFileService().currentFileDocument!.isChanged = true;
    notifyListeners();
  }

  void updateAttributeName(int index, String newValue) {
    isChanged = true;
    currentCard.rows[index].name = newValue;
    CurrentFileService().currentFileDocument!.isChanged = true;
    notifyListeners();
  }

  void updateTags(List<String> values) {
    isChanged = true;
    currentCard.tags = values.map((tag) => tag.toString()).toList();
    CurrentFileService().currentFileDocument!.isChanged = true;

    notifyListeners();
  }

  void deleteAttribute(int index) {
    isChanged = true;
    currentCard.rows.removeAt(index);
    CurrentFileService().currentFileDocument!.isChanged = true;

    notifyListeners();
  }

  Future<List<BlastAttribute>> getRows() async {
    return Future.value(List.from(currentCard.rows));
  }

  void addAttribute(BlastAttributeType type) {
    isChanged = true;

    var newAttribute = BlastAttribute();
    newAttribute.type = type;

    switch (type) {
      case BlastAttributeType.typePassword:
        newAttribute.name = 'password';
        break;
      case BlastAttributeType.typeURL:
        newAttribute.name = 'URL';
        break;
      default:
        break;
    }

    currentCard.rows.add(newAttribute);
    CurrentFileService().currentFileDocument!.isChanged = true;

    notifyListeners();
  }

  void swapType(int index) {
    isChanged = true;

    switch (currentCard.rows[index].type) {
      case BlastAttributeType.typeHeader:
        currentCard.rows[index].type = BlastAttributeType.typePassword;
      case BlastAttributeType.typePassword:
        currentCard.rows[index].type = BlastAttributeType.typeString;
      case BlastAttributeType.typeString:
        currentCard.rows[index].type = BlastAttributeType.typeURL;
      case BlastAttributeType.typeURL:
        currentCard.rows[index].type = BlastAttributeType.typeHeader;
    }

    CurrentFileService().currentFileDocument!.isChanged = true;
    notifyListeners();
  }

  void deleteCard() {
    CurrentFileService().currentFileDocument!.cards.remove(_sourceCard);
    CurrentFileService().currentFileDocument!.isChanged = true;
    context.router.maybePop();
  }

  void moveRow(int oldIndex, int newIndex) {
    newIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;

    final oldItem = currentCard.rows.removeAt(oldIndex);
    currentCard.rows.insert(newIndex, oldItem);

    isChanged = true;
    CurrentFileService().currentFileDocument!.isChanged = true;
    notifyListeners();
  }
}
