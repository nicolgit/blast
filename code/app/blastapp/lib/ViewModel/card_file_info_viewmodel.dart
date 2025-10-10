import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CardFileInfoViewModel extends ChangeNotifier {
  final CurrentFileService fileService = CurrentFileService();
  final BuildContext context;

  List<bool> showPasswordRow = [];

  CardFileInfoViewModel(this.context);

  void closeCommand() {
    context.router.maybePop();
  }

  void copyToClipboard() {
    final key = fileService.key;
    final hexKey = _toReadableString(key);
    Clipboard.setData(ClipboardData(text: hexKey));
  }

  Future<void> printRecoveryKey() async {
    final recoveryKey = getRecoveryKey();
    final fileName = fileService.currentFileInfo?.fileName ?? 'Unknown File';
    final lastModified = fileService.currentFileInfo?.lastModified ?? 'Unknown Date';

    final theme = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.nunitoExtraLight(),
      bold: await PdfGoogleFonts.nunitoExtraBold(),
      italic: await PdfGoogleFonts.nunitoExtraLightItalic(),
      boldItalic: await PdfGoogleFonts.nunitoBoldItalic(),
    );

    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BLAST File Recovery Key',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('File: $fileName'),
              pw.SizedBox(height: 10),
              pw.Text('Last Modified: $lastModified'),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Text(
                  recoveryKey,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Important Information:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'This recovery key allows anyone who possesses it to access this encrypted file.',
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'It can be used as an alternative to the password if the password is forgotten.',
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Store this key in a safe place, separate from your computer and devices.',
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'This key changes each time you change your master password.',
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Remember to back it up each time you change your master password.',
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  String getRecoveryKey() {
    final key = fileService.key;

    return _toReadableString(key);
  }

  String _toReadableString(Uint8List data) {
    // convert Uint8List to hex string each 1 byte to 2 characters hex
    final hexKey = data.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

    // add a - every 8 characters
    var hexKeyWithDashes = hexKey.replaceAllMapped(RegExp(r".{8}"), (match) => '${match.group(0)} - ');

    // remove last char '-' from string
    hexKeyWithDashes = hexKeyWithDashes.substring(0, hexKeyWithDashes.length - 1);

    // to uppercase
    hexKeyWithDashes = hexKeyWithDashes.toUpperCase();

    return hexKeyWithDashes;
  }
}
