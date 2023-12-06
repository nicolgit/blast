import 'package:blastmodel/settings_service.dart';

class CurrentFileService {
  static final CurrentFileService _instance = CurrentFileService._internal();

  factory CurrentFileService() {
    return _instance;
  }

  CurrentFileService._internal() {
    // init things inside this
  }

  BlastFile? currentFile;
}
