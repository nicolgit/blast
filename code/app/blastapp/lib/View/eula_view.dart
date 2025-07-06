import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/eula_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class EulaView extends StatefulWidget {
  const EulaView({super.key});

  @override
  State<StatefulWidget> createState() => _EulaViewState();
}

class _EulaViewState extends State<EulaView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EulaViewModel(context),
      child: Consumer<EulaViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;
  late TextTheme _textTheme;

  Widget _buildScaffold(BuildContext context, EulaViewModel vm) {
    _theme = Theme.of(context);
    _textTheme = _theme.textTheme.apply(bodyColor: _theme.colorScheme.onSurface);

    return Container(
        color: _theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _theme.colorScheme.surface,
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                        child: Column(
                      children: [
                        Text(
                          'If you use this software, you accept the followig *MIT* License:',
                          style: _textTheme.bodyLarge,
                        ),
                        const Text(' '),
                        Text('Copyright (c) 2023 Nicola Delfino', style: _textTheme.bodyMedium),
                        const Text(' '),
                        Text(
                            'Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:',
                            style: _textTheme.bodyMedium),
                        const Text(' '),
                        Text(
                            'The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.',
                            style: _textTheme.bodyMedium),
                        const Text(' '),
                        Text(
                            'THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
                            style: _textTheme.bodyMedium),
                        const Text(' '),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextButton.icon(
                            onPressed: () async {
                              final Uri url = Uri.parse('https://github.com/nicolgit/blast/blob/main/PRIVACYPOLICY.md');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            icon: Icon(
                              Icons.privacy_tip,
                              color: _theme.colorScheme.primary,
                            ),
                            label: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: _theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextButton.icon(
                            onPressed: () async {
                              final Uri url = Uri.parse('https://github.com/nicolgit/blast');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            icon: Icon(
                              Icons.code,
                              color: _theme.colorScheme.primary,
                            ),
                            label: Text(
                              'source code on GitHub',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: _theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Wrap(
                            alignment: WrapAlignment.spaceEvenly,
                            runSpacing: 8.0,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: FilledButton(
                                  onPressed: () {
                                    vm.acceptEula();
                                  },
                                  child: const Text('accept'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _theme.colorScheme.error,
                                    foregroundColor: _theme.colorScheme.onError,
                                  ),
                                  onPressed: () {
                                    vm.denyEula();
                                  },
                                  child: const Text(
                                    'I do not accept and I will not use this app',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                  ),
                ))));
  }
}
