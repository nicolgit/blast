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
    super.dispose();
  }

  Widget _buildScaffold(BuildContext context, CreatePasswordViewModel vm) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Text('Create a password'),
          TextField(
            obscureText: true,
            onChanged: (value) => vm.setPassword(value),
            controller: passwordController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter your password'),
          ),
          Text(vm.passwordError),
          TextField(
            obscureText: true,
            controller: confirmPasswordController,
            onChanged: (value) => vm.setConfirmPassword(value),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Confirm Password',
                hintText: 'Enter your password'),
          ),
          Text(vm.passwordConfirmError),
          FutureBuilder<bool>(
            future: vm.passwordsMatch(),
            builder: (context, passwordsMatch) => Text(
                passwordsMatch.data ?? true ? "" : "passwords don't match"),
          ),
          FutureBuilder<bool>(
            future: vm.isPasswordValidAndMatch(),
            builder: (context, isPasswordValidAndMatch) => TextButton(
              onPressed: (isPasswordValidAndMatch.data ?? false)
                  ? vm.acceptPassword()
                  : null,
              child: const Text('confirm password'),
            ),
          ),
        ],
      )),
    );
  }
}
