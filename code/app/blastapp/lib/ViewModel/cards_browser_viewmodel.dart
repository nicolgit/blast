import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';

enum SortType { none, star, mostUsed, recentUsed}

class CardsBrowserViewModel extends ChangeNotifier {
  final BuildContext context;
  final CurrentFileService currentFileService = CurrentFileService();
  List<BlastCard> cardsView = [];
  SortType sortType = SortType.none;
  String searchText = "";
  CardsBrowserViewModel(this.context);
  
  Future<List<BlastCard>>? getCards() async {
    final List<String> words = removeDiacritics(searchText).toLowerCase().split(" ");

    switch (sortType) {
      case SortType.none:
        return currentFileService.currentFileDocument!.cards.where((element) => element.seach(words, SearchOperator.and) != SearchResult.notFound).toList();
      case SortType.star:
        return [];
      case SortType.mostUsed:
        return [];
      case SortType.recentUsed:
        return [];
    }
  }

  void selectCard(BlastCard selectedCard) {
    context.router.push(CardRoute(card: selectedCard));
  }

  void closeCommand() {
    context.router.replaceAll([const SplashRoute()]);
  }

  void sortCardsCommand(SortType sortType) {
    this.sortType = sortType;
    notifyListeners();
  }

  void refreshCardListCommand() {
    notifyListeners();
  }
}
