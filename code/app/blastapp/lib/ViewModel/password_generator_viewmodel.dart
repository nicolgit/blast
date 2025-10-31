import 'dart:async';
import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum GeneratorTypes {
  guid,
  text,
  numeric;
}

class PasswordGeneratorViewModel extends ChangeNotifier {
  final BuildContext context;
  GeneratorTypes _generatorType = GeneratorTypes.guid; // Default to GUID
  bool _isRunning = false;
  Timer? _backgroundTimer;
  String _password = 'Generated password will appear here';
  int _textLength = 10;

  PasswordGeneratorViewModel(this.context) {
    _startBackgroundProcess();
  }

  GeneratorTypes get generatorType => _generatorType;
  bool get isRunning => _isRunning;
  String get password => _password;
  int get textLength => _textLength;

  void setGeneratorType(GeneratorTypes type) {
    if (_generatorType != type) {
      _generatorType = type;
      notifyListeners();
    }
  }

  void setPassword(String newPassword) {
    if (_password != newPassword) {
      _password = newPassword;
      notifyListeners();
    }
  }

  void setTextLength(int length) {
    if (_textLength != length && length >= 5 && length <= 20) {
      _textLength = length;
      notifyListeners();
    }
  }

  String _generateGuid() {
    final random = Random();
    final chars = '0123456789abcdef';

    String generateSegment(int length) {
      return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
    }

    return '${generateSegment(8)}-${generateSegment(4)}-${generateSegment(4)}-${generateSegment(4)}-${generateSegment(12)}';
  }

  String _generateTextPassword() {
    final random = Random();
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const digits = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    final allChars = lowercase + uppercase + digits + special;
    final passwordLength = _textLength;

    // Ensure at least one character from each category if length allows
    String password = '';
    if (passwordLength >= 4) {
      password += lowercase[random.nextInt(lowercase.length)];
      password += uppercase[random.nextInt(uppercase.length)];
      password += digits[random.nextInt(digits.length)];
      password += special[random.nextInt(special.length)];
    }

    // Fill the rest with random characters
    for (int i = password.length; i < passwordLength; i++) {
      password += allChars[random.nextInt(allChars.length)];
    }

    // Shuffle the password to randomize the order
    List<String> passwordList = password.split('');
    passwordList.shuffle(random);

    return passwordList.join();
  }

  String _generateNumericPassword() {
    final random = Random();
    const digits = '0123456789';
    final passwordLength = _textLength;

    String password = '';
    for (int i = 0; i < passwordLength; i++) {
      password += digits[random.nextInt(digits.length)];
    }

    return password;
  }

  void _startBackgroundProcess() {
    _isRunning = true;
    _backgroundTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      // Background process logic goes here
      // This runs every 500ms
      if (_generatorType == GeneratorTypes.guid) {
        setPassword(_generateGuid());
      } else if (_generatorType == GeneratorTypes.text) {
        setPassword(_generateTextPassword());
      } else if (_generatorType == GeneratorTypes.numeric) {
        setPassword(_generateNumericPassword());
      }
      debugPrint('Background process tick: ${DateTime.now()}');
    });
  }

  void _stopBackgroundProcess() {
    _isRunning = false;
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }

  void startGenerator() {
    if (!_isRunning) {
      _startBackgroundProcess();
      notifyListeners();
    }
  }

  void stopGenerator() {
    if (_isRunning) {
      _stopBackgroundProcess();
      notifyListeners();
    }
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void closeCommand() {
    _stopBackgroundProcess();
    context.router.maybePop();
  }

  @override
  void dispose() {
    _stopBackgroundProcess();
    super.dispose();
  }
}
