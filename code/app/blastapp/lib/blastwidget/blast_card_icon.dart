import 'package:blastapp/helpers/icon_lookup_helper.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:flutter/material.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class BlastCardIcon extends StatelessWidget {
  const BlastCardIcon({super.key, required this.card, required this.size});

  final BlastCard card;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconSlug = _getIconSlug();
    if (iconSlug != null) {
      return _buildSvgIcon(context, iconSlug);
    }

    final String? urlDomain = _getFirstUrlDomain();
    if (urlDomain != null) {
      String iconUriString = "https://www.google.com/s2/favicons?sz=256&domain=$urlDomain";
      Uri iconUri = Uri.parse(iconUriString);

      return Container(
        width: size,
        height: size,
        decoration: _buildIconDecoration(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ColoredBox(
            color: Colors.white,
            child: Image.network(
              iconUri.toString(),
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to circular text icon when image fails to load
                return _buildTextIcon(context, _generateInitials(card.title));
              },
            ),
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
        color: card.isFavorite ? Colors.amber : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        width: card.isFavorite ? 2.0 : 0.5,
      ),
    );
  }

  Widget _buildTextIcon(BuildContext context, String initials) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
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

  String? _getIconSlug() {
    for (var field in card.rows) {
      if ((field.type == BlastAttributeType.typeString) &&
          field.name.toLowerCase() == 'icon' &&
          field.value.isNotEmpty) {
        return field.value;
      }
    }
    return null;
  }

  Widget _buildSvgIcon(BuildContext context, String iconSlug) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark || card.isFavorite;
    final BrandInfo brandInfo = BrandInfo('', iconSlug);
    final iconUrl = isDark ? brandInfo.urlDark : brandInfo.url;

    return Container(
      width: size,
      height: size,
      decoration: _buildIconDecoration(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(size * 0.15),
          child: FutureBuilder<String?>(
            future: _fetchSvgData(iconUrl),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SizedBox(
                    width: size * 0.3,
                    height: size * 0.3,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                // Fallback to text icon when SVG fails to load
                return _buildTextIcon(context, _generateInitials(card.title));
              }

              return SvgPicture.string(
                snapshot.data!,
                fit: BoxFit.contain,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<String?> _fetchSvgData(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Timeout'),
          );

      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      // Silently handle network errors
      return null;
    }
  }

  String? _getFirstUrlDomain() {
    for (var field in card.rows) {
      if (field.type == BlastAttributeType.typeURL) {
        try {
          var source = field.value.toLowerCase();

          if (!source.startsWith('http://') && !source.startsWith('https://')) {
            source = 'https://$source';
          }

          var uri = Uri.parse(source);
          return uri.host;
        } catch (e) {
          // Ignore parsing errors
        }
      }
    }
    return null;
  }
}
