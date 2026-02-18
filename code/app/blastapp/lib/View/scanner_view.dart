import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/scanner_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScannerViewModel(context),
      child: Consumer<ScannerViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;

  Widget _buildScaffold(BuildContext context, ScannerViewModel vm) {
    _theme = Theme.of(context);

    return Container(
      color: _theme.colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: _theme.colorScheme.surface,
          body: Column(
            children: [
              AppBar(
                title: const Text("Scan Barcode/QRCode"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () {
                      vm.closeCommand();
                    },
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: MobileScanner(
                            controller: vm.scannerController,
                            onDetect: vm.onBarcodeDetected,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (vm.scannedValue == null) ...[
                              Icon(
                                Icons.qr_code_scanner,
                                size: 40,
                                color: _theme.colorScheme.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Point the camera at a barcode or QR code',
                                style: _theme.textTheme.bodyMedium?.copyWith(
                                  color: _theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else ...[
                              Text(
                                vm.scannedFormat ?? 'Detected',
                                style: _theme.textTheme.labelSmall?.copyWith(
                                  color: _theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: SingleChildScrollView(
                                  child: SelectableText(
                                    vm.scannedValue!,
                                    style: _theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: vm.clearScannedValue,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Scan again'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
