import 'package:auto_route/auto_route.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastmodel/Cloud/cloud_object.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';

class ChooseFileViewModel extends ChangeNotifier {
  BuildContext context;
  CurrentFileService currentFileService = CurrentFileService();
  String currentPath = "";

  ChooseFileViewModel(this.context);

  Future<List<CloudObject>>? getFiles() async {
    return currentFileService.cloud!.getFiles(currentPath);
  }

  void selectItem(CloudObject object) {
    if (object.isDirectory) {
      currentPath = object.url;
      notifyListeners();
    } else {
      context.router.push(const TypePasswordRoute());
    }
  }

  newFileCommand() async {
    return context.router.push(const CreatePasswordRoute());
  }
}
