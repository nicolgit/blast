import 'package:flutter/material.dart';

/// A reusable widget for settings that includes a label and a switch toggle
class BlastSettingSwitch extends StatelessWidget {
  /// The text label to display for this setting
  final String label;

  /// The future that provides the boolean value for the switch
  final Future<bool> future;

  /// Callback function when the switch value changes
  final Function(bool) onChanged;

  /// The text theme to apply to the label
  final TextTheme textTheme;

  /// The theme data for styling
  final ThemeData theme;

  const BlastSettingSwitch({
    super.key,
    required this.label,
    required this.future,
    required this.onChanged,
    required this.textTheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        FutureBuilder<bool>(
          future: future,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return Switch(
              value: snapshot.hasData ? snapshot.data! : false,
              onChanged: (bool value) async {
                await onChanged(value);
              },
              activeColor: theme.colorScheme.primary,
            );
          },
        ),
      ],
    );
  }
}
