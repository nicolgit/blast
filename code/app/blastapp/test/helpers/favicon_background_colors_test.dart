import 'dart:typed_data';

import 'package:blastapp/helpers/favicon_background_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uint8List image(Color Function(int x, int y) pixel) {
    final bytes = Uint8List(32 * 32 * 4);
    for (var y = 0; y < 32; y++) {
      for (var x = 0; x < 32; x++) {
        final argb = pixel(x, y).toARGB32();
        final offset = (y * 32 + x) * 4;
        bytes[offset] = (argb >> 16) & 255;
        bytes[offset + 1] = (argb >> 8) & 255;
        bytes[offset + 2] = argb & 255;
        bytes[offset + 3] = (argb >> 24) & 255;
      }
    }
    return bytes;
  }

  double contrast(Color a, Color b) {
    final first = a.computeLuminance();
    final second = b.computeLuminance();
    return first > second
        ? (first + 0.05) / (second + 0.05)
        : (second + 0.05) / (first + 0.05);
  }

  test('extends an opaque white border rather than the dominant red logo', () {
    final palette = FaviconBackgroundColors.fromPixels(
        image((x, y) => x < 2 || y < 2 || x >= 30 || y >= 30
            ? Colors.white
            : const Color(0xFFFF0000)),
        32,
        32)!;
    expect(palette.light, Colors.white);
    expect(palette.dark, Colors.white);
  });

  test('transparent red logo remains visible on both theme canvases', () {
    const red = Color(0xFFFF0000);
    final palette = FaviconBackgroundColors.fromPixels(
        image((x, y) =>
            x >= 8 && x < 24 && y >= 8 && y < 24 ? red : Colors.transparent),
        32,
        32)!;
    expect(contrast(red, palette.light), greaterThanOrEqualTo(3));
    expect(contrast(red, palette.dark), greaterThanOrEqualTo(3));
    expect(palette.light.computeLuminance(),
        greaterThan(palette.dark.computeLuminance()));
  });

  test('prefers readability over theme for white and black transparent logos',
      () {
    for (final logo in [Colors.white, Colors.black]) {
      final palette = FaviconBackgroundColors.fromPixels(
          image((x, y) =>
              x >= 8 && x < 24 && y >= 8 && y < 24 ? logo : Colors.transparent),
          32,
          32)!;
      expect(contrast(logo, palette.light), greaterThanOrEqualTo(7));
      expect(contrast(logo, palette.dark), greaterThanOrEqualTo(7));
    }
  });

  test('scores semitransparent pixels after compositing', () {
    const red = Color(0x80FF0000);
    final palette = FaviconBackgroundColors.fromPixels(
        image((x, y) =>
            x >= 8 && x < 24 && y >= 8 && y < 24 ? red : Colors.transparent),
        32,
        32)!;
    for (final canvas in [palette.light, palette.dark]) {
      final bestNeutralContrast = [
        const Color(0xFFF5F5F5),
        const Color(0xFF171717),
      ]
          .map((neutral) => contrast(Color.alphaBlend(red, neutral), neutral))
          .reduce((a, b) => a > b ? a : b);
      expect(contrast(Color.alphaBlend(red, canvas), canvas),
          greaterThanOrEqualTo(bestNeutralContrast * 0.9));
    }
  });

  test('ambiguous multicolored borders do not masquerade as a solid canvas',
      () {
    final palette = FaviconBackgroundColors.fromPixels(
        image((x, y) => x < 16 ? Colors.black : Colors.white), 32, 32)!;
    expect(palette.light, isNot(Colors.white));
    expect(palette.dark, isNot(Colors.black));
  });

  test('fully transparent pixels produce no palette', () {
    expect(
        FaviconBackgroundColors.fromPixels(
            image((x, y) => const Color(0x00FF0000)), 32, 32),
        isNull);
  });

  test('rejects malformed RGBA data', () {
    expect(() => FaviconBackgroundColors.fromPixels(Uint8List(3), 1, 1),
        throwsArgumentError);
  });
}
