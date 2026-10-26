import 'package:blastapp/blastwidget/blast_password_complexity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final entry in {
    '': 'Empty',
    'a': 'Weak',
    'abcd1234': 'Medium',
    'Abcd1234!xyz5678@': 'Strong',
  }.entries) {
    testWidgets('shows "${entry.value}" for "${entry.key}"', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlastPasswordComplexity(
            currentPassword: entry.key,
            showLabel: true,
          ),
        ),
      ));

      expect(find.text(entry.value), findsOneWidget);
      if (entry.key.isEmpty) {
        expect(find.text('Weak'), findsNothing);
      }
    });
  }

  testWidgets('hides the label by default for an empty password', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: BlastPasswordComplexity(currentPassword: ''),
      ),
    ));

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });
}
