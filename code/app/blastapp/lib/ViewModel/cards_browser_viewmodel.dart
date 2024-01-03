import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class CardsBrowserViewModel extends ChangeNotifier {
  final BuildContext context;
  final CurrentFileService currentFileService = CurrentFileService();

  CardsBrowserViewModel(this.context);

  Future<List<BlastCard>>? getCards() async {
    return currentFileService.currentFileDocument!.cards;
  }

  void selectCard(BlastCard selectedCard) {
    context.router.push( CardRoute( card: selectedCard ));
  }
}
