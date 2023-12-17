import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/blastfile.dart';

class CurrentFileService {
  static final CurrentFileService _instance = CurrentFileService._internal();

  static const String versionCurrent = "BLAST01";
  static const String version01 = versionCurrent;

  Cloud? cloud;
  BlastFile? currentFileInfo;
  Uint8List? currentFileEncrypted;
  String? currentFileJsonString;
  BlastDocument? currentFileDocument;
  String? password;

  factory CurrentFileService() {
    return _instance;
  }

  CurrentFileService._internal() {
    reset();
  }

  void reset() {
    cloud = null;
    currentFileInfo = null;
    currentFileEncrypted = null;
    currentFileJsonString = null;
    currentFileDocument = null;
  }

  void setCloud(Cloud cloud) {
    this.cloud = cloud;
    //TODO reset all other values because we are changing cloud
  }

  // ENCRYPT/DECRYPT helpers
  final PaddedBlockCipher _cipher = PaddedBlockCipher("AES/CBC/PKCS7");
  Uint8List _encryptString(String stringToEncrypt, Uint8List iv) {
    Uint8List utf = Uint8List.fromList(utf8.encode(stringToEncrypt));
    _cipher.init(true, ParametersWithIV(KeyParameter(utf), iv));
    return _cipher.process(utf);
  }

  String _decryptBytes(Uint8List bytesToDecrypt, Uint8List iv) {
    _cipher.init(false, ParametersWithIV(KeyParameter(bytesToDecrypt), iv));
    Uint8List decrypted = _cipher.process(bytesToDecrypt);
    return utf8.decode(decrypted);
  }
}
