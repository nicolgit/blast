import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/password_generator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class PasswordGeneratorView extends StatefulWidget {
  final bool allowCopyToClipboard;
  final bool returnsValue;

  const PasswordGeneratorView({
    super.key,
    required this.allowCopyToClipboard,
    required this.returnsValue,
  });

  @override
  State<PasswordGeneratorView> createState() => _PasswordGeneratorViewState();
}

class _PasswordGeneratorViewState extends State<PasswordGeneratorView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PasswordGeneratorViewModel(context),
      child: Consumer<PasswordGeneratorViewModel>(
        builder: (context, viewmodel, child) => _buildScaffold(context, viewmodel),
      ),
    );
  }

  late ThemeData _theme;

  Widget _buildScaffold(BuildContext context, PasswordGeneratorViewModel vm) {
    _theme = Theme.of(context);

    return Container(
        color: _theme.colorScheme.surface,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: _theme.colorScheme.surface,
                body: Center(
                  child: Column(children: [
                    AppBar(
                      title: const Text("Password Generator"),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Close',
                          onPressed: () {
                            vm.closeCommand();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Theme(
                      data: Theme.of(context).copyWith(
                        segmentedButtonTheme: SegmentedButtonThemeData(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return _theme.colorScheme.primaryContainer;
                                }
                                return null; // Use default for unselected
                              },
                            ),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SegmentedButton<GeneratorTypes>(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(fontSize: 12),
                            ),
                          ),
                          segments: const <ButtonSegment<GeneratorTypes>>[
                            ButtonSegment<GeneratorTypes>(
                              value: GeneratorTypes.guid,
                              label: Text('GUID'),
                              icon: Icon(Icons.fingerprint, size: 18),
                            ),
                            ButtonSegment<GeneratorTypes>(
                              value: GeneratorTypes.text,
                              label: Text('Text'),
                              icon: Icon(Icons.text_fields, size: 18),
                            ),
                            ButtonSegment<GeneratorTypes>(
                              value: GeneratorTypes.numeric,
                              label: Text('Num'),
                              icon: Icon(Icons.pin, size: 18),
                            ),
                            ButtonSegment<GeneratorTypes>(
                              value: GeneratorTypes.wikiword,
                              label: Text('Wiki✨'),
                              icon: Icon(Icons.auto_awesome, size: 18),
                            ),
                          ],
                          selected: <GeneratorTypes>{vm.generatorType},
                          onSelectionChanged: (Set<GeneratorTypes> newSelection) {
                            vm.setGeneratorType(newSelection.first);
                          },
                          showSelectedIcon: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (vm.generatorType == GeneratorTypes.text || vm.generatorType == GeneratorTypes.numeric) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Password Length',
                                  style: _theme.textTheme.titleMedium,
                                ),
                                Text(
                                  '${vm.textLength}',
                                  style: _theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: vm.textLength.toDouble(),
                              min: 5,
                              max: 20,
                              divisions: 15,
                              onChanged: (value) {
                                vm.setTextLength(value.round());
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (vm.generatorType == GeneratorTypes.wikiword) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                'words',
                                style: _theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<int>(
                              segments: const <ButtonSegment<int>>[
                                ButtonSegment<int>(
                                  value: 1,
                                  label: Text('1'),
                                ),
                                ButtonSegment<int>(
                                  value: 2,
                                  label: Text('2'),
                                ),
                                ButtonSegment<int>(
                                  value: 3,
                                  label: Text('3'),
                                ),
                                ButtonSegment<int>(
                                  value: 4,
                                  label: Text('4'),
                                ),
                              ],
                              selected: <int>{vm.wordCount},
                              onSelectionChanged: (Set<int> newSelection) {
                                vm.setWordCount(newSelection.first);
                              },
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'language',
                                style: _theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<String>(
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                ),
                                textStyle: WidgetStateProperty.all(
                                  const TextStyle(fontSize: 18),
                                ),
                              ),
                              segments: vm.availableLanguages.keys.map((languageCode) {
                                // Map language codes to flag emoticons
                                const flagMap = {
                                  'en': '🇺🇸', // English -> US flag
                                  'it': '🇮🇹', // Italian -> Italy flag
                                  'fr': '🇫🇷', // French -> France flag
                                  'de': '🇩🇪', // German -> Germany flag
                                  'es': '🇪🇸', // Spanish -> Spain flag
                                  'pt': '🇵🇹', // Portuguese -> Portugal flag
                                  'nl': '🇳🇱', // Dutch -> Netherlands flag
                                };

                                return ButtonSegment<String>(
                                  value: languageCode,
                                  label: Tooltip(
                                    message: vm.availableLanguages[languageCode] ?? languageCode,
                                    child: Text(flagMap[languageCode] ?? '🏳️'),
                                  ),
                                );
                              }).toList(),
                              selected: <String>{vm.selectedLanguage},
                              onSelectionChanged: (Set<String> newSelection) {
                                vm.setSelectedLanguage(newSelection.first);
                              },
                              showSelectedIcon: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: _theme.colorScheme.outline),
                                        borderRadius: BorderRadius.circular(8),
                                        color: _theme.colorScheme.surfaceContainerHighest,
                                      ),
                                      child: TextField(
                                        controller: TextEditingController(text: vm.password),
                                        maxLines: null,
                                        minLines: 2,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (widget.returnsValue || widget.allowCopyToClipboard)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          if (widget.returnsValue)
                                            ElevatedButton.icon(
                                              onPressed: vm.usePasswordCommand,
                                              icon: const Icon(Icons.check, size: 20),
                                              label: const Text('Use Password'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _theme.colorScheme.primaryContainer,
                                                foregroundColor: _theme.colorScheme.onPrimaryContainer,
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                minimumSize: const Size(180, 44),
                                                textStyle: const TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          if (widget.allowCopyToClipboard)
                                            ElevatedButton.icon(
                                              onPressed: vm.copyToClipboard,
                                              icon: const Icon(Icons.copy, size: 20),
                                              label: const Text('Copy to Clipboard'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _theme.colorScheme.secondaryContainer,
                                                foregroundColor: _theme.colorScheme.onSecondaryContainer,
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                minimumSize: const Size(180, 44),
                                                textStyle: const TextStyle(fontSize: 16),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                // Determine if we should use a single row or wrap for better mobile layout
                                bool useWrap = constraints.maxWidth < 400;

                                List<Widget> buttons = [
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: vm.isRunning ? vm.stopGenerator : vm.startGenerator,
                                      icon: Icon(
                                        vm.isRunning ? Icons.stop : Icons.play_arrow,
                                        size: 20,
                                      ),
                                      label: Text(vm.isRunning ? 'Stop' : 'Start'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: vm.isRunning
                                            ? _theme.colorScheme.errorContainer
                                            : _theme.colorScheme.primaryContainer,
                                        foregroundColor: vm.isRunning
                                            ? _theme.colorScheme.onErrorContainer
                                            : _theme.colorScheme.onPrimaryContainer,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        minimumSize: const Size(100, 44),
                                        textStyle: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  if (!vm.isRunning) ...[
                                    const SizedBox(width: 8, height: 8),
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: vm.refreshPassword,
                                        icon: const Icon(Icons.refresh, size: 20),
                                        label: const Text('Refresh'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _theme.colorScheme.surfaceContainerHighest,
                                          foregroundColor: _theme.colorScheme.onSurface,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          minimumSize: const Size(100, 44),
                                          textStyle: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ];

                                if (useWrap) {
                                  return Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: buttons,
                                  );
                                } else {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: buttons,
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ))));
  }
}
