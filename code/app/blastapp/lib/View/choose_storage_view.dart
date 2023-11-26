import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/choose_storage_view_model.dart';
import 'package:blastapp/choose_file_view.dart';
import 'package:blastmodel/Cloud/cloud.dart';
import 'package:flutter/material.dart';
import 'package:kt_dart/kt.dart';
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
          child: Column(children: [
            FutureBuilder<List<Cloud>>(
              future: vm.supportedClouds(),
              builder: (context, cloudList) {
                return _buildCloudList(cloudList.data ?? []);
              },
            ),
          ],
        ),
      ),
    );
  }

  Column _buildCloudList(List<Cloud> cloudList) {
    var myList = Column(
      children: [
        for (Cloud cloud in cloudList)
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChooseFileView()),
                );
              },
              child: Text(cloud.name)
            ),
      ],
    );

    return myList;
  }

}

class ChooseStorageViewX extends StatelessWidget {
  const ChooseStorageViewX({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            children: [
              const Text('welcome! where do you want to store your data?'),
              
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('local file system!'),
              ),
              TextButton(
                onPressed: () {
                  throw NotImplementedException("OneDrive not implemented");
                },
                child: const Text('OneDrive'),
              ),
              TextButton(
                onPressed: () {
                  throw NotImplementedException("Google Drive not implemented");
                },
                child: const Text('Google Drive'),
              ),
              TextButton(
                onPressed: () {
                  throw NotImplementedException("Apple iCloud not implemented");
                },
                child: const Text('Apple iCloud'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChooseFileView()),
                  );
                },
                child: const Text(
                    'Fake Cloud - for testing purposes only'),
              ),
            ],
        ),
      ),
    );
  }
}
