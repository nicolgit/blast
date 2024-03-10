import 'dart:ffi';

class BlastException implements Exception {
  BlastException();
}

class BlastWrongPasswordException implements BlastException {
  BlastWrongPasswordException();
}

class BlastUnknownFileVersionException implements BlastException {
  BlastUnknownFileVersionException();
}

class BlastInvalidFileException implements BlastException {
  BlastInvalidFileException();
}

class BlastAuthenticationFailedException implements BlastException {
  BlastAuthenticationFailedException();
}

class BlastRESTAPIException implements BlastException {
  int statusCode;
  String body;
  BlastRESTAPIException(this.statusCode, this.body);
}
