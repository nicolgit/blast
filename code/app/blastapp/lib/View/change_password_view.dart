import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/change_password_viewmodel.dart';
import 'package:blastmodel/currentfile_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<StatefulWidget> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final passwordController = TextEditingController();
  final filenameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChangePasswordViewModel(context),
      child: Consumer<ChangePasswordViewModel>(
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

  void _showIterationsInfo(BuildContext context, ChangePasswordViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Iterations'),
          content: const Text(
            'Iterations are used by Blast to generate a secure key from your password (PBKDF2KeyDerivator). '
            'A higher number of iterations makes your file more secure, but opening it may slow down. '
            'Choose a balance that works for you.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  late ThemeData _theme;
  late TextTheme _textTheme;
  late TextStyle _textThemeHint;
  late TextStyle _textThemeError;

  Widget _buildScaffold(BuildContext context, ChangePasswordViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);
    _textThemeHint = _textTheme.bodySmall!.copyWith(color: _theme.colorScheme.onSurface.withValues(alpha: 0.5));
    _textThemeError = _textTheme.bodySmall!.copyWith(color: _theme.colorScheme.error);

    return Scaffold(
      backgroundColor: _theme.colorScheme.surface,
      body: Center(
          child: Column(children: [
        AppBar(
          title: const Text("Change your password"),
        ),
        Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(children: [
                  const SizedBox(height: 12.0),
                  Icon(Icons.lock, color: _theme.colorScheme.error, size: 48.0),
                  const SizedBox(height: 12.0),
                  Text(
                    'choose the new master password of your blast file',
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
                  Text(
                    'Current PBKDF2KeyDerivator iterations: ${CurrentFileService().iterations}',
                    style: _textTheme.labelSmall,
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'New PBKDF2KeyDerivator iterations: ${ChangePasswordViewModel.iterationsList[vm.iterationLevel]}',
                          style: _textTheme.labelSmall),
                      const SizedBox(width: 8.0),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showIterationsInfo(context, vm),
                        iconSize: 18.0,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Slider(
                      value: vm.iterationLevel.toDouble(),
                      min: 0,
                      max: (ChangePasswordViewModel.iterationsList.length - 1).toDouble(),
                      divisions: ChangePasswordViewModel.iterationsList.length - 1,
                      onChanged: (value) {
                        vm.setIterationLevel(value.toInt());
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  FutureBuilder<bool>(
                    future: vm.passwordsMatch(),
                    builder: (context, passwordsMatch) =>
                        Text(passwordsMatch.data ?? true ? "" : "passwords don't match", style: _textThemeError),
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
                        'change password',
                      ),
                    ),
                  ),
                ])))
      ])),
    );
  }
}
