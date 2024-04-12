import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class CardEditViewModel extends ChangeNotifier {
  final BuildContext context;
  bool isChanged = false;
  final BlastCard? _sourceCard;
  BlastCard currentCard = BlastCard();
  List<String> allTags = CurrentFileService().currentFileDocument!.getTags();

  CardEditViewModel(this.context, this._sourceCard) {
    if (_sourceCard != null) {
      currentCard.copyFrom(_sourceCard!);
    } else {
      currentCard = BlastCard();
    }
  }

  void cancelCommand() {
    context.router.pop();
  }

  void saveCommand() {
    if (_sourceCard == null) {
      CurrentFileService().currentFileDocument!.cards.add(currentCard);
    } else {
      _sourceCard?.copyFrom(currentCard);
      _sourceCard?.lastUpdateDateTime = DateTime.now();
    }

    CurrentFileService().currentFileDocument!.isChanged = true;

    context.router.pop();
  }

  void updateTitle(String value) {
    isChanged = true;
    currentCard.title = value;
  }

  void updateNotes(String value) {
    if (value != currentCard.notes) {
      isChanged = true;
      currentCard.notes = value;
    }
  }

  updateAttributeValue(int index, String newValue) {
    isChanged = true;
    currentCard.rows[index].value = newValue;
  }

  updateAttributeName(int index, String newValue) {
    isChanged = true;
    currentCard.rows[index].name = newValue;
  }

  void updateTags(List<String> values) {
    isChanged = true;
    currentCard.tags = values.map((tag) => tag.toString()).toList();
  }

  deleteAttribute(int index) {
    isChanged = true;
    currentCard.rows.removeAt(index);

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

    notifyListeners();
  }

  deleteCard() {
    CurrentFileService().currentFileDocument!.cards.remove(_sourceCard);
    
    CurrentFileService().currentFileDocument!.isChanged = true;
    context.router.pop();
  }
}
