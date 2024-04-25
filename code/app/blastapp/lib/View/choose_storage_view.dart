import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_storage_viewmodel.dart';
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
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, ChooseStorageViewModel vm) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            AppBar(
              title: const Text("Choose the storage for your Blast file"),
            ),
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
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: ElevatedButton(
              onPressed: () {
                vm.goToChooseFile(cloud);
              },
              child: Row(children: [
                Image.asset("assets/storage/${cloud.id}.png", width: 48, height: 48),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      cloud.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      cloud.description,
                    ),
                  ]),
                )
              ]),
            ),
          ),
      ],
    );

    return myList;
  }
}
