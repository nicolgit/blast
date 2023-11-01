import 'package:blastapp/choose_storage_view.dart';
import 'package:blastapp/eula_view.dart';
import 'package:flutter/material.dart';
import 'package:blastviewmodel/splash_view_model.dart';
import 'package:provider/provider.dart';

/// REFERENCE MVVM ARCHITECTURE https://www.filledstacks.com/post/flutter-architecture-my-provider-implementation-guide/

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SplashViewModel(),
      child: Consumer<SplashViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      )
    );
  }

  Widget _buildScaffold(BuildContext context, SplashViewModel vm) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          
          const Text('Hello World!'),
          const Text('I am the splash screen!'),
          
          FutureBuilder<bool> ( 
            future: vm.eulaAccepted(),
            builder: (context, boolEulaAccepted) {
              return Visibility(
                visible: !(boolEulaAccepted.data ?? false),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EulaView()),
                    );
                  },
                  child: const Text('show EULA'),
                )
              );
            }
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChooseStorageView()),
              );
            },
            child: const Text('begin using app'),
          ),
        ],
      )),
    );
  }
}
