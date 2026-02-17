import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/scanner_viewmodel.dart';
import 'package:flutter/material.dart';
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 100,
                        color: _theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Lorem ipsum dixit',
                        style: _theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scanner functionality will be implemented here',
                        style: _theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
