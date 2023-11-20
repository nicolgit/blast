import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/eula_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


@RoutePage()
class EulaView extends StatefulWidget {
  const EulaView({super.key});

  @override
  State<StatefulWidget> createState() => _EulaViewState();
}

class _EulaViewState extends State<EulaView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EulaViewModel(context),
      child: Consumer<EulaViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

   Widget _buildScaffold(BuildContext context, EulaViewModel vm) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Text('EULA'),
          const Text(' '),
          const Text(
              'lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua '),
          TextButton(
            onPressed: () {
              vm.acceptEula();
            },
            child: const Text('accept and go back to splash screen'),
          ),
          TextButton(
            onPressed: () {
              vm.denyEula();
            },
            child: const Text('I do not want to accept and use this app'),
          ),
          TextButton(
            onPressed: () => vm.testViewModel(),
            child: const Text('test button'),
          ),
          Text(vm.testText())
        ],
      )),
    );
  }
}
