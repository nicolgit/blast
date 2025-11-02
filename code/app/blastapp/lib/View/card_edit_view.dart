import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_edit_viewmodel.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastapp/blastwidget/file_changed_banner.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:provider/provider.dart';

@RoutePage()
class CardEditView extends StatefulWidget {
  const CardEditView({super.key, this.card});
  final BlastCard? card;

  @override
  State<StatefulWidget> createState() => _CardEditViewState();
}

class _CardEditViewState extends State<CardEditView> {
  FocusOn _focusOn = FocusOn.title;

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

  late BlastWidgetFactory _widgetFactory;
  late ThemeData _theme;

  final _formKey = GlobalKey<FormState>();
  Widget _buildScaffold(BuildContext context, CardEditViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);
    _theme = _widgetFactory.theme;

    return Container(
        color: _theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _widgetFactory.viewBackgroundColor(),
                body: Center(
                    child: Column(
                  children: [
                    AppBar(
                      automaticallyImplyLeading: false,
                      leading: BackButton(
                        onPressed: () => _showChangedDialog(context, vm),
                      ),
                      title: Text('Edit Card'),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.save),
                          tooltip: 'Save',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              vm.saveCommand(saveAndExit: true);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete',
                          onPressed: () async {
                            await _showDeleteCardDialog(context, vm);
                          },
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                              initialValue: vm.currentCard.title,
                              onChanged: (value) {
                                vm.updateTitle(value);
                              },
                              validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                              autofocus: _focusOn == FocusOn.title,
                              textInputAction: TextInputAction.next,
                              style: _widgetFactory.textTheme.labelMedium,
                              decoration: _widgetFactory.blastTextFieldDecoration(
                                  'Card <${vm.currentCard.id}> title', 'Choose a title for the card')),
                        )),
                    _buildTagsRow(vm),
                    FutureBuilder<List<BlastAttribute>>(
                      future: vm.getRows(),
                      builder: (context, snapshot) {
                        return Expanded(
                          child: Container(
                            child: _buildAttributeList(snapshot.data != null ? snapshot.data! : [], vm),
                          ),
                        );
                      },
                    ),
                    _showBottomToolbar(vm),
                    FileChangedBanner(
                      isFileChangedFuture: vm.isFileChangedAsync(),
                      onSavePressed: () async {
                        if (_formKey.currentState!.validate()) {
                          vm.saveCommand(saveAndExit: false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("file saved successfully!"),
                            ));
                          }
                        }
                      },
                    ),
                  ],
                )))));
  }

  ReorderableListView _buildAttributeList(List<BlastAttribute> rows, CardEditViewModel vm) {
    var myList = ReorderableListView(
        onReorder: (oldIndex, newIndex) => vm.moveRow(oldIndex, newIndex),
        buildDefaultDragHandles: false,
        children: [
          for (int i = 0; i < rows.length; i++)
            _widgetFactory.buildAttributeRowEdit(
              rows,
              i,
              focusOn: _focusOn,
              onNameChanged: (value) => vm.updateAttributeName(i, value),
              onValueChanged: (value) => vm.updateAttributeValue(i, value),
              onDelete: () => vm.deleteAttribute(i),
              onTypeSwap: () => vm.swapType(i),
              onGeneratePassword: () => vm.openPasswordGenerator(i),
            ),
        ]);

    return myList;
  }

  Future<String> _displayTextInputDialog(BuildContext context, String valueText) async {
    final oldValue = valueText;

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('notes (some markdown is ok)', style: _widgetFactory.textTheme.headlineSmall),
            content: TextField(
              controller: TextEditingController()..text = valueText,
              keyboardType: TextInputType.multiline,
              minLines: 4,
              maxLines: null,
              style: _widgetFactory.textTheme.bodyMedium,
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
          title: Text('Unsaved changes',
              style: _widgetFactory.textTheme.headlineMedium!
                  .copyWith(color: _widgetFactory.theme.colorScheme.onPrimaryContainer)),
          content: Text('Do you want to save your changes?',
              style: _widgetFactory.textTheme.bodyMedium!
                  .copyWith(color: _widgetFactory.theme.colorScheme.onPrimaryContainer)),
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
                      vm.saveCommand(saveAndExit: true),
                      Navigator.pop(context),
                    }),
          ],
        );
      },
    );
  }

  Future _showDeleteCardDialog(BuildContext context, CardEditViewModel vm) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Text('Delete '),
              Text('${vm.currentCard.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('Are you sure you want to delete this card and all its content?'),
          actions: <Widget>[
            TextButton(
                child: const Text('No'),
                onPressed: () => {
                      Navigator.pop(context),
                    }),
            TextButton(
                child: const Text('Yes please!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onPressed: () => {
                      vm.deleteCard(),
                      Navigator.pop(context),
                    }),
          ],
        );
      },
    );
  }

  Wrap _buildTagsRow(CardEditViewModel vm) {
    List<Widget> rowItems = [];
    for (var tag in vm.currentCard.tags) {
      rowItems.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add padding to top and bottom
        child: _widgetFactory.blastTag(tag),
      ));
    }

    rowItems.add(TextButton.icon(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (ctx) {
              return MultiSelectDialog(
                title: Text("Select tags",
                    style: _widgetFactory.textTheme.headlineMedium!
                        .copyWith(color: _widgetFactory.theme.colorScheme.onPrimaryContainer)),
                items: vm.allTags.map((e) => MultiSelectItem(e, e)).toList(),
                initialValue: vm.currentCard.tags,
                onConfirm: (values) {
                  vm.updateTags(List<String>.from(values));
                },
                listType: MultiSelectListType.CHIP,
                selectedColor: _widgetFactory.theme.colorScheme.primary,
                unselectedColor: _widgetFactory.theme.colorScheme.surface,
                selectedItemsTextStyle:
                    _widgetFactory.textTheme.labelSmall!.copyWith(color: _widgetFactory.theme.colorScheme.onPrimary),
              );
            },
          );
        },
        icon: const Icon(Icons.calculate),
        label: const Text("edit"),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
        )));
    return Wrap(spacing: 6.0, runSpacing: 6.0, children: rowItems);
  }

  Widget _showBottomToolbar(CardEditViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: _theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(3.0),
          topRight: Radius.circular(3.0),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(spacing: 3.0, runSpacing: 1.0, alignment: WrapAlignment.center, children: [
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typeString);
                  _focusOn = FocusOn.lastRow;
                },
                icon: const Icon(Icons.description),
                label: const Text("add value"),
              ),
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typePassword);
                  _focusOn = FocusOn.lastRowValue;
                },
                icon: const Icon(Icons.lock),
                label: const Text("add password"),
              ),
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typeURL);
                },
                icon: const Icon(Icons.link),
                label: const Text("add URL"),
              ),
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typeHeader);
                  _focusOn = FocusOn.lastRow;
                },
                icon: const Icon(Icons.text_increase),
                label: const Text("add title"),
              ),
            ])),
        Row(
          children: [
            TextButton(
              child: const Text('edit notes > '),
              onPressed: () async {
                vm.updateNotes(await _displayTextInputDialog(context, vm.currentCard.notes ?? ""));
              },
            ),
            Expanded(
                child: Text(vm.currentCard.notes ?? "",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: _widgetFactory.textTheme.labelMedium!
                        .copyWith(color: _widgetFactory.theme.colorScheme.onSurface))),
          ],
        ),
      ]),
    );
  }
}
