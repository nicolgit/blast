import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_storage_view_model.dart';
import 'package:blastapp/choose_file_view.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChooseStorageView extends StatefulWidget {
  const ChooseStorageView({super.key});

  @override
  State<StatefulWidget> createState() => _ChooseStorageViewState();
}

class _ChooseStorageViewState extends State<ChooseStorageView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChooseStorageViewModel(context),
      child: Consumer<ChooseStorageViewModel>(
        builder: (context, viewmodel, child) =>
            _buildScaffold(context, viewmodel),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, ChooseStorageViewModel vm) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            FutureBuilder<List<Cloud>>(
              future: vm.supportedClouds(),
              builder: (context, cloudList) {
                return _buildCloudList(cloudList.data ?? [], vm);
              },
            ),
          ],
        ),
      ),
    );
  }

  Column _buildCloudList(List<Cloud> cloudList, ChooseStorageViewModel vm) {
    var myList = Column(
      children: [
        for (Cloud cloud in cloudList)
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChooseFileView()),
                );
              },
              child: Text(cloud.name)),
      ],
    );

    return myList;
  }
}
