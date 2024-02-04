import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';

class CardEditViewModel extends ChangeNotifier {
  final BuildContext context;
  bool isChanged = false;
  BlastCard sourceCard;
  BlastCard currentCard = BlastCard();
  
  CardEditViewModel(this.context, this.sourceCard) {
    currentCard.copyFrom(sourceCard);
  }

  void cancelCommand() {
    context.router.pop();
  }
  
  void saveCommand() {
    sourceCard.copyFrom(currentCard);
    sourceCard.lastUpdateDateTime = DateTime.now();
    
    context.router.pop();
  }

  void updateTitle(String value) {
    isChanged = true;
    currentCard.title = value;
  }

  void updateNotes(String value) {
    isChanged = true;
    currentCard.notes = value;
  }

  updateAttributeValue(int index, String newValue) {
    isChanged = true;
    currentCard.rows[index].value = newValue;
    
  }

  updateAttributeName(int index, String newValue) {
    isChanged = true;
    currentCard.rows[index].name = newValue;
  }
}