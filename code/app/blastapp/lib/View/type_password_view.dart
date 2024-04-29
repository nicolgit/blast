import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/type_password_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class TypePasswordView extends StatefulWidget {
  const TypePasswordView({super.key});

  @override
  State<StatefulWidget> createState() => _TypePasswordViewState();
}

class _TypePasswordViewState extends State<TypePasswordView> {
  final passwordController = TextEditingController();
  late FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    passwordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TypePasswordViewModel(context),
      child: Consumer<TypePasswordViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }

  late ThemeData _theme;
  late TextTheme _textTheme;

  Widget _buildScaffold(BuildContext context, TypePasswordViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onBackground);

    return Scaffold(
      backgroundColor: _theme.colorScheme.background,
      body: Center(
          child: Column(
        children: [
          AppBar(
            title: Text("open file: ${vm.fileName}"),
          ),
          Text('type the master password to open your blast file', style: _textTheme.labelLarge),
          TextField(
            autofocus: true,
            focusNode: passwordFocusNode,
            obscureText: true,
            controller: passwordController,
            onChanged: (value) => vm.setPassword(value),
            onSubmitted: (value) async => {
              if (!await vm.checkPassword()) passwordFocusNode.requestFocus(),
            },
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Password', hintText: 'Enter your password'),
          ),
          Text(vm.errorMessage, style: const TextStyle(color: Colors.red)),
          FutureBuilder<bool>(
            future: vm.isCheckingPassword(),
            builder: (context, isCheckingPassword) {
              if (isCheckingPassword.data ?? false) {
                return const Text("checking password...");
              } else {
                return const Text("");
              }
            },
          ),
          FutureBuilder<bool>(
            future: vm.isPasswordValid(),
            builder: (context, isPasswordValid) {
              return TextButton(
                onPressed: isPasswordValid.data ?? false ? () => vm.checkPassword() : null,
                child: const Text('open'),
              );
            },
          ),
        ],
      )),
    );
  }
}
