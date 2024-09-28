import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardFileInfoViewModel extends ChangeNotifier {
  final CurrentFileService fileService = CurrentFileService();
  final BuildContext context;

  List<bool> showPasswordRow = [];

  CardFileInfoViewModel(this.context);

  void closeCommand() {
    context.router.maybePop();
  }

  void copyToClipboard() {
    final key = fileService.key;
    final hexKey = _toReadableString(key);
    Clipboard.setData(ClipboardData(text: hexKey));
  }

  String getRecoveryKey() {
    final key = fileService.key;

    return _toReadableString(key);
  }

  String _toReadableString(Uint8List data) {
    // convert Uint8List to hex string each 1 byte to 2 characters hex
    final hexKey = data.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

    // add a - every 8 characters
    var hexKeyWithDashes = hexKey.replaceAllMapped(
        RegExp(r".{8}"), (match) => '${match.group(0)}-');

    // remove last char '-' from string
    hexKeyWithDashes =
        hexKeyWithDashes.substring(0, hexKeyWithDashes.length - 1);

    // to uppercase
    hexKeyWithDashes = hexKeyWithDashes.toUpperCase();

    return hexKeyWithDashes;
  }
}
