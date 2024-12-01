import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/create_password_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class CreatePasswordView extends StatefulWidget {
  const CreatePasswordView({super.key});

  @override
  State<StatefulWidget> createState() => _CreatePasswordViewState();
}

class _CreatePasswordViewState extends State<CreatePasswordView> {
  final passwordController = TextEditingController();
  final filenameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreatePasswordViewModel(context),
      child: Consumer<CreatePasswordViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    confirmPasswordController.dispose();
    filenameController.dispose();
    super.dispose();
  }

  late ThemeData _theme;
  late TextTheme _textTheme;
  late TextStyle _textThemeHint;
  late TextStyle _textThemeError;

  Widget _buildScaffold(BuildContext context, CreatePasswordViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);
    _textThemeHint = _textTheme.bodySmall!.copyWith(color: _theme.colorScheme.onSurface.withOpacity(0.5));
    _textThemeError = _textTheme.bodySmall!.copyWith(color: _theme.colorScheme.error);

    return Scaffold(
      backgroundColor: _theme.colorScheme.surface,
      body: Center(
          child: Column(children: [
        AppBar(
          title: const Text("Create a new file"),
        ),
        Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(children: [
                  const SizedBox(height: 12.0),
                  Icon(Icons.edit_document, color: _theme.colorScheme.primary, size: 48.0),
                  Text(
                    "choose a file name for your blast file",
                    style: _textTheme.labelMedium,
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                      autofocus: true,
                      onChanged: (value) => vm.setFilename(value),
                      controller: filenameController,
                      style: _textTheme.labelMedium,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Filename',
                          hintText: 'Choose a name for your file',
                          hintStyle: _textThemeHint)),
                  const SizedBox(height: 12.0),
                  Icon(Icons.lock, color: _theme.colorScheme.error, size: 48.0),
                  const SizedBox(height: 12.0),
                  Text(
                    'choose a master password to protect your blast file',
                    style: _textTheme.labelMedium,
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    obscureText: true,
                    onChanged: (value) => vm.setPassword(value),
                    controller: passwordController,
                    style: _textTheme.labelMedium,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'master password',
                        hintText: 'Choose a password for your file',
                        hintStyle: _textThemeHint),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    obscureText: true,
                    controller: confirmPasswordController,
                    style: _textTheme.labelMedium,
                    onChanged: (value) => vm.setConfirmPassword(value),
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Confirm Password',
                        hintText: 'confirm password for your file',
                        hintStyle: _textThemeHint),
                  ),
                  const SizedBox(height: 12.0),
                  FutureBuilder<bool>(
                    future: vm.passwordsMatch(),
                    builder: (context, passwordsMatch) =>
                        Text(passwordsMatch.data ?? true ? "" : "passwords don't match", style: _textThemeError),
                  ),
                  FutureBuilder<bool>(
                    future: vm.isFilenameNotEmpty(),
                    builder: (context, filenameNotEmpty) =>
                        Text(filenameNotEmpty.data ?? true ? "" : "filename can't be empty", style: _textThemeError),
                  ),
                  FutureBuilder<bool>(
                    future: vm.isPasswordsNotEmpty(),
                    builder: (context, passwordsNotEmpty) =>
                        Text(passwordsNotEmpty.data ?? true ? "" : "passwords can't be empty", style: _textThemeError),
                  ),
                  const SizedBox(height: 12.0),
                  FutureBuilder<bool>(
                    future: vm.isFormReadyToConfirm(),
                    builder: (context, isFormReadyToConfirm) => FilledButton(
                      onPressed: isFormReadyToConfirm.data ?? true ? () => vm.acceptPassword() : null,
                      child: const Text(
                        'create a new file',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  FutureBuilder<bool>(
                    future: vm.isFormReadyToConfirm(),
                    builder: (context, isFormReadyToConfirm) => FilledButton(
                      onPressed: isFormReadyToConfirm.data ?? true ? () => vm.acceptAndImport() : null,
                      child: const Text(
                        'import from another password manager',
                      ),
                    ),
                  ),
                ])))
      ])),
    );
  }
}
