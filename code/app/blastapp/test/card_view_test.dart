import 'package:auto_route/auto_route.dart';
import 'package:blastapp/View/field_edit_view.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: CardRoute.page),
        AutoRoute(page: FieldEditRoute.page),
      ];
}

void main() {
  final cases = [
    ('+Password', 'password', '', BlastAttributeType.typePassword),
    ('+Title', 'title', 'title', BlastAttributeType.typeHeader),
    ('+URL', 'URL', '', BlastAttributeType.typeURL),
    ('+Value', 'attribute', '', BlastAttributeType.typeString),
  ];

  for (final (button, name, value, type) in cases) {
    testWidgets('$button opens the editor with the expected defaults',
        (tester) async {
      final card = BlastCard()..title = 'Test card';
      final router = _TestRouter();
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router.config(
          deepLinkBuilder: (_) =>
              DeepLink([CardRoute(card: card, openInEditMode: true)]),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(button));
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();

      final editor = tester.widget<FieldEditView>(find.byType(FieldEditView));
      expect(editor.attribute.name, name);
      expect(editor.attribute.value, value);
      expect(editor.attribute.type, type);
      expect(card.rows, isEmpty);

      router.pop(false);
      await tester.pumpAndSettle();
      expect(card.rows, isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    });
  }
}
