import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CardViewModel extends ChangeNotifier {
  final BuildContext context;
  final BlastCard currentCard;

  List<bool> showPasswordRow = [];

  CardViewModel(this.context, this.currentCard) {
    showPasswordRow = List.filled(currentCard.rows.length, false);
  }

  Future<List<BlastAttribute>> getRows() async {
    return currentCard.rows;
  }

  void closeCommand() {
    context.router.maybePop();
  }

  void copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    currentCard.usedCounter++;
    _blastDocumentChanged();
    notifyListeners();
  }

  void toggleShowPassword(int cardRow) {
    showPasswordRow[cardRow] = !showPasswordRow[cardRow];
    currentCard.usedCounter++;
    _blastDocumentChanged();
    notifyListeners();
  }

  bool isPasswordRowVisible(int row) {
    return showPasswordRow[row];
  }

  Future openUrl(String urlString) async {
    if (urlString.substring(0, 5).toLowerCase() != 'http://' &&
        urlString.substring(0, 6).toLowerCase() != 'https://' &&
        urlString.substring(0, 7).toLowerCase() != 'mailto:') {
      urlString = 'https://$urlString';
    }

    final url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      currentCard.usedCounter++;
      _blastDocumentChanged();
      notifyListeners();

      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future editCommand() async {
    await context.router
        .push(CardEditRoute(card: currentCard))
        .then((value) => {showPasswordRow = List.filled(currentCard.rows.length, false)});

    return Future.value();
  }

  void refresh() {
    notifyListeners();
  }

  void _blastDocumentChanged() {
    currentCard.lastUpdateDateTime = DateTime.now();
    CurrentFileService().currentFileDocument?.isChanged = true;
  }

  void toggleFavorite() {
    currentCard.isFavorite = !currentCard.isFavorite;
    _blastDocumentChanged();
    notifyListeners();
  }

  void showFieldView(String value) async {
    _blastDocumentChanged();
    notifyListeners();

    await context.router.push(FieldRoute(value: value));
  }
}
