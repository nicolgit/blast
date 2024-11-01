import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
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

        currentFileService.currentFileEncrypted =
            await currentFileService.cloud!.getFile(currentFileService.currentFileInfo!.fileUrl);

        // check if the file is a valid blast file
        currentFileService.getFileVersion(currentFileService.currentFileEncrypted!);

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
