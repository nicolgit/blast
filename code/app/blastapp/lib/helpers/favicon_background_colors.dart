import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Theme-aware canvases derived from straight (not premultiplied) RGBA pixels.
class FaviconBackgroundColors {
  const FaviconBackgroundColors({required this.light, required this.dark});

  final Color light;
  final Color dark;

  Color forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static FaviconBackgroundColors? fromPixels(
      Uint8List pixels, int width, int height) {
    if (width <= 0 || height <= 0 || pixels.length != width * height * 4) {
      throw ArgumentError('Expected width * height * 4 RGBA bytes.');
    }

    final counts = <int, int>{};
    final borderCounts = <int, int>{};
    var borderPixels = 0;
    var opaqueBorderPixels = 0;
    final borderWidth = math.max(1, math.min(width, height) ~/ 16);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final offset = (y * width + x) * 4;
        final alpha = pixels[offset + 3];
        final bucket = ((pixels[offset] >> 4) << 8) |
            ((pixels[offset + 1] >> 4) << 4) |
            (pixels[offset + 2] >> 4);
        if (alpha >= 32) {
          counts.update(bucket, (weight) => weight + alpha,
              ifAbsent: () => alpha);
        }
        if (x < borderWidth ||
            y < borderWidth ||
            x >= width - borderWidth ||
            y >= height - borderWidth) {
          borderPixels++;
          if (alpha >= 240) {
            opaqueBorderPixels++;
            borderCounts.update(bucket, (count) => count + 1,
                ifAbsent: () => 1);
          }
        }
      }
    }
    if (counts.isEmpty) {
      return null;
    }

    Color bucketColor(int bucket) => Color.fromARGB(
        255,
        ((bucket >> 8) & 15) * 17,
        ((bucket >> 4) & 15) * 17,
        (bucket & 15) * 17);

    if (opaqueBorderPixels >= borderPixels * 0.9) {
      final border =
          borderCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);
      if (border.value >= opaqueBorderPixels * 0.75) {
        final canvas = bucketColor(border.key);
        return FaviconBackgroundColors(light: canvas, dark: canvas);
      }
    }

    final dominant =
        counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final brand = HSLColor.fromColor(bucketColor(dominant.key));
    final saturation = brand.saturation * 0.45;
    final candidates = [
      brand.withSaturation(saturation).withLightness(0.94).toColor(),
      brand.withSaturation(saturation).withLightness(0.12).toColor(),
      const Color(0xFFF5F5F5),
      const Color(0xFF171717),
    ];

    double score(Color background) {
      final luminance = background.computeLuminance();
      var total = 0.0;
      var weight = 0.0;
      for (var offset = 0; offset < pixels.length; offset += 4) {
        final alpha = pixels[offset + 3];
        if (alpha < 32) {
          continue;
        }
        final opacity = alpha / 255;
        final visibleColor = Color.alphaBlend(
            Color.fromARGB(
                alpha, pixels[offset], pixels[offset + 1], pixels[offset + 2]),
            background);
        final visibleLuminance = visibleColor.computeLuminance();
        final contrast = (math.max(luminance, visibleLuminance) + 0.05) /
            (math.min(luminance, visibleLuminance) + 0.05);
        // Cap large ratios so a bright region cannot hide low-contrast details.
        total += math.min(contrast, 7) * opacity;
        if (contrast < 3) {
          total -= (3 - contrast) * opacity;
        }
        weight += opacity;
      }
      return total / weight;
    }

    final scores = candidates.map(score).toList();
    var best = 0;
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > scores[best]) {
        best = i;
      }
    }

    Color choose(int preferred) {
      // Keep the brand tint and theme preference when contrast is comparable.
      if (scores[preferred] >= scores[best] * 0.9 ||
          (scores[preferred] >= 3 &&
              scores[preferred] >= scores[best] * 0.75)) {
        return candidates[preferred];
      }
      final alternate = 1 - preferred;
      if (scores[alternate] >= scores[best] * 0.9) {
        return candidates[alternate];
      }
      return candidates[best];
    }

    return FaviconBackgroundColors(light: choose(0), dark: choose(1));
  }
}
