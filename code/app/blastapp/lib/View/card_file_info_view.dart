import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_file_info_viewmodel.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class CardFileInfoView extends StatefulWidget {
  const CardFileInfoView({super.key});

  @override
  State<CardFileInfoView> createState() => _CardFileInfoViewState();
}

class _CardFileInfoViewState extends State<CardFileInfoView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardFileInfoViewModel(context),
      child: Consumer<CardFileInfoViewModel>(
        builder: (context, viewmodel, child) =>
            _buildScaffold(context, viewmodel),
      ),
    );
  }

  late BlastWidgetFactory _widgetFactory;

  Widget _buildScaffold(BuildContext context, CardFileInfoViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);

    return Scaffold(
        backgroundColor: _widgetFactory.viewBackgroundColor(),
        body: 
          SingleChildScrollView(
            child: 
        Center(
            child: Column(children: [
          AppBar(
            title: const Text("Card File Info: Recovery Key"),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Quit',
                onPressed: () {
                  vm.closeCommand();
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Text("Recovery Key", style: _widgetFactory.textTheme.titleMedium),
              const SizedBox(height: 24),
              SelectableText(vm.getRecoveryKey(),
                  style: _widgetFactory.textTheme.titleLarge,
                  textAlign: TextAlign.center),
              IconButton(
                onPressed: () {
                  vm.copyToClipboard();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Recovery key copied to clipboard!"),
                  ));
                },
                icon: Icon(Icons.copy,
                    color: _widgetFactory.theme.colorScheme.tertiary),
                tooltip: 'copy to clipboard',
              ),
              FilledButton(
                onPressed: () {
                  vm.copyToClipboard();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Recovery key copied to clipboard!"),
                  ));},
                child: const Text('copy to clipboard'),
              ),
              const SizedBox(height: 24),
              Text(
                  "This recovery key allows anyone who possesses it to access this encrypted file. It can be used as an alternative to the password if the password is forgotten.",
                  style: _widgetFactory.textTheme.titleSmall),
              const SizedBox(height: 12),
              Text(
                  "You can print this master key and store it in a safe place, separate from your computer and devices. This will serve as a physical backup that you can refer to if you are locked out of your encrypted file.",
                  style: _widgetFactory.textTheme.titleSmall),
              const SizedBox(height: 12),
              Text(
                  "This master key is equivalent to your password, and it changes each time you change your encrypted file's master password. Remember to back it up each time you change your master password.",
                  style: _widgetFactory.textTheme.titleSmall),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => vm.closeCommand(),
                child: const Text('continue'),
              )
            ]),
          ),
        ]))));
  }
}
