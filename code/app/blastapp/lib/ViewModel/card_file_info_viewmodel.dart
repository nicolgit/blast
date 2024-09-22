import 'package:flutter/material.dart';

class CardFileInfoViewModel extends ChangeNotifier {
  final BuildContext context;

  List<bool> showPasswordRow = [];

  CardFileInfoViewModel(this.context);
}
