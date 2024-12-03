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

  late ThemeData _theme;
  late TextTheme _textTheme;

  Widget _buildScaffold(BuildContext context, ChooseStorageViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);

    return Scaffold(
      backgroundColor: _theme.colorScheme.surface,
      body: Center(
        child: Column(
          children: [
            AppBar(
              title: const Text("Choose the storage for your Blast file"),
            ),
            FutureBuilder<List<Cloud>>(
              future: vm.supportedClouds(),
              builder: (context, cloudList) {
                return Container(
                    constraints: BoxConstraints(maxWidth: 600), child: _buildCloudList(cloudList.data ?? [], vm));
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
            child: Material(
              borderRadius: BorderRadius.circular(6),
              elevation: 1,
              color: _theme.colorScheme.surface,
              shadowColor: _theme.colorScheme.onSurface,
              surfaceTintColor: _theme.colorScheme.onSurface,
              type: MaterialType.card,
              child: ListTile(
                leading: Image.asset("assets/storage/${cloud.id}.png", width: 48, height: 48),
                title: Text(cloud.name, style: _textTheme.labelLarge),
                subtitle: Text(cloud.description, style: _textTheme.labelSmall),
                onTap: () {
                  vm.goToChooseFile(cloud);
                },
              ),
            ),
          ),
      ],
    );

    return myList;
  }
}
