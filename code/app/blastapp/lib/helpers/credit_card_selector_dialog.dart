import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastapp/helpers/icon_lookup_helper.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreditCardSelectorDialog extends StatefulWidget {
  const CreditCardSelectorDialog({super.key});

  static const _brands = [
    BrandInfo('Visa', 'visa'),
    BrandInfo('Mastercard', 'mastercard'),
    BrandInfo('American Express', 'americanexpress'),
    BrandInfo('JCB', 'jcb'),
    BrandInfo('Discover', 'discover'),
    BrandInfo('Bank of America', 'bankofamerica'),
    BrandInfo('(my card is not listed)', ''),
  ];

  static Future<bool> selectIcon(BuildContext context, BlastCard card) async {
    final brand = await showDialog<BrandInfo>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CreditCardSelectorDialog(),
    );
    if (brand == null) return false;

    card.icon =
        brand.brandSlug.isEmpty ? null : 'simpleicons:${brand.brandSlug}';
    card.title = brand.brandSlug.isEmpty ? 'credit card' : brand.brandName;
    return true;
  }

  @override
  State<CreditCardSelectorDialog> createState() =>
      _CreditCardSelectorDialogState();
}

class _CreditCardSelectorDialogState extends State<CreditCardSelectorDialog> {
  BrandInfo? _selectedBrand;

  @override
  Widget build(BuildContext context) {
    final factory = BlastWidgetFactory(context);
    final colors = factory.theme.colorScheme;
    final onSurface = colors.onSurface;
    return AlertDialog(
      title: Text('Credit card selector', style: TextStyle(color: onSurface)),
      content: SizedBox(
        width: 360,
        child: DropdownButton<BrandInfo>(
          value: _selectedBrand,
          isExpanded: true,
          itemHeight: 56,
          dropdownColor: colors.surface,
          style: factory.textTheme.bodyLarge,
          iconEnabledColor: colors.onSurfaceVariant,
          underline: SizedBox(
            height: 1,
            child: ColoredBox(color: colors.outline),
          ),
          hint: Text(
            'Select a credit card',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          items: [
            for (final brand in CreditCardSelectorDialog._brands)
              DropdownMenuItem(
                value: brand,
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: brand.brandSlug.isEmpty
                          ? Icon(Icons.credit_card, color: onSurface)
                          : SvgPicture.network(
                              brand.brandColorUrl,
                              width: 32,
                              height: 32,
                              colorFilter:
                                  ColorFilter.mode(onSurface, BlendMode.srcIn),
                              placeholderBuilder: (_) =>
                                  const SizedBox(width: 32, height: 32),
                              errorBuilder: (_, error, stackTrace) => Tooltip(
                                message:
                                    'Unable to load ${brand.brandName} icon',
                                child: Icon(Icons.broken_image_outlined,
                                    color: onSurface),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        brand.brandName,
                        style: TextStyle(color: onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: (brand) => setState(() => _selectedBrand = brand),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selectedBrand == null
              ? null
              : () => Navigator.of(context).pop(_selectedBrand),
          child: const Text('Next'),
        ),
      ],
    );
  }
}
