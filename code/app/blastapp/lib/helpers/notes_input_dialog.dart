import 'package:flutter/material.dart';

class NotesInputDialog {
  static Future<String> show(BuildContext context, String initialValue) async {
    final theme = Theme.of(context);
    String valueText = initialValue;
    final oldValue = initialValue;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('notes (some markdown is ok)',
              style: theme.textTheme.headlineSmall!.copyWith(color: theme.colorScheme.onSurface)),
          content: TextField(
            controller: TextEditingController()..text = valueText,
            keyboardType: TextInputType.multiline,
            minLines: 4,
            maxLines: null,
            style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurface),
            onChanged: (value) {
              valueText = value;
            },
            decoration: const InputDecoration(hintText: "type your notes here..."),
          ),
          actions: <Widget>[
            MaterialButton(
              color: Colors.red,
              textColor: Colors.white,
              child: const Text('cancel'),
              onPressed: () {
                valueText = oldValue;
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              color: Colors.green,
              textColor: Colors.white,
              child: const Text('ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    return valueText;
  }
}
