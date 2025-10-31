import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/password_generator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class PasswordGeneratorView extends StatefulWidget {
  const PasswordGeneratorView({super.key});

  @override
  State<PasswordGeneratorView> createState() => _PasswordGeneratorViewState();
}

class _PasswordGeneratorViewState extends State<PasswordGeneratorView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PasswordGeneratorViewModel(context),
      child: Consumer<PasswordGeneratorViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;

  Widget _buildScaffold(BuildContext context, PasswordGeneratorViewModel vm) {
    _theme = Theme.of(context);

    return Container(
        color: _theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _theme.colorScheme.surface,
                body: Center(
                  child: Column(children: [
                    AppBar(
                      title: const Text("Password Generator"),
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
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Center(
                          child: Text(
                            'Password Generator - Coming Soon',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ))));
  }
}
