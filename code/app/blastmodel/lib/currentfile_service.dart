import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:blastmodel/exceptions.dart';
import 'package:pointycastle/export.dart';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/blastfile.dart';

enum PasskeyType { password, hexkey }

class CurrentFileService {
  static final CurrentFileService _instance = CurrentFileService._internal();

  static const String versionCurrent = "BLAST01";
  static const int defaultIterations = 10000;
  static const String version01 = versionCurrent;

  Cloud? cloud;
  BlastFile? currentFileInfo;
  Uint8List? currentFileEncrypted;
  String? currentFileJsonString;
  BlastDocument? currentFileDocument;

  int iterations = defaultIterations;
  Uint8List salt = Uint8List(0);
  Uint8List iv = Uint8List(0);
  Uint8List key = Uint8List(0);
  String password = "";

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

  void newPassword(String password) {
    this.password = password;

    // Generate salt
    final random = Random.secure();
    final salt = Uint8List(8);
    for (int i = 0; i < salt.length; i++) {
      salt[i] = random.nextInt(256);
    }
    this.salt = salt;

    // Generate IV
    Uint8List iv = Uint8List(16);
    for (int i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(256);
    }
    this.iv = iv;

    iterations = defaultIterations;

    // Generate Key
    key = _generateMasterKey(salt, iterations, password);
  }

  Uint8List encodeFile(String jsonDocument) {
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
    var sourceBytes = utf8.encode(jsonDocument);
    var destinationEncryptedBytes = cipher.process(Uint8List.fromList(sourceBytes));
    buffer.add(destinationEncryptedBytes);

    return buffer.toBytes();
  }

  String decodeFile(Uint8List binary, String passkey, PasskeyType passkeyType) {
    String fileVersion =  getFileVersion(binary);
    int offset = fileVersion.length + 1;

    switch (fileVersion) {
      case version01:
        salt = binary.sublist(offset, offset + 8);
        offset += 8;

        iterations = _readIntegerFromUint8List(binary.sublist(offset, offset + 4));
        offset += 4;

        iv = binary.sublist(offset, offset + 16);
        offset += 16;

        if (passkeyType == PasskeyType.password) {
          key = _generateMasterKey(salt, iterations, passkey);
        } else {
          // key already contains the hex key from the recovery key
        }

        return _decodeJson(binary, offset, iv, key);
      default:
        throw BlastUnknownFileVersionException();
    }
  }

  Uint8List _generateMasterKey(Uint8List salt, int iterations, String passkey) {
    // Generate Key
    var pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, iterations, 32)); // 32 * 8 = 256 bits key (AES256)
    return pbkdf2.process(Uint8List.fromList(passkey.codeUnits));
  }

  String _decodeJson(Uint8List binary, int offset, Uint8List iv, Uint8List key) {
    // Create AES cipher
    final cipher = PaddedBlockCipher("AES/CBC/PKCS7");
    final ivParams = ParametersWithIV(KeyParameter(key), iv);
    cipher.init(false, PaddedBlockCipherParameters(ivParams, null)); // false = encrypt

    var loremEncrypted = binary.sublist(offset);
    Uint8List output = Uint8List(0);

    try {
      output = cipher.process(loremEncrypted);
    } catch (e) {
      // Wrong password => Invalid argument(s): Invalid or corrupted pad block
      throw BlastWrongPasswordException();
    }

    String loremDecrypted = utf8.decode(output);

    return loremDecrypted;
  }

  String getFileVersion(Uint8List binary) {
    int fileVersionLenght = binary[0];
    var fileVersion = utf8.decode(binary.sublist(1, fileVersionLenght + 1));

    if (fileVersion == versionCurrent) {
      return fileVersion;
    } else {
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
