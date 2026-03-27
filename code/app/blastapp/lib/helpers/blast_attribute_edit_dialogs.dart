import 'package:blastapp/ViewModel/card_viewmodel.dart';
import 'package:blastmodel/blastattribute.dart';
import 'package:flutter/material.dart';

class BlastAttributeEditDialogs {
  static Future<void> showEditHeaderDialog(BuildContext context, BlastAttribute attribute, CardViewModel vm) {
    final controller = TextEditingController(text: attribute.name);
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit header', style: TextStyle(color: theme.colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Header',
            labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              vm.updateAttributeName(attribute, controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showDeleteFieldDialog(BuildContext context, BlastAttribute attribute, CardViewModel vm) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete attribute', style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text('Delete "${attribute.name}"?', style: TextStyle(color: theme.colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              vm.deleteAttribute(attribute);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static void showEditPasswordFieldDialog(BuildContext context, BlastAttribute attribute, CardViewModel vm) {
    final controller = TextEditingController(text: attribute.value);
    final confirmController = TextEditingController(text: attribute.value);
    bool obscure = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final mismatch = controller.text != confirmController.text;
          return AlertDialog(
            title: Row(
              children: [
                Expanded(
                  child: Text(attribute.name, style: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface)),
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 18, color: Theme.of(dialogContext).colorScheme.primary),
                  tooltip: 'Edit field name',
                  onPressed: () async {
                    await showEditHeaderDialog(dialogContext, attribute, vm);
                    setState(() {});
                  },
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: '${attribute.name} value',
                    labelStyle: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurfaceVariant),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscure = !obscure),
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: obscure,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Confirm ${attribute.name} value',
                    labelStyle: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurfaceVariant),
                  ),
                ),
                if (mismatch) ...[
                  const SizedBox(height: 8),
                  Text(
                    'values do not match',
                    style: TextStyle(color: Theme.of(dialogContext).colorScheme.error, fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: mismatch
                    ? null
                    : () {
                        vm.updateAttributeValue(attribute, controller.text);
                        Navigator.of(dialogContext).pop();
                      },
                child: const Text('OK'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showEditFieldDialog(BuildContext context, BlastAttribute attribute, CardViewModel vm) {
    final controller = TextEditingController(text: attribute.value);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(attribute.name, style: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface)),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: Theme.of(dialogContext).colorScheme.primary),
                tooltip: 'Edit field name',
                onPressed: () async {
                  await showEditHeaderDialog(dialogContext, attribute, vm);
                  setState(() {});
                },
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Value',
              labelStyle: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurfaceVariant),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                vm.updateAttributeValue(attribute, controller.text);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
