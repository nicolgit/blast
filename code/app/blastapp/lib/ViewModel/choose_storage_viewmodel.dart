import 'package:auto_route/auto_route.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';

class ChooseStorageViewModel extends ChangeNotifier {
  BuildContext context;

  ChooseStorageViewModel(this.context);

  Future<List<Cloud>> supportedClouds() async {
    return SettingService().getCloudStoragelist();
  }

  goToChooseFile(Cloud cloud) async {
    CurrentFileService().setCloud(cloud);

    // return true to indicate that a cloud has been selected
    await context.router.maybePop(true);
  }
}
