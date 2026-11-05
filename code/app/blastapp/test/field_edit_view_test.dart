import 'package:auto_route/auto_route.dart';
import 'package:blastapp/View/field_edit_view.dart';
import 'package:blastapp/ViewModel/scanner_viewmodel.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastapp/blastwidget/blast_card_icon.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class _TestRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: FieldEditRoute.page),
    AutoRoute(
      page: PageInfo(
        ScannerRoute.name,
        builder: (data) {
          final args = data.argsAs<ScannerRouteArgs>();
          return Scaffold(
            body: Column(
              children: [
                Text('returnsValue: ${args.returnsValue}'),
                TextButton(
                  onPressed: () => maybePop('https://example.com/scanned'),
                  child: const Text('Return scan'),
                ),
                TextButton(
                  onPressed: () => maybePop(),
                  child: const Text('Cancel scan'),
                ),
              ],
            ),
          );
        },
      ),
    ),
  ];
}

void main() {
  for (final type in BlastAttributeType.values) {
    testWidgets(
      'Scan visibility for ${type.name}',
      (tester) => http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: FieldEditView(
              attribute: BlastAttribute.withParams('Name', '', type),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final canScan =
            type == BlastAttributeType.typeString ||
            type == BlastAttributeType.typeURL;
        expect(
          find.byTooltip('Scan barcode or QR code'),
          canScan ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Test'),
          type == BlastAttributeType.typeURL ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(BlastCardIcon),
          type == BlastAttributeType.typeURL ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Confirm value'),
          type == BlastAttributeType.typePassword
              ? findsOneWidget
              : findsNothing,
        );
        expect(find.text('Confirm password'), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      }, () => MockClient((_) async => http.Response('', 404))),
    );
  }

  testWidgets('URL icon is centered, 48x48 and follows unsaved URL edits', (
    tester,
  ) async {
    final attribute = BlastAttribute.withParams(
      'Website',
      'https://initial.example/path',
      BlastAttributeType.typeURL,
    );
    final requestedDomains = <String?>[];
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          MaterialApp(home: FieldEditView(attribute: attribute)),
        );
        await tester.pumpAndSettle();

        final iconFinder = find.byType(BlastCardIcon);
        final nameFinder = find.byType(TextField).at(0);
        final valueFinder = find.byType(TextField).at(1);
        final iconRect = tester.getRect(iconFinder);
        final nameRect = tester.getRect(nameFinder);
        expect(iconRect.size, const Size(48, 48));
        expect(iconRect.center.dx, closeTo(nameRect.center.dx, 0.01));
        expect(iconRect.bottom, lessThan(nameRect.top));
        expect(requestedDomains, ['initial.example']);

        for (final url in [
          'https://updated.example/login',
          '',
          'plain.example',
        ]) {
          await tester.enterText(valueFinder, url);
          await tester.pumpAndSettle();
          final icon = tester.widget<BlastCardIcon>(iconFinder);
          if (url.isEmpty) {
            expect(icon.card.rows, isEmpty);
          } else {
            expect(icon.card.rows.single.type, BlastAttributeType.typeURL);
            expect(icon.card.rows.single.value, url);
          }
          expect(tester.getSize(iconFinder), const Size(48, 48));
          expect(attribute.value, 'https://initial.example/path');
        }
        expect(requestedDomains, [
          'initial.example',
          'updated.example',
          'plain.example',
        ]);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      () => MockClient((request) async {
        requestedDomains.add(request.url.queryParameters['domain']);
        return http.Response('', 404);
      }),
    );
  });

  for (final cancel in [false, true]) {
    testWidgets(
      'Scanning ${cancel ? 'cancels' : 'updates Value without saving'}',
      (tester) => http.runWithClient(() async {
        final original =
            'https://${cancel ? 'cancel' : 'scan'}.example/original';
        final attribute = BlastAttribute.withParams(
          'Website',
          original,
          BlastAttributeType.typeURL,
        );
        final router = _TestRouter();
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router.config(
              deepLinkBuilder: (_) =>
                  DeepLink([FieldEditRoute(attribute: attribute)]),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Scan barcode or QR code'));
        await tester.pumpAndSettle();
        expect(find.text('returnsValue: true'), findsOneWidget);
        await tester.tap(find.text(cancel ? 'Cancel scan' : 'Return scan'));
        await tester.pumpAndSettle();

        final valueField = tester.widget<TextField>(
          find.byType(TextField).at(1),
        );
        expect(
          valueField.controller!.text,
          cancel ? original : 'https://example.com/scanned',
        );
        expect(
          tester
              .widget<BlastCardIcon>(find.byType(BlastCardIcon))
              .card
              .rows
              .single
              .value,
          cancel ? original : 'https://example.com/scanned',
        );
        expect(attribute.value, original);
        expect(find.text('Test'), findsOneWidget);

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(
          attribute.value,
          cancel ? original : 'https://example.com/scanned',
        );
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
      }, () => MockClient((_) async => http.Response('', 404))),
    );
  }

  testWidgets(
    'Scanner accepts QR codes and barcodes without format restrictions',
    (tester) async {
      late ScannerViewModel scanner;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              scanner = ScannerViewModel(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(scanner.scannerController.formats, isEmpty);
      scanner.onBarcodeDetected(
        BarcodeCapture(
          barcodes: [
            Barcode(rawValue: 'QR content', format: BarcodeFormat.qrCode),
          ],
        ),
      );
      expect(scanner.scannedValue, 'QR content');
      expect(scanner.scannedFormat, BarcodeFormat.qrCode.name);
      scanner.onBarcodeDetected(
        BarcodeCapture(
          barcodes: [
            Barcode(rawValue: '1234567890128', format: BarcodeFormat.ean13),
          ],
        ),
      );
      expect(scanner.scannedValue, '1234567890128');
      expect(scanner.scannedFormat, BarcodeFormat.ean13.name);
      scanner.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
