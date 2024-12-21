import 'package:blastapp/specific/win32register/win32register.dart';

class Win32RegisterWeb extends Win32Register {
  @override
  Future<void> register(String scheme) async {}
}

Win32Register getWin32Register() => Win32RegisterWeb();
