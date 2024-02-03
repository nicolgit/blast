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
            title: Text('Edit Card ${vm.currentCard.id}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save',
                onPressed: () {
                  //vm.closeCommand();
                },
              ),
            ],
          ),
          TextFormField(
            initialValue: vm.currentCard.title,
            onChanged: (value) {
              vm.currentCard.title = value;
            },
            autofocus: true,
            //controller: filenameController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Card title',
                hintText: 'Choose a title for the card'),
            ),
          Expanded(child: Container(
            child: _buildFieldList(vm),
            ),
          ),
        ], 
      ),
      )
    );
  }

  ListView _buildFieldList(CardEditViewModel vm) {
    var myList = ListView.builder(
      itemCount: vm.currentCard.rows.length, //cardsList.length,
      itemBuilder: (context, index) {
        //String name = cardsList[index].name;
        //String value = cardsList[index].value;
        //final type = cardsList[index].type;
        return ListTile(
          title: Row(
            children: <Widget>[
              new Expanded ( 
        flex:1,
        child : Column(
        children: <Widget>[TextFormField(
            initialValue: vm.currentCard.rows[index].name,
            autofocus: true,
            //controller: filenameController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Attribute name',
                hintText: 'Choose the attribute name'),
            )],
      ),),
      new Expanded( 
        flex : 3,
        child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: vm.currentCard.rows[index].value,
            autofocus: true,
            //controller: filenameController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Attribute value',
                hintText: 'Choose the attribute name'),
            )
          ],
      ),)             
            ],
          ), 
          );
      });
    
    return myList;
  }

}