import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class ChooseFileViewModel extends ChangeNotifier {
  BuildContext context;
  CurrentFileService currentFileService = CurrentFileService();
  String currentPath = CurrentFileService().cloud!.rootpath;

  ChooseFileViewModel(this.context);

  Future<List<CloudObject>>? getFiles() async {
    return currentFileService.cloud!.getFiles(currentPath);
  }

  void selectItem(CloudObject object) async {
    if (object.isDirectory) {
      currentPath = object.url;
      notifyListeners();
    } else {
      currentFileService.currentFileInfo =
          BlastFile(cloudName: currentFileService.cloud!.name, fileName: object.name, filePath: object.path);

      currentFileService.currentFileEncrypted =
          await currentFileService.cloud!.getFile(currentFileService.currentFileInfo!.filePath);

      if (!context.mounted) return;
      context.router.push(const TypePasswordRoute());
    }
  }

  newFileCommand() async {
    return context.router.push(const CreatePasswordRoute());
  }
}
