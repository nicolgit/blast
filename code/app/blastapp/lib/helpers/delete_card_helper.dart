import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';

class DeleteCardHelper {
  /// Shows a confirmation dialog for deleting a card.
  /// Returns `true` if the user confirmed deletion, `false` otherwise.
  static Future<bool> showDeleteCardDialog(BuildContext context, BlastCard card) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final onSurface = Theme.of(context).colorScheme.onSurface;
        return AlertDialog(
          title: Row(
            children: [
              Text('Delete ', style: TextStyle(color: onSurface)),
              Text('${card.title}', style: TextStyle(fontWeight: FontWeight.bold, color: onSurface)),
            ],
          ),
          content: Text('Are you sure you want to delete this card and all its content?',
              style: TextStyle(color: onSurface)),
          actions: <Widget>[
            TextButton(
                child: const Text('No'),
                onPressed: () => Navigator.pop(context, false)),
            TextButton(
                child: const Text('Yes please!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context, true)),
          ],
        );
      },
    );
    return result ?? false;
  }
}
