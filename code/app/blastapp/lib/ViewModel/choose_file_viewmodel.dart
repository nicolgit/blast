import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

enum FileSelectionResult { newFile, existingFile }

class ChooseFileViewModel extends ChangeNotifier {
  BuildContext context;
  CurrentFileService currentFileService = CurrentFileService();
  Future<String> currentPath = CurrentFileService().cloud!.rootpath;
  bool isLoading = false;

  ChooseFileViewModel(this.context);

  List<CloudObject>? _cachedFiles;

  Future<List<CloudObject>>? getFiles() async {
    if (_cachedFiles == null) {
      List<CloudObject> files;

      try {
        isLoading = true;
        files = await currentFileService.cloud!.getFiles(await currentPath);
        isLoading = false;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('error: $e'),
          ));
        }
        files = [];
      } finally {
        isLoading = false;
      }

      _cachedFiles = files;
    }

    return Future<List<CloudObject>>.value(_cachedFiles);
  }

  Future selectItem(CloudObject object) async {
    if (object.isDirectory) {
      currentPath = Future.value(object.url);
      _cachedFiles = null;
      notifyListeners();
    } else {
      try {
        isLoading = true;
        notifyListeners();

        currentFileService.currentFileInfo = BlastFile(
            cloudId: currentFileService.cloud!.id,
            fileName: object.name,
            fileUrl: object.url,
            jsonCredentials: currentFileService.cloud!.cachedCredentials);

        final cloudFile = await currentFileService.cloud!.getFile(currentFileService.currentFileInfo!.fileUrl);
        currentFileService.currentFileInfo!.lastModified = cloudFile.lastModified;

        currentFileService.currentFileEncrypted = cloudFile.data;
            

        // check if the file is a valid blast file
        currentFileService.getFileVersion(currentFileService.currentFileEncrypted!);

        if (!context.mounted) return;
        context.router.maybePop(FileSelectionResult.existingFile);
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  newFileCommand() async {
    return context.router.maybePop(FileSelectionResult.newFile);
  }

  upDirectoryCommand() async {
    currentPath = Future.value(currentFileService.cloud!.goToParentDirectory(await currentPath));
    _cachedFiles = null;
    notifyListeners();
  }

  void copyToClipboard(param0) {}
}
