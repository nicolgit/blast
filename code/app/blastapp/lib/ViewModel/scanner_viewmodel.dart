import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerViewModel extends ChangeNotifier {
  final BuildContext context;
  final CurrentFileService fileService = CurrentFileService();

  String? _scannedValue;
  String? get scannedValue => _scannedValue;

  String? _scannedFormat;
  String? get scannedFormat => _scannedFormat;

  late final MobileScannerController scannerController;

  ScannerViewModel(this.context) {
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  void onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null && barcode.rawValue != _scannedValue) {
        _scannedValue = barcode.rawValue;
        _scannedFormat = barcode.format.name;
        notifyListeners();
      }
    }
  }

  void clearScannedValue() {
    _scannedValue = null;
    _scannedFormat = null;
    notifyListeners();
  }

  void addThisCard(String cardName, String cardholderName) {
    if (_scannedValue == null) return;

    var card = BlastCard.createFidelityCard();
    card.title = cardName;

    for (var row in card.rows) {
      if (row.name == 'Cardholder Name') {
        row.value = cardholderName;
      } else if (row.name == 'Card Number') {
        row.value = _scannedValue!;
      }
    }

    fileService.currentFileDocument!.cards.insert(0, card);
    fileService.currentFileDocument!.isChanged = true;

    closeCommand();
  }

  void closeCommand() {
    if (!context.mounted) return;
    scannerController.dispose();
    context.router.maybePop();
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }
}
