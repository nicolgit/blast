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
    super.dispose();
  }

  Widget _buildScaffold(BuildContext context, TypePasswordViewModel vm) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
                    AppBar(
            title: const Text("open file"),
          ),
          const Text('type the master password to open your blast file'),
          TextField(
            obscureText: true,
            controller: passwordController,
            onChanged: (value) => vm.setPassword(value),
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Password', hintText: 'Enter your password'),
          ),
          Text(vm.errorMessage),
          FutureBuilder<bool>(
            future: vm.isPasswordValid(),
            builder: (context, isPasswordValid) => TextButton(
              onPressed: isPasswordValid.data ?? false ? () => vm.checkPassword() : null,
              child: const Text('open'),
            ),
          ),
        ],
      )),
    );
  }
}
