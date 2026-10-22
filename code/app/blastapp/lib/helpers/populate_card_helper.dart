import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastapp/blastwidget/blast_password_complexity.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';

enum _PopulateResult { next, prev, ok, cancel }

class PopulateCardHelper {
  static Future<bool> populateCreditCard(BuildContext context, BlastCard card) {
    final cardType = card.title!;
    return populateCard(
      context,
      card,
      titleFromFirstAttribute: (value) {
        final cardholder = value.trim();
        return cardholder.isEmpty ? cardType : "$cardholder's $cardType";
      },
    );
  }

  static Future<bool> populateCard(
    BuildContext context,
    BlastCard card, {
    String Function(String)? titleFromFirstAttribute,
  }) async {
    if (card.rows.isEmpty) return true;

    if (titleFromFirstAttribute == null) {
      if (!context.mounted) return false;
      final nameAttribute = BlastAttribute.withParams(
        card.title ?? '',
        'CardName',
        BlastAttributeType.typeHeader,
      );
      final saved = await context.router.push<bool>(
        FieldEditRoute(attribute: nameAttribute),
      );
      if (saved != true) return false;

      card.title = nameAttribute.name.trim();
    }

    final editableRows = card.rows
        .where((r) => r.type != BlastAttributeType.typeHeader)
        .toList();
    if (editableRows.isEmpty) return true;

    int currentIndex = 0;

    while (true) {
      if (!context.mounted) return false;
      final attribute = editableRows[currentIndex];
      final isFirst = currentIndex == 0;
      final isLast = currentIndex == editableRows.length - 1;
      final isPassword = attribute.type == BlastAttributeType.typePassword;

      final controller = TextEditingController(text: attribute.value);
      bool hideValue = isPassword;

      final result = await showDialog<_PopulateResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final onSurface = Theme.of(context).colorScheme.onSurface;
              return AlertDialog(
                title:
                    Text(card.title ?? '', style: TextStyle(color: onSurface)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(attribute.name,
                        style: TextStyle(
                            color: onSurface, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      style: TextStyle(color: onSurface),
                      textInputAction:
                          isLast ? TextInputAction.done : TextInputAction.next,
                      obscureText: isPassword && hideValue,
                      obscuringCharacter: '*',
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) {
                        Navigator.of(context).pop(
                            isLast ? _PopulateResult.ok : _PopulateResult.next);
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter ${attribute.name}',
                        suffixIcon: isPassword
                            ? IconButton(
                                onPressed: () {
                                  setState(() => hideValue = !hideValue);
                                },
                                icon: Icon(hideValue
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                tooltip: hideValue
                                    ? 'Show password'
                                    : 'Hide password',
                              )
                            : null,
                      ),
                    ),
                    if (isPassword) ...[
                      const SizedBox(height: 8),
                      BlastPasswordComplexity(currentPassword: controller.text),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_PopulateResult.cancel),
                    child: const Text('Cancel'),
                  ),
                  if (!isFirst)
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_PopulateResult.prev),
                      child: const Text('Prev'),
                    ),
                  if (!isLast)
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_PopulateResult.next),
                      child: const Text('Next'),
                    ),
                  if (isLast)
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_PopulateResult.ok),
                      child: const Text('OK'),
                    ),
                ],
              );
            },
          );
        },
      );

      if (result == null || result == _PopulateResult.cancel) {
        return false;
      }

      attribute.value = controller.text;
      if (isFirst && titleFromFirstAttribute != null) {
        card.title = titleFromFirstAttribute(attribute.value);
      }

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
