import 'dart:convert';
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CardViewModel extends ChangeNotifier {
  final BuildContext context;
  final BlastCard currentCard;
  final _fileService = CurrentFileService();
  final _settingsService = SettingService();

  var cardHasBeenUsed = false;
  bool editMode = false;

  List<bool> showPasswordRow = [];
  late Timer _timer;
  final ValueNotifier<int> timeTextNotifier = ValueNotifier<int>(0);
  bool _isDisposed = false;

  CardViewModel(this.context, this.currentCard, {bool startInEditMode = false}) {
    editMode = startInEditMode;
    showPasswordRow = List.filled(currentCard.rows.length, false);
    _initializeTimer();
  }

  void _initializeTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      timeTextNotifier.value++;
    });
  }

  Future<List<BlastAttribute>> getRows() async {
    return currentCard.rows;
  }

  void closeCommand() {
    context.router.maybePop();
  }

  void copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    _markCardAsUsed();
    _notifySafely();
  }

  void toggleShowPassword(int cardRow) {
    showPasswordRow[cardRow] = !showPasswordRow[cardRow];

    if (showPasswordRow[cardRow]) {
      _markCardAsUsed();
    }

    _notifySafely();
  }

  bool isPasswordRowVisible(int row) {
    return showPasswordRow[row];
  }

  void toggleEditMode(bool value) {
    editMode = value;
    _notifySafely();
  }

  void updateTitle(String value) {
    if (value != currentCard.title) {
      currentCard.title = value;
      _blastDocumentChanged();
      _notifySafely();
    }
  }

  List<String> get allTags => CurrentFileService().currentFileDocument?.getTags() ?? [];

  void updateTags(List<String> values) {
    currentCard.tags = values.map((tag) => tag.toString()).toList();
    _blastDocumentChanged();
    _notifySafely();
  }

  void updateNotes(String value) {
    if (value != currentCard.notes) {
      currentCard.notes = value;
      _blastDocumentChanged();
      _notifySafely();
    }
  }

  void updateAttributeValue(BlastAttribute attribute, String newValue) {
    attribute.value = newValue;
    _blastDocumentChanged();
    _notifySafely();
  }

  Future<void> setGeneratedPassword(BlastAttribute attribute, String newValue) async {
    if (attribute.value.isNotEmpty) {
      if (!context.mounted) return;
      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Replace Password'),
            content: Text('Do you want to replace current password (${attribute.value}) with the new one ($newValue)?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
      if (result != true) return;
    }
    attribute.value = newValue;
    _blastDocumentChanged();
    _notifySafely();
  }

  void updateAttributeName(BlastAttribute attribute, String newName) {
    attribute.name = newName;
    _blastDocumentChanged();
    _notifySafely();
  }

  void deleteAttribute(BlastAttribute attribute) {
    currentCard.rows.remove(attribute);
    showPasswordRow = List.filled(currentCard.rows.length, false);
    _blastDocumentChanged();
    _notifySafely();
  }

  void addAttribute(BlastAttribute attribute) {
    currentCard.rows.add(attribute);
    showPasswordRow = List.filled(currentCard.rows.length, false);
    _blastDocumentChanged();
    _notifySafely();
  }

  void reorderAttributes(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = currentCard.rows.removeAt(oldIndex);
    currentCard.rows.insert(newIndex, item);
    showPasswordRow = List.filled(currentCard.rows.length, false);
    _blastDocumentChanged();
    _notifySafely();
  }

  Future openUrl(String urlString) async {
    if (urlString.toLowerCase().startsWith('http://') ||
        urlString.toLowerCase().startsWith('https://') ||
        urlString.toLowerCase().startsWith('mailto:')) {
      // do nothing
    } else {
      urlString = 'https://$urlString';
    }

    final url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      _markCardAsUsed();
      _notifySafely();

      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void refresh() {
    _notifySafely();
  }

  void _blastDocumentChanged() {
    currentCard.lastUpdateDateTime = DateTime.now();
    CurrentFileService().currentFileDocument?.isChanged = true;
  }

  void toggleFavorite() async {
    currentCard.isFavorite = !currentCard.isFavorite;
    CurrentFileService().currentFileDocument?.isChanged = true;

    _notifySafely();

    if (await _settingsService.autoSave) {
      await _fileService.saveFile(false);
    } else {
      _blastDocumentChanged();
    }

    _notifySafely();
  }

  Future<void> changeDocumentIcon() async {
    final result = await context.router.push(ChangeIconRoute(currentIcon: currentCard.icon));
    if (result != null && result is String && result.isNotEmpty) {
      if (result == 'clear') {
        currentCard.icon = null;
      } else {
        currentCard.icon = result;
      }
      _blastDocumentChanged();
      _notifySafely();
    }
  }

  void showFieldView(String value) async {
    _markCardAsUsed();
    _notifySafely();

    await context.router.push(FieldRoute(value: value));
  }

  void _markCardAsUsed() async {
    if (cardHasBeenUsed) return;

    cardHasBeenUsed = true;
    currentCard.usedCounter++;
    _blastDocumentChanged();

    if (await _settingsService.autoSave) {
      await _fileService.saveFile(false);
    }

    _notifySafely();
  }

  Future<bool> isFileChangedAsync() {
    return Future.value(CurrentFileService().currentFileDocument?.isChanged ?? false);
  }

  Future<bool> saveCommand() async {
    if (await _fileService.saveFile(false)) {
      _notifySafely();
      return true;
    } else {
      // message box: file modified on another device - save or discard
      if (!context.mounted) return false;
      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('File Modified'),
            content: const Text(
                'The file has been modified on another device. Do you want to save your changes or discard them?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Discard changes
                },
                child: const Text('Discard'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true); // Save changes
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (result == true) {
        await _fileService.saveFile(true);
        _notifySafely();

        return true;
      } else {
        return false;
      }
    }
  }

  Future<void> showJsonDataDialog(BuildContext viewContext) async {
    final String jsonData = const JsonEncoder.withIndent('  ').convert(currentCard.toJson());

    final theme = Theme.of(context);
    final foregroundColor = theme.colorScheme.onSurface;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('JSON data', style: TextStyle(color: foregroundColor)),
        content: SizedBox(
          width: 600,
          child: TextFormField(
            initialValue: jsonData,
            readOnly: true,
            minLines: 12,
            maxLines: 20,
            style: TextStyle(fontFamily: 'monospace', color: foregroundColor),
            contextMenuBuilder: (context, editableTextState) {
              return Theme(
                data: theme.copyWith(
                  cardColor: theme.colorScheme.surfaceContainerHighest,
                ),
                child: AdaptiveTextSelectionToolbar.buttonItems(
                  anchors: editableTextState.contextMenuAnchors,
                  buttonItems: editableTextState.contextMenuButtonItems,
                ),
              );
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: theme.colorScheme.tertiaryContainer,
            ),
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonData));
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(viewContext).showSnackBar(
                const SnackBar(
                  content: Text('JSON copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Copy to clipboard'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _notifySafely() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer.cancel();
    timeTextNotifier.dispose();
    super.dispose();
  }
}
