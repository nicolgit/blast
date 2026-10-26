import 'package:auto_route/auto_route.dart';
import 'package:blastapp/View/field_edit_view.dart';
import 'package:blastapp/ViewModel/scanner_viewmodel.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    testWidgets('Scan visibility for ${type.name}', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: FieldEditView(
          attribute: BlastAttribute.withParams('Name', 'Original', type),
        ),
      ));
      await tester.pumpAndSettle();

      final canScan = type == BlastAttributeType.typeString ||
          type == BlastAttributeType.typeURL;
      expect(find.byTooltip('Scan barcode or QR code'),
          canScan ? findsOneWidget : findsNothing);
      expect(find.text('Test'),
          type == BlastAttributeType.typeURL ? findsOneWidget : findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final cancel in [false, true]) {
    testWidgets(
        'Scanning ${cancel ? 'cancels' : 'updates Value without saving'}',
        (tester) async {
      final attribute = BlastAttribute.withParams(
        'Website',
        'Original',
        BlastAttributeType.typeURL,
      );
      final router = _TestRouter();
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router.config(
          deepLinkBuilder: (_) =>
              DeepLink([FieldEditRoute(attribute: attribute)]),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Scan barcode or QR code'));
      await tester.pumpAndSettle();
      expect(find.text('returnsValue: true'), findsOneWidget);
      await tester.tap(find.text(cancel ? 'Cancel scan' : 'Return scan'));
      await tester.pumpAndSettle();

      final valueField = tester.widget<TextField>(
        find.byType(TextField).at(1),
      );
      expect(valueField.controller!.text,
          cancel ? 'Original' : 'https://example.com/scanned');
      expect(attribute.value, 'Original');
      expect(find.text('Test'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
          attribute.value, cancel ? 'Original' : 'https://example.com/scanned');
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    });
  }

  testWidgets(
      'Scanner accepts QR codes and barcodes without format restrictions',
      (tester) async {
    late ScannerViewModel scanner;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        scanner = ScannerViewModel(context);
        return const SizedBox.shrink();
      }),
    ));

    expect(scanner.scannerController.formats, isEmpty);
    scanner.onBarcodeDetected(BarcodeCapture(barcodes: [
      Barcode(rawValue: 'QR content', format: BarcodeFormat.qrCode),
    ]));
    expect(scanner.scannedValue, 'QR content');
    expect(scanner.scannedFormat, BarcodeFormat.qrCode.name);
    scanner.onBarcodeDetected(BarcodeCapture(barcodes: [
      Barcode(rawValue: '1234567890128', format: BarcodeFormat.ean13),
    ]));
    expect(scanner.scannedValue, '1234567890128');
    expect(scanner.scannedFormat, BarcodeFormat.ean13.name);
    scanner.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
