import 'package:auto_route/auto_route.dart';
import 'package:blastapp/ViewModel/field_edit_viewmodel.dart';
import 'package:blastapp/blast_router.dart';
import 'package:blastapp/blastwidget/blast_widgetfactory.dart';
import 'package:blastapp/blastwidget/blast_password_complexity.dart';
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
  late final TextEditingController _nameController;
  late final TextEditingController _controller;
  late final TextEditingController _confirmController;
  late final FocusNode _confirmFocusNode;
  late final FocusNode _nameFocusNode;
  late final FocusNode _focusNode;
  bool _obscurePassword = true;

  Widget _passwordVisibilityButton() => IconButton(
        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      );

  @override
  void initState() {
    super.initState();
    _viewModel = FieldEditViewModel(widget.attribute);
    _nameController = TextEditingController(text: widget.attribute.name);
    _controller = TextEditingController(text: _viewModel.initialValue);
    _confirmController = TextEditingController(text: _viewModel.initialValue);
    _confirmFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _nameFocusNode.dispose();
    _confirmFocusNode.dispose();
    _confirmController.dispose();
    _nameController.dispose();
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
        (_nameFocusNode.hasFocus || _focusNode.hasFocus || _confirmFocusNode.hasFocus) &&
        (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
      if (_nameFocusNode.hasFocus) {
        _focusNode.requestFocus();
      } else if (_viewModel.isPassword && _focusNode.hasFocus) {
        _confirmFocusNode.requestFocus();
      } else {
        _save();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _cancel() {
    Navigator.of(context).pop(false);
  }

  void _save() {
    if (_passwordMismatch) {
      _confirmFocusNode.requestFocus();
      return;
    }
    _viewModel.save(_controller.text, name: _nameController.text);
    Navigator.of(context).pop(true);
  }

  bool get _passwordMismatch => _viewModel.isPassword && _controller.text != _confirmController.text;

  Future<void> _generatePassword() async {
    final generated = await context.router.push<String>(
      PasswordGeneratorRoute(allowCopyToClipboard: false, returnsValue: true),
    );
    if (!mounted || generated == null || generated.isEmpty) return;

    setState(() {
      _controller.text = generated;
      _confirmController.text = generated;
    });
    _focusNode.requestFocus();
  }

  Future<void> _testUrl() async {
    String? error;
    try {
      if (!await _viewModel.testUrl(_controller.text)) {
        error = 'Could not open the URL';
      }
    } on FormatException catch (exception) {
      error = exception.message;
    } on PlatformException catch (exception) {
      error = 'Could not open the URL: ${exception.message ?? exception.code}';
    }
    if (mounted && error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = BlastWidgetFactory(context);
    final theme = widgetFactory.theme;
    final inputStyle = widgetFactory.textTheme.titleMedium;
    final labelStyle = TextStyle(color: theme.colorScheme.onSurfaceVariant);

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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Focus(
                    onKeyEvent: _handleKeyEvent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_viewModel.canEditName) ...[
                          TextField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            style: inputStyle,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _focusNode.requestFocus(),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Attribute name',
                              labelStyle: labelStyle,
                              floatingLabelStyle: labelStyle,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _viewModel.isSupported
                            ? TextField(
                                controller: _controller,
                                style: inputStyle,
                                focusNode: _focusNode,
                                autofocus: true,
                                obscureText: _viewModel.isPassword && _obscurePassword,
                                autocorrect: !_viewModel.isPassword,
                                enableSuggestions: !_viewModel.isPassword,
                                onChanged: _viewModel.isPassword ? (_) => setState(() {}) : null,
                                keyboardType: _viewModel.canTestUrl ? TextInputType.url : TextInputType.text,
                                textInputAction: _viewModel.isPassword ? TextInputAction.next : TextInputAction.done,
                                onSubmitted: (_) {
                                  if (_viewModel.isPassword) {
                                    _confirmFocusNode.requestFocus();
                                  } else {
                                    _save();
                                  }
                                },
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: _viewModel.labelText,
                                  labelStyle: labelStyle,
                                  floatingLabelStyle: labelStyle,
                                  suffixIcon: _viewModel.canTestUrl
                                      ? TextButton(
                                          onPressed: _testUrl,
                                          child: const Text('Test'),
                                        )
                                      : _viewModel.isPassword
                                          ? _passwordVisibilityButton()
                                          : null,
                                ),
                              )
                            : Text(
                                _viewModel.labelText,
                                style: widgetFactory.textTheme.bodyLarge,
                              ),
                        const SizedBox(height: 12),
                        if (_viewModel.isPassword) ...[
                          TextField(
                            controller: _confirmController,
                            focusNode: _confirmFocusNode,
                            style: inputStyle,
                            obscureText: _obscurePassword,
                            autocorrect: false,
                            enableSuggestions: false,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _save(),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Confirm password',
                              labelStyle: labelStyle,
                              floatingLabelStyle: labelStyle,
                              errorText: _passwordMismatch ? 'values do not match' : null,
                              suffixIcon: _passwordVisibilityButton(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          BlastPasswordComplexity(
                            currentPassword: _controller.text,
                            showLabel: true,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _generatePassword,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Generate password'),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _cancel,
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _viewModel.isSupported && !_passwordMismatch ? _save : null,
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
        ),
      ),
    );
  }
}
