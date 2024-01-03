
import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_viewmodel.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class CardView extends StatefulWidget {
  const CardView({super.key, required this.card});
  final BlastCard card;
  
  @override
  State<StatefulWidget> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  final BlastCard card = BlastCard();

  @override
  Widget build(BuildContext context) {
    final card = widget.card; // this is the card passed in from the CardsBrowserView

    return ChangeNotifierProvider(
      create: (context) => CardViewModel(context, card),
      child: Consumer<CardViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, CardViewModel vm) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          const Text('title'),
          const Text('notes'),
          FutureBuilder<List<BlastAttribute>>(
              future: vm.getRows(),
              builder: (context, cardsList) {
                return Expanded(
                  child: Container(
                    child: _buildAttributesList(cardsList.data ?? [], vm),
                  ),
                );
              }),
        ],
      ),
    ));
  }

  ListView _buildAttributesList(List<BlastAttribute> cardsList, CardViewModel vm) {
    var myList = ListView.builder(
      itemCount: cardsList.length,
      itemBuilder: (context, index) {
        String name = cardsList[index].name;
        String value = cardsList[index].value;
        BlastAttributeType type = BlastAttributeType.typeHeader;// cardsList[index].type;

        return ListTile(
          leading: const Icon(Icons.file_copy_outlined),
          title: Column(
            children: [
              Row(
                children: [
                  Text(name),
                  Text(value),
                  Text(type.toString()),
                ],
              ),
            ],
          ),
        );
      },
    );

    return myList;
  }
}
