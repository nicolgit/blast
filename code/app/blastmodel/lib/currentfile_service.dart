import 'dart:math';
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
  static const String loremText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

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

  /*
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
  */

  Uint8List encodeFile(String jsonDocument, String password) {
    // Generate salt
    final random = Random.secure();
    final salt = Uint8List(8);
    for (int i = 0; i < salt.length; i++) {
      salt[i] = random.nextInt(256);
    }

    // Generate Key
    int iterations = 1000;
    var pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, iterations, 16));

    Uint8List key = pbkdf2.process(Uint8List.fromList(password.codeUnits));

    // Generate IV
    Uint8List iv = Uint8List(16);
    for (int i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(256);
    }

    // Create AES cipher
    final cipher = BlockCipher("AES/CBC");
    final ivParams = ParametersWithIV(KeyParameter(key), iv);
    cipher.init(true, ivParams);

    // Create a memory buffer
    var buffer = BytesBuilder();

    // Write file type identifier
    buffer.add(utf8.encode(versionCurrent));

    // Write the crypt_iv in the file
    buffer.add(salt);
    buffer.addByte(iterations);
    buffer.add(ivParams.iv);

    var sourceBytes = utf8.encode(loremText);
    var destinationEncryptedBytes = Uint8List(sourceBytes.length);
    cipher.processBlock(sourceBytes, 0, destinationEncryptedBytes, 0);
    buffer.add(destinationEncryptedBytes);

    return buffer.toBytes();
  }
}
