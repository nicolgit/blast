import 'package:auto_route/auto_route.dart';
import 'package:blastapp/helpers/biometric_helper.dart';
import 'package:blastapp/helpers/currentfile_helper.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:biometric_storage/biometric_storage.dart';

enum PasswordType {
  password,
  recoveryKey,
}

class TypePasswordViewModel extends ChangeNotifier {
  late BuildContext context;

  TypePasswordViewModel();

  // Helper method to show error message dialog
  Future<void> _showErrorMessage(String message) async {
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

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

  void setPassword(String value) {
    password = value;
    errorMessage = '';
    notifyListeners();
  }

  void setRecoveryKey(String value) {
    recoveryKey = value;
    errorMessage = '';
    notifyListeners();
  }

  Future<bool> isCheckingPassword() async {
    return _isCheckingPassword;
  }

  Future<bool> checkPassword(bool biometricAuthIntegration) async {
    bool isOk = false;

    _isCheckingPassword = true;
    notifyListeners();

    try {
      await CurrentFileHelper.decrypt(passwordType: passwordType, password: password, recoveryKey: recoveryKey);
      errorMessage = '';
      isOk = true;
    } on BlastWrongPasswordException {
      errorMessage = 'wrong password - please try again';
      await _showErrorMessage(errorMessage);
      isOk = false;
    } on BlastUnknownFileVersionException {
      errorMessage = 'unknown file version - unable to open your file';
      await _showErrorMessage(errorMessage);
      isOk = false;
    } on FormatException {
      errorMessage = 'file format exception - unable to open your file';
      await _showErrorMessage(errorMessage);
      isOk = false;
    } catch (e) {
      errorMessage = 'unexpeceted error - unable to open your file - ${e.toString()}';
      await _showErrorMessage(errorMessage);
      isOk = false;
    }

    _isCheckingPassword = false;
    notifyListeners();

    if (isOk) {
      if (passwordType == PasswordType.password) {
        final response = await BiometricStorage().canAuthenticate();

        // biometric authentication support (no web)
        if (!kIsWeb &&
            biometricAuthIntegration &&
            response == CanAuthenticateResponse.success &&
            await SettingService().askForBiometricAuth) {
          if (!context.mounted) return false;

          var theme = Theme.of(context);
          var textTheme = theme.textTheme.apply(bodyColor: theme.colorScheme.onSurface);

          // show alert dialog
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Biometric authentication', style: textTheme.titleLarge),
                content:
                    Text('Do you want to enable biometric authentication for this file?', style: textTheme.labelMedium),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      await SettingService().setAskForBiometricAuth(false);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Do not ask anymore'),
                  ),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      try {
                        await BiometricHelper.saveData(password);
                      } catch (e) {
                        // Don't show error message if user canceled the biometric authentication
                        if (e is AuthException && e.code == AuthExceptionCode.userCanceled) {
                          // User canceled, silently continue
                        } else {
                          await _showErrorMessage('Failed to enable biometric authentication: ${e.toString()}');
                        }
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );
        }
      }

      // return true to the calling function
      if (context.mounted) {
        context.router.maybePop(true);
      }
    }

    return isOk;
  }
}
