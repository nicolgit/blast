import 'package:flutter/material.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';

class BlastAttributeRow extends StatelessWidget {
  final BlastAttribute attribute;
  final int index;
  final Function(int) toggleShowPassword;
  final bool Function(int) isPasswordRowVisible;
  final Function(String) copyToClipboard;
  final Function(String) showFieldView;
  final Function(String) openUrl;
  final bool editMode;
  final Function(BlastAttribute) editField;
  final Function(BlastAttribute)? deleteField;
  final Future<void> Function(BlastAttribute)? generatePassword;

  const BlastAttributeRow({
    super.key,
    required this.attribute,
    required this.index,
    required this.toggleShowPassword,
    required this.isPasswordRowVisible,
    required this.copyToClipboard,
    required this.showFieldView,
    required this.openUrl,
    required this.editMode,
    required this.editField,
    this.deleteField,
    this.generatePassword,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.apply(bodyColor: theme.colorScheme.onSurface);

    final name = attribute.name;
    final value = attribute.value;
    final type = attribute.type;

    switch (type) {
      case BlastAttributeType.typeHeader:
        return Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: GestureDetector(
                      onTap: () => showFieldView(name),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: textTheme.titleLarge!.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                            ),
                            if (editMode)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: IconButton.outlined(
                                  onPressed: () {
                                    editField(attribute);
                                  },
                                  icon: Icon(Icons.edit, color: theme.colorScheme.onPrimaryContainer),
                                  tooltip: 'edit field',
                                  iconSize: 20,
                                  style: IconButton.styleFrom(
                                    side: BorderSide(color: theme.colorScheme.secondary),
                                  ),
                                ),
                              ),
                            if (editMode && deleteField != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: IconButton.outlined(
                                  onPressed: () {
                                    deleteField!(attribute);
                                  },
                                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.onPrimaryContainer),
                                  tooltip: 'delete field',
                                  iconSize: 20,
                                  style: IconButton.styleFrom(
                                    side: BorderSide(color: theme.colorScheme.secondary),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ))));
      case BlastAttributeType.typePassword:
        return Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Card(
                        child: GestureDetector(
                            onDoubleTap: () {
                              copyToClipboard(value);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("$name copied to clipboard!"),
                              ));
                            },
                            child: ListTile(
                              leading: const Icon(Icons.lock),
                              title: Text(isPasswordRowVisible(index) ? value : "***********",
                                  style: textTheme.titleMedium!.copyWith(color: theme.colorScheme.error)),
                              subtitle: Text(
                                name,
                                style: textTheme.labelSmall,
                              ),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                if (!editMode)
                                  Visibility(
                                    visible: !isPasswordRowVisible(index),
                                    child: IconButton(
                                      onPressed: () {
                                        toggleShowPassword(index);
                                      },
                                      icon: const Icon(Icons.visibility_off),
                                      tooltip: 'hide',
                                    ),
                                  ),
                                if (!editMode)
                                  Visibility(
                                    visible: isPasswordRowVisible(index),
                                    child: IconButton(
                                      onPressed: () {
                                        toggleShowPassword(index);
                                      },
                                      icon: const Icon(Icons.visibility),
                                      tooltip: 'show',
                                    ),
                                  ),
                                if (!editMode)
                                  IconButton(
                                      onPressed: () {
                                        copyToClipboard(value);
                                      },
                                      icon: const Icon(Icons.copy),
                                      tooltip: 'copy to clipboard'),
                                if (editMode && generatePassword != null)
                                  TextButton(
                                      onPressed: () => generatePassword!(attribute), child: const Text('generate')),
                                if (editMode)
                                  IconButton(
                                      onPressed: () {
                                        editField(attribute);
                                      },
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'edit field'),
                                if (editMode && deleteField != null)
                                  IconButton(
                                      onPressed: () {
                                        deleteField!(attribute);
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'delete field'),
                              ]),
                              onTap: () async {
                                showFieldView(value);
                              },
                            ))))));
      case BlastAttributeType.typeURL:
        return Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: GestureDetector(
                        onDoubleTap: () {
                          copyToClipboard(value);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("$name copied to clipboard!"),
                          ));
                        },
                        child: Card(
                            child: ListTile(
                          leading: const Icon(Icons.link),
                          title: InkWell(
                            onTap: () {
                              openUrl(value);
                            },
                            child: Text(value,
                                style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                    decorationColor: Colors.blue)),
                          ),
                          subtitle: Text(
                            name,
                            style: textTheme.labelSmall,
                          ),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (!editMode)
                              IconButton(
                                  onPressed: () {
                                    copyToClipboard(value);
                                  },
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'copy to clipboard'),
                            if (editMode)
                              IconButton(
                                  onPressed: () {
                                    editField(attribute);
                                  },
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'edit field'),
                            if (editMode && deleteField != null)
                              IconButton(
                                  onPressed: () {
                                    deleteField!(attribute);
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'delete field'),
                          ]),
                          onTap: () async {
                            showFieldView(value);
                          },
                        ))))));
      case BlastAttributeType.typeString:
        return Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: GestureDetector(
                        onDoubleTap: () {
                          copyToClipboard(value);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("$name copied to clipboard!"),
                          ));
                        },
                        child: Card(
                            child: ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(value, style: textTheme.titleMedium),
                          subtitle: Text(
                            name,
                            style: textTheme.labelSmall,
                          ),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (!editMode)
                              IconButton(
                                  onPressed: () {
                                    copyToClipboard(value);
                                  },
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'copy to clipboard'),
                            if (editMode)
                              IconButton(
                                  onPressed: () {
                                    editField(attribute);
                                  },
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'edit field'),
                            if (editMode && deleteField != null)
                              IconButton(
                                  onPressed: () {
                                    deleteField!(attribute);
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'delete field'),
                          ]),
                          onTap: () async {
                            showFieldView(value);
                          },
                        ))))));
    }
  }
}
