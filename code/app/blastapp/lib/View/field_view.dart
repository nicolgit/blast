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

  Widget _buildScaffold(BuildContext context, FieldViewModel vm) {
    _theme = Theme.of(context);

    return Container(
        color: Colors.white,
        child: SafeArea(
            child: Scaffold(
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
                          qrCodeStyle.data == null ? QrCodeViewStyle.barcode : qrCodeStyle.data!,
                        },
                        onSelectionChanged: (Set<QrCodeViewStyle> newSelection) {
                          vm.setCurrentQrCodeViewStyle(newSelection.first);
                        }));
              }),
          const SizedBox(height: 12),
          Flexible(
              fit: FlexFit.loose,
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                      child: FutureBuilder(
                          future: vm.getCurrentQrCodeViewStyle(),
                          builder: (context, qrCodeStyle) {
                            Widget displayWidget;

                            final qr = qrCodeStyle.data != null ? qrCodeStyle.data! : QrCodeViewStyle.qrcode;

                            switch (qr) {
                              case QrCodeViewStyle.text:
                                displayWidget = Text(vm.currentField,
                                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 99,
                                    overflow: TextOverflow.ellipsis);
                                break;
                              case QrCodeViewStyle.barcode:
                                displayWidget = ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 250),
                                    child: BarcodeWidget(
                                      barcode: Barcode.code128(), // Barcode type and settings
                                      data: vm.currentField,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ));
                                break;
                              case QrCodeViewStyle.qrcode:
                                displayWidget = AspectRatio(
                                    aspectRatio: 1.0,
                                    child: QrImageView(
                                      data: vm.currentField,
                                      version: QrVersions.auto,
                                      embeddedImage: const AssetImage('assets/general/app-icon.png'),
                                      size: 1000.0,
                                    ));
                                break;
                            }

                            return displayWidget;
                          })))),
        ])))));
  }
}
