import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/field_edit_viewmodel.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

@RoutePage()
class FieldEditView extends StatefulWidget {
  const FieldEditView({super.key, required this.attribute});

  final BlastAttribute attribute;

  @override
  State<FieldEditView> createState() => _FieldEditViewState();
}

class _FieldEditViewState extends State<FieldEditView> {
  late final FieldEditViewModel _viewModel;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _viewModel = FieldEditViewModel(widget.attribute);
    _controller = TextEditingController(text: _viewModel.initialValue);
    _focusNode = FocusNode(onKeyEvent: _handleKeyEvent);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _cancel();
      return KeyEventResult.handled;
    }

    if (_viewModel.isSupported &&
        (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
      _save();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _cancel() {
    Navigator.of(context).pop(false);
  }

  void _save() {
    _viewModel.save(_controller.text);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider<FieldEditViewModel>.value(
      value: _viewModel,
      child: PopScope<bool>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _cancel();
          }
        },
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(title: const Text('Edit field')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _viewModel.isSupported
                        ? TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: true,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: _viewModel.labelText,
                            ),
                          )
                        : Text(
                            _viewModel.labelText,
                            style: theme.textTheme.bodyLarge,
                          ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _cancel,
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _viewModel.isSupported ? _save : null,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
