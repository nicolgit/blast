import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class CardsBrowserViewModel extends ChangeNotifier {
  BuildContext context;
  CurrentFileService currentFileService = CurrentFileService();

  CardsBrowserViewModel(this.context);

  Future<List<BlastCard>>? getCards() async {
    return currentFileService.currentFileDocument!.cards;
  }

  void selectCard(BlastCard cardsList) {}
}
