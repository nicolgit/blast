import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_viewmodel.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                  //vm.closeCommand();
                },
              ),
            ],
          ),
          const Text('title'),
          Text(vm.currentCard.title != null ? vm.currentCard.title! : "",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const Text('notes'),
          Text(vm.currentCard.notes != null ? vm.currentCard.notes! : "",
              style: const TextStyle(fontWeight: FontWeight.bold)),
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
              leading: const Icon(Icons.file_copy_outlined),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          case BlastAttributeType.typePassword:
            return ListTile(
              leading: const Icon(Icons.file_copy_outlined),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name),
                  const Text("***********", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [
                    TextButton(
                        onPressed: () {
                          vm.copyToClipboard(value);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("secret copied to clipboard!"),
                          ));
                        },
                        child: const Text("copy to clipboard")),
                    TextButton(
                        onPressed: () {
                          vm.copyToClipboard(value);
                        },
                        child: const Text("show/hide not working yet")),
                  ]),
                ],
              ),
            );
          case BlastAttributeType.typeURL:
            return ListTile(
              leading: const Icon(Icons.web_asset),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name),
                  Text(value,
                      style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  Row(children: [
                    TextButton(
                        onPressed: () {
                          vm.copyToClipboard(value);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("secret copied to clipboard!"),
                          ));
                        },
                        child: const Text("copy to clipboard")),
                    TextButton(
                        onPressed: () {
                          vm.copyToClipboard(value);
                        },
                        child: const Text("open in browser - not working yet")),
                  ]),
                ],
              ),
            );
          case BlastAttributeType.typeString:
          default:
            return ListTile(
              leading: const Icon(Icons.file_copy_outlined),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      children: [
        const Text('TAGS: '),
        for (var tag in tags) Text("[$tag] "),
      ],
    );
  }
}
