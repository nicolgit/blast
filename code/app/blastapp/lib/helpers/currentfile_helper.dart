import 'dart:convert';

import 'package:blastapp/ViewModel/type_password_viewmodel.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/foundation.dart';

class CurrentFileHelper {
  static Future load(BlastFile file, String? cloudCachedCredentials) async {
    CurrentFileService().reset();
    CurrentFileService().cloud = await SettingService().getCloudStorageById(file.cloudId);
    CurrentFileService().cloud!.cachedCredentials = cloudCachedCredentials ?? '';
    CurrentFileService().currentFileInfo = file;

    final myFile = await CurrentFileService().cloud!.getFile(CurrentFileService().currentFileInfo!.fileUrl);
    CurrentFileService().currentFileInfo?.lastModified = myFile.lastModified;
    CurrentFileService().currentFileEncrypted = myFile.data;
  }

  static Future decrypt(
      {required PasswordType passwordType, required String password, required String recoveryKey}) async {
    Map<String, dynamic> inputData = {
      'type': passwordType,
      'password': password,
      'recoveryKey': recoveryKey,
      'currentFileEncrypted': CurrentFileService().currentFileEncrypted!,
      'iterations': CurrentFileService().iterations
    };

    Map<String, dynamic> resultMap = await compute(_checkPasswordComputation, inputData);

    CurrentFileService().currentFileJsonString = resultMap['jsonFile'];
    CurrentFileService().currentFileDocument = resultMap['binaryFile'];
    CurrentFileService().key = resultMap['binaryRecoveryKey'];
    CurrentFileService().password = resultMap['password'];
    CurrentFileService().salt = resultMap['salt'];
    CurrentFileService().iv = resultMap['iv'];
    CurrentFileService().iterations = resultMap['iterations'];
  }

  static Map<String, dynamic> _checkPasswordComputation(Map<String, dynamic> inputData) {
    PasswordType passwordType = inputData['type'];
    String password = inputData['password'];
    String recoveryKey = inputData['recoveryKey'];
    Uint8List currentFileEncrypted = inputData['currentFileEncrypted'];
    int iterations = inputData['iterations'];

    CurrentFileService currentFileService = CurrentFileService();

    if (passwordType == PasswordType.recoveryKey) {
      // convert string to Uint8List each 2 characters (hex) to 1 byte\
      Uint8List recoveryKeyBinary = Uint8List(32);
      for (int i = 0; i < 32; i++) {
        recoveryKeyBinary[i] = int.parse(recoveryKey.substring(i * 2, i * 2 + 2), radix: 16);
      }

      currentFileService.password = '';
      currentFileService.key = recoveryKeyBinary;
      currentFileService.iterations = iterations;
      currentFileService.currentFileJsonString =
          currentFileService.decodeFile(currentFileEncrypted, recoveryKey, PasskeyType.hexkey);
    } else {
      // password
      currentFileService.password = password;
      currentFileService.iterations = iterations;
      currentFileService.currentFileJsonString =
          currentFileService.decodeFile(currentFileEncrypted, password, PasskeyType.password);
    }

    currentFileService.currentFileDocument =
        BlastDocument.fromJson(jsonDecode(currentFileService.currentFileJsonString!));

    Map<String, dynamic> resultMap = {
      'binaryRecoveryKey': currentFileService.key,
      'password': password,
      'binaryFile': currentFileService.currentFileDocument,
      'jsonFile': currentFileService.currentFileJsonString,
      'salt': currentFileService.salt,
      'iv': currentFileService.iv,
      'iterations': currentFileService.iterations,
    };

    return resultMap;
  }
}
