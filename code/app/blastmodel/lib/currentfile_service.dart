import 'dart:typed_data';

import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/blastfile.dart';

class CurrentFileService {
  static final CurrentFileService _instance = CurrentFileService._internal();

  Cloud? cloud;
  BlastFile? currentFileInfo;
  Uint8List? currentFileEncrypted;
  String? currentFileJsonString;
  BlastDocument? currentFileDocument;

  factory CurrentFileService() {
    return _instance;
  }

  CurrentFileService._internal() {
    // init things inside this
    reset();
  }

  void reset() {
    cloud = null;
    currentFileInfo = null;
    currentFileEncrypted = null;
    currentFileJsonString = null;
    currentFileDocument = null;
  }

  void setCloud(Cloud cloud) {
    this.cloud = cloud;
    //TODO reset all other values because we are changing cloud
  }
}
