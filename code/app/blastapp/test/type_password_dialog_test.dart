import 'package:blastapp/ViewModel/type_password_viewmodel.dart';
import 'package:blastapp/blast_theme.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Wrong password dialog stays light in ${brightness.name} mode',
      (tester) async {
        final service = CurrentFileService();
        final originalIterations = service.iterations;
        addTearDown(() {
          service.reset();
          service.iterations = originalIterations;
        });
        service.iterations = 1;
        service.newPassword('correct-test-password');
        service.currentFileEncrypted = service.encodeFile('{}');
        final viewModel = TypePasswordViewModel()
          ..password = 'wrong-test-password';
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: brightness == Brightness.dark
                ? BlastTheme.dark
                : BlastTheme.light,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  viewModel.context = context;
                  return const Text('Password screen');
                },
              ),
            ),
          ),
        );
        late Future<bool> result;
        await tester.runAsync(() async {
          result = viewModel.checkPassword(false);
          await Future.doWhile(() async {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            return viewModel.errorMessage.isEmpty;
          }).timeout(const Duration(seconds: 5));
        });
        await tester.pumpAndSettle();

        expect(find.text('Error'), findsOneWidget);
        expect(find.text('wrong password - please try again'), findsOneWidget);
        final dialog = find.byType(AlertDialog);
        final dialogTheme = Theme.of(tester.element(dialog));
        expect(dialogTheme.brightness, Brightness.light);
        expect(dialogTheme.colorScheme, BlastTheme.light.colorScheme);
        final material = tester.widget<Material>(
          find.descendant(of: dialog, matching: find.byType(Material)).first,
        );
        expect(
          ThemeData.estimateBrightnessForColor(material.color!),
          Brightness.light,
        );
        expect(
          Theme.of(tester.element(find.text('Password screen'))).brightness,
          brightness,
        );
        expect(Focus.of(tester.element(find.text('OK'))).hasFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(await tester.runAsync(() => result), isFalse);
        expect(find.byType(AlertDialog), findsNothing);
        expect(await viewModel.isCheckingPassword(), isFalse);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
