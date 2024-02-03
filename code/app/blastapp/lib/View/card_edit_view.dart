import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_edit_viewmodel.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class CardEditView extends StatefulWidget {
  const CardEditView({super.key, required this.card});
  final BlastCard card;

  @override
  State<StatefulWidget> createState() => _CardEditViewState();
}

class _CardEditViewState extends State<CardEditView> {
  final BlastCard card = BlastCard();

  @override
  Widget build(BuildContext context) {
    final card = widget.card; // this is the card passed in from the CardsBrowserView

    return ChangeNotifierProvider(
      create: (context) => CardEditViewModel(context, card),
      child: Consumer<CardEditViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, CardEditViewModel vm) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          AppBar(
            title: const Text('Edit Card'),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Quit',
                onPressed: () {
                  //vm.closeCommand();
                },
              ),
            ],
          ),
          const Text('Edit Card'),
        ], 
      ),
      )
    );
  }
}