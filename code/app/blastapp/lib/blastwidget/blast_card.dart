import 'package:blastapp/blastwidget/blast_card_icon.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:humanizer/humanizer.dart';

class BlastCardItem extends StatelessWidget {
  final BlastCard card;
  final Function(BlastCard) onDeletePressed;
  final Function(BlastCard) onFavoritePressed;
  final Function(BlastCard) onTap;
  final bool isSelected;
  final List<String> textToHighlight;

  const BlastCardItem({
    super.key,
    required this.card,
    required this.onDeletePressed,
    required this.onFavoritePressed,
    required this.onTap,
    required this.isSelected,
    required this.textToHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final widgetFactory = BlastWidgetFactory(context);
    final String name = card.title ?? '';
    final bool isFavorite = card.isFavorite;

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Card(
            elevation: 6,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              minVerticalPadding: 0,
              leading: BlastCardIcon(card: card, size: 48.0),
              tileColor: theme.colorScheme.surfaceContainer,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
              title:
                  _buildHighlightedText(context, name, textToHighlight, const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      'used ${card.usedCounter} times, last time ${card.lastUpdateDateTime.difference(DateTime.now()).toApproximateTime()}',
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTagsRow(card.tags, widgetFactory),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber : widgetFactory.theme.colorScheme.secondary,
                        ),
                        onPressed: () => onFavoritePressed(card),
                        tooltip: isFavorite ? "remove from favorites" : "add to favorites",
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.delete, color: widgetFactory.theme.colorScheme.secondary),
                        onPressed: () => onDeletePressed(card),
                        tooltip: "delete",
                      ),
                    ],
                  ),
                ],
              ),
              selectedTileColor: theme.colorScheme.primaryContainer,
              selected: isSelected,
              onTap: () => onTap(card),
            )));
  }

  Widget _buildTagsRow(List<String> tags, BlastWidgetFactory widgetFactory) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: tags
            .map((tag) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: widgetFactory.blastTag(tag),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildHighlightedText(BuildContext context, String text, List<String> textToHighlight, TextStyle? style) {
    final theme = Theme.of(context);

    if (textToHighlight.isEmpty) {
      return Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: style,
      );
    }

    final TextStyle baseStyle = style?.copyWith(
          color: style.color ?? theme.colorScheme.onSurface,
        ) ??
        TextStyle(color: theme.colorScheme.onSurface);

    List<TextSpan> spans = [];
    String remainingText = text;

    while (remainingText.isNotEmpty) {
      String? foundTerm;
      int foundIndex = -1;

      for (String term in textToHighlight) {
        int index = remainingText.toLowerCase().indexOf(term.toLowerCase());
        if (index != -1 && (foundIndex == -1 || index < foundIndex)) {
          foundIndex = index;
          foundTerm = term;
        }
      }

      if (foundIndex == -1) {
        spans.add(TextSpan(text: remainingText, style: baseStyle));
        break;
      } else {
        if (foundIndex > 0) {
          spans.add(TextSpan(text: remainingText.substring(0, foundIndex), style: baseStyle));
        }
        final String actualTerm = remainingText.substring(foundIndex, foundIndex + foundTerm!.length);
        spans.add(TextSpan(
          text: actualTerm,
          style: baseStyle.copyWith(
            backgroundColor: theme.colorScheme.secondary,
            color: theme.colorScheme.onSecondary,
          ),
        ));
        remainingText = remainingText.substring(foundIndex + foundTerm.length);
      }
    }

    return RichText(
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      text: TextSpan(children: spans),
    );
  }
}
