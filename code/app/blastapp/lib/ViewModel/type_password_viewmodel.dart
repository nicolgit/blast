import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PasswordType {
  password,
  recoveryKey,
}

class TypePasswordViewModel extends ChangeNotifier {
  BuildContext context;

  TypePasswordViewModel(this.context);

  String get fileName => CurrentFileService().currentFileInfo!.fileName;
  String get cloudIcon => 'assets/storage/${CurrentFileService().currentFileInfo!.cloudId}.png';
  PasswordType passwordType = PasswordType.password;
  String password = '';
  String recoveryKey = '';
  String errorMessage = '';
  bool _isCheckingPassword = false;

  Future<bool> isPasswordValid() async {
    if (passwordType == PasswordType.password) {
      return password.isNotEmpty;
    } else {
      return recoveryKey.isNotEmpty && recoveryKey.length == 64;
    }
  }

  Future<PasswordType> getPasswordType() async {
    return passwordType;
  }

  Future<bool> checkPasswordOld() async {
    bool isOk = false;

    _isCheckingPassword = true;
    notifyListeners();

    try {
      if (passwordType == PasswordType.recoveryKey) {
        // convert string to Uint8List each 2 characters (hex) to 1 byte\
        Uint8List recoveryKeyBinary = Uint8List(32);
        for (int i = 0; i < 32; i++) {
          recoveryKeyBinary[i] = int.parse(recoveryKey.substring(i * 2, i * 2 + 2), radix: 16);
        }

        CurrentFileService().password = '';
        CurrentFileService().key = recoveryKeyBinary;
        CurrentFileService().currentFileJsonString =
            CurrentFileService().decodeFile(CurrentFileService().currentFileEncrypted!, recoveryKey, PasskeyType.hexkey);
      } else { // password
        CurrentFileService().password = password;
        CurrentFileService().currentFileJsonString =
            CurrentFileService().decodeFile(CurrentFileService().currentFileEncrypted!, password, PasskeyType.password);
      }

      CurrentFileService().currentFileDocument =
        BlastDocument.fromJson(jsonDecode(CurrentFileService().currentFileJsonString!));

      errorMessage = '';

      isOk = true;
    } on BlastWrongPasswordException {
      errorMessage = 'wrong password - please try again';
      isOk = false;
    } on BlastUnknownFileVersionException {
      errorMessage = 'unknown file version - unable to open your file';
      isOk = false;
    } on FormatException {
      errorMessage = 'file format exception - unable to open your file';
      isOk = false;
    } catch (e) {
      errorMessage = 'unexpeceted error - unable to open your file - ${e.toString()}';
      isOk = false;
    }

    _isCheckingPassword = false;
    notifyListeners();

    if (isOk) {
      // return true to the calling function
      if (!context.mounted) return false;
      return context.router.maybePop(true);
    }

    return false;
  }

  setPassword(String value) {
    password = value;
    errorMessage = '';
    notifyListeners();
  }

  setRecoveryKey(String value) {
    recoveryKey = value;
    errorMessage = '';
    notifyListeners();
  }

  Future<bool> isCheckingPassword() async {
    return _isCheckingPassword;
  }

  Future<bool> checkPassword() async {
    bool isOk = false;

    _isCheckingPassword = true;
    notifyListeners();

    try {

      Map<String, dynamic> inputData = {'type': passwordType,
                                        'password': password,
                                        'recoveryKey': recoveryKey,
                                        'currentFileEncrypted': CurrentFileService().currentFileEncrypted!
                                        };
                                    
      Map<String, dynamic> resultMap = await compute(_checkPasswordComputation , inputData); 
      
      CurrentFileService().currentFileJsonString = resultMap['jsonFile'];
      CurrentFileService().currentFileDocument = resultMap['binaryFile'];
      CurrentFileService().key = resultMap['binaryRecoveryKey'];
      CurrentFileService().password = resultMap['password'];
      CurrentFileService().salt = resultMap['salt'];
      CurrentFileService().iv = resultMap['iv'];
      
      errorMessage = '';

      isOk = true;
    } on BlastWrongPasswordException {
      errorMessage = 'wrong password - please try again';
      isOk = false;
    } on BlastUnknownFileVersionException {
      errorMessage = 'unknown file version - unable to open your file';
      isOk = false;
    } on FormatException {
      errorMessage = 'file format exception - unable to open your file';
      isOk = false;
    } catch (e) {
      errorMessage = 'unexpeceted error - unable to open your file - ${e.toString()}';
      isOk = false;
    }

    var x = CurrentFileService().currentFileDocument;
    var y = CurrentFileService().currentFileJsonString;

    _isCheckingPassword = false;
    notifyListeners();

    if (isOk) {
      // return true to the calling function
      if (!context.mounted) return false;
      return context.router.maybePop(true);
    }

    return false;
  }
 
}



Map<String, dynamic> _checkPasswordComputation(Map<String, dynamic> inputData) {
  PasswordType passwordType = inputData['type'];
  String password = inputData['password'];
  String recoveryKey = inputData['recoveryKey'];
  Uint8List currentFileEncrypted = inputData['currentFileEncrypted'];

  CurrentFileService currentFileService = CurrentFileService();
  

  if (passwordType == PasswordType.recoveryKey) {
        // convert string to Uint8List each 2 characters (hex) to 1 byte\
        Uint8List recoveryKeyBinary = Uint8List(32);      
        for (int i = 0; i < 32; i++) {
          recoveryKeyBinary[i] = int.parse(recoveryKey.substring(i * 2, i * 2 + 2), radix: 16);
        }

        currentFileService.password = '';
        currentFileService.key = recoveryKeyBinary;
        currentFileService.currentFileJsonString =
            currentFileService.decodeFile(currentFileEncrypted, recoveryKey, PasskeyType.hexkey);
      } else { // password
        currentFileService.password = password;
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
        'iv': currentFileService.iv
      };
  
  return resultMap;
}