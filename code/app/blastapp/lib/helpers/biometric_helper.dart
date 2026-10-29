import 'dart:convert';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:blastmodel/blastbiometricstorage.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/foundation.dart';

class BiometricHelper {
  static PromptInfo _getPromptInfo() {
    var pApple = IosPromptInfo(
        accessTitle: "access to your cached cloud credentials and personal Blast password",
        saveTitle: "save your cached cloud credentials and personal Blast password");
    var pAndroid = AndroidPromptInfo(
      confirmationRequired: false,
      title: "Blast password manager",
      subtitle: "Unlock to authorize",
      description: "access to your cached cloud credentials and personal Blast password",
    );

    return PromptInfo(iosPromptInfo: pApple, androidPromptInfo: pAndroid, macOsPromptInfo: pApple);
  }

  static Future<BlastBiometricStorageData?> readData(String cloudId) async {
    try {
      if (kIsWeb) return null;
      if (await SettingService().askForBiometricAuth == false) return null;
      if (await SettingService().biometricAuthEnabled == false) return null;

      final storageFile = await BiometricStorage().getStorage('blastvault', promptInfo: _getPromptInfo());
      final jsonData = await storageFile.read();

      if (jsonData != null) {
        final json = jsonDecode(jsonData) as Map<String, dynamic>;
        // Legacy biometric entries are unbound and must never authorize the new app-folder provider.
        if (json['CloudId'] != cloudId && (json['CloudId'] != null || cloudId == 'DROPBOXFOLDER')) {
          return null;
        }
        BlastBiometricStorageData data = BlastBiometricStorageData.fromJson(json);
        return data;
      }
    } catch (e) {
      // print("error loading biometric storage: $e");
      await SettingService().setBiometricAuthEnabled(false);
    }
    return null;
  }

  static Future<void> saveData(String password) async {
    try {
      final storageFile = await BiometricStorage().getStorage('blastvault', promptInfo: _getPromptInfo());

      BlastBiometricStorageData biometricData = BlastBiometricStorageData(
        password: password,
        cloudCredentials: CurrentFileService().cloud!.cachedCredentials ?? '',
      );

      final json = biometricData.toJson();
      json['CloudId'] = CurrentFileService().cloud!.id;
      await storageFile.write(jsonEncode(json));

      SettingService().setBiometricAuthEnabled(true);
    } catch (e) {
      // Don't show error message if user canceled the biometric authentication
      if (e is AuthException && e.code == AuthExceptionCode.userCanceled) {
        // User canceled, silently continue
      } else {
        rethrow; // Re-throw the exception so the caller can handle it
      }

      SettingService().setBiometricAuthEnabled(false);
    }
  }
}
