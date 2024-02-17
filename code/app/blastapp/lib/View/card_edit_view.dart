import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_edit_viewmodel.dart';
import 'package:blastmodel/blastattribute.dart';
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
  final List<TextEditingController> _namesControllers = List.empty(growable: true);
  final List<TextEditingController> _valuesControllers = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    final card = widget.card; // this is the card passed in from the CardsBrowserView

    return ChangeNotifierProvider(
      create: (context) {
        final vm = CardEditViewModel(context, card);

        _initTextControllers(vm);
        return vm;
      },
      child: Consumer<CardEditViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _namesControllers) {
      controller.dispose();
    }
    for (var controller in _valuesControllers) {
      controller.dispose();
    }
    super.dispose();
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
        itemCount: rows.length, //cardsList.length,
        itemBuilder: (context, index) {
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
                        controller:
                            index < _namesControllers.length ? _namesControllers[index] : TextEditingController(),
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
                        controller:
                            index < _valuesControllers.length ? _valuesControllers[index] : TextEditingController(),
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

                    _updateTextControllers(vm, index);

                    vm.refresh();
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

  // initialize the text controllers for the card's attributes
  void _initTextControllers(CardEditViewModel vm) {
    final card = vm.currentCard;

    for (var i = 0; i < card.rows.length; i++) {
      var nameController = TextEditingController(text: card.rows[i].name);
      nameController.addListener(() {
        vm.updateAttributeName(i, nameController.text);
      });
      _namesControllers.add(nameController);

      var valueController = TextEditingController(text: card.rows[i].value);
      valueController.addListener(() {
        vm.updateAttributeValue(i, valueController.text);
      });
      _valuesControllers.add(TextEditingController(text: card.rows[i].value));
    }
  }

  // remove the index row and update controllers accordingly
  void _updateTextControllers(CardEditViewModel vm, int index) {
    _namesControllers[index].removeListener(() {});
    _namesControllers[index].dispose();
    _namesControllers.removeAt(index);

    _valuesControllers[index].removeListener(() {});
    _valuesControllers[index].dispose();
    _valuesControllers.removeAt(index);

    for (var i = 0; i < _namesControllers.length; i++) {
      _namesControllers[i].removeListener(() {});
      _namesControllers[i].addListener(() {
        vm.updateAttributeName(i, _namesControllers[i].text);
      });

      _valuesControllers[i].removeListener(() {});
      _valuesControllers[i].addListener(() {
        vm.updateAttributeValue(i, _valuesControllers[i].text);
      });
    }
  }
}
