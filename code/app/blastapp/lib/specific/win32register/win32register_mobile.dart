import 'dart:io';
import 'package:win32_registry/win32_registry.dart'; // for windows registry access

import 'package:blastapp/specific/win32register/win32register.dart';

class Win32RegisterMobile extends Win32Register {
  @override
  Future<void> register(String scheme) async {
    if (!Platform.isWindows) return;

    String appPath = Platform.resolvedExecutable;

    String protocolRegKey = 'Software\\Classes\\$scheme';
    const RegistryValue protocolRegValue = RegistryValue.string(
      'URL Protocol',
      '',
    );
    String protocolCmdRegKey = 'shell\\open\\command';
    RegistryValue protocolCmdRegValue = RegistryValue.string(
      '',
      '"$appPath" "%1"',
    );

    final regKey = Registry.currentUser.createKey(protocolRegKey);
    regKey.createValue(protocolRegValue);
    regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
  }
}

Win32Register getWin32Register() => Win32RegisterMobile();
