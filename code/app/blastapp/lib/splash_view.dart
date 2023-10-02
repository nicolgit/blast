import 'package:blastapp/choose_storage_view.dart';
import 'package:blastapp/eula_view.dart';
import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Text('I am the splash screen!'),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EulaView()),
              );
            },
            child: const Text('show EULA'),
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
          const Text('Hello World!'),
        ],
      )),
    );
  }
}
