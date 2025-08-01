import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/settings_viewmodel.dart';
import 'package:blastapp/main.dart';
import 'package:blastmodel/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsViewModel(context),
      child: Consumer<SettingsViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;
  late TextTheme _textTheme;

  Widget _buildScaffold(BuildContext context, SettingsViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);

    return Container(
        color: _theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _theme.colorScheme.surface,
                body: Center(
                  child: Column(children: [
                    AppBar(
                      title: Text("Settings"),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Quit',
                          onPressed: () {
                            vm.closeCommand();
                          },
                        ),
                      ],
                    ),
                    Container(
                        padding: EdgeInsets.all(6),
                        child: SingleChildScrollView(
                            child: Column(
                          children: [
                            Card(
                                elevation: 6,
                                child: Container(
                                    padding: EdgeInsets.all(6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // dropdown theme selector
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("app theme", style: _textTheme.bodyLarge),
                                            FutureBuilder(
                                                future: vm.themeMode,
                                                builder: (BuildContext context, AsyncSnapshot<ThemeMode> theme) {
                                                  return DropdownButton<ThemeMode>(
                                                    borderRadius: BorderRadius.circular(6),
                                                    dropdownColor: _theme.colorScheme.surface,
                                                    value: theme.data,
                                                    onChanged: (ThemeMode? newValue) async {
                                                      await vm.setThemeMode(newValue!);
                                                      if (!context.mounted) return;
                                                      BlastApp.of(context).changeTheme(newValue);
                                                    },
                                                    items: vm.getThemeSelectorItems().map((ThemeView value) {
                                                      return DropdownMenuItem<ThemeMode>(
                                                        value: value.themeMode,
                                                        child: Container(
                                                          color: Colors.transparent,
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: 6),
                                                              Icon(value.icon, color: _theme.colorScheme.onSurface),
                                                              SizedBox(width: 6),
                                                              Text(value.themeName, style: _textTheme.bodyLarge),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  );
                                                }),
                                          ],
                                        ),

                                        // toogle switch for qrcode view
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("remember last QR code view used", style: _textTheme.bodyLarge),
                                            FutureBuilder<bool>(
                                                future: vm.rememberLastQrCodeView,
                                                builder: (BuildContext context, AsyncSnapshot<bool> remember) {
                                                  return Switch(
                                                    value: remember.hasData ? remember.data! : false,
                                                    onChanged: (bool value) async {
                                                      await vm.setRememberLastQrCodeView();
                                                    },
                                                    activeColor: _theme.colorScheme.primary,
                                                  );
                                                }),
                                          ],
                                        ),

                                        // show QrCodeViewStyle if rememberlastQR is enabled
                                        FutureBuilder<bool>(
                                            future: vm.rememberLastQrCodeView,
                                            builder: (BuildContext context, AsyncSnapshot<bool> remember) {
                                              if (remember.hasData && remember.data!) {
                                                return Container();
                                              } else {
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("default QR code view", style: _textTheme.bodyLarge),
                                                    FutureBuilder(
                                                        future: vm.lastQrCodeView,
                                                        builder: (BuildContext context,
                                                            AsyncSnapshot<QrCodeViewStyle> qrCodeView) {
                                                          return DropdownButton<QrCodeViewStyle>(
                                                            borderRadius: BorderRadius.circular(6),
                                                            dropdownColor: _theme.colorScheme.surface,
                                                            value: qrCodeView.data,
                                                            onChanged: (QrCodeViewStyle? newValue) async {
                                                              await vm.setLastQrCodeView(newValue!);
                                                            },
                                                            items: vm
                                                                .getQrCodeViewStyleItems()
                                                                .map((QrCodeViewStyleView value) {
                                                              return DropdownMenuItem<QrCodeViewStyle>(
                                                                value: value.viewStyle,
                                                                child: Container(
                                                                  color: Colors.transparent,
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(width: 6),
                                                                      Icon(value.icon,
                                                                          color: _theme.colorScheme.onSurface),
                                                                      SizedBox(width: 6),
                                                                      Text(value.viewName, style: _textTheme.bodyLarge),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          );
                                                        }),
                                                  ],
                                                );
                                              }
                                            }),

                                        // dropdown select default QR view

                                        Container(
                                            padding: EdgeInsets.only(top: 6, bottom: 6),
                                            child: Divider(
                                              color: _theme.colorScheme.outline,
                                              thickness: 1,
                                              height: 1,
                                            )),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("auto save changes", style: _textTheme.bodyLarge),
                                            FutureBuilder<bool>(
                                                future: vm.autoSave,
                                                builder: (BuildContext context, AsyncSnapshot<bool> autoSave) {
                                                  return Switch(
                                                    value: autoSave.hasData ? autoSave.data! : false,
                                                    onChanged: (bool value) async {
                                                      await vm.setAutoSave(value);
                                                    },
                                                    activeColor: _theme.colorScheme.primary,
                                                  );
                                                }),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("auto logoff after", style: _textTheme.bodyLarge),
                                            FutureBuilder<int>(
                                                future: vm.autoLogoutAfter,
                                                builder: (BuildContext context, AsyncSnapshot<int> timeout) {
                                                  return DropdownButton<int>(
                                                      borderRadius: BorderRadius.circular(6),
                                                      dropdownColor: _theme.colorScheme.surface,
                                                      value: timeout.data,
                                                      onChanged: (int? newValue) async {
                                                        await vm.setAutoLogoutAfter(newValue!);
                                                      },
                                                      items: vm.getAutoLogoutAfterItems()!.map((int value) {
                                                        return DropdownMenuItem<int>(
                                                            value: value,
                                                            child: Container(
                                                                color: Colors.transparent,
                                                                child: Text(" $value minutes",
                                                                    style: _textTheme.bodyLarge)));
                                                      }).toList());
                                                })
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("ask for biometric authentication", style: _textTheme.bodyLarge),
                                            FutureBuilder<bool>(
                                                future: vm.askForBiometricAuth,
                                                builder: (BuildContext context, AsyncSnapshot<bool> askBiometric) {
                                                  return Switch(
                                                    value: askBiometric.hasData ? askBiometric.data! : true,
                                                    onChanged: (bool value) async {
                                                      await vm.setAskForBiometricAuth(value);
                                                    },
                                                    activeColor: _theme.colorScheme.primary,
                                                  );
                                                }),
                                          ],
                                        ),
                                      ],
                                    )))
                          ],
                        )))
                  ]),
                ))));
  }
}
