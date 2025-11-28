import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/change_icon_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChangeIconView extends StatefulWidget {
  const ChangeIconView({super.key});

  @override
  State<ChangeIconView> createState() => _ChangeIconViewState();
}

class _ChangeIconViewState extends State<ChangeIconView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChangeIconViewModel(context),
      child: Consumer<ChangeIconViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;

  Widget _buildScaffold(BuildContext context, ChangeIconViewModel vm) {
    _theme = Theme.of(context);

    return Container(
        color: _theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _theme.colorScheme.surface,
                body: Center(
                  child: Column(children: [
                    AppBar(
                      title: const Text("Change Icon"),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Close',
                          onPressed: () => vm.closeCommand(),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () => vm.selectIcon('hello'),
                          child: const Text('Hello'),
                        ),
                      ),
                    ),
                  ]),
                ))));
  }
}
