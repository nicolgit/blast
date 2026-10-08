import 'package:blastapp/blastwidget/blast_card_icon.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastapp/blastwidget/blastcard/blast_card_base.dart';
import 'package:flutter/material.dart';
import 'package:humanizer/humanizer.dart';

class BlastCardItem extends BlastCardBase {
  static double get childAspectRatio => 600 / 150;

  const BlastCardItem({
    super.key,
    required super.card,
    required super.onDeletePressed,
    required super.onEditPressed,
    required super.onFavoritePressed,
    required super.onTap,
    required super.isSelected,
    required super.textToHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final widgetFactory = BlastWidgetFactory(context);
    final String name = card.title ?? '';
    final bool isFavorite = card.isFavorite;
    final contentColor = isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface;

    const borderRadius = BorderRadius.all(Radius.circular(6));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Card(
        margin: EdgeInsets.zero,
        color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainer,
        clipBehavior: Clip.antiAlias,
        elevation: 6,
        shape: const RoundedRectangleBorder(borderRadius: borderRadius),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () => onTap(card),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BlastCardIcon(card: card, size: 48.0),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHighlightedText(
                        context,
                        name,
                        TextStyle(
                          color: contentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(color: contentColor),
                        'used ${card.usedCounter} times, last time ${card.lastUpdateDateTime.difference(DateTime.now()).toApproximateTime()}',
                      ),
                      SizedBox(
                        height: 32,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTagsRow(card.tags, widgetFactory),
                            ),
                            _buildActionButton(
                              icon: isFavorite ? Icons.star : Icons.star_border,
                              color: isFavorite ? Colors.amber : widgetFactory.theme.colorScheme.secondary,
                              onPressed: () => onFavoritePressed(card),
                              tooltip: isFavorite ? "remove from favorites" : "add to favorites",
                            ),
                            _buildActionButton(
                              icon: Icons.edit,
                              color: widgetFactory.theme.colorScheme.secondary,
                              onPressed: () => onEditPressed(card),
                              tooltip: "edit",
                            ),
                            _buildActionButton(
                              icon: Icons.delete,
                              color: widgetFactory.theme.colorScheme.secondary,
                              onPressed: () => onDeletePressed(card),
                              tooltip: "delete",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      constraints: const BoxConstraints.tightFor(width: 40, height: 32),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      iconSize: 20,
      icon: Icon(icon, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
    );
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
}
