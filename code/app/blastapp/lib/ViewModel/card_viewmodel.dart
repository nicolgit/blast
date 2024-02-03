import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastcard.dart';
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
    context.router.pop();
  }

  void copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
  }

  void toggleShowPassword(int row) {
    showPasswordRow[row] = !showPasswordRow[row];
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

  void editCommand() {
    context.router.push(CardEditRoute(card: currentCard));
  }
}
