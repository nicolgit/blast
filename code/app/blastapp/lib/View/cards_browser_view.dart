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
        String name = cardsList[index].title;

        return ListTile(
          leading: const Icon(Icons.file_copy_outlined),
          title: Row(
            children: [
              Text(name),
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
}
