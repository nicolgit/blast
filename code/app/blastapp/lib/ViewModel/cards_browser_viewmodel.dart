import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class CardsBrowserViewModel extends ChangeNotifier {
  final BuildContext context;
  final CurrentFileService currentFileService = CurrentFileService();
  List<BlastCard> cardsView = [];
  SortType sortType = SortType.none;
  String searchText = "";
  SearchOperator searchOperator = SearchOperator.and;

  bool searchInTitleOnly = false;

  CardsBrowserViewModel(this.context);
  
  Future<List<BlastCard>>? getCards() async {
    return currentFileService.currentFileDocument!.search(searchText, searchOperator, sortType);
  }

  void selectCard(BlastCard selectedCard) {
    context.router.push(CardRoute(card: selectedCard));
  }

  void closeCommand() {
    context.router.replaceAll([const SplashRoute()]);
  }

  void refreshCardListCommand() {
    notifyListeners();
  }

}
