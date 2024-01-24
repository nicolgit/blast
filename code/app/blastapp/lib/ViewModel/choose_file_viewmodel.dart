import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class ChooseFileViewModel extends ChangeNotifier {
  BuildContext context;
  CurrentFileService currentFileService = CurrentFileService();
  Future<String> currentPath = CurrentFileService().cloud!.rootpath;

  ChooseFileViewModel(this.context);

  Future<List<CloudObject>>? getFiles() async {
    return currentFileService.cloud!.getFiles(await currentPath);
  }

  Future selectItem(CloudObject object) async {
    if (object.isDirectory) {
      currentPath = Future.value(object.url);
      notifyListeners();
    } else {
      currentFileService.currentFileInfo =
          BlastFile(cloudId: currentFileService.cloud!.id, fileName: object.name, fileUrl: object.url);

      currentFileService.currentFileEncrypted =
          await currentFileService.cloud!.getFile(currentFileService.currentFileInfo!.fileUrl);

      if (!context.mounted) return;
      context.router.push(const TypePasswordRoute());
    }
  }

  newFileCommand() async {
    return context.router.push(const CreatePasswordRoute());
  }

  upDirectoryCommand() async {
    currentPath = Future.value(currentFileService.cloud!.goToParentDirectory(await currentPath));
    notifyListeners();
  }
}
