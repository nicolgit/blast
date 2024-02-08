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
  bool _isChanged = false; please check

  List<bool> showPasswordRow = [];

  CardViewModel(this.context, this.currentCard) {
    showPasswordRow = List.filled(currentCard.rows.length, false);
  }

  Future<List<BlastAttribute>> getRows() async {
    return currentCard.rows;
  }

  void closeCommand() {

    context.router.pop();
  }

  void copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));

    CurrentFileService().currentFileDocument!.cards[cardRow].usedCounter++;
    CurrentFileService().currentFileDocument!.isChanged = true;
  }

  void toggleShowPassword(int cardRow) {
    showPasswordRow[cardRow] = !showPasswordRow[cardRow];
    CurrentFileService().currentFileDocument!.isChanged = true;
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
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future editCommand() async {
    await context.router.push(CardEditRoute(card: currentCard));
    return Future.value();
  }

  void refresh() {
    notifyListeners();
  }
}
