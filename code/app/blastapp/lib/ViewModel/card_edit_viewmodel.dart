import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class CardEditViewModel extends ChangeNotifier {
  final BuildContext context;
  bool isChanged = false;
  BlastCard sourceCard;
  BlastCard currentCard = BlastCard();
  List<String> allTags = CurrentFileService().currentFileDocument!.getTags();

  CardEditViewModel(this.context, this.sourceCard) {
    currentCard.copyFrom(sourceCard);
  }

  void cancelCommand() {
    context.router.pop();
  }
  
  void saveCommand() {
    sourceCard.copyFrom(currentCard);
    sourceCard.lastUpdateDateTime = DateTime.now();
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
    return Future.value(List.from( currentCard.rows));
  }
}