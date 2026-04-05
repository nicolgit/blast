import 'package:flutter/material.dart';

class BlastEditButton extends StatelessWidget {
  const BlastEditButton({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.iconSize = 18,
    this.padding,
  });

  final VoidCallback? onPressed;
  final String? tooltip;
  final double iconSize;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final button = IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(Icons.edit, size: iconSize),
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.tertiaryContainer,
        foregroundColor: theme.colorScheme.onTertiaryContainer,
        side: BorderSide(color: theme.colorScheme.primary),
      ),
    );

    if (padding != null) {
      return Padding(padding: padding!, child: button);
    }

    return button;
  }
}
