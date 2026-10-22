import 'package:auto_route/auto_route.dart';
import 'package:blastapp/View/field_edit_view.dart';
import 'package:blastapp/blast_router.dart';
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
    bool creditCard = true,
  }) async {
    final home = Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            if (!creditCard) {
              onResult(await PopulateCardHelper.populateCard(context, card));
              return;
            }
            final selected =
                await CreditCardSelectorDialog.selectIcon(context, card);
            onResult(selected);
            if (selected && populate && context.mounted) {
              await PopulateCardHelper.populateCreditCard(context, card);
            }
          },
          child: const Text('Add credit card'),
        ),
      ),
    );
    if (creditCard) {
      await tester.pumpWidget(MaterialApp(theme: theme, home: home));
    } else {
      final router = RootStackRouter.build(routes: [
        NamedRouteDef(
          name: 'TestHome',
          path: '/',
          builder: (context, data) => home,
        ),
        AutoRoute(page: FieldEditRoute.page),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(
        theme: theme,
        routerConfig: router.config(),
      ));
      await tester.pumpAndSettle();
    }
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
    testWidgets('Next confirms ${brand.key} and continues to Cardholder Name',
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
      expect(find.text('Card Name'), findsNothing);
      expect(find.text('Cardholder Name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  Nicola  ');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(card.title, "Nicola's ${brand.key}");
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
    expect(find.text('Card Name'), findsNothing);
    expect(find.text('Cardholder Name'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Nicola');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(card.title, "Nicola's credit card");
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'keeps the selected icon and generated title through attribute entry',
      (tester) async {
    final card = BlastCard.createCreditCard();
    await openSelector(tester, card, (_) {}, populate: true);
    await selectBrand(tester, 'Visa');
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
    expect(card.title, "Test User's Visa");
    expect(card.rows.map((row) => row.value), values);
    expect(card.icon, 'simpleicons:visa');
    expect(BlastCard.fromJson(card.toJson()).icon, 'simpleicons:visa');
    expect(BlastCard.fromJson(card.toJson()).title, "Test User's Visa");
  });

  testWidgets('updates the title when the cardholder is changed using Prev',
      (tester) async {
    final card = BlastCard.createCreditCard();
    await openSelector(tester, card, (_) {}, populate: true);
    await selectBrand(tester, 'Visa');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nicola');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(card.title, "Nicola's Visa");

    await tester.tap(find.text('Prev'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Nicola');
    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(card.title, "Alex's Visa");
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('an empty cardholder keeps the card type without a possessive',
      (tester) async {
    final card = BlastCard.createCreditCard();
    await openSelector(tester, card, (_) {}, populate: true);
    await selectBrand(tester, '(my card is not listed)');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(card.title, 'credit card');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  for (final factory in {
    'web': BlastCard.createWebCard,
    'fidelity': BlastCard.createFidelityCard,
    'Wi-Fi': BlastCard.createWifiCredentialsCard,
  }.entries) {
    testWidgets('${factory.key} cards use the field editor for the name',
        (tester) async {
      final card = factory.value();
      await openSelector(tester, card, (_) {}, creditCard: false);
      expect(find.byType(FieldEditView), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Card Name'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  Custom name  ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(card.title, 'Custom name');
      expect(find.text(card.rows.first.name), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('${factory.key} name editor rejects empty names',
        (tester) async {
      final card = factory.value();
      await openSelector(tester, card, (_) {}, creditCard: false);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(FieldEditView), findsOneWidget);
      expect(find.text('Card name cannot be empty'), findsOneWidget);
      expect(card.title, '');
      await tester.enterText(find.byType(TextField), 'Valid name');
      await tester.pump();
      expect(find.text('Card name cannot be empty'), findsNothing);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(card.title, 'Valid name');
      expect(find.text(card.rows.first.name), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('${factory.key} name editor cancels without changing the card',
        (tester) async {
      final card = factory.value()..title = 'Original name';
      bool? confirmed;
      await openSelector(tester, card, (value) => confirmed = value,
          creditCard: false);
      await tester.enterText(find.byType(TextField), 'Discarded name');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
      expect(card.title, 'Original name');
      expect(find.byType(FieldEditView), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });
  }
}
