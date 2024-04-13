import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/cards_browser_viewmodel.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
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

  Widget _buildScaffold(BuildContext context, CardsBrowserViewModel vm) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.question_mark),
              onPressed: () {},
            ),
            TextButton.icon(
              onPressed: () {
                _showModalBottomSheet(context, vm);
              },
              icon: const Icon(
                Icons.search,
                size: 24.0,
              ),
              label: const Text('Search'),
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
                    Widget cancelButton = TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop(); // dismiss dialod
                      },
                    );
                    Widget noButton = TextButton(
                      child:
                          const Text("No, just exit", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
                        vm.closeCommand();
                      },
                    );
                    Widget okButton = TextButton(
                      child: const Text("Yes save it"),
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
            child: const Text('BlastApp'),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('import .json file'),
            onTap: () {
              Navigator.pop(context); // close drawer

              Widget noButton = TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
                },
              );

              Widget okButton = TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                child: const Text("Yes import it anyway"),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog

                  try {
                    await vm.importCommand();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("unable to import selected file. Please check the file format."),
                    ));
                  }
                },
              );

              AlertDialog alert = AlertDialog(
                title: const Text("import blast .json file"),
                content: const Text(
                    "WARNING: Importing a Blast .json file here will overwrite all the current file content. Are you sure to continue?"),
                actions: [
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
        ],
      )),
    );
  }

  ListView _buildCardsList(List<BlastCard> cardsList, CardsBrowserViewModel vm) {
    var myList = ListView.separated(
      itemCount: cardsList.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        String name = cardsList[index].title != null ? cardsList[index].title! : '';
        bool isFavorite = cardsList[index].isFavorite;

        return ListTile(
          leading: const Icon(Icons.file_copy_outlined),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  vm.editCard(cardsList[index]).then((value) {
                    vm.refreshCardListCommand();
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteCardDialog(context, vm, cardsList[index]);
                },
              ),
            ],
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Row(
            children: [
              Visibility(
                visible: isFavorite,
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                ),
              ),
              Text(
                  'used ${cardsList[index].usedCounter} times, last time ${cardsList[index].lastUpdateDateTime.difference(DateTime.now()).toApproximateTime()}'),
              _buildTagsRow(cardsList[index].tags),
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

  Row _buildTagsRow(List<String> tags) {
    List<MultiSelectItem<String>> mscdTags = tags.map((tag) {
      final val = MultiSelectItem<String>(tag, tag);
      val.selected = false;
      return val;
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MultiSelectChipDisplay(
          items: mscdTags,
          onTap: (value) {
            setState(() {
              //value.selected = !value.selected;
            });
          },
          textStyle: const TextStyle(fontSize: 12),
        )
      ],
    );
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

  void _showModalBottomSheet(BuildContext context, CardsBrowserViewModel vm) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
          return Wrap(
            runSpacing: 12,
            spacing: 12,
            children: [
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
                  initialValue: vm.searchText,
                  onChanged: (value) {
                    vm.searchText = value;
                    vm.refreshCardListCommand();
                  },
                  autofocus: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Search',
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
