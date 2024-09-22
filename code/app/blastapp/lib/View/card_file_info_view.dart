import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/card_file_info_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class CardFileInfoView extends StatefulWidget {
  const CardFileInfoView({super.key});

  @override
  State<CardFileInfoView> createState() => _CardFileInfoViewState();
}

class _CardFileInfoViewState extends State<CardFileInfoView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardFileInfoViewModel(context),
      child: Consumer<CardFileInfoViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;
  late TextTheme _textTheme;

  Widget _buildScaffold(BuildContext context, CardFileInfoViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);

    return Scaffold(
        backgroundColor: _theme.colorScheme.surface,
        body: const SingleChildScrollView(
            child: Center(
          child: Column(children: [
            Text("sample text"),
          ]),
        )));
  }
}
