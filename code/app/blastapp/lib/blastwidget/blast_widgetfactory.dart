import 'package:flutter/material.dart';

class BlastWidgetFactory {
  late ThemeData theme;
  late TextTheme textTheme;
  late TextTheme textTooltip;
  late TextStyle _textThemeHint;

  BlastWidgetFactory(BuildContext context) {
    theme = Theme.of(context);
    textTheme = theme.textTheme.apply(bodyColor: theme.colorScheme.onSurface);
    textTooltip = theme.textTheme.apply(bodyColor: theme.colorScheme.onInverseSurface);
    _textThemeHint = textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5));
  }

  Widget blastTag(String tag) => Padding(
      // ignore: prefer_const_constructors
      padding: const EdgeInsets.only(right: 3, left: 3),
      child: Container(
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(3), color: theme.colorScheme.secondaryContainer),
          child: Text("   $tag   ",
              style: textTheme.labelSmall!.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ))));

  Color viewBackgroundColor() => theme.colorScheme.surface;

  Widget blastCardIcon(String text) {
    String iconText = "";

    int i = 0;
    for (var world in text.split(" ")) {
      if (world.isNotEmpty) {
        iconText += world[0].toUpperCase();
        i++;
      }

      if (i == 3) {
        break;
      }
    }

    return CircleAvatar(
      backgroundColor: theme.colorScheme.primary,
      child: Text(
        iconText,
        style: textTheme.labelSmall!.copyWith(color: theme.colorScheme.onPrimary),
      ),
    );
  }

  InputDecoration blastTextFieldDecoration(String label, String hintText, {void Function()? onPressed}) {
    return InputDecoration(
        border: const OutlineInputBorder(), labelText: label, hintText: hintText, hintStyle: _textThemeHint, suffixIcon: onPressed!=null ? IconButton(icon: const Icon(Icons.clear), onPressed: onPressed) : null);
  }
}