import 'package:flutter/material.dart';
import 'package:blastmodel/blastcard.dart';

class BlastCardIcon extends StatelessWidget {
  const BlastCardIcon({super.key, required this.card});

  final BlastCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Generate initials from card title
    String initials = _generateInitials(card.title);

    return CircleAvatar(
      child: Text(
        initials,
        style: textTheme.labelSmall!.copyWith(color: theme.colorScheme.onPrimary),
      ),
    );
  }

  /*
  Widget _buildTextIcon(String initials) {
    return CircleAvatar(
      backgroundColor: theme.colorScheme.primary,
      child: Text(
        initials,
        style: textTheme.labelSmall!.copyWith(color: theme.colorScheme.onPrimary),
      ),
    );
  }*/

  String _generateInitials(String? text) {
    if (text == null || text.isEmpty) {
      return "??";
    }

    String iconText = "";

    for (var world in text.split(" ")) {
      if (world.isNotEmpty) {
        iconText += world[0].toUpperCase();
      }
    }

    // remove from words all non-alphabetic characters
    iconText = iconText.replaceAll(RegExp(r'[^a-zA-Z]'), '');

    // max 3 characters
    if (iconText.length > 3) {
      iconText = iconText.substring(0, 3);
    }

    return iconText;
  }
}
