import 'package:flutter/material.dart';
import 'package:viewmodelpackage/viewmodelpackage.dart';

void main() {
  // test package references
  final viewModelCalculator = ViewModelCalculator();
  viewModelCalculator.addOne(12);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
