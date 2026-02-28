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
                                  color: _theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: SingleChildScrollView(
                                  child: SelectableText(
                                    vm.scannedValue!,
                                    style: _theme.textTheme.bodyLarge?.copyWith(
                                      color: _theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 16),
                                  FilledButton.icon(
                                    onPressed: () => _showAddCardDialog(context, vm),
                                    icon: const Icon(Icons.add_card, size: 18),
                                    label: const Text('Add this card'),
                                  ),
                                ],
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

  Future<void> _showAddCardDialog(BuildContext context, ScannerViewModel vm) async {
    final cardNameController = TextEditingController();
    final cardholderNameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Fidelity Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNameController,
                style: TextStyle(
                  color: _theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Card Name',
                  hintText: 'e.g. Store Loyalty Card',
                  labelStyle: TextStyle(
                    color: _theme.colorScheme.onSurface,
                  ),
                  hintStyle: TextStyle(
                    color: _theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cardholderNameController,
                style: TextStyle(
                  color: _theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'e.g. John Doe',
                  labelStyle: TextStyle(
                    color: _theme.colorScheme.onSurface,
                  ),
                  hintStyle: TextStyle(
                    color: _theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final cardName = cardNameController.text.trim();
                final cardholderName = cardholderNameController.text.trim();

                if (cardName.isEmpty || cardholderName.isEmpty) {
                  await showDialog<void>(
                    context: dialogContext,
                    builder: (warningDialogContext) => AlertDialog(
                      title: Text(
                        'Missing required fields',
                        style: TextStyle(
                          color: _theme.colorScheme.onSurface,
                        ),
                      ),
                      content: Text(
                        'Card name and card holder name must not be empty.',
                        style: TextStyle(
                          color: _theme.colorScheme.onSurface,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(warningDialogContext).pop(),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: _theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    final cardName = cardNameController.text.trim();
    final cardholderName = cardholderNameController.text.trim();

    if (result == true) {
      vm.addThisCard(
        cardName,
        cardholderName,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cardNameController.dispose();
      cardholderNameController.dispose();
    });
  }
}
