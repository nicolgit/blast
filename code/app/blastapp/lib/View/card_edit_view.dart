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
            automaticallyImplyLeading: false,
            leading: BackButton( 
              onPressed: () => _showChangedDialog(context, vm),
            ),
            title: Text('Edit Card ${vm.currentCard.id}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save',
                onPressed: () {
                  vm.saveCommand();
                },
              ),
            ],
          ),
          TextFormField(
            initialValue: vm.currentCard.title,
            onChanged: (value) {
              vm.updateTitle(value);
            },
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Card title',
                hintText: 'Choose a title for the card'),
            ),
            TextButton(
              onPressed: () async {
                  vm.updateNotes(await _displayTextInputDialog(context, vm.currentCard.notes ?? ""));
                },
              child: const Text('notes'),
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
        return ListTile(
          title: Row(
            children: <Widget>[
              Expanded ( 
        flex:1,
        child : Column(
        children: <Widget>[TextFormField(
            initialValue: vm.currentCard.rows[index].name,
            textInputAction: TextInputAction.next,
            onChanged: (newValue) => vm.updateAttributeName(index, newValue),
            autofocus: true,
            //controller: filenameController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Attribute name',
                hintText: 'Choose the attribute name'),
            )],
      ),),
      Expanded( 
        flex : 3,
        child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: vm.currentCard.rows[index].value,
            textInputAction: TextInputAction.next,
            onChanged: (newValue) => vm.updateAttributeValue(index, newValue),
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

  Future<String> _displayTextInputDialog(BuildContext context, String valueText) async {
    final oldValue = valueText;
    
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('notes'),
            content: TextField(
              controller: TextEditingController()..text = valueText,
              keyboardType: TextInputType.multiline,
              minLines: 4,
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              decoration:
                  const InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    valueText = oldValue;
                  });
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('ok'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });

        return valueText;
  }

  Future _showChangedDialog(BuildContext context, CardEditViewModel vm) async {
    if (!vm.isChanged) {
      vm.cancelCommand();
      return;
    }

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved changes'),
          content: const Text('Do you want to save your changes?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => {
                vm.cancelCommand(),
                Navigator.pop(context),
              }
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () => {
                vm.saveCommand(),
                Navigator.pop(context),
              }
            ),
          ],
        );
      },
    );
  }
}
