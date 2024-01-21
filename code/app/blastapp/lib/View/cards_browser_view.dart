import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/cards_browser_viewmodel.dart';
import 'package:blastmodel/blastcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        body: Center(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            title: Text(vm.currentFileService.currentFileInfo!.fileName),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'close',
                onPressed: () {
                  // set up the buttons
                  Widget cancelButton = TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
                    },
                  );
                  Widget continueButton = TextButton(
                    child: const Text("Ok"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
                      vm.closeCommand();
                    },
                  );

                  AlertDialog alert = AlertDialog(
                    title: const Text("File changed"),
                    content: const Text("Are you sure you want to close it and loose all your updates?"),
                    actions: [
                      cancelButton,
                      continueButton,
                    ],
                  );
                  // show the dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
                  //vm.closeCommand();
                },
              ),
            ],
          ),
          const Text('your cards.'),
          FutureBuilder<List<BlastCard>>(
              future: vm.getCards(),
              builder: (context, cardsList) {
                return Expanded(
                  child: Container(
                    child: _buildFileList(cardsList.data ?? [], vm),
                  ),
                );
              }),
        ],
      ),
    ));
  }

  ListView _buildFileList(List<BlastCard> cardsList, CardsBrowserViewModel vm) {
    var myList = ListView.builder(
      itemCount: cardsList.length,
      itemBuilder: (context, index) {
        String name = cardsList[index].title != null ? cardsList[index].title! : '';
        bool isFavorite = cardsList[index].isFavorite;

        return ListTile(
          leading: const Icon(Icons.file_copy_outlined),
          title: Column(
            children: [
              Row(
                children: [
                  Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                  ),
                  Text('used ${cardsList[index].usedCounter} times'),
                  _buildTagsRow(cardsList[index].tags),
                ],
              ),
            ],
          ),
          onTap: () {
            vm.selectCard(cardsList[index]);
          },
        );
      },
    );

    return myList;
  }

  Row _buildTagsRow(List<String> tags) {
    return Row(
      children: [
        for (var tag in tags)
          Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              padding: const EdgeInsets.all(1),
              child: Text(tag)),
      ],
    );
  }
}
