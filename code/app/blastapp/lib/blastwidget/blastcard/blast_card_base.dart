import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';

abstract class BlastCardBase extends StatelessWidget {
  static double get childAspectRatio => throw UnimplementedError(
      'BlastCardBase subclasses must define childAspectRatio');

  final BlastCard card;
  final Function(BlastCard) onDeletePressed;
  final Function(BlastCard) onEditPressed;
  final Function(BlastCard) onFavoritePressed;
  final Function(BlastCard) onTap;
  final bool isSelected;
  final List<String> textToHighlight;

  const BlastCardBase({
    super.key,
    required this.card,
    required this.onDeletePressed,
    required this.onEditPressed,
    required this.onFavoritePressed,
    required this.onTap,
    required this.isSelected,
    required this.textToHighlight,
  });

  Widget buildHighlightedText(
    BuildContext context,
    String text,
    TextStyle? style, {
    TextAlign textAlign = TextAlign.start,
  }) {
    final theme = Theme.of(context);

    if (textToHighlight.isEmpty) {
      return Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: textAlign,
        style: style,
      );
    }

    final baseStyle = style?.copyWith(
          color: style.color ?? theme.colorScheme.onSurface,
        ) ??
        TextStyle(color: theme.colorScheme.onSurface);
    final spans = <TextSpan>[];
    var remainingText = text;

    while (remainingText.isNotEmpty) {
      String? foundTerm;
      var foundIndex = -1;

      for (final term in textToHighlight) {
        final index = remainingText.toLowerCase().indexOf(term.toLowerCase());
        if (index != -1 && (foundIndex == -1 || index < foundIndex)) {
          foundIndex = index;
          foundTerm = term;
        }
      }

      if (foundIndex == -1) {
        spans.add(TextSpan(text: remainingText, style: baseStyle));
        break;
      }

      if (foundIndex > 0) {
        spans.add(
          TextSpan(
            text: remainingText.substring(0, foundIndex),
            style: baseStyle,
          ),
        );
      }

      final actualTerm =
          remainingText.substring(foundIndex, foundIndex + foundTerm!.length);
      spans.add(
        TextSpan(
          text: actualTerm,
          style: baseStyle.copyWith(
            backgroundColor: theme.colorScheme.secondary,
            color: theme.colorScheme.onSecondary,
          ),
        ),
      );
      remainingText = remainingText.substring(foundIndex + foundTerm.length);
    }

    return RichText(
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: textAlign,
      text: TextSpan(children: spans),
    );
  }
}
