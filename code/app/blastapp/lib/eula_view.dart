import 'package:flutter/material.dart';

class EulaView extends StatelessWidget {
  const EulaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Text('EULA'),
          const Text(
              'lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua '),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('accept and go back to splash screen'),
          ),
          const Text('Hello World!'),
        ],
      )),
    );
  }
}
