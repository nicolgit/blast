import 'dart:convert';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:blastmodel/blastbiometricstorage.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';

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

  static Future<BlastBiometricStorageData?> readData() async {
    try {
      if (await SettingService().biometricAuthEnabled) {
        final storageFile = await BiometricStorage().getStorage('blastvault', promptInfo: _getPromptInfo());

        final jsonData = await storageFile.read();

        if (jsonData != null) {
          BlastBiometricStorageData data = BlastBiometricStorageData.fromJson(jsonDecode(jsonData));
          CurrentFileService().cloud!.cachedCredentials = data.cloudCredentials ?? '';
          return data;
        }
      } else {
        await SettingService().setBiometricAuthEnabled(false);
      }
    } catch (e) {
      print("error loading biometric storage: $e");
      await SettingService().setBiometricAuthEnabled(false);
    }
    return null;
  }

  static Future<void> saveData(String password) async {
    try {
      final storageFile = await BiometricStorage().getStorage('blastvault', promptInfo: _getPromptInfo());

      BlastBiometricStorageData biometricData = BlastBiometricStorageData(
        password: password,
        cloudCredentials: CurrentFileService().cloud!.cachedCredentials,
      );

      await storageFile.write(jsonEncode(biometricData));

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
