import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/field_viewmodel.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';

@RoutePage()
class FieldView extends StatefulWidget {
  const FieldView({super.key, required this.value});
  final String value;

  @override
  State<StatefulWidget> createState() => _FieldViewState();
}

class _FieldViewState extends State<FieldView> {
  @override
  Widget build(BuildContext context) {
    final field = widget.value; // this is the card passed in from the CardsBrowserView

    return ChangeNotifierProvider(
      create: (context) => FieldViewModel(context, field),
      child: Consumer<FieldViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;
  late TextTheme _textTheme;

  Widget _buildScaffold(BuildContext context, FieldViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);

    return Container( color: _theme.colorScheme.surface, child: SafeArea( child: Scaffold(
        backgroundColor: _theme.colorScheme.surface,
        body: Center(
            child: Column(children: [
          AppBar(
            title: Text(vm.currentField),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Quit',
                onPressed: () {
                  vm.closeCommand();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder(
              future: vm.getCurrentQrCodeViewStyle(),
              builder: (context, qrCodeStyle) {
                return Theme(
                    data: ThemeData.light(),
                    child: SegmentedButton<QrCodeViewStyle>(
                        segments: const <ButtonSegment<QrCodeViewStyle>>[
                          ButtonSegment<QrCodeViewStyle>(
                              value: QrCodeViewStyle.text, label: Text('text'), icon: Icon(Icons.text_fields)),
                          ButtonSegment<QrCodeViewStyle>(
                              value: QrCodeViewStyle.qrcode, label: Text('qrcode'), icon: Icon(Icons.qr_code)),
                          ButtonSegment<QrCodeViewStyle>(
                              value: QrCodeViewStyle.barcode, label: Text('bar'), icon: Icon(Icons.barcode_reader)),
                        ],
                        selected: <QrCodeViewStyle>{
                          qrCodeStyle.data!,
                        },
                        onSelectionChanged: (Set<QrCodeViewStyle> newSelection) {
                          vm.setCurrentQrCodeViewStyle(newSelection.first);
                        }));
              }),
          const SizedBox(height: 12),
          FutureBuilder(
              future: vm.getCurrentQrCodeViewStyle(),
              builder: (context, qrCodeStyle) {
                Widget displayWidget;

                switch (qrCodeStyle.data!) {
                  case QrCodeViewStyle.text:
                    displayWidget = Text(vm.currentField,
                        style: const TextStyle(fontSize: 96),
                        textAlign: TextAlign.center,
                        maxLines: 99,
                        overflow: TextOverflow.ellipsis);
                    break;
                  case QrCodeViewStyle.barcode:
                    displayWidget = Padding(
                        padding: const EdgeInsets.all(6),
                        child: BarcodeWidget(
                          barcode: Barcode.code128(), // Barcode type and settings
                          data: vm.currentField,
                          width: 600,
                          height: 200,
                          style: const TextStyle(fontSize: 24),
                        ));
                    break;
                  case QrCodeViewStyle.qrcode:
                  default:
                    displayWidget = Expanded(
                        child: Align(
                            alignment: Alignment.center,
                            child: AspectRatio(
                                aspectRatio: 1.0,
                                child: QrImageView(
                                  data: vm.currentField,
                                  version: QrVersions.auto,
                                  embeddedImage: const AssetImage('assets/general/app-icon.png'),
                                  size: 1000.0,
                                ))));
                    break;
                }

                return displayWidget;
              }),
        ])))));
  }
}
