import 'package:flutter/material.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';

enum FocusOn { title, lastRow, lastRowValue }

class BlastWidgetFactory {
  late ThemeData theme;
  late TextTheme textTheme;
  late TextTheme textTooltip;
  late TextStyle _textThemeHint;

  BlastWidgetFactory(BuildContext context) {
    theme = Theme.of(context);
    textTheme = theme.textTheme.apply(bodyColor: theme.colorScheme.onSurface);
    textTooltip = theme.textTheme.apply(bodyColor: theme.colorScheme.onInverseSurface);
    _textThemeHint = textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5));
  }

  Widget blastTag(String tag) => Padding(
      // ignore: prefer_const_constructors
      padding: const EdgeInsets.only(right: 3, left: 3),
      child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: theme.colorScheme.primary),
          child: Text("   $tag   ",
              style: textTheme.labelSmall!.copyWith(
                color: theme.colorScheme.onPrimary,
              ))));

  Color viewBackgroundColor() => theme.colorScheme.surface;

  Widget blastCardIcon(String text, Color bgColor) {
    String iconText = "";

    for (var world in text.split(" ")) {
      if (world.isNotEmpty) {
        iconText += world[0].toUpperCase();
      }
    }

    // remove from words all non-alphabetic characters
    iconText = iconText.replaceAll(RegExp(r'[^a-zA-Z]'), '');

    // max 3 characters
    if (iconText.length > 3) {
      iconText = iconText.substring(0, 3);
    }

    return CircleAvatar(
      backgroundColor: bgColor,
      child: Text(
        iconText,
        style: textTheme.labelSmall!.copyWith(color: theme.colorScheme.onPrimary),
      ),
    );
  }

  InputDecoration blastTextFieldDecoration(String label, String hintText, {void Function()? onPressed}) {
    return InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        hintText: hintText,
        hintStyle: _textThemeHint,
        suffixIcon: onPressed != null ? IconButton(icon: const Icon(Icons.clear), onPressed: onPressed) : null);
  }

  ListTile buildAttributeRowEdit(
    List<BlastAttribute> rows,
    int i, {
    required FocusOn focusOn,
    required Function(String) onNameChanged,
    required Function(String) onValueChanged,
    required VoidCallback onDelete,
    required VoidCallback onTypeSwap,
  }) {
    return ListTile(
      key: ValueKey(i),
      title: Container(
        decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest, borderRadius: const BorderRadius.all(Radius.circular(6))),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Text(
                  "$i",
                  style: textTheme.labelSmall,
                ),
                const SizedBox(width: 3),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        key: ValueKey('name_$i'),
                        initialValue: rows[i].name,
                        textInputAction: TextInputAction.next,
                        onChanged: onNameChanged,
                        autofocus: (i == rows.length - 1) && (focusOn == FocusOn.lastRow),
                        style: textTheme.labelMedium,
                        decoration: blastTextFieldDecoration('Attribute name', 'Choose the attribute name'),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                buildIconTypeButton(rows[i].type, onTypeSwap),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  tooltip: "delete",
                ),
              ],
            ),
            Visibility(
              visible: rows[i].type != BlastAttributeType.typeHeader,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  key: ValueKey('value_$i'),
                  initialValue: rows[i].value,
                  textInputAction: TextInputAction.next,
                  onChanged: onValueChanged,
                  autofocus: (i == rows.length - 1) && (focusOn == FocusOn.lastRowValue),
                  style: textTheme.labelMedium,
                  decoration: blastTextFieldDecoration('Attribute value', 'Choose the attribute value'),
                ),
              ),
            ),
          ],
        ),
      ),
      trailing: ReorderableDragStartListener(
        index: i,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)), color: theme.colorScheme.surfaceContainer),
          padding: EdgeInsets.all(1.0),
          child: Icon(Icons.drag_handle),
        ),
      ),
    );
  }

  IconButton buildIconTypeButton(BlastAttributeType type, VoidCallback onTypeSwap) {
    var icon = const Icon(Icons.error);

    switch (type) {
      case BlastAttributeType.typeString:
        icon = const Icon(Icons.description);
      case BlastAttributeType.typeHeader:
        icon = const Icon(Icons.text_increase);
      case BlastAttributeType.typePassword:
        icon = const Icon(Icons.lock);
      case BlastAttributeType.typeURL:
        icon = const Icon(Icons.link);
    }

    return IconButton(
      onPressed: onTypeSwap,
      icon: icon,
      tooltip: "${type.description}\n tap to change",
    );
  }

  Widget buildAttributeRow(
      BuildContext context,
      BlastAttribute attribute,
      int index,
      Function(int) toggleShowPassword,
      bool Function(int) isPasswordRowVisible,
      Function(String) copyToClipboard,
      Function(String) showFieldView,
      Function(String) openUrl) {
    String name = attribute.name;
    String value = attribute.value;
    final type = attribute.type;

    switch (type) {
      case BlastAttributeType.typeHeader:
        return ListTile(
          title: Container(
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
            child: Text(name,
                style: textTheme.titleLarge!
                    .copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
          ),
          onTap: () async {},
        );
      case BlastAttributeType.typePassword:
        return Padding(
            padding: EdgeInsets.only(left: 12, right: 12),
            child: Card(
                child: GestureDetector(
                    onDoubleTap: () {
                      // Handle double-tap event here
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
                        IconButton(
                            onPressed: () {
                              showFieldView(value);
                            },
                            icon: const Icon(Icons.qr_code),
                            tooltip: 'show qr code'),
                      ]),
                      onTap: () async {
                        // toast notification warning
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("double tap to copy $name to clipboard")));
                      },
                    ))));
      case BlastAttributeType.typeURL:
        return Padding(
            padding: EdgeInsets.only(left: 12, right: 12),
            child: GestureDetector(
                onDoubleTap: () {
                  // Handle double-tap event here
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
                            decoration: TextDecoration.underline, color: Colors.blue, decorationColor: Colors.blue)),
                  ),
                  subtitle: Text(
                    name,
                    style: textTheme.labelSmall,
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        onPressed: () {
                          showFieldView(value);
                        },
                        icon: const Icon(Icons.qr_code),
                        tooltip: 'show qr code'),
                  ]),
                  onTap: () async {
                    // toast notification warning
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("double tap to copy $name to clipboard")));
                  },
                ))));
      case BlastAttributeType.typeString:
        return Padding(
            padding: EdgeInsets.only(left: 12, right: 12),
            child: GestureDetector(
                onDoubleTap: () {
                  // Handle double-tap event here
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
                    IconButton(
                        onPressed: () {
                          showFieldView(value);
                        },
                        icon: const Icon(Icons.qr_code),
                        tooltip: 'show qr code'),
                  ]),
                  onTap: () async {
                    // toast notification warning
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("double tap to copy $name to clipboard")));
                  },
                ))));
    }
  }
}
