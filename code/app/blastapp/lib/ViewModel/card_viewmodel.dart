import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
}
