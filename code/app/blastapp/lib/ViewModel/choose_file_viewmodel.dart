import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/blastfile.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

enum FileSelectionAction { newFile, existingFile }

class FileSelectionResult {
  final FileSelectionAction action;
  final String? newFilePath;

  FileSelectionResult({required this.action, this.newFilePath});
}

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

        // Sort files alphabetically by name, with directories first, then .blast files
        files.sort((a, b) {
          // If one is directory and other is not, directory comes first
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;

          // If both are files (not directories), prioritize .blast files
          if (!a.isDirectory && !b.isDirectory) {
            bool aIsBlast = a.name.toLowerCase().endsWith('.blast');
            bool bIsBlast = b.name.toLowerCase().endsWith('.blast');

            // If one is .blast and other is not, .blast comes first
            if (aIsBlast && !bIsBlast) return -1;
            if (!aIsBlast && bIsBlast) return 1;
          }

          // If both are same type (both directories, both .blast files, or both other files), sort alphabetically
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

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
        );

        final cloudFile = await currentFileService.cloud!.getFile(currentFileService.currentFileInfo!.fileUrl);
        currentFileService.currentFileInfo!.lastModified = cloudFile.lastModified;

        currentFileService.currentFileEncrypted = cloudFile.data;

        // check if the file is a valid blast file
        currentFileService.getFileVersion(currentFileService.currentFileEncrypted!);

        if (!context.mounted) return;
        context.router.maybePop(FileSelectionResult(action: FileSelectionAction.existingFile));
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<Future<bool>> newFileCommand() async {
    return context.router
        .maybePop(FileSelectionResult(action: FileSelectionAction.newFile, newFilePath: await currentPath));
  }

  Future<void> upDirectoryCommand() async {
    currentPath = Future.value(currentFileService.cloud!.goToParentDirectory(await currentPath));
    _cachedFiles = null;
    notifyListeners();
  }

  void goToFolderCommand() async {
    if (!Platform.isWindows) return;

    try {
      String? selectedPath = await FilePicker.platform.getDirectoryPath();

      if (selectedPath != null) {
        currentPath = Future.value(selectedPath);
        _cachedFiles = null;
        notifyListeners();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error selecting folder: $e'),
        ));
      }
    }
  }

  bool get shouldShowGoToFolderButton {
    return Platform.isWindows && currentFileService.cloud?.id == "LOCAL";
  }
}
