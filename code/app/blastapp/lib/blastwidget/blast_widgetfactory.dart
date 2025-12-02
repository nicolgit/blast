import 'package:flutter/material.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:blastmodel/blastattributetype.dart';
import 'blast_attribute_edit.dart';

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

  InputDecoration blastTextFieldDecoration(String label, String hintText, {void Function()? onPressed}) {
    return InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        hintText: hintText,
        hintStyle: _textThemeHint,
        suffixIcon: onPressed != null ? IconButton(icon: const Icon(Icons.clear), onPressed: onPressed) : null);
  }

  Widget buildAttributeRowEdit(
    List<BlastAttribute> rows,
    int i, {
    required FocusOn focusOn,
    required Function(String) onNameChanged,
    required Function(String) onValueChanged,
    required VoidCallback onDelete,
    required VoidCallback onTypeSwap,
  }) {
    return BlastAttributeEdit(
      rows: rows,
      index: i,
      focusOn: focusOn,
      onNameChanged: onNameChanged,
      onValueChanged: onValueChanged,
      onDelete: onDelete,
      onTypeSwap: onTypeSwap,
      blastTextFieldDecoration: blastTextFieldDecoration,
      buildIconTypeButton: buildIconTypeButton,
      theme: theme,
      textTheme: textTheme,
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
        return Padding(
            padding: EdgeInsets.only(left: 12, right: 12),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: ListTile(
                      title: Container(
                        padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                        child: Text(name,
                            style: textTheme.titleLarge!
                                .copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                      ),
                      onTap: () async {},
                    ))));
      case BlastAttributeType.typePassword:
        return Padding(
            padding: EdgeInsets.only(left: 12, right: 12),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
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
                            ))))));
      case BlastAttributeType.typeURL:
        return Padding(
            padding: EdgeInsets.only(left: 12, right: 12),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
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
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                    decorationColor: Colors.blue)),
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
                        ))))));
      case BlastAttributeType.typeString:
        return Padding(
            padding: EdgeInsets.only(left: 12, right: 12),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
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
                        ))))));
    }
  }
}
