import 'package:blastapp/choose_file_view.dart';
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChooseFileView()),
              );
            },
            child: const Text(
                'Fake Cloud - for testing purposes only'),
          ),
        ],
      )),
    );
  }
}