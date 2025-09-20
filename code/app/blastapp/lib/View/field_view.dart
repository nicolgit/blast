import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/field_viewmodel.dart';
import 'package:blastapp/blast_theme.dart';
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

late ThemeData _theme;

class _FieldViewState extends State<FieldView> {
  int _selectedCharacterIndex = -1; // Track which character was tapped

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

  Widget _buildScaffold(BuildContext context, FieldViewModel vm) {
    _theme = BlastTheme.light;

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
                    data: ThemeData.light().copyWith(
                      segmentedButtonTheme: SegmentedButtonThemeData(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return _theme.colorScheme.primaryContainer;
                              }
                              return null; // Use default for unselected
                            },
                          ),
                        ),
                      ),
                    ),
                    child: SegmentedButton<QrCodeViewStyle>(
                        segments: const <ButtonSegment<QrCodeViewStyle>>[
                          ButtonSegment<QrCodeViewStyle>(
                              value: QrCodeViewStyle.text, label: Text('text'), icon: Icon(Icons.text_fields)),
                          ButtonSegment<QrCodeViewStyle>(
                              value: QrCodeViewStyle.code, label: Text('code'), icon: Icon(Icons.code_sharp)),
                          ButtonSegment<QrCodeViewStyle>(
                              value: QrCodeViewStyle.qrcode, label: Text('qr'), icon: Icon(Icons.qr_code)),
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
                                displayWidget = _buildText(vm.currentField);
                                break;
                              case QrCodeViewStyle.code:
                                displayWidget = _buildCharacterGrid(vm.currentField);
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
                                displayWidget = Container(
                                  margin: const EdgeInsets.all(64),
                                  child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: QrImageView(
                                        data: vm.currentField,
                                        version: QrVersions.auto,
                                        embeddedImage: const AssetImage('assets/general/app-icon.png'),
                                        size: 1000.0,
                                      )),
                                );
                                break;
                            }

                            return displayWidget;
                          })))),
        ])))));
  }

  Color _getCharacterColor(String char) {
    bool isLetter = RegExp(r'\p{L}', unicode: true).hasMatch(char);
    bool isNumber = RegExp(r'[0-9]').hasMatch(char);

    if (isLetter) {
      return Colors.black;
    } else if (isNumber) {
      return _theme.colorScheme.error;
    } else {
      return Colors.green;
    }
  }

  Widget _buildCharacterGrid(String text) {
    const double charSize = 48.0;
    const double charSpacing = 4.0;
    const double horizontalPadding = 48.0; // Total horizontal padding from parent widgets

    // Calculate maxCharsPerRow based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - horizontalPadding;
    final charWithSpacing = charSize + charSpacing;
    final maxCharsPerRow = (availableWidth / charWithSpacing).floor().clamp(1, 30);

    List<Widget> rows = [];
    int index = 0;

    while (index < text.length) {
      List<Widget> rowChildren = [];
      int charsInRow = 0;

      // Build characters for current row
      while (index < text.length && charsInRow < maxCharsPerRow) {
        String char = text[index];
        final currentIndex = index; // Capture current index for closure

        rowChildren.add(
          GestureDetector(
            onTap: () {
              setState(() {
                // If tapping on the last selected character, remove highlight
                if (_selectedCharacterIndex == currentIndex) {
                  _selectedCharacterIndex = -1;
                } else {
                  _selectedCharacterIndex = currentIndex;
                }
              });
            },
            child: Container(
              width: charSize,
              height: charSize,
              margin: const EdgeInsets.all(charSpacing / 2),
              decoration: BoxDecoration(
                color: _selectedCharacterIndex >= 0 && currentIndex <= _selectedCharacterIndex
                    ? _theme.colorScheme.primaryContainer
                    : Colors.transparent,
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  char,
                  style: TextStyle(
                    fontSize: charSize * 0.6, // Calculate font size as 60% of char box size
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: _getCharacterColor(char),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );

        index++;
        charsInRow++;
      }
      // Create row
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: rowChildren,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _buildText(String text) {
    List<TextSpan> spans = [];

    for (int i = 0; i < text.length; i++) {
      String char = text[i];

      spans.add(
        TextSpan(
          text: char,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: _getCharacterColor(char),
          ),
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }
}
