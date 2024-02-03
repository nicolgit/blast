import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_viewmodel.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
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
                    vm.refresh();
                  })
                  ;
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
          const Text('title'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vm.currentCard.title != null ? vm.currentCard.title! : "",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Icon(vm.currentCard.isFavorite ? Icons.star : Icons.star_border)
            ],
          ),
          Text(
              "updated on ${DateFormat.yMMMEd().format(vm.currentCard.lastUpdateDateTime)}, used ${vm.currentCard.usedCounter} times, last time used ${DateFormat.yMMMEd().format(vm.currentCard.lastOpenedDateTime)}, about ${vm.currentCard.lastOpenedDateTime.difference(DateTime.now()).toApproximateTime()} "),
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
      itemCount: cardsList.length,
      itemBuilder: (context, index) {
        String name = cardsList[index].name;
        String value = cardsList[index].value;
        final type = cardsList[index].type;

        switch (type) {
          case BlastAttributeType.typeHeader:
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          case BlastAttributeType.typePassword:
            return ListTile(
              leading: const Icon(Icons.lock),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(name),
                  const Text(": "),
                  Text(vm.isPasswordRowVisible(index) ? value : "***********",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Row(children: [
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
                    Visibility(
                      visible: !vm.isPasswordRowVisible(index),
                      child: IconButton(
                      onPressed: () {
                        vm.toggleShowPassword(index);
                      },
                      icon: const Icon(Icons.visibility_off),
                      tooltip: 'hide',
                    ), ),
                    Visibility(
                      visible: vm.isPasswordRowVisible(index),
                      child: IconButton(
                      onPressed: () {
                        vm.toggleShowPassword(index);
                      },
                      icon: const Icon(Icons.visibility),
                      tooltip: 'hide',
                    ), ),
                    
                  ]),
                ],
              ),
            );
          case BlastAttributeType.typeURL:
            return ListTile(
              leading: const Icon(Icons.link),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(name),
                  const Text(": "),
                  TextButton(
                    onPressed: () {
                      vm.openUrl(value);
                    },
                    child: Text(value,
                        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  ),
                  Row(children: [
                    IconButton(
                      onPressed: () {
                        vm.copyToClipboard(value);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("copied to clipboard!"),
                        ));
                      },
                      icon: const Icon(Icons.copy),
                      tooltip: 'copy to clipboard',
                    ),
                  ]),
                ],
              ),
            );
          case BlastAttributeType.typeString:
          default:
            return ListTile(
              leading: const Icon(Icons.description),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(name),
                  const Text(": "),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () {
                      vm.copyToClipboard(value);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("copied to clipboard!"),
                      ));
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: 'copy to clipboard',
                  ),
                ],
              ),
            );
        }
      },
    );

    return myList;
  }

  Row _rowOfTags(List<String> tags) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var tag in tags) // Text("[$tag] "),
          Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(6))),
              padding: const EdgeInsets.all(1),
              child: Text(tag)),
      ],
    );
  }
}
