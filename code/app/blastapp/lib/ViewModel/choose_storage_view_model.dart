import 'package:blastmodel/Cloud/cloud.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';


class ChooseStorageViewModel extends ChangeNotifier{
  BuildContext context;

  ChooseStorageViewModel(this.context);

  Future<List<Cloud>> supportedClouds() async {
    return SettingService().getCloudStoragelist();
  }

}