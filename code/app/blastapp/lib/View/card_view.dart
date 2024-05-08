import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_viewmodel.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:humanizer/humanizer.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
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
  final BlastCard card = BlastCard();

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

  Widget _buildScaffold(BuildContext context, CardViewModel vm) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          AppBar(
            title: Text(vm.currentCard.title != null ? vm.currentCard.title! : "No Title"),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () {
                  vm.editCommand().then((value) {
                    vm.closeCommand();
                  });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vm.currentCard.title != null ? vm.currentCard.title! : "",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                  icon: vm.currentCard.isFavorite ? const Icon(Icons.star) : const Icon(Icons.star_border),
                  tooltip: "toggle favorite",
                  onPressed: () {
                    vm.toggleFavorite();
                  })
            ],
          ),
          Text(
              "updated on ${DateFormat.yMMMEd().format(vm.currentCard.lastUpdateDateTime)}, used ${vm.currentCard.usedCounter} times, last used ${vm.currentCard.lastOpenedDateTime.difference(DateTime.now()).toApproximateTime()} "),
          _rowOfTags(vm.currentCard.tags),
          FutureBuilder<List<BlastAttribute>>(
              future: vm.getRows(),
              builder: (context, cardsList) {
                return Expanded(
                  child: Container(
                    child: _buildAttributesList(cardsList.data ?? [], vm),
                  ),
                );
              }),
        ],
      ),
    ));
  }

  ListView _buildAttributesList(List<BlastAttribute> cardsList, CardViewModel vm) {
    var myList = ListView.builder(
      itemCount: cardsList.length + 1,
      itemBuilder: (context, index) {
        if (index == cardsList.length && vm.currentCard.notes != null) {
          return _showNotes(vm.currentCard.notes!, vm);
        }

        String name = cardsList[index].name;
        String value = cardsList[index].value;
        final type = cardsList[index].type;

        switch (type) {
          case BlastAttributeType.typeHeader:
            return ListTile(
              title: Container(
                padding: const EdgeInsets.fromLTRB(0, 48, 0, 0),
                child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
              ),
              onTap: () async {},
            );
          case BlastAttributeType.typePassword:
            return ListTile(
              leading: const Icon(Icons.lock),
              title: Text(vm.isPasswordRowVisible(index) ? value : "***********",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              subtitle: Text(name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: !vm.isPasswordRowVisible(index),
                    child: IconButton(
                      onPressed: () {
                        vm.toggleShowPassword(index);
                      },
                      icon: const Icon(Icons.visibility_off),
                      tooltip: 'hide',
                    ),
                  ),
                  Visibility(
                    visible: vm.isPasswordRowVisible(index),
                    child: IconButton(
                      onPressed: () {
                        vm.toggleShowPassword(index);
                      },
                      icon: const Icon(Icons.visibility),
                      tooltip: 'hide',
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      vm.copyToClipboard(value);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("secret copied to clipboard!"),
                      ));
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: 'copy to clipboard',
                  ),
                ],
              ),
              onTap: () async {},
            );
          case BlastAttributeType.typeURL:
            return ListTile(
              leading: const Icon(Icons.link),
              title: InkWell(
                onTap: () {
                  vm.openUrl(value);
                },
                child: Text(value,
                    style: const TextStyle(
                        decoration: TextDecoration.underline, color: Colors.blue, decorationColor: Colors.blue)),
              ),
              subtitle: Text(name),
              trailing: IconButton(
                onPressed: () {
                  vm.copyToClipboard(value);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("secret copied to clipboard!"),
                  ));
                },
                icon: const Icon(Icons.copy),
                tooltip: 'copy to clipboard',
              ),
              onTap: () async {},
            );
          case BlastAttributeType.typeString:
          default:
            return ListTile(
              leading: const Icon(Icons.description),
              title: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(name),
              trailing: IconButton(
                onPressed: () {
                  vm.copyToClipboard(value);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("copied to clipboard!"),
                  ));
                },
                icon: const Icon(Icons.copy),
                tooltip: 'copy to clipboard',
              ),
              onTap: () async {},
            );
        }
      },
    );

    return myList;
  }

  Row _rowOfTags(List<String> tags) {
    List<MultiSelectItem<String>> mscdTags = tags.map((tag) => MultiSelectItem<String>(tag, tag)).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MultiSelectChipDisplay(
          items: mscdTags,
          /*onTap: (value) {
            setState(() {
              _selectedAnimals.remove(value);
            });
          }*/
        )
      ],
    );
  }

  Column _showNotes(String notes, CardViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Notes", style: TextStyle(fontWeight: FontWeight.bold)),
        SelectableText(notes, style: const TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  }
}
