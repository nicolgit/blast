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
  bool isLoading = false;

  ChooseFileViewModel(this.context);

  Future<List<CloudObject>>? getFiles() async {
    isLoading = true;
    var files = await currentFileService.cloud!.getFiles(await currentPath);
    isLoading = false;

    return Future<List<CloudObject>>.value(files);
  }

  Future selectItem(CloudObject object) async {
    if (object.isDirectory) {
      currentPath = Future.value(object.url);
      notifyListeners();
    } else {

      isLoading = true;
      notifyListeners();

      currentFileService.currentFileInfo = BlastFile(
          cloudId: currentFileService.cloud!.id,
          fileName: object.name,
          fileUrl: object.url,
          jsonCredentials: currentFileService.cloud!.cachedCredentials);

      currentFileService.currentFileEncrypted =
          await currentFileService.cloud!.getFile(currentFileService.currentFileInfo!.fileUrl);

      isLoading = false;
      notifyListeners();
      
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

  void copyToClipboard(param0) {}
}
