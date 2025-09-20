import 'package:biometric_storage/biometric_storage.dart';

class BiometricHelper {
  static PromptInfo getPromptInfo() {
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
}
