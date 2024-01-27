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
        builder: (context, viewmodel, child) =>
            _buildScaffold(context, viewmodel),
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

  Widget _buildScaffold(BuildContext context, CreatePasswordViewModel vm) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          AppBar(
            title: const Text("Create a new file"),
          ),
          const Text("choone a file name for your blast file"),
          TextField(
            autofocus: true,
            onChanged: (value) => vm.setFilename(value),
            controller: filenameController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Filename',
                hintText: 'Choose a name for your file'),
          ),
          Text(vm.filenameError),
          const Text('choose a master password to protect your blast file'),
          TextField(
            obscureText: true,
            onChanged: (value) => vm.setPassword(value),
            controller: passwordController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'master password',
                hintText: 'Choose a password for your file'),
          ),
          Text(vm.passwordError),
          TextField(
            obscureText: true,
            controller: confirmPasswordController,
            onChanged: (value) => vm.setConfirmPassword(value),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Confirm Password',
                hintText: 'confirm password for your file'),
          ),
          Text(vm.passwordConfirmError),
          FutureBuilder<bool>(
            future: vm.passwordsMatch(),
            builder: (context, passwordsMatch) => Text(
                passwordsMatch.data ?? true ? "" : "passwords don't match"),
          ),
          FutureBuilder<bool>(
            future: vm.isFormReadyToConfirm(),
            builder: (context, isFormReadyToConfirm) => TextButton(
              onPressed: isFormReadyToConfirm.data ?? true
                  ? () => vm.acceptPassword()
                  : null,
              child: const Text('confirm password'),
            ),
          ),
        ],
      )),
    );
  }
}
