import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_viewmodel.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
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
  //late ThemeData _theme;
  //late TextTheme _textTheme;

  Widget _buildScaffold(BuildContext context, CardViewModel vm) {
    _widgetFactory = BlastWidgetFactory(context);
    //_theme = Theme.of(context);
    //_textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);

    return SafeArea(
        child: Scaffold(
            backgroundColor: _widgetFactory.viewBackgroundColor(),
            body: Center(
                child: Column(children: [
              AppBar(
                title: Text(vm.currentCard.title != null ? vm.currentCard.title! : "No Title"),
                actions: [
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
                                  onPressed: () async {
                                    if (await vm.saveCommand()) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text("file saved successfully!"),
                                        ));
                                      }
                                    }
                                  },
                                )),
                            Text('to save', style: TextStyle(color: _widgetFactory.theme.colorScheme.onError)),
                          ],
                        ),
                      ),
                    );
                  }),
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
                          textAlign: TextAlign.center, style: _widgetFactory.textTheme.titleLarge)),
                ],
              ),
              Text(
                "updated on ${DateFormat.yMMMEd().format(vm.currentCard.lastUpdateDateTime)}, used ${vm.currentCard.usedCounter} times, last time ${vm.currentCard.lastUpdateDateTime.difference(DateTime.now()).toApproximateTime()}",
                style: _widgetFactory.textTheme.labelSmall,
              ),
              const SizedBox(height: 12),
              _rowOfTags(vm.currentCard.tags),
              const SizedBox(height: 12),
              FutureBuilder<List<BlastAttribute>>(
                  future: vm.getRows(),
                  builder: (context, cardsList) {
                    return Expanded(
                      child: Container(
                        child: _buildAttributesList(cardsList.data ?? [], vm),
                      ),
                    );
                  }),
            ]))));
  }

  ListView _buildAttributesList(List<BlastAttribute> cardsList, CardViewModel vm) {
    var myList = ListView.builder(
      itemCount: cardsList.length + 1,
      itemBuilder: (context, index) {
        if (index == cardsList.length && vm.currentCard.notes != null) {
          return _showNotes(vm.currentCard.notes!, vm);
        }

        return _widgetFactory.buildAttributeRow(context, cardsList[index], index, vm.toggleShowPassword,
            vm.isPasswordRowVisible, vm.copyToClipboard, vm.showFieldView, vm.openUrl);
      },
    );

    return myList;
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
                  color: _widgetFactory.theme.colorScheme.tertiaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Notes", style: _widgetFactory.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SelectableText(notes,
                            style: _widgetFactory.textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic))),
                  ],
                ))));
  }
}
