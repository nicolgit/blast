import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:blastapp/helpers/icon_lookup_helper.dart';
import 'package:blastapp/helpers/favicon_background_colors.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:flutter/material.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class BlastCardIcon extends StatelessWidget {
  static final Map<String, Future<_FaviconData?>> _faviconCache = {};

  const BlastCardIcon({
    super.key,
    required this.card,
    required this.size,
    this.transparentBackground = false,
    this.initialsColor,
  });

  final BlastCard card;
  final double size;
  final bool transparentBackground;
  final Color? initialsColor;

  static Future<Color?> getBackgroundColor(BlastCard card,
      {Brightness brightness = Brightness.light}) {
    final iconSlug = IconLookupHelper.getIconSlug(card);
    if (iconSlug != null) {
      return IconLookupHelper.getBrandColor(iconSlug);
    }

    final domain = _getFirstUrlDomain(card);
    if (domain == null) {
      return Future.value();
    }

    return _faviconCache
        .putIfAbsent(domain, () => _fetchFaviconData(domain))
        .then(
            (favicon) => favicon?.backgroundColors?.forBrightness(brightness));
  }

  @override
  Widget build(BuildContext context) {
    final iconSlug = IconLookupHelper.getIconSlug(card);
    if (iconSlug != null) {
      return _buildSvgIcon(context, iconSlug);
    }

    final String? urlDomain = _getFirstUrlDomain(card);
    if (urlDomain != null) {
      return _buildFavicon(context, urlDomain);
    }
    return _buildTextIcon(context, _generateInitials(card.title));
  }

  BoxDecoration _buildIconDecoration(BuildContext context,
      {Color? backgroundColor}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: backgroundColor ??
          (card.isFavorite
              ? Colors.amber
              : Theme.of(context).colorScheme.primary),
      border: Border.all(
        color: card.isFavorite
            ? Colors.amber
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        width: card.isFavorite ? 2.0 : 0.5,
      ),
    );
  }

  Widget _buildTextIcon(
    BuildContext context,
    String initials, {
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: transparentBackground
          ? null
          : _buildIconDecoration(context, backgroundColor: backgroundColor),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: Text(
            initials,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall!.copyWith(
              fontSize: size * 0.29,
              color: foregroundColor ??
                  initialsColor ??
                  theme.colorScheme.onPrimary,
            ),
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

  Widget _buildSvgIcon(BuildContext context, String iconSlug) {
    final theme = Theme.of(context);
    final BrandInfo brandInfo = BrandInfo('', iconSlug);

    return FutureBuilder<Color?>(
      future: IconLookupHelper.getBrandColor(iconSlug),
      builder: (context, colorSnapshot) {
        final brandColor = colorSnapshot.data;
        final useLightForeground = brandColor == null
            ? theme.brightness != Brightness.dark && !card.isFavorite
            : ThemeData.estimateBrightnessForColor(brandColor) ==
                Brightness.dark;
        final foregroundColor =
            useLightForeground ? Colors.white : Colors.black;
        final iconUrl = useLightForeground ? brandInfo.url : brandInfo.urlDark;

        return Container(
          width: size,
          height: size,
          decoration: transparentBackground
              ? null
              : _buildIconDecoration(
                  context,
                  backgroundColor: brandColor,
                ),
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

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    // Fallback to text icon when SVG fails to load
                    return _buildTextIcon(
                      context,
                      _generateInitials(card.title),
                      backgroundColor: brandColor,
                      foregroundColor: foregroundColor,
                    );
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
      },
    );
  }

  Widget _buildFavicon(BuildContext context, String domain) {
    return FutureBuilder<_FaviconData?>(
      future:
          _faviconCache.putIfAbsent(domain, () => _fetchFaviconData(domain)),
      builder: (context, snapshot) {
        final favicon = snapshot.data;
        if (favicon == null) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: size,
              height: size,
              child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          return _buildTextIcon(context, _generateInitials(card.title));
        }

        return Container(
          width: size,
          height: size,
          decoration: transparentBackground
              ? null
              : _buildIconDecoration(
                  context,
                  backgroundColor: favicon.backgroundColors
                      ?.forBrightness(Theme.of(context).brightness),
                ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.all(size * 0.15),
              child: Image.memory(
                favicon.bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<_FaviconData?> _fetchFaviconData(String domain) async {
    try {
      final uri =
          Uri.parse('https://www.google.com/s2/favicons?sz=256&domain=$domain');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        return null;
      }

      final bytes = response.bodyBytes;
      final backgroundColors = await _calculateBackgroundColors(bytes);
      return _FaviconData(bytes, backgroundColors);
    } catch (_) {
      return null;
    }
  }

  static Future<FaviconBackgroundColors?> _calculateBackgroundColors(
      Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes,
        targetWidth: 32, targetHeight: 32);
    try {
      final frame = await codec.getNextFrame();
      try {
        final byteData = await frame.image
            .toByteData(format: ui.ImageByteFormat.rawStraightRgba);
        if (byteData == null) {
          return null;
        }
        return FaviconBackgroundColors.fromPixels(
            byteData.buffer
                .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
            frame.image.width,
            frame.image.height);
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
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

  static String? _getFirstUrlDomain(BlastCard card) {
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

class _FaviconData {
  const _FaviconData(this.bytes, this.backgroundColors);

  final Uint8List bytes;
  final FaviconBackgroundColors? backgroundColors;
}
