import 'package:flutter/material.dart';

class BlastWidgetFactory {
  late ThemeData _theme;
  late TextTheme _textTheme;

  BlastWidgetFactory(BuildContext context) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onBackground);
  }

  Widget blastTag(String tag) => Padding(
      // ignore: prefer_const_constructors
      padding: const EdgeInsets.only(right: 3, left: 3),
      child: Container(
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(6), color: _theme.colorScheme.secondaryContainer),
          child: Text("   $tag   ",
              style: _textTheme.labelSmall!.copyWith(
                color: _theme.colorScheme.onSecondaryContainer,
                backgroundColor: _theme.colorScheme.secondaryContainer,
              ))));

  Color viewBackgroundColor() => _theme.colorScheme.background;
}
