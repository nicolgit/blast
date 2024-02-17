import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_edit_viewmodel.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:provider/provider.dart';

@RoutePage()
class CardEditView extends StatefulWidget {
  const CardEditView({super.key, required this.card});
  final BlastCard card;

  @override
  State<StatefulWidget> createState() => _CardEditViewState();
}

class _CardEditViewState extends State<CardEditView> {
  
  @override
  Widget build(BuildContext context) {
    final card = widget.card; // this is the card passed in, from the CardsBrowserView

    return ChangeNotifierProvider(
      create: (context) {
        return CardEditViewModel(context, card);
      },
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
                border: OutlineInputBorder(), labelText: 'Card title', hintText: 'Choose a title for the card'),
          ),
          _buildTagsSelector(vm),
          TextButton(
            onPressed: () async {
              vm.updateNotes(await _displayTextInputDialog(context, vm.currentCard.notes ?? ""));
            },
            child: const Text('notes'),
          ),
          FutureBuilder<List<BlastAttribute>>(
            future: vm.getRows(),
            builder: (context, snapshot) {
              return Expanded(
                child: Container(
                  child: _buildFieldList(snapshot.data != null ? snapshot.data! : [], vm),
                ),
              );
            },
          ),
        ],
      ),
    ));
  }

  ListView _buildFieldList(List<BlastAttribute> rows, CardEditViewModel vm) {
    var myList = ListView.builder(
        itemCount: rows.length+1, //cardsList.length,
        itemBuilder: (context, index) {
          if (index == rows.length) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typeString);
                },
                icon: const Icon(Icons.description),
                label: const Text("Add row"),
              ),
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typeHeader);
                },
                icon: const Icon(Icons.text_increase),
                label: const Text("Add header"),
              ),
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typePassword);
                },
                icon: const Icon(Icons.lock),
                label: const Text("Add secret"),
              ),
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typeURL);
                },
                icon: const Icon(Icons.link),
                label: const Text("Add URL"),
              ),
            ]);
          }
          
          return ListTile(
            title: Row(
              children: <Widget>[
                Text("$index"),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        textInputAction: TextInputAction.next,
                        controller: TextEditingController()
                          ..text = rows[index].name,
                        onChanged: (value) => vm.updateAttributeName(index, value),
                        autofocus: true,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Attribute name',
                            hintText: 'Choose the attribute name'),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        textInputAction: TextInputAction.next,
                        controller: TextEditingController()
                          ..text = rows[index].value,
                        onChanged: (value) => vm.updateAttributeValue(index, value),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Attribute value',
                            hintText: 'Choose the attribute name'),
                      )
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    vm.deleteAttribute(index);
                  },
                  icon: const Icon(Icons.delete),
                  tooltip: "delete",
                ),
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
              decoration: const InputDecoration(hintText: "Text Field in Dialog"),
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
                child: const Text('Cancel'),
                onPressed: () => {
                      Navigator.pop(context),
                    }),
            TextButton(
                child: const Text('No'),
                onPressed: () => {
                      vm.cancelCommand(),
                      Navigator.pop(context),
                    }),
            TextButton(
                child: const Text('Yes'),
                onPressed: () => {
                      vm.saveCommand(),
                      Navigator.pop(context),
                    }),
          ],
        );
      },
    );
  }

  _buildTagsSelector(CardEditViewModel vm) {
    return MultiSelectDialogField(
      initialValue: vm.currentCard.tags,
      buttonText: const Text("choose more tags"),
      buttonIcon: const Icon(Icons.tag),
      title: const Text("tags"),
      items: vm.allTags.map((e) => MultiSelectItem(e, e)).toList(),
      listType: MultiSelectListType.CHIP,
      onConfirm: (values) {
        vm.updateTags(values);
      },
    );
  }
}
