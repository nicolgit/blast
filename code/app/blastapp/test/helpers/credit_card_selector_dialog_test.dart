import 'package:blastapp/blast_theme.dart';
import 'package:blastapp/helpers/credit_card_selector_dialog.dart';
import 'package:blastapp/helpers/icon_lookup_helper.dart';
import 'package:blastapp/helpers/populate_card_helper.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final icon = await const SvgStringLoader(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '<path d="M0 0h24v24H0z"/></svg>',
    ).loadBytes(null);
    for (final slug in [
      'visa',
      'mastercard',
      'americanexpress',
      'jcb',
      'discover',
      'bankofamerica',
    ]) {
      await svg.cache.putIfAbsent(
        SvgNetworkLoader('https://cdn.simpleicons.org/$slug').cacheKey(null),
        () async => icon,
      );
    }
  });

  tearDownAll(() => svg.cache.clear());

  Future<void> openSelector(
    WidgetTester tester,
    BlastCard card,
    ValueChanged<bool> onResult, {
    bool populate = false,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final selected =
                  await CreditCardSelectorDialog.selectIcon(context, card);
              onResult(selected);
              if (selected && populate && context.mounted) {
                await PopulateCardHelper.populateCard(context, card);
              }
            },
            child: const Text('Add credit card'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Add credit card'));
    await tester.pumpAndSettle();
  }

  Future<void> selectBrand(WidgetTester tester, String label) async {
    await tester.tap(find.byType(DropdownButton<BrandInfo>));
    await tester.pumpAndSettle();
    final item = find.text(label).last;
    await tester.ensureVisible(item);
    await tester.tap(item);
    await tester.pumpAndSettle();
  }

  double contrast(Color first, Color second) {
    final a = first.computeLuminance();
    final b = second.computeLuminance();
    return a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
  }

  for (final theme
      in {'light': BlastTheme.light, 'dark': BlastTheme.dark}.entries) {
    testWidgets('dropdown has readable colors in ${theme.key} mode',
        (tester) async {
      await openSelector(tester, BlastCard.createCreditCard(), (_) {},
          theme: theme.value);
      final colors = theme.value.colorScheme;
      final dropdown = tester.widget<DropdownButton<BrandInfo>>(
          find.byType(DropdownButton<BrandInfo>));
      expect(dropdown.dropdownColor, colors.surface);
      expect(dropdown.iconEnabledColor, colors.onSurfaceVariant);
      final hint = tester.widget<Text>(find.text('Select a credit card'));
      expect(hint.style?.color, colors.onSurfaceVariant);
      expect(contrast(hint.style!.color!, colors.surfaceContainerHigh),
          greaterThanOrEqualTo(4.5));
      expect(contrast(dropdown.iconEnabledColor!, colors.surfaceContainerHigh),
          greaterThanOrEqualTo(3));

      await tester.tap(find.byType(DropdownButton<BrandInfo>));
      await tester.pumpAndSettle();
      final visa = find.text('Visa').last;
      final text = tester.widget<Text>(visa);
      expect(contrast(text.style!.color!, dropdown.dropdownColor!),
          greaterThanOrEqualTo(4.5));
      for (final icon
          in tester.widgetList<SvgPicture>(find.byType(SvgPicture))) {
        expect(icon.colorFilter,
            ColorFilter.mode(colors.onSurface, BlendMode.srcIn));
      }
      await tester.tap(visa);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text('Visa')).style?.color,
          colors.onSurface);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('dropdown lists all brands and requires a selection before Next',
      (tester) async {
    await openSelector(tester, BlastCard.createCreditCard(), (_) {});

    expect(find.text('Credit card selector'), findsOneWidget);
    expect(find.byType(DropdownButton<BrandInfo>), findsOneWidget);
    expect(find.text('Select a credit card'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Next'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byType(DropdownButton<BrandInfo>));
    await tester.pumpAndSettle();
    for (final label in [
      'Visa',
      'Mastercard',
      'American Express',
      'JCB',
      'Discover',
      'Bank of America',
      '(my card is not listed)',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(SvgPicture), findsNWidgets(6));
    await tester.tap(find.text('Visa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('Cancel does not change the card or continue', (tester) async {
    final card = BlastCard.createCreditCard()..icon = 'simpleicons:visa';
    bool? result;
    await openSelector(tester, card, (value) => result = value, populate: true);
    await selectBrand(tester, 'Mastercard');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(card.icon, 'simpleicons:visa');
    expect(find.text('Card Name'), findsNothing);
  });

  for (final brand in {
    'Visa': 'visa',
    'Mastercard': 'mastercard',
    'American Express': 'americanexpress',
    'JCB': 'jcb',
    'Discover': 'discover',
    'Bank of America': 'bankofamerica',
  }.entries) {
    testWidgets('Next confirms ${brand.key} and continues to Card Name',
        (tester) async {
      final card = BlastCard.createCreditCard();
      bool? result;
      await openSelector(tester, card, (value) => result = value,
          populate: true);
      await selectBrand(tester, brand.key);
      expect(card.icon, isNull);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(card.icon, 'simpleicons:${brand.value}');
      expect(find.text('Card Name'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('unlisted card continues without an icon', (tester) async {
    final card = BlastCard.createCreditCard()..icon = 'simpleicons:visa';
    bool? result;
    await openSelector(tester, card, (value) => result = value, populate: true);
    await selectBrand(tester, '(my card is not listed)');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(card.icon, isNull);
    expect(find.text('Card Name'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('keeps the selected icon through naming and attribute entry',
      (tester) async {
    final card = BlastCard.createCreditCard();
    await openSelector(tester, card, (_) {}, populate: true);
    await selectBrand(tester, 'Visa');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'My credit card');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    const values = ['Test User', '4111111111111111', '12/30', '123'];
    for (var index = 0; index < values.length; index++) {
      expect(find.text(card.rows[index].name), findsOneWidget);
      await tester.enterText(find.byType(TextField), values[index]);
      await tester.tap(find.text(index == values.length - 1 ? 'OK' : 'Next'));
      await tester.pumpAndSettle();
    }

    expect(find.byType(AlertDialog), findsNothing);
    expect(card.title, 'My credit card');
    expect(card.rows.map((row) => row.value), values);
    expect(card.icon, 'simpleicons:visa');
    expect(BlastCard.fromJson(card.toJson()).icon, 'simpleicons:visa');
  });
}
