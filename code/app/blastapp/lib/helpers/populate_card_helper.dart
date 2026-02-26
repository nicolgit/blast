import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';

enum _PopulateResult { next, prev, ok, cancel }

class PopulateCardHelper {
  static Future<bool> populateCard(BuildContext context, BlastCard card) async {
    if (card.rows.isEmpty) return true;

    // Step 1: Ask for the card name
    final nameController = TextEditingController(text: card.title);
    String? nameError;

    while (true) {
      final nameResult = await showDialog<_PopulateResult>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              final focusNode = FocusNode();
              return AlertDialog(
                title: Text('Card Name', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                content: TextField(
                  controller: nameController,
                  focusNode: focusNode,
                  autofocus: true,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (nameController.text.trim().isEmpty) {
                      setState(() => nameError = 'Card name cannot be empty');
                      focusNode.requestFocus();
                    } else {
                      Navigator.of(context).pop(_PopulateResult.next);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter card name',
                    errorText: nameError,
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                  onChanged: (_) {
                    if (nameError != null) {
                      setState(() => nameError = null);
                    }
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_PopulateResult.cancel),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) {
                        setState(() => nameError = 'Card name cannot be empty');
                      } else {
                        Navigator.of(context).pop(_PopulateResult.next);
                      }
                    },
                    child: const Text('Next'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (nameResult == null || nameResult == _PopulateResult.cancel) {
        return false;
      }
      if (nameResult == _PopulateResult.next) {
        card.title = nameController.text.trim();
        break;
      }
    }

    // Step 2: Iterate through attributes (skip headers)
    final editableRows = card.rows.where((r) => r.type != BlastAttributeType.typeHeader).toList();
    if (editableRows.isEmpty) return true;

    int currentIndex = 0;

    while (true) {
      final attribute = editableRows[currentIndex];
      final isFirst = currentIndex == 0;
      final isLast = currentIndex == editableRows.length - 1;

      final controller = TextEditingController(text: attribute.value);

      final result = await showDialog<_PopulateResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final onSurface = Theme.of(context).colorScheme.onSurface;
          return AlertDialog(
            title: Text(card.title ?? '', style: TextStyle(color: onSurface)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attribute.name, style: TextStyle(color: onSurface, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: onSurface),
                  textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
                  onSubmitted: (_) {
                    Navigator.of(context).pop(isLast ? _PopulateResult.ok : _PopulateResult.next);
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter ${attribute.name}',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(_PopulateResult.cancel),
                child: const Text('Cancel'),
              ),
              if (!isFirst)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_PopulateResult.prev),
                  child: const Text('Prev'),
                ),
              if (!isLast)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_PopulateResult.next),
                  child: const Text('Next'),
                ),
              if (isLast)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_PopulateResult.ok),
                  child: const Text('OK'),
                ),
            ],
          );
        },
      );

      if (result == null || result == _PopulateResult.cancel) {
        return false;
      }

      attribute.value = controller.text;

      if (result == _PopulateResult.next) {
        currentIndex++;
      } else if (result == _PopulateResult.prev) {
        currentIndex--;
      } else if (result == _PopulateResult.ok) {
        return true;
      }
    }
  }
}
