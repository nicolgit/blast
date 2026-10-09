import 'package:blastapp/View/field_edit_view.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('either visibility button toggles both password fields', (tester) async {
    final attribute = BlastAttribute.withParams('Password', 'secret', BlastAttributeType.typePassword);
    await tester.pumpWidget(MaterialApp(home: FieldEditView(attribute: attribute)));
    await tester.pumpAndSettle();

    void expectPasswordFields(bool obscured) {
      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields, hasLength(3));
      expect(fields[0].obscureText, isFalse);
      for (final field in fields.skip(1)) {
        expect(field.obscureText, obscured);
        expect(field.controller!.text, 'secret');
      }
      expect(attribute.value, 'secret');
    }

    expectPasswordFields(true);
    expect(find.byTooltip('Show password'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Show password').first);
    await tester.pump();
    expectPasswordFields(false);
    expect(find.byTooltip('Hide password'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Hide password').last);
    await tester.pump();
    expectPasswordFields(true);
    await tester.tap(find.byTooltip('Show password').last);
    await tester.pump();
    expectPasswordFields(false);
    await tester.tap(find.byTooltip('Hide password').first);
    await tester.pump();
    expectPasswordFields(true);
  });

  for (final type in [
    BlastAttributeType.typeString,
    BlastAttributeType.typeURL,
    BlastAttributeType.typeHeader,
  ]) {
    testWidgets('${type.name} does not show password visibility buttons', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: FieldEditView(attribute: BlastAttribute.withParams('Name', 'Value', type)),
      ));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Show password'), findsNothing);
      expect(find.byTooltip('Hide password'), findsNothing);
      for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
        expect(field.obscureText, isFalse);
      }
    });
  }
}
