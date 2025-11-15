import 'package:blastmodel/blastattributetype.dart';
import 'package:flutter/material.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter_test/flutter_test.dart';

class BlastCardIcon extends StatelessWidget {
  const BlastCardIcon({super.key, required this.card});

  final BlastCard card;
  @override
  Widget build(BuildContext context) {
    final String? urlDomain = _getFirstUrlDomain();
    if (urlDomain != null) {
      String iconUriString = "https://www.google.com/s2/favicons?sz=256&domain=$urlDomain";
      Uri iconUri = Uri.parse(iconUriString);

      return Container(
        width: 40,
        height: 40,
        decoration: _buildIconDecoration(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            iconUri.toString(),
            fit: BoxFit.cover,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to circular text icon when image fails to load
              return _buildTextIcon(context, _generateInitials(card.title));
            },
          ),
        ),
      );
    }
    return _buildTextIcon(context, _generateInitials(card.title));
  }

  BoxDecoration _buildIconDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: card.isFavorite ? Colors.amber : Theme.of(context).colorScheme.primary,
      border: Border.all(
        color: card.isFavorite ? Colors.amber : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        width: card.isFavorite ? 2.0 : 0.5,
      ),
    );
  }

  Widget _buildTextIcon(BuildContext context, String initials) {
    final theme = Theme.of(context);

    return Container(
      width: 40,
      height: 40,
      decoration: _buildIconDecoration(
        context,
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.labelSmall!.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

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

  String? _getFirstUrlDomain() {
    for (var field in card.rows) {
      if (field.type == BlastAttributeType.typeURL) {
        try {
          final uri = Uri.parse(field.value);

          return uri.host;
        } catch (e) {
          // Ignore parsing errors
        }
      }
    }
    return null;
  }
}
