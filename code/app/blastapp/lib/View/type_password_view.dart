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
  late TextStyle _textThemeHint;
  late TextStyle _textThemeError;

  Widget _buildScaffold(BuildContext context, TypePasswordViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onBackground);
    _textThemeHint = _textTheme.bodySmall!.copyWith(color: _theme.colorScheme.onBackground.withOpacity(0.5));
    _textThemeError = _textTheme.bodySmall!.copyWith(color: _theme.colorScheme.error);

    return Scaffold(
      backgroundColor: _theme.colorScheme.background,
      body: Center(
          child: Column(
        children: [
          AppBar(
            title: Text("open file: ${vm.fileName}"),
          ),
          const SizedBox(height: 12.0),
          FutureBuilder<bool>(
            future: vm.isPasswordValid(),
            builder: (context, isPasswordValid) {
              return Icon(isPasswordValid.data ?? false ? Icons.lock_open : Icons.lock,
                  color: _theme.colorScheme.primary, size: 48.0);
            },
          ),
          Text('type the master password to open your blast file', style: _textTheme.labelMedium),
          const SizedBox(height: 12.0),
          Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                autofocus: true,
                focusNode: passwordFocusNode,
                obscureText: true,
                controller: passwordController,
                onChanged: (value) => vm.setPassword(value),
                onSubmitted: (value) async => {
                  if (!await vm.checkPassword()) passwordFocusNode.requestFocus(),
                },
                style: _textTheme.labelMedium,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    hintStyle: _textThemeHint),
              )),
          Text(vm.errorMessage, style: _textThemeError),
          FutureBuilder<bool>(
            future: vm.isCheckingPassword(),
            builder: (context, isCheckingPassword) {
              if (isCheckingPassword.data ?? false) {
                return Text("checking password...", style: _textTheme.labelMedium);
              } else {
                return Text("", style: _textTheme.labelMedium);
              }
            },
          ),
          FutureBuilder<bool>(
            future: vm.isPasswordValid(),
            builder: (context, isPasswordValid) {
              return FilledButton(
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
