import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/password_generator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class PasswordGeneratorView extends StatefulWidget {
  const PasswordGeneratorView({super.key});

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
                      child: SegmentedButton<GeneratorTypes>(
                        segments: const <ButtonSegment<GeneratorTypes>>[
                          ButtonSegment<GeneratorTypes>(
                            value: GeneratorTypes.guid,
                            label: Text('GUID'),
                            icon: Icon(Icons.fingerprint),
                          ),
                          ButtonSegment<GeneratorTypes>(
                            value: GeneratorTypes.text,
                            label: Text('Text'),
                            icon: Icon(Icons.text_fields),
                          ),
                          ButtonSegment<GeneratorTypes>(
                            value: GeneratorTypes.numeric,
                            label: Text('Numeric'),
                            icon: Icon(Icons.pin),
                          ),
                        ],
                        selected: <GeneratorTypes>{vm.generatorType},
                        onSelectionChanged: (Set<GeneratorTypes> newSelection) {
                          vm.setGeneratorType(newSelection.first);
                        },
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
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: _theme.colorScheme.outline),
                                    borderRadius: BorderRadius.circular(8),
                                    color: _theme.colorScheme.surfaceContainerHighest,
                                  ),
                                  child: TextField(
                                    readOnly: true,
                                    controller: TextEditingController(text: vm.password),
                                    style: const TextStyle(
                                      fontSize: 24,
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
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: vm.isRunning ? vm.stopGenerator : vm.startGenerator,
                                  icon: Icon(vm.isRunning ? Icons.stop : Icons.play_arrow),
                                  label: Text(vm.isRunning ? 'Stop' : 'Start'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: vm.isRunning
                                        ? _theme.colorScheme.errorContainer
                                        : _theme.colorScheme.primaryContainer,
                                    foregroundColor: vm.isRunning
                                        ? _theme.colorScheme.onErrorContainer
                                        : _theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: vm.copyToClipboard,
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _theme.colorScheme.secondaryContainer,
                                    foregroundColor: _theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
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
