import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/cards_browser_viewmodel.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastapp/blastwidget/file_changed_banner.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:blastmodel/blastdocument.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:blastmodel/secrets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:humanizer/humanizer.dart';
import 'package:lottie/lottie.dart';

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
  late ThemeData _theme;
  late TextTheme _textTheme;

  final FocusNode _focusNode = FocusNode();
  Widget _buildScaffold(BuildContext context, CardsBrowserViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);

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
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _widgetFactory.viewBackgroundColor(),
                bottomNavigationBar: BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Tooltip(
                          message: 'Generate password',
                          child: TextButton.icon(
                            label: const Text('Generate password'),
                            icon: const Icon(Icons.password, size: 24.0),
                            onPressed: () {
                              vm.goToPasswordGenerator();
                            },
                          )),
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
                      Tooltip(
                          message: 'open settings',
                          child: TextButton.icon(
                            label: const Text('Settings'),
                            icon: const Icon(Icons.settings, size: 24.0),
                            onPressed: () {
                              vm.goToSettings();
                            },
                          )),
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
                            onPressed: () async {
                              if (await vm.saveCommand()) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text("file saved successfully!"),
                                ));
                              }
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
                                onPressed: () async {
                                  Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
                                  await vm.saveCommand();
                                  vm.closeCommand();
                                },
                              );

                              if (vm.isFileChanged()) {
                                AlertDialog alert = AlertDialog(
                                  backgroundColor: Colors.white,
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
                      FileChangedBanner(
                        isFileChangedFuture: vm.isFileChangedAsync(),
                        onSavePressed: () async {
                          if (await vm.saveCommand()) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("file saved successfully!"),
                              ));
                            }
                          }
                        },
                      ),
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
                drawer: _buildHamburgetMenu(context, vm))));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildCardsList(List<BlastCard> cardsList, CardsBrowserViewModel vm) {
    List<String> searchTerms = vm.searchText.split(' ').where((term) => term.isNotEmpty).toList();
    if (cardsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/general/man-walking.json',
                repeat: true,
                reverse: false,
                animate: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'This app is sad without cards, create a card now!',
              style: _widgetFactory.textTheme.labelMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                vm.addCard().then((value) {
                  vm.refreshCardListCommand();
                });
              },
              child: const Text('Create Card'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 600.0,
            mainAxisExtent: 180.0,
          ),
          padding: const EdgeInsets.all(8.0),
          itemCount: cardsList.length,
          itemBuilder: (context, index) {
            return _buildCardItem(
              card: cardsList[index],
              onEditPressed: (card) => vm.editCard(card).then((value) {
                vm.refreshCardListCommand();
              }),
              onDeletePressed: (card) => _showDeleteCardDialog(context, vm, card),
              onFavoritePressed: (card) {
                card.isFavorite = !card.isFavorite;
                card.lastUpdateDateTime = DateTime.now();
                CurrentFileService().currentFileDocument!.isChanged = true;
                vm.refreshCardListCommand();
              },
              onTap: (card) => vm.selectCard(card).then((value) {
                vm.refreshCardListCommand();
              }),
              isSelected: vm.selectedCard != null ? vm.selectedCard!.id == cardsList[index].id : false,
              textToHighlight: searchTerms,
            );
          },
        );
      },
    );
  }

  Widget _buildCardItem({
    required BlastCard card,
    required Function(BlastCard) onEditPressed,
    required Function(BlastCard) onDeletePressed,
    required Function(BlastCard) onFavoritePressed,
    required Function(BlastCard) onTap,
    required bool isSelected,
    required List<String> textToHighlight,
  }) {
    String name = card.title != null ? card.title! : '';
    bool isFavorite = card.isFavorite;

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Card(
            elevation: 6,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(
                child: ListTile(
                  leading: _widgetFactory.blastCardIcon(name, isFavorite ? Colors.amber : _theme.colorScheme.primary),
                  tileColor: _theme.colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                  title: Row(children: [
                    Visibility(
                      visible: isFavorite,
                      child: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                    ),
                    Expanded(
                        child:
                            _buildHighlightedText(name, textToHighlight, const TextStyle(fontWeight: FontWeight.bold)))
                  ]),
                  subtitle: Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    'used ${card.usedCounter} times, last time ${card.lastUpdateDateTime.difference(DateTime.now()).toApproximateTime()}',
                  ),
                  selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                  selected: isSelected,
                  onTap: () async {
                    onTap(card);
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: _widgetFactory.theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6))),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: [
                      Expanded(child: _buildTagsRow(card.tags)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.star : Icons.star_border,
                              color: isFavorite ? Colors.amber : _widgetFactory.theme.colorScheme.secondary,
                            ),
                            onPressed: () {
                              onFavoritePressed(card);
                            },
                            tooltip: isFavorite ? "remove from favorites" : "add to favorites",
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: _widgetFactory.theme.colorScheme.secondary),
                            onPressed: () {
                              onEditPressed(card);
                            },
                            tooltip: "edit",
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: _widgetFactory.theme.colorScheme.secondary),
                            onPressed: () {
                              onDeletePressed(card);
                            },
                            tooltip: "delete",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ])));
  }

  Wrap _buildTagsRow(List<String> tags) {
    List<Widget> rowItems = [];
    for (var tag in tags) {
      rowItems.add(_widgetFactory.blastTag(tag));
    }
    return Wrap(spacing: 6.0, runSpacing: 6.0, children: rowItems);
  }

  Future _showDeleteCardDialog(BuildContext context, CardsBrowserViewModel vm, BlastCard card) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Wrap(alignment: WrapAlignment.center, spacing: 6.0, runSpacing: 6.0, children: [
                        Tooltip(
                          message: 'toggle favorites only',
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  vm.favoritesOnly ? _theme.colorScheme.secondaryContainer : _theme.colorScheme.surface,
                              border: Border.all(
                                color: _theme.colorScheme.outline,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20.0),
                                onTap: () {
                                  setModalState(() {
                                    vm.favoritesOnly = !vm.favoritesOnly;
                                    vm.refreshCardListCommand();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                                  child: Icon(
                                    Icons.star,
                                    color: vm.favoritesOnly
                                        ? _theme.colorScheme.onSecondaryContainer
                                        : _theme.colorScheme.onSurface,
                                    size: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'search operator',
                          child: SegmentedButton<SearchOperator>(
                            segments: const <ButtonSegment<SearchOperator>>[
                              ButtonSegment<SearchOperator>(
                                  value: SearchOperator.and,
                                  label: Text('and'),
                                  icon: Icon((Icons.radio_button_unchecked))),
                              ButtonSegment<SearchOperator>(
                                  value: SearchOperator.or,
                                  label: Text('or'),
                                  icon: Icon(Icons.radio_button_unchecked)),
                            ],
                            selected: <SearchOperator>{vm.searchOperator},
                            onSelectionChanged: (Set<SearchOperator> newSelection) {
                              setModalState(() {
                                vm.searchOperator = newSelection.first;
                                vm.refreshCardListCommand();
                              });
                            },
                          ),
                        ),
                        Tooltip(
                          message: 'search scope',
                          child: SegmentedButton<SearchWhere>(
                            segments: const <ButtonSegment<SearchWhere>>[
                              ButtonSegment<SearchWhere>(
                                  value: SearchWhere.title, label: Text('title'), icon: Icon(Icons.subject)),
                              ButtonSegment<SearchWhere>(
                                  value: SearchWhere.everywhere, label: Text('all'), icon: Icon(Icons.all_inclusive)),
                            ],
                            selected: <SearchWhere>{vm.searchWhere},
                            onSelectionChanged: (Set<SearchWhere> newSelection) {
                              setModalState(() {
                                vm.searchWhere = newSelection.first;
                                vm.refreshCardListCommand();
                              });
                            },
                          ),
                        ),
                        Tooltip(
                          message: 'sort type',
                          child: SegmentedButton<SortType>(
                            segments: const <ButtonSegment<SortType>>[
                              ButtonSegment<SortType>(
                                  value: SortType.mostUsed, label: Text('used'), icon: Icon(Icons.upload)),
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
                        ),
                      ])),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 6.0),
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
              ));
        });
      },
    );
  }

  Widget _buildHamburgetMenu(BuildContext context, CardsBrowserViewModel vm) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Column(
            children: [
              const Image(image: AssetImage('assets/general/icon-v01.png'), width: 102, height: 102),
              Text("build ${Secrets.buildNumber}",
                  style: _textTheme.labelMedium?.copyWith(color: _theme.colorScheme.onPrimary)),
            ],
          ),
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
                backgroundColor: Colors.white,
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
          title: const Text('show master key'),
          onTap: () {
            Navigator.pop(context); // close drawer

            vm.exportMasterKeyCommand();
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock_reset),
          title: const Text('change password'),
          onTap: () {
            Navigator.pop(context); // close drawer

            vm.changePasswordCommand();
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('settings'),
          onTap: () {
            Navigator.pop(context); // close drawer

            vm.goToSettings();
          },
        ),
      ],
    ));
  }

  Widget _buildHighlightedText(String text, List<String> textToHighlight, TextStyle? style) {
    if (textToHighlight.isEmpty) {
      return Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: style,
      );
    }

    List<TextSpan> spans = [];
    String remainingText = text;

    // Ensure the base style has proper color
    TextStyle baseStyle = style?.copyWith(
          color: style.color ?? _theme.colorScheme.onSurface,
        ) ??
        TextStyle(color: _theme.colorScheme.onSurface);

    while (remainingText.isNotEmpty) {
      String? foundTerm;
      int foundIndex = -1;

      // Find the first occurrence of any highlight term
      for (String term in textToHighlight) {
        int index = remainingText.toLowerCase().indexOf(term.toLowerCase());
        if (index != -1 && (foundIndex == -1 || index < foundIndex)) {
          foundIndex = index;
          foundTerm = term;
        }
      }

      if (foundIndex == -1) {
        // No more terms to highlight, add the rest as normal text
        spans.add(TextSpan(text: remainingText, style: baseStyle));
        break;
      } else {
        // Add text before the highlighted term
        if (foundIndex > 0) {
          spans.add(TextSpan(text: remainingText.substring(0, foundIndex), style: baseStyle));
        }

        // Add the highlighted term
        String actualTerm = remainingText.substring(foundIndex, foundIndex + foundTerm!.length);
        spans.add(TextSpan(
          text: actualTerm,
          style: baseStyle.copyWith(
            backgroundColor: _theme.colorScheme.secondary,
            color: _theme.colorScheme.onSecondary,
          ),
        ));

        // Continue with the remaining text
        remainingText = remainingText.substring(foundIndex + foundTerm.length);
      }
    }

    return RichText(
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      text: TextSpan(children: spans),
    );
  }
}
