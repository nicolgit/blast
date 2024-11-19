import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/cards_browser_viewmodel.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:humanizer/humanizer.dart';

@RoutePage()
class CardsBrowserView extends StatefulWidget {
  const CardsBrowserView({super.key});

  @override
  State<StatefulWidget> createState() => _CardBrowserViewState();
}

class _CardBrowserViewState extends State<CardsBrowserView> {
  _CardBrowserViewState();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardsBrowserViewModel(context),
      child: Consumer<CardsBrowserViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late BlastWidgetFactory _widgetFactory;

  final FocusNode _focusNode = FocusNode();
  Widget _buildScaffold(BuildContext context, CardsBrowserViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);

    return KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space)) {
            _showModalBottomSheet(context, vm);
          }

          if (event.logicalKey == LogicalKeyboardKey.escape) {
            vm.clearSearchTextCommand();
          }
        },
        child: Scaffold(
          backgroundColor: _widgetFactory.viewBackgroundColor(),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.question_mark),
                  onPressed: () {},
                ),
                Tooltip(
                  message: 'press SPACE or ENTER to search',
                  child: TextButton.icon(
                    onPressed: () {
                      _showModalBottomSheet(context, vm);
                    },
                    icon: const Icon(
                      Icons.search,
                      size: 24.0,
                    ),
                    label: const Text('Search'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.question_mark),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          body: Center(
            child: Column(
              children: [
                AppBar(
                  automaticallyImplyLeading: true,
                  title: Text(vm.fileService.currentFileInfo!.fileName),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.save),
                      tooltip: 'save',
                      onPressed: () {
                        vm.saveCommand();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("file saved successfully!"),
                        ));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'close',
                      onPressed: () {
                        // set up the buttons
                        Widget cancelButton = FilledButton(
                          child: Text(
                            "Cancel",
                            style: _widgetFactory.textTooltip.labelLarge,
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop(); // dismiss dialod
                          },
                        );
                        Widget noButton = FilledButton.tonal(
                          child: const Text("No, just exit"),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
                            vm.closeCommand();
                          },
                        );
                        Widget okButton = FilledButton(
                          child: Text("Yes save it", style: _widgetFactory.textTooltip.labelLarge),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
                            vm.saveCommand();
                            vm.closeCommand();
                          },
                        );

                        if (vm.isFileChanged()) {
                          AlertDialog alert = AlertDialog(
                            title: const Text("File changed"),
                            content: const Text("Do you want to save it before closing?"),
                            actions: [
                              cancelButton,
                              noButton,
                              okButton,
                            ],
                          );
                          // show the dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );
                        } else {
                          // close the file
                          vm.closeCommand();
                        }
                      },
                    ),
                  ],
                ),
                FutureBuilder<bool>(
                    future: vm.isFileChangedAsync(),
                    builder: (context, isFileChanged) {
                      return Visibility(
                        visible: isFileChanged.data ?? false,
                        child: Container(
                          width: double.infinity,
                          color: _widgetFactory.theme.colorScheme.error,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('file changed, click',
                                  style: TextStyle(color: _widgetFactory.theme.colorScheme.onError)),
                              Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: FilledButton(
                                    child: const Text('here'),
                                    onPressed: () {
                                      vm.saveCommand();
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text("file saved successfully!"),
                                      ));
                                    },
                                  )),
                              Text('to save', style: TextStyle(color: _widgetFactory.theme.colorScheme.onError)),
                            ],
                          ),
                        ),
                      );
                    }),
                FutureBuilder<List<BlastCard>>(
                    future: vm.getCards(),
                    builder: (context, cardsList) {
                      return Expanded(
                        child: Material(
                          type: MaterialType.transparency,
                          child: _buildCardsList(cardsList.data ?? [], vm),
                        ),
                      );
                    }),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              vm.addCard().then((value) {
                vm.refreshCardListCommand();
              });
            },
            child: const Icon(Icons.add),
          ),
          drawer: Drawer(
              child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const Image(image: AssetImage('assets/general/icon-v01.png')),
              ),
              ListTile(
                leading: const Icon(Icons.upload),
                title: const Text('import from...'),
                onTap: () {
                  Navigator.pop(context); // close drawer

                  Widget cancelButton = TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: _widgetFactory.theme.colorScheme.error,
                    ),
                    child: const Text("cancel"),
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
                    },
                  );

                  if (vm.isFileNotEmpty()) {
                    AlertDialog alert = AlertDialog(
                      title: const Text("import from another password manager"),
                      content: const Text(
                          "WARNING: your current Blast file is not empty. To import data you must have an empty file."),
                      actions: [
                        cancelButton,
                      ],
                    );
                    // show the dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  } else {
                    context.router.push(const ImporterRoute()).then((value) {
                      vm.refreshCardListCommand();
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('export .json file'),
                enabled: !kIsWeb,
                onTap: () {
                  Navigator.pop(context); // close drawer
                  vm.exportCommand();
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('export master key'),
                onTap: () {
                  Navigator.pop(context); // close drawer

                  vm.exportMasterKeyCommand();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('change password'),
                enabled: !kIsWeb,
                onTap: () {
                  Navigator.pop(context); // close drawer
                  
                  vm.changePasswordCommand();
                },
              ),
            ],
          )),
        ));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  ListView _buildCardsList(List<BlastCard> cardsList, CardsBrowserViewModel vm) {
    var myList = ListView.separated(
      itemCount: cardsList.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        String name = cardsList[index].title != null ? cardsList[index].title! : '';
        bool isFavorite = cardsList[index].isFavorite;

        return ListTile(
          leading: _widgetFactory.blastCardIcon(name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                ),
                onPressed: () {
                  vm.editCard(cardsList[index]).then((value) {
                    vm.refreshCardListCommand();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: _widgetFactory.theme.colorScheme.secondary),
                onPressed: () {
                  _showDeleteCardDialog(context, vm, cardsList[index]);
                },
              ),
            ],
          ),
          title: Row(children: [
            Visibility(
              visible: isFavorite,
              child: Icon(
                isFavorite ? Icons.star : Icons.star_border,
              ),
            ),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold))
          ]),
          subtitle: Row(
            children: [
              _buildTagsRow(cardsList[index].tags),
              Text(
                  'used ${cardsList[index].usedCounter} times, last time ${cardsList[index].lastUpdateDateTime.difference(DateTime.now()).toApproximateTime()}'),
            ],
          ),
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
          selected: vm.selectedCard != null ? vm.selectedCard!.id == cardsList[index].id : false,
          onTap: () async {
            vm.selectCard(cardsList[index]).then((value) {
              vm.refreshCardListCommand();
            });
          },
        );
      },
    );

    return myList;
  }

  Widget _buildTagsRow(List<String> tags) {
    List<Widget> rowItems = [];
    for (var tag in tags) {
      rowItems.add(_widgetFactory.blastTag(tag));
    }

    return Row(children: rowItems);
  }

  Future _showDeleteCardDialog(BuildContext context, CardsBrowserViewModel vm, BlastCard card) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Text('Delete '),
              Text('${card.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      vm.deleteCard(card),
                      Navigator.pop(context),
                    }),
          ],
        );
      },
    );
  }

  final _searchController = TextEditingController();

  void _showModalBottomSheet(BuildContext context, CardsBrowserViewModel vm) {
    _searchController.text = vm.searchText;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SegmentedButton<SearchOperator>(
                      segments: const <ButtonSegment<SearchOperator>>[
                        ButtonSegment<SearchOperator>(
                            value: SearchOperator.and, label: Text('and'), icon: Icon((Icons.radio_button_unchecked))),
                        ButtonSegment<SearchOperator>(
                            value: SearchOperator.or, label: Text('or'), icon: Icon(Icons.radio_button_unchecked)),
                      ],
                      selected: <SearchOperator>{vm.searchOperator},
                      onSelectionChanged: (Set<SearchOperator> newSelection) {
                        setModalState(() {
                          vm.searchOperator = newSelection.first;
                          vm.refreshCardListCommand();
                        });
                      },
                    ),
                    Container(width: 12),
                    SegmentedButton<SearchWhere>(
                      segments: const <ButtonSegment<SearchWhere>>[
                        ButtonSegment<SearchWhere>(
                            value: SearchWhere.title, label: Text('title only'), icon: Icon((Icons.abc))),
                        ButtonSegment<SearchWhere>(
                            value: SearchWhere.everywhere, label: Text('everywhere'), icon: Icon((Icons.abc))),
                      ],
                      selected: <SearchWhere>{vm.searchWhere},
                      onSelectionChanged: (Set<SearchWhere> newSelection) {
                        setModalState(() {
                          vm.searchWhere = newSelection.first;
                          vm.refreshCardListCommand();
                        });
                      },
                    ),
                  ])),
              SegmentedButton<SortType>(
                segments: const <ButtonSegment<SortType>>[
                  ButtonSegment<SortType>(value: SortType.none, label: Text('all'), icon: Icon(Icons.abc)),
                  ButtonSegment<SortType>(value: SortType.star, label: Text('starred'), icon: Icon(Icons.star)),
                  ButtonSegment<SortType>(value: SortType.mostUsed, label: Text('most used'), icon: Icon(Icons.upload)),
                  ButtonSegment<SortType>(
                      value: SortType.recentUsed, label: Text('recent'), icon: Icon(Icons.schedule)),
                ],
                selected: <SortType>{vm.sortType},
                onSelectionChanged: (Set<SortType> newSelection) {
                  setModalState(() {
                    vm.sortType = newSelection.first;
                    vm.refreshCardListCommand();
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  onChanged: (value) {
                    vm.searchText = value;
                    vm.refreshCardListCommand();
                  },
                  onFieldSubmitted: (value) {
                    Navigator.pop(context);
                  },
                  textInputAction: TextInputAction.search,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: _widgetFactory.textTheme.labelMedium,
                  controller: _searchController,
                  decoration:
                      _widgetFactory.blastTextFieldDecoration('Search', 'Enter your search text', onPressed: () {
                    setModalState(() {
                      vm.clearSearchTextCommand();
                      _searchController.clear();
                    });
                  }),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
