import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/type_password_viewmodel.dart';
import 'package:blastapp/blastwidget/animated_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

@RoutePage()
class TypePasswordView extends StatefulWidget {
  const TypePasswordView({super.key, this.forceSkipBiometricQuestion = false});

  final bool forceSkipBiometricQuestion;

  @override
  State<StatefulWidget> createState() => _TypePasswordViewState();
}

class _TypePasswordViewState extends State<TypePasswordView> {
  final passwordController = TextEditingController();
  late FocusNode passwordFocusNode;
  final viewModel = TypePasswordViewModel();

  @override
  void initState() {
    super.initState();

    viewModel.context = context;
    viewModel.forceSkipBiometricQuestion = widget.forceSkipBiometricQuestion;

    passwordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
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

  var maskRecoveryKeyFormatter = MaskTextInputFormatter(
      mask: '########-########-########-########-########-########-########-########',
      filter: {"#": RegExp(r'[0-9a-fA-F]')},
      type: MaskAutoCompletionType.lazy);

  Widget _buildScaffold(BuildContext context, TypePasswordViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);
    _textThemeHint = _textTheme.bodySmall!.copyWith(color: _theme.colorScheme.onSurface.withValues(alpha: 0.5));
    _textThemeError = _textTheme.bodySmall!.copyWith(color: _theme.colorScheme.error);

    return Container(
        color: _theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _theme.colorScheme.surface,
                body: SingleChildScrollView(
                  child: Center(
                      child: Column(
                    children: [
                      AppBar(
                        title: Text("file: ${vm.fileName}"),
                      ),
                      const SizedBox(height: 12.0),
                      // Animated cloud storage icon
                      AnimatedLogo(
                        width: 90,
                        height: 90,
                        assetPath: vm.cloudIcon,
                        oscillation: false,
                      ),
                      Text('type the master password or the recovery key to continue', style: _textTheme.labelMedium),
                      const SizedBox(height: 12.0),
                      FutureBuilder<bool>(
                        future: vm.isPasswordValid(),
                        builder: (context, isPasswordValid) {
                          return Icon(isPasswordValid.data ?? false ? Icons.lock_open : Icons.lock,
                              color: _theme.colorScheme.primary, size: 36.0);
                        },
                      ),
                      const SizedBox(height: 12.0),
                      SegmentedButton<PasswordType>(
                          segments: <ButtonSegment<PasswordType>>[
                            ButtonSegment<PasswordType>(
                              label: Text('Password', style: _textTheme.labelSmall),
                              value: PasswordType.password,
                            ),
                            ButtonSegment<PasswordType>(
                              label: Text('Recovery Key', style: _textTheme.labelSmall),
                              value: PasswordType.recoveryKey,
                            ),
                          ],
                          selected: <PasswordType>{
                            vm.passwordType
                          },
                          onSelectionChanged: (Set<PasswordType> newSelection) {
                            setState(() {
                              vm.passwordType = newSelection.first;
                            });
                          }),
                      FutureBuilder<PasswordType>(
                        future: vm.getPasswordType(),
                        builder: (context, passwordType) {
                          if (passwordType.data == PasswordType.password) {
                            return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                    constraints: BoxConstraints(maxWidth: 600),
                                    child: TextField(
                                        autofocus: true,
                                        focusNode: passwordFocusNode,
                                        obscureText: true,
                                        controller: passwordController,
                                        onChanged: (value) => vm.setPassword(value),
                                        onSubmitted: (value) async => {
                                              if (!await vm.checkPassword(true)) passwordFocusNode.requestFocus(),
                                            },
                                        style: _textTheme.labelMedium,
                                        decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            labelText: 'Password',
                                            hintText: 'Enter your password',
                                            hintStyle: _textThemeHint))));
                          } else {
                            return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: TextField(
                                  onChanged: (value) => vm.setRecoveryKey(maskRecoveryKeyFormatter.getUnmaskedText()),
                                  onSubmitted: (value) async => {
                                    vm.setRecoveryKey(maskRecoveryKeyFormatter.getUnmaskedText()),
                                    if (!await vm.checkPassword(false)) passwordFocusNode.requestFocus(),
                                  },
                                  style: _textTheme.labelMedium,
                                  inputFormatters: [maskRecoveryKeyFormatter],
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: 'recovery key',
                                      hintText:
                                          '12345678-12345678-12345678-12345678-12345678-12345678-12345678-12345678',
                                      hintStyle: _textThemeHint),
                                ));
                          }
                        },
                      ),
                      Text(vm.errorMessage, style: _textThemeError),
                      const SizedBox(height: 12.0),
                      FutureBuilder<bool>(
                        future: vm.isPasswordValid(),
                        builder: (context, isPasswordValid) {
                          return FilledButton(
                            onPressed: isPasswordValid.data ?? false ? () => vm.checkPassword(true) : null,
                            child: const Text('open'),
                          );
                        },
                      ),
                      const SizedBox(height: 12.0),
                      FutureBuilder<bool>(
                        future: vm.isCheckingPassword(),
                        builder: (context, isCheckingPassword) {
                          if (isCheckingPassword.data ?? false) {
                            return CircularProgressIndicator(); //Text("checking password...", style: _textTheme.labelMedium);
                          } else {
                            return Text("", style: _textTheme.labelMedium);
                          }
                        },
                      ),
                    ],
                  )),
                ))));
  }
}
