import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerViewModel extends ChangeNotifier {
  final BuildContext context;

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
