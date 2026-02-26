import 'package:flutter/material.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'blast_attribute_edit.dart';
import 'blast_attribute_row.dart';

class BlastWidgetFactory {
  late ThemeData theme;
  late TextTheme textTheme;
  late TextTheme textTooltip;
  late TextStyle _textThemeHint;

  BlastWidgetFactory(BuildContext context) {
    theme = Theme.of(context);
    textTheme = theme.textTheme.apply(bodyColor: theme.colorScheme.onSurface);
    textTooltip = theme.textTheme.apply(bodyColor: theme.colorScheme.onInverseSurface);
    _textThemeHint = textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5));
  }

  Widget blastTag(String tag) => Padding(
      // ignore: prefer_const_constructors
      padding: const EdgeInsets.only(right: 3, left: 3),
      child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: theme.colorScheme.primary),
          child: Text("   $tag   ",
              style: textTheme.labelSmall!.copyWith(
                color: theme.colorScheme.onPrimary,
              ))));

  Color viewBackgroundColor() => theme.colorScheme.surface;

  InputDecoration blastTextFieldDecoration(String label, String hintText, {void Function()? onPressed}) {
    return InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        hintText: hintText,
        hintStyle: _textThemeHint,
        suffixIcon: onPressed != null ? IconButton(icon: const Icon(Icons.clear), onPressed: onPressed) : null);
  }

  Widget buildAttributeRowEdit(
    List<BlastAttribute> rows,
    int i, {
    required FocusOn focusOn,
    required Function(String) onNameChanged,
    required Function(String) onValueChanged,
    required VoidCallback onDelete,
    required VoidCallback onTypeSwap,
  }) {
    return BlastAttributeEdit(
      rows: rows,
      index: i,
      focusOn: focusOn,
      onNameChanged: onNameChanged,
      onValueChanged: onValueChanged,
      onDelete: onDelete,
      onTypeSwap: onTypeSwap,
      blastTextFieldDecoration: blastTextFieldDecoration,
      buildIconTypeButton: buildIconTypeButton,
      theme: theme,
      textTheme: textTheme,
    );
  }

  IconButton buildIconTypeButton(BlastAttributeType type, VoidCallback onTypeSwap) {
    var icon = const Icon(Icons.error);

    switch (type) {
      case BlastAttributeType.typeString:
        icon = const Icon(Icons.description);
      case BlastAttributeType.typeHeader:
        icon = const Icon(Icons.text_increase);
      case BlastAttributeType.typePassword:
        icon = const Icon(Icons.lock);
      case BlastAttributeType.typeURL:
        icon = const Icon(Icons.link);
    }

    return IconButton(
      onPressed: onTypeSwap,
      icon: icon,
      tooltip: "${type.description}\n tap to change",
    );
  }
}
