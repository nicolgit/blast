import 'package:blastapp/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:kt_dart/kt.dart';

class ChooseStorageView extends StatelessWidget {
  const ChooseStorageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Text('welcome! where do you want to store your data?'),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('local file system!'),
          ),
          TextButton(
            onPressed: () {
              throw NotImplementedException("OneDrive not implemented");
            },
            child: const Text('OneDrive'),
          ),
          TextButton(
            onPressed: () {
              throw NotImplementedException("Google Drive not implemented");
            },
            child: const Text('Google Drive'),
          ),
          TextButton(
            onPressed: () {
              throw NotImplementedException("Apple iCloud not implemented");
            },
            child: const Text('Apple iCloud'),
          ),
          TextButton(
            onPressed: () {
              throw NotImplementedException('Fake Cloud not implemented');
            },
            child: const Text(
                'Fake Cloud(TM) - for testing purposes only, do not use!'),
          ),
        ],
      )),
    );
  }
}
