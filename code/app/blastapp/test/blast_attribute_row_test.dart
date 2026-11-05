import 'package:blastapp/blastwidget/blast_attribute_row.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final type in BlastAttributeType.values) {
    testWidgets('Copy visibility follows row width for ${type.name}', (
      tester,
    ) async {
      final copied = <String>[];
      final attribute = BlastAttribute.withParams('Name', 'Value', type);
      var passwordVisible = false;

      Future<void> pumpRow(double width, {bool editMode = false}) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: BlastAttributeRow(
                    attribute: attribute,
                    index: 0,
                    toggleShowPassword: (_) =>
                        passwordVisible = !passwordVisible,
                    isPasswordRowVisible: (_) => passwordVisible,
                    copyToClipboard: copied.add,
                    showFieldView: (_) {},
                    openUrl: (_) {},
                    editMode: editMode,
                    editField: (_) async {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(BlastAttributeRow)).width, width);
        expect(tester.takeException(), isNull);
      }

      for (final width in [299.0, 300.0, 301.0, 299.0]) {
        await pumpRow(width);
        final copyButton = find.byTooltip('copy to clipboard');
        final hasCopy = type != BlastAttributeType.typeHeader && width >= 300;
        expect(copyButton, hasCopy ? findsOneWidget : findsNothing);
        if (hasCopy) {
          await tester.tap(copyButton);
          await tester.pump(const Duration(milliseconds: 350));
          expect(copied.last, 'Value');
        }
        if (type == BlastAttributeType.typePassword) {
          expect(find.byIcon(Icons.visibility_off), findsOneWidget);
          await tester.tap(find.byIcon(Icons.visibility_off));
          await tester.pump(const Duration(milliseconds: 350));
          expect(passwordVisible, isTrue);
          passwordVisible = false;
        }
      }

      if (type != BlastAttributeType.typeHeader) {
        copied.clear();
        final title = find.text(
          type == BlastAttributeType.typePassword ? '***********' : 'Value',
        );
        await tester.tap(title);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(title);
        await tester.pumpAndSettle();
        expect(copied, ['Value']);
      }

      for (final width in [299.0, 300.0]) {
        await pumpRow(width, editMode: true);
        expect(find.byTooltip('copy to clipboard'), findsNothing);
        expect(find.byTooltip('edit field'), findsOneWidget);
      }
    });
  }
}
