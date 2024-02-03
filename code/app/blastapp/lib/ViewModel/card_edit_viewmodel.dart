import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';

class CardEditViewModel extends ChangeNotifier {
  final BuildContext context;
  BlastCard sourceCard;
  BlastCard currentCard = BlastCard();
  
  CardEditViewModel(this.context, this.sourceCard) {
    currentCard.copyFrom(sourceCard);
  }

  void saveCommand() {
    sourceCard.copyFrom(currentCard);
    sourceCard.lastUpdateDateTime = DateTime.now();
    
    context.router.pop();
  }
}