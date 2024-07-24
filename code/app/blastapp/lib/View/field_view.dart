import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/field_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

@RoutePage()
class FieldView extends StatefulWidget {
  const FieldView({super.key, required this.value});
  final String value;

  @override
  State<StatefulWidget> createState() => _FieldViewState();
}

class _FieldViewState extends State<FieldView> {
  @override
  Widget build(BuildContext context) {
    final field = widget.value; // this is the card passed in from the CardsBrowserView

    return ChangeNotifierProvider(
      create: (context) => FieldViewModel(context, field),
      child: Consumer<FieldViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, FieldViewModel vm) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Column(children: [
          AppBar(
            title: Text(vm.currentField),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Quit',
                onPressed: () {
                  vm.closeCommand();
                },
              ),
            ],
          ),
          QrImageView(
            data: vm.currentField,
            version: QrVersions.auto,
            embeddedImage: const AssetImage('assets/general/app-icon.png'),
            size: 600.0,
          )
        ])));
  }
}
