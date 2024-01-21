import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:blastmodel/exceptions.dart';
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
    reset();
    this.cloud = cloud;
  }

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
    pbkdf2.init(Pbkdf2Parameters(salt, iterations, 32)); // 32 *8 = 256 bits key (AES256)
    Uint8List key = pbkdf2.process(Uint8List.fromList(password.codeUnits));

    // Generate IV
    Uint8List iv = Uint8List(16);
    for (int i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(256);
    }

    // Create AES cipher

    final cipher = PaddedBlockCipher("AES/CBC/PKCS7");
    final ivParams = ParametersWithIV(KeyParameter(key), iv);
    cipher.init(true, PaddedBlockCipherParameters(ivParams, null)); // true = encrypt

    // Create a memory buffer
    var buffer = BytesBuilder();

    // Write file type identifier
    buffer.addByte(versionCurrent.length);
    buffer.add(utf8.encode(versionCurrent));

    // Write the crypt_iv in the file
    buffer.add(salt);
    _addIntegerToBytesBuilder(buffer, iterations);
    buffer.add(ivParams.iv);

    // Write the lorem ipsum text
    var sourceBytes = utf8.encode(loremText + jsonDocument);
    var destinationEncryptedBytes = cipher.process(Uint8List.fromList(sourceBytes));
    buffer.add(destinationEncryptedBytes);

    return buffer.toBytes();
  }

  String decodeFile(Uint8List binary, String password) {
    int fileVersionLenght = binary[0];
    var fileVersion = utf8.decode(binary.sublist(1, fileVersionLenght + 1));
    int offset = fileVersionLenght + 1;

    switch (fileVersion) {
      case version01:
        var salt = binary.sublist(offset, offset + 8);
        offset += 8;

        var iterations = _readIntegerFromUint8List(binary.sublist(offset, offset + 4));
        offset += 4;

        var iv = binary.sublist(offset, offset + 16);
        offset += 16;

        // Generate Key
        var pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
        pbkdf2.init(Pbkdf2Parameters(salt, iterations, 32)); // 32 *8 = 256 bits key (AES256)
        Uint8List key = pbkdf2.process(Uint8List.fromList(password.codeUnits));

        // Create AES cipher
        final cipher = PaddedBlockCipher("AES/CBC/PKCS7");
        final ivParams = ParametersWithIV(KeyParameter(key), iv);
        cipher.init(false, PaddedBlockCipherParameters(ivParams, null)); // false = encrypt

        var loremEncrypted = binary.sublist(offset);
        Uint8List output = Uint8List(0);

        try {
          output = cipher.process(loremEncrypted);
        } catch (e) {
          // Wrong password: > Invalid argument(s): Invalid or corrupted pad block
          throw BlastWrongPasswordException();
        }

        String loremDecrypted = utf8.decode(output);

        if (!loremDecrypted.startsWith(loremText)) {
          throw BlastWrongPasswordException();
        } else {
          return loremDecrypted.substring(loremText.length);
        }
      default:
        throw BlastUnknownFileVersionException();
    }
  }

  void _addIntegerToBytesBuilder(BytesBuilder buffer, int value) {
    var byteData = ByteData(4); // Create byte data with space for a 32-bit integer

    byteData.setInt32(0, value, Endian.little); // Set the integer
    buffer.add(byteData.buffer.asUint8List()); // Add the byte data to the buffer
  }

  int _readIntegerFromUint8List(Uint8List data) {
    var byteData = ByteData.view(data.buffer);

    int value = byteData.getInt32(0, Endian.little);

    return value; // Read a 32-bit integer from the start of the data
  }
}
