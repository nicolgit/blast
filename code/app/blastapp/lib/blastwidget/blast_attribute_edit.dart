import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'package:blastapp/blast_router.dart';

enum FocusOn { title, lastRowName, lastRowValue }

class BlastAttributeEdit extends StatefulWidget {
  final List<BlastAttribute> rows;
  final int index;
  final FocusOn focusOn;
  final Function(String) onNameChanged;
  final Function(String) onValueChanged;
  final VoidCallback onDelete;
  final VoidCallback onTypeSwap;
  final InputDecoration Function(String, String, {void Function()? onPressed}) blastTextFieldDecoration;
  final IconButton Function(BlastAttributeType, VoidCallback) buildIconTypeButton;
  final ThemeData theme;
  final TextTheme textTheme;

  BlastAttributeEdit({
    Key? key,
    required this.rows,
    required this.index,
    required this.focusOn,
    required this.onNameChanged,
    required this.onValueChanged,
    required this.onDelete,
    required this.onTypeSwap,
    required this.blastTextFieldDecoration,
    required this.buildIconTypeButton,
    required this.theme,
    required this.textTheme,
  }) : super(key: key ?? ValueKey(index));

  @override
  State<BlastAttributeEdit> createState() => _BlastAttributeEditState();
}

class _BlastAttributeEditState extends State<BlastAttributeEdit> {
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  late FocusNode _nameFocusNode;
  bool _isNameEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rows[widget.index].name);
    _valueController = TextEditingController(text: widget.rows[widget.index].value);
    _nameFocusNode = FocusNode();
    _nameFocusNode.addListener(_onNameFocusChange);

    if (widget.focusOn == FocusOn.lastRowName) {
      _isNameEditing = true;
    }
  }

  void _onNameFocusChange() {
    if (!_nameFocusNode.hasFocus && _isNameEditing) {
      setState(() {
        _isNameEditing = false;
      });
    }
  }

  void _toggleNameEditing() {
    setState(() {
      _isNameEditing = !_isNameEditing;
      if (_isNameEditing) {
        // Request focus when entering edit mode
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _nameFocusNode.requestFocus();
        });
      }
    });
  }

  @override
  void didUpdateWidget(BlastAttributeEdit oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if the data has changed externally
    if (oldWidget.rows[widget.index].name != widget.rows[widget.index].name) {
      _nameController.text = widget.rows[widget.index].name;
    }
    if (oldWidget.rows[widget.index].value != widget.rows[widget.index].value) {
      _valueController.text = widget.rows[widget.index].value;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openPasswordGenerator() async {
    final String? generatedPassword =
        await context.router.push(PasswordGeneratorRoute(allowCopyToClipboard: false, returnsValue: true));

    if (generatedPassword != null && generatedPassword.isNotEmpty) {
      // Check if there's already a password after returning from password generator
      final currentPassword = _valueController.text.trim();
      if (currentPassword.isNotEmpty) {
        final bool? shouldReplace = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Replace existing password?'),
              content: Text(
                  'There is already a password in this field($currentPassword). Do you want to replace it with the new generated password? ($generatedPassword)'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Replace'),
                ),
              ],
            );
          },
        );

        if (shouldReplace != true) {
          return; // User cancelled or closed dialog
        }
      }

      _valueController.text = generatedPassword;
      widget.onValueChanged(generatedPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //key: ValueKey(widget.index),
      title: Container(
        decoration: BoxDecoration(
            color: widget.theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.all(Radius.circular(6))),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Text(
                  "${widget.index}",
                  style: widget.textTheme.labelSmall,
                ),
                const SizedBox(width: 3),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      _isNameEditing
                          ? Focus(
                              onKeyEvent: (node, event) {
                                if (event.logicalKey == LogicalKeyboardKey.escape) {
                                  _nameFocusNode.unfocus();
                                  return KeyEventResult.handled;
                                }
                                return KeyEventResult.ignored;
                              },
                              child: TextFormField(
                                key: ValueKey('name_${widget.index}'),
                                controller: _nameController,
                                focusNode: _nameFocusNode,
                                textInputAction: TextInputAction.done,
                                onChanged: widget.onNameChanged,
                                onFieldSubmitted: (value) {
                                  setState(() {
                                    _isNameEditing = false;
                                  });
                                },
                                autofocus:
                                    (widget.index == widget.rows.length - 1) && (widget.focusOn == FocusOn.lastRowName),
                                style: widget.textTheme.labelMedium,
                                decoration:
                                    widget.blastTextFieldDecoration('Attribute name', 'Choose the attribute name'),
                              ),
                            )
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(left: 12),
                                child: Text(
                                  widget.rows[widget.index].name.isEmpty
                                      ? 'Attribute name'
                                      : widget.rows[widget.index].name,
                                  style: widget.textTheme.labelLarge?.copyWith(
                                    color: widget.theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                IconButton(
                  onPressed: _toggleNameEditing,
                  icon: Icon(_isNameEditing ? Icons.check : Icons.edit),
                  tooltip: _isNameEditing ? "done" : "edit",
                ),
                widget.buildIconTypeButton(widget.rows[widget.index].type, widget.onTypeSwap),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete),
                  tooltip: "delete",
                ),
              ],
            ),
            Visibility(
              visible: widget.rows[widget.index].type != BlastAttributeType.typeHeader,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('value_${widget.index}'),
                        controller: _valueController,
                        textInputAction: TextInputAction.next,
                        onChanged: widget.onValueChanged,
                        autofocus: (widget.index == widget.rows.length - 1) && (widget.focusOn == FocusOn.lastRowValue),
                        style: widget.textTheme.labelMedium,
                        decoration: widget.blastTextFieldDecoration('Attribute value', 'Choose the attribute value'),
                      ),
                    ),
                    if (widget.rows[widget.index].type == BlastAttributeType.typePassword) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _openPasswordGenerator,
                        icon: const Icon(Icons.auto_fix_high),
                        tooltip: 'Generate password',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      trailing: ReorderableDragStartListener(
        index: widget.index,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)), color: widget.theme.colorScheme.surfaceContainer),
          padding: EdgeInsets.all(1.0),
          child: Icon(Icons.drag_handle),
        ),
      ),
    );
  }
}
