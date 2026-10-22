import 'dart:async';

import 'package:blastapp/View/password_generator_view.dart';
import 'package:blastapp/ViewModel/password_generator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

void main() {
  Future<PasswordGeneratorViewModel> openGenerator(
    WidgetTester tester, {
    bool allowCopyToClipboard = true,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: PasswordGeneratorView(
        allowCopyToClipboard: allowCopyToClipboard,
        returnsValue: true,
      ),
    ));
    await tester.pump();
    return tester.element(find.text('Stop')).read<PasswordGeneratorViewModel>();
  }

  testWidgets('Start resumes periodic generation after Stop', (tester) async {
    final vm = await openGenerator(tester);
    vm.setGeneratorType(GeneratorTypes.guid);
    await tester.pump();

    for (var cycle = 0; cycle < 2; cycle++) {
      await tester.tap(find.text('Stop'));
      await tester.pump();
      expect(vm.status, Status.terminated);
      final stoppedPassword = vm.password;

      await tester.pump(const Duration(seconds: 1));
      expect(vm.password, stoppedPassword);

      await tester.tap(find.text('Start'));
      await tester.pump();
      expect(vm.status, Status.running);
      expect(find.text('Stop'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      expect(vm.password, isNot(stoppedPassword));
      final firstPassword = vm.password;
      await tester.pump(const Duration(milliseconds: 500));
      expect(vm.password, isNot(firstPassword));
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Copy to Clipboard receives initial focus', (tester) async {
    final vm = await openGenerator(tester);
    final copyContext = tester.element(find.text('Copy to Clipboard'));
    expect(Focus.of(copyContext).hasPrimaryFocus, isTrue);

    vm.setGeneratorType(GeneratorTypes.guid);
    await tester.pump(const Duration(milliseconds: 500));
    expect(Focus.of(copyContext).hasPrimaryFocus, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Copy to Clipboard can remain hidden', (tester) async {
    await openGenerator(tester, allowCopyToClipboard: false);
    expect(find.text('Copy to Clipboard'), findsNothing);
    expect(find.text('Use Password'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final succeeds in [true, false]) {
    testWidgets(
        'Wiki request ${succeeds ? 'success' : 'failure'} after disposal is ignored',
        (tester) async {
      final response = Completer<http.Response>();
      var requestCount = 0;

      await http.runWithClient(() async {
        final vm = await openGenerator(tester);
        var notifications = 0;
        vm.addListener(() => notifications++);

        await tester.pump(const Duration(milliseconds: 500));
        expect(requestCount, 1);

        await tester.pumpWidget(const SizedBox.shrink());
        response.complete(http.Response(
          succeeds
              ? '{"results":{"bindings":[{"lemmaLabel":{"value":"Example"}}]}}'
              : 'Service unavailable',
          succeeds ? 200 : 503,
        ));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(vm.password, isEmpty);
        expect(vm.wikiError, isNull);
        expect(notifications, 0);
        expect(requestCount, 1);
        expect(tester.takeException(), isNull);
      },
          () => MockClient((request) {
                requestCount++;
                return response.future;
              }));
    });
  }
}
