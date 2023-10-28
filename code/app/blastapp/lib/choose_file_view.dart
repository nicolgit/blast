import 'package:flutter/material.dart';
import 'package:kt_dart/kt.dart';

class ChooseFileView extends StatelessWidget {
  const ChooseFileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Text('choose to create a file'),
          TextButton(
            onPressed: () {
              //Navigator.pop(context);
            },
            child: const Text('new file'),
          ),
          const Text('or to open an existing one'),
/*          ListView(
            padding: const EdgeInsets.all(6),
            children: <Widget>[
              ListTile( title: Text("Battery Full"), leading: Icon(Icons.battery_full), trailing: Icon(Icons.star)),
              ListTile( title: Text("Anchor"), leading: Icon(Icons.anchor), trailing: Icon(Icons.star)),
              ListTile( title: Text("Alarm"), leading: Icon(Icons.access_alarm), trailing: Icon(Icons.star)),
              ListTile( title: Text("Ballot"), leading: Icon(Icons.ballot), trailing: Icon(Icons.star))
            ],
          ),
          */
        ],
      )),
    );
  }
}