import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';

class CardEditViewModel extends ChangeNotifier {
  final BuildContext context;
  final BlastCard currentCard;
  
  CardEditViewModel(this.context, this.currentCard);
}