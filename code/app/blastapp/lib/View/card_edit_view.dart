import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_edit_viewmodel.dart';
import 'package:blastapp/blastwidget/blast_attribute_edit.dart';
import 'package:blastapp/blastwidget/blast_card_icon.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastapp/helpers/delete_card_helper.dart';
import 'package:blastapp/helpers/notes_input_dialog.dart';
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
  final TextEditingController _titleController = TextEditingController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

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

    // Set initial text and select all only once
    if (!_isInitialized) {
      _titleController.text = vm.currentCard.title ?? "";
      _titleController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _titleController.text.length,
      );
      _isInitialized = true;
    }

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
                            final confirmed = await DeleteCardHelper.showDeleteCardDialog(context, vm.currentCard);
                            if (confirmed) {
                              vm.deleteCard();
                            }
                          },
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          children: [
                            BlastCardIcon(card: vm.currentCard, size: 48.0),
                            const SizedBox(width: 6.0),
                            IconButton(
                              icon: Icon(Icons.edit, color: _theme.colorScheme.onSurface),
                              iconSize: 20.0,
                              tooltip: 'Change Icon',
                              onPressed: () => vm.changeIcon(),
                            ),
                            const SizedBox(width: 6.0),
                            Expanded(
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                    controller: _titleController,
                                    onChanged: (value) {
                                      vm.updateTitle(value);
                                    },
                                    validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                                    autofocus: _focusOn == FocusOn.title,
                                    textInputAction: TextInputAction.next,
                                    style: _widgetFactory.textTheme.labelMedium,
                                    decoration: _widgetFactory.blastTextFieldDecoration(
                                        'Card <${vm.currentCard.id}> title', 'Choose a title for the card')),
                              ),
                            ),
                          ],
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
            BlastAttributeEdit(
              key: ValueKey(i),
              rows: rows,
              index: i,
              focusOn: _focusOn,
              onNameChanged: (value) => vm.updateAttributeName(i, value),
              onValueChanged: (value) => vm.updateAttributeValue(i, value),
              onDelete: () => vm.deleteAttribute(i),
              onTypeSwap: () => vm.swapType(i),
              blastTextFieldDecoration: _widgetFactory.blastTextFieldDecoration,
              buildIconTypeButton: _widgetFactory.buildIconTypeButton,
              theme: _widgetFactory.theme,
              textTheme: _widgetFactory.textTheme,
            ),
        ]);

    return myList;
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
                  _focusOn = FocusOn.lastRowName;
                },
                icon: const Icon(Icons.description),
                label: const Text("value"),
              ),
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typePassword);
                  _focusOn = FocusOn.lastRowValue;
                },
                icon: const Icon(Icons.lock),
                label: const Text("passwd"),
              ),
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typeURL);
                  _focusOn = FocusOn.lastRowValue;
                },
                icon: const Icon(Icons.link),
                label: const Text("URL"),
              ),
              TextButton.icon(
                onPressed: () {
                  vm.addAttribute(BlastAttributeType.typeHeader);
                  _focusOn = FocusOn.lastRowName;
                },
                icon: const Icon(Icons.text_increase),
                label: const Text("title"),
              ),
            ])),
        Row(
          children: [
            TextButton(
              child: const Text('edit notes > '),
              onPressed: () async {
                vm.updateNotes(await NotesInputDialog.show(context, vm.currentCard.notes ?? ""));
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
