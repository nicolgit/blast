import 'package:blastapp/blastwidget/blast_card_icon.dart';
import 'package:blastapp/blastwidget/blastcard/blast_card_base.dart';
import 'package:flutter/material.dart';

class BlastCardMinimal extends BlastCardBase {
  static double get childAspectRatio => 85.60 / 53.98;

  const BlastCardMinimal({
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
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildCard(Color? backgroundColor) {
      return AspectRatio(
        aspectRatio: BlastCardMinimal.childAspectRatio,
        child: Card(
          color: isSelected ? colorScheme.onPrimary : backgroundColor ?? colorScheme.primary,
          clipBehavior: Clip.antiAlias,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            side: card.isFavorite ? const BorderSide(color: Colors.amber, width: 2) : BorderSide.none,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: () => onTap(card),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: card.isFavorite
                              ? BoxDecoration(
                                  border: Border.all(color: Colors.amber, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          child: BlastCardIcon(
                            card: card,
                            size: 72,
                            transparentBackground: true,
                            initialsColor: isSelected ? colorScheme.primary : colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          color: colorScheme.onSurface,
                          child: buildHighlightedText(
                            context,
                            card.title ?? '',
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  onPressed: () => onFavoritePressed(card),
                  tooltip: card.isFavorite ? 'remove from favorites' : 'add to favorites',
                  icon: Icon(
                    card.isFavorite ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: IconButton(
                  onPressed: () => onDeletePressed(card),
                  tooltip: 'delete',
                  icon: Icon(
                    Icons.delete,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isSelected) {
      return buildCard(null);
    }

    return FutureBuilder<Color?>(
      future: BlastCardIcon.getBackgroundColor(card),
      builder: (context, snapshot) => buildCard(snapshot.data),
    );
  }
}
