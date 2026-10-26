import 'dart:async';

import 'package:blastapp/View/change_icon_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _brands = List.generate(
  120,
  (index) => '| `Brand $index` | `brand$index` |',
).join('\n');

Color _brandColor(int index) => index.isEven ? const Color(0xFFFFE066) : const Color(0xFF112233);

http.Response _response(Uri url) {
  final brandIndex = int.tryParse(url.pathSegments.firstOrNull?.replaceFirst('brand', '') ?? '') ?? 0;
  final color = switch (url.pathSegments.lastOrNull) {
    'white' => 'FFFFFF',
    'black' => '000000',
    _ => brandIndex.isEven ? 'FFE066' : '112233',
  };
  return http.Response(
    url.host == 'raw.githubusercontent.com'
        ? _brands
        : '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="#$color">'
            '<rect width="24" height="24"/></svg>',
    200,
  );
}

void main() {
  testWidgets('Loading brands after closing the picker is safe', (tester) async {
    final response = Completer<http.Response>();
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: ChangeIconView()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      response.complete(_response(Uri.https('raw.githubusercontent.com')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }, () => MockClient((request) => response.future));
  });

  testWidgets('Current icons retain brand colors, contrast and selection across themes and sizes', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final scenario in [
      (icon: 'simpleicons:brand75', width: 1000.0, brightness: Brightness.light),
      (icon: 'brand75', width: 1400.0, brightness: Brightness.dark),
      (icon: 'simpleicons:brand0', width: 800.0, brightness: Brightness.light),
      (icon: 'simpleicons:brand119', width: 800.0, brightness: Brightness.dark),
    ]) {
      await tester.binding.setSurfaceSize(Size(scenario.width, 900));
      final iconRequests = <Uri>[];
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(brightness: scenario.brightness),
          home: ChangeIconView(currentIcon: scenario.icon),
        ));
        await tester.pumpAndSettle();

        final selected = find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.selected == true,
        );
        expect(selected, findsOneWidget);
        final selectedCard = find.descendant(of: selected, matching: find.byType(Card));
        final card = tester.widget<Card>(selectedCard);
        final index = int.parse(scenario.icon.split('brand').last);
        expect(card.color, _brandColor(index));
        expect(card.elevation, 6);
        expect((card.shape! as RoundedRectangleBorder).side.width, 3);
        expect((card.shape! as RoundedRectangleBorder).side.color, Colors.amber);
        expect(iconRequests,
            contains(Uri.parse('https://cdn.simpleicons.org/brand$index/${index.isEven ? 'black' : 'white'}')));
        for (final card in tester.widgetList<Card>(find.byType(Card))) {
          final label = find.descendant(of: find.byWidget(card), matching: find.byType(Text));
          final text = tester.widget<Text>(label);
          final brandIndex = int.parse(text.data!.split(' ').last);
          expect(card.color, _brandColor(brandIndex));
          expect(text.style!.color, brandIndex.isEven ? Colors.black : Colors.white);
        }
        expect(find.byIcon(Icons.check_circle), findsNothing);
        final viewport = tester.getRect(find.byType(GridView));
        final cardRect = tester.getRect(selectedCard);
        final iconRect = tester.getRect(find.descendant(of: selected, matching: find.byType(SvgPicture)));
        expect(iconRect.center.dx, closeTo(cardRect.center.dx, 0.01));
        expect(cardRect.top, greaterThanOrEqualTo(viewport.top));
        expect(cardRect.bottom, lessThanOrEqualTo(viewport.bottom));
        expect(tester.takeException(), isNull);

        await tester.enterText(find.byType(TextField), 'Brand 1');
        await tester.pumpAndSettle();
        expect(tester.widget<GridView>(find.byType(GridView)).semanticChildCount, 31);
        expect(find.text('Brand 75'), findsNothing);
        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();
        expect(tester.widget<GridView>(find.byType(GridView)).semanticChildCount, 120);
        await tester.pumpWidget(const SizedBox.shrink());
      },
          () => MockClient((request) async {
                iconRequests.add(request.url);
                return _response(request.url);
              }));
    }
  });

  for (final icon in [null, '', 'simpleicons:missing']) {
    testWidgets('Missing current icon ($icon) leaves the grid at the start', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await http.runWithClient(() async {
        await tester.pumpWidget(MaterialApp(home: ChangeIconView(currentIcon: icon)));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_circle), findsNothing);
        final scrollable = tester.state<ScrollableState>(
          find.descendant(of: find.byType(GridView), matching: find.byType(Scrollable)),
        );
        expect(scrollable.position.pixels, 0);
        expect(find.text('Brand 0'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }, () => MockClient((request) async => _response(request.url)));
    });
  }
}
