import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/blastfile.dart';

class CurrentFileService {
  static final CurrentFileService _instance = CurrentFileService._internal();
  Cloud? cloud = null;

  factory CurrentFileService() {
    return _instance;
  }

  CurrentFileService._internal() {
    // init things inside this
  }

  BlastFile? currentFile;

  void setCloud(Cloud cloud) {
    this.cloud = cloud;
    //TODO reset all other values because we are changing cloud
  }
}
