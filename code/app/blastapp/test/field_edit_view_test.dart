import 'package:blastapp/View/field_edit_view.dart';
import 'package:blastapp/ViewModel/field_edit_viewmodel.dart';
import 'package:blastapp/blast_theme.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openEditor(WidgetTester tester, BlastAttribute attribute, List<bool?> results) async {
  await tester.pumpWidget(MaterialApp(
    theme: BlastTheme.dark,
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            results.add(await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => FieldEditView(attribute: attribute)),
            ));
          },
          child: const Text('Open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  final launches = <MethodCall>[];
  var launchResult = true;
  var platformError = false;

  setUp(() {
    launches.clear();
    launchResult = true;
    platformError = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      launches.add(call);
      if (platformError) {
        throw PlatformException(code: 'failed', message: 'Browser unavailable');
      }
      return launchResult;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  for (final type in [BlastAttributeType.typeString, BlastAttributeType.typeURL]) {
    for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.numpadEnter]) {
      testWidgets('${type.name}: ${key.keyLabel} focuses value then saves both fields', (tester) async {
        final attribute = BlastAttribute.withParams('Name', 'old', type);
        final results = <bool?>[];
        await openEditor(tester, attribute, results);
        final fields = find.byType(TextField);
        expect(fields, findsNWidgets(2));
        expect(tester.widget<TextField>(fields.at(1)).focusNode!.hasFocus, isTrue);
        for (final input in tester.widgetList<EditableText>(find.byType(EditableText))) {
          expect(input.style.color, BlastTheme.dark.colorScheme.onSurface);
        }
        expect(find.text('Test'), type == BlastAttributeType.typeURL ? findsOneWidget : findsNothing);
        await tester.enterText(fields.at(1), 'https://example.com');
        await tester.enterText(fields.at(0), 'Website');
        await tester.sendKeyEvent(key);
        await tester.pump();
        expect(results, isEmpty);
        expect(attribute.name, 'Name');
        expect(attribute.value, 'old');
        expect(tester.widget<TextField>(fields.at(1)).focusNode!.hasFocus, isTrue);
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
        expect(results, [true]);
        expect(attribute.name, 'Website');
        expect(attribute.value, 'https://example.com');
      });
    }
  }

  testWidgets('Test opens the draft URL externally without saving; Cancel discards edits', (tester) async {
    final attribute = BlastAttribute.withParams('Website', 'https://old.example', BlastAttributeType.typeURL);
    final results = <bool?>[];
    await openEditor(tester, attribute, results);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'New website');
    await tester.enterText(fields.at(1), ' example.com/path?q=test ');
    await tester.tap(find.text('Test'));
    await tester.pumpAndSettle();
    expect(launches, hasLength(1));
    expect(launches.single.method, 'launch');
    final arguments = launches.single.arguments as Map;
    expect(arguments['url'], 'https://example.com/path?q=test');
    expect(arguments['useWebView'], isFalse);
    expect(arguments['useSafariVC'], isFalse);
    expect(results, isEmpty);
    expect(attribute.value, 'https://old.example');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(results, [false]);
    expect(attribute.name, 'Website');
    expect(attribute.value, 'https://old.example');
  });

  testWidgets('Enter on the Test button tests without saving', (tester) async {
    final attribute = BlastAttribute.withParams('Website', 'https://example.com', BlastAttributeType.typeURL);
    final results = <bool?>[];
    await openEditor(tester, attribute, results);
    Focus.of(tester.element(find.text('Test'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(launches, hasLength(1));
    expect(results, isEmpty);
  });

  for (final value in ['', 'https://', 'not a URL']) {
    testWidgets('Test reports invalid URL "$value" without launching', (tester) async {
      final attribute = BlastAttribute.withParams('Website', value, BlastAttributeType.typeURL);
      await openEditor(tester, attribute, <bool?>[]);
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();
      expect(find.text(value.isEmpty ? 'Enter a URL to test' : 'Enter a valid URL to test'), findsOneWidget);
      expect(launches, isEmpty);
    });
  }

  for (final throwsError in [false, true]) {
    testWidgets('Test reports browser ${throwsError ? 'exception' : 'failure'}', (tester) async {
      launchResult = false;
      platformError = throwsError;
      final attribute = BlastAttribute.withParams('Website', 'https://example.com', BlastAttributeType.typeURL);
      final results = <bool?>[];
      await openEditor(tester, attribute, results);
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();
      expect(find.text(throwsError ? 'Could not open the URL: Browser unavailable' : 'Could not open the URL'),
          findsOneWidget);
      expect(results, isEmpty);
    });
  }

  test('headers still save only the name; passwords remain unsupported', () {
    final header = BlastAttribute.withParams('Header', 'Value', BlastAttributeType.typeHeader);
    final headerModel = FieldEditViewModel(header);
    headerModel.save('New header', name: 'Ignored');
    expect(header.name, 'New header');
    expect(header.value, 'Value');
    expect(headerModel.canTestUrl, isFalse);
    headerModel.dispose();
    final password = BlastAttribute.withParams('Password', 'Value', BlastAttributeType.typePassword);
    final passwordModel = FieldEditViewModel(password);
    expect(passwordModel.isSupported, isFalse);
    expect(() => passwordModel.save('Changed', name: 'Changed'), throwsUnsupportedError);
    passwordModel.dispose();
  });
}
