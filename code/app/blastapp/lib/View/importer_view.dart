import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/importer_viewmodel.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ImporterView extends StatefulWidget {
  const ImporterView({super.key});

  @override
  State<StatefulWidget> createState() => _ImporterViewState();
}

class _ImporterViewState extends State<ImporterView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ImporterViewModel(context),
      child: Consumer<ImporterViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late BlastWidgetFactory _widgetFactory;
  late TextTheme _textTheme;

  Widget _buildScaffold(BuildContext context, ImporterViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);
    _textTheme = _widgetFactory.textTheme.apply(bodyColor: _widgetFactory.theme.colorScheme.onSurface);

    return Scaffold(
        backgroundColor: _widgetFactory.viewBackgroundColor(),
        body: Center(
            child: Column(children: [
          AppBar(
            title: const Text("importer"),
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
          Text("with this function you can import data into Blast extracted from another application",
              style: _textTheme.labelLarge),
          const SizedBox(height: 12),
          Text("choose from where you want to import your data", style: _textTheme.labelLarge),
          Padding(
              padding: const EdgeInsets.all(6.0),
              child: FilledButton(
                onPressed: () async {
                  try {
                    await vm.importBlastCommand();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Imported successfully " + vm.importedCount() + " items!")));

                    context.router.maybePop();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("unable to import selected file. error: $e"),
                    ));
                  }
                },
                child: const Text('Blast .json file'),
              )),
          Padding(
              padding: const EdgeInsets.all(6.0),
              child: FilledButton(
                onPressed: () async {
                  try {
                    await vm.importKeepassXMLCommand();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Imported successfully " + vm.importedCount() + " items!")));

                    context.router.maybePop();
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("unable to import selected file. error: $e"),
                    ));
                  }
                },
                child: const Text('KeePass XML (2.x) file'),
              )),
          Padding(
              padding: const EdgeInsets.all(6.0),
              child: FilledButton(
                onPressed: () async {
                  try {
                    await vm.importPwsafeXMLCommand();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Imported successfully " + vm.importedCount() + " items!")));

                    context.router.maybePop();
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("unable to import selected file. error: $e"),
                    ));
                  }
                },
                child: const Text('Password Safe XML file'),
              )),
          const Text("WARNING: Importing your data here will overwrite all the current file content."),
        ])));
  }
}
