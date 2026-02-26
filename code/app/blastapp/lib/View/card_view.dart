import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_viewmodel.dart';
import 'package:blastapp/blastwidget/blast_markdown_text.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastapp/blastwidget/blast_attribute_row.dart';
import 'package:blastapp/blastwidget/file_changed_banner.dart';
import 'package:blastapp/blastwidget/blast_card_icon.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:humanizer/humanizer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; //for date formate locale

@RoutePage()
class CardView extends StatefulWidget {
  const CardView({super.key, required this.card});
  final BlastCard card;

  @override
  State<StatefulWidget> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
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

  late BlastWidgetFactory _widgetFactory;

  Widget _buildScaffold(BuildContext context, CardViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);
    //_theme = Theme.of(context);
    //_textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);

    return SafeArea(
        child: Scaffold(
            backgroundColor: _widgetFactory.viewBackgroundColor(),
            appBar: AppBar(
              title: Text(vm.currentCard.title != null ? vm.currentCard.title! : "No Title"),
              actions: [
                Row(
                  children: [
                    const Text('Edit Mode'),
                    Switch(
                      value: vm.editMode,
                      onChanged: (value) {
                        vm.toggleEditMode(value);
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                  onPressed: () {
                    vm.editCommand();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Quit',
                  onPressed: () {
                    vm.closeCommand();
                  },
                ),
              ],
            ),
            body: Column(children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Center(
                          child: Column(children: [
                const SizedBox(height: 16),
                BlastCardIcon(card: vm.currentCard, size: 128),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: vm.currentCard.isFavorite
                            ? Icon(
                                Icons.star,
                                color: Colors.amber,
                              )
                            : Icon(Icons.star_border, color: _widgetFactory.theme.colorScheme.primary),
                        tooltip: "toggle favorite",
                        onPressed: () {
                          vm.toggleFavorite();
                        }),
                    Center(
                        child: Text(vm.currentCard.title != null ? vm.currentCard.title! : "",
                            textAlign: TextAlign.center,
                            style: _widgetFactory.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold))),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: ValueListenableBuilder<int>(
                    valueListenable: vm.timeTextNotifier,
                    builder: (context, _, __) => Text(
                      "updated on ${DateFormat.yMMMEd().format(vm.currentCard.lastUpdateDateTime)}, used ${vm.currentCard.usedCounter} times, last time ${vm.currentCard.lastUpdateDateTime.difference(DateTime.now()).toApproximateTime()}",
                      style: _widgetFactory.textTheme.labelSmall,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _rowOfTags(vm.currentCard.tags),
                const SizedBox(height: 12),
                FutureBuilder<List<BlastAttribute>>(
                    future: vm.getRows(),
                    builder: (context, cardsList) {
                      return Container(
                        child: _buildAttributesList(cardsList.data ?? [], vm),
                      );
                    }),
              ])))),
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
            ])));
  }

  Column _buildAttributesList(List<BlastAttribute> cardsList, CardViewModel vm) {
    List<Widget> children = [];

    for (int index = 0; index < cardsList.length; index++) {
      children.add(BlastAttributeRow(
        attribute: cardsList[index],
        index: index,
        toggleShowPassword: vm.toggleShowPassword,
        isPasswordRowVisible: vm.isPasswordRowVisible,
        copyToClipboard: vm.copyToClipboard,
        showFieldView: vm.showFieldView,
        openUrl: vm.openUrl,
        editMode: vm.editMode,
        editField: (attribute) {
          _showEditFieldDialog(context, attribute, vm);
        },
      ));
    }

    if (vm.currentCard.notes != null) {
      children.add(_showNotes(vm.currentCard.notes!, vm));
    }

    return Column(children: children);
  }

  void _showEditFieldDialog(BuildContext context, BlastAttribute attribute, CardViewModel vm) {
    final controller = TextEditingController(text: attribute.value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(attribute.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Value',
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              vm.updateAttributeValue(attribute, controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Wrap _rowOfTags(List<String> tags) {
    List<Widget> rowItems = [];
    for (var tag in tags) {
      rowItems.add(_widgetFactory.blastTag(tag));
    }

    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      alignment: WrapAlignment.center,
      children: rowItems,
    );
  }

  Widget _showNotes(String notes, CardViewModel vm) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 600, minWidth: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _widgetFactory.theme.colorScheme.secondaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Notes",
                            style: _widgetFactory.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.copy, size: 18, color: _widgetFactory.theme.colorScheme.primary),
                          tooltip: 'Copy notes to clipboard',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: notes));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Notes copied to clipboard!"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: BlastMarkdownText(
                        text: notes,
                        style: _widgetFactory.textTheme.bodyMedium,
                        styleHeader: _widgetFactory.textTheme.titleMedium!.copyWith(
                          color: _widgetFactory.theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}
