import 'package:flutter/material.dart';

/// A text widget that displays text with preserved newlines and allows text selection.
///
/// This widget takes a string and a text style as input, and displays the text
/// while maintaining line breaks and allowing partial text selection.
class BlastMarkdownText extends StatelessWidget {
  /// The text string to display
  final String text;

  /// The style to apply to the text
  final TextStyle? style;

  /// The style to apply to header text (lines beginning with #)
  final TextStyle? styleHeader;

  /// Creates a BlastText widget.
  ///
  /// The [text] parameter is required and contains the text to display.
  /// The [style] parameter is optional and defines the text styling.
  /// The [styleHeader] parameter is optional and defines the header styling.
  const BlastMarkdownText({
    super.key,
    required this.text,
    this.style,
    this.styleHeader,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      _buildTextSpan(),
      style: style,
      // Preserve newlines and whitespace
      textAlign: TextAlign.start,
      // Allow partial text selection
      enableInteractiveSelection: true,
      // Show cursor when text is selected
      showCursor: true,
      // Allow selection across multiple lines
      selectionControls: MaterialTextSelectionControls(),
    );
  }

  /// Builds a TextSpan with formatting for text between asterisks, headers, and bullets
  /// * = italic, ** = bold, *** = bold+italic
  /// Lines beginning with # ## ### #### ##### ###### are headers (bold + styleHeader)
  /// Lines beginning with "* " are bullet points
  TextSpan _buildTextSpan() {
    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check if line is a header (starts with #)
      final headerMatch = RegExp(r'^(#{1,6})\s*(.*)$').firstMatch(line);

      // Check if line is a bullet point (starts with "* ")
      final bulletMatch = RegExp(r'^\*\s+(.*)$').firstMatch(line);

      if (headerMatch != null) {
        // This is a header line
        final headerText = headerMatch.group(2)!; // Text after #

        // Apply header style (bold + custom styleHeader if provided)
        final headerStyle = (styleHeader ?? style ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.bold,
        );

        spans.add(TextSpan(
          text: headerText,
          style: headerStyle,
        ));
      } else if (bulletMatch != null) {
        // This is a bullet point line
        final bulletText = bulletMatch.group(1)!; // Text after "* "

        // Add bullet character and formatted text
        spans.add(TextSpan(
          text: '• ',
          style: style,
        ));
        spans.add(_buildFormattedLineSpan(bulletText));
      } else {
        // This is a regular line, apply asterisk formatting
        spans.add(_buildFormattedLineSpan(line));
      }

      // Add newline except for the last line
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: spans);
  }

  /// Builds a TextSpan for a single line with asterisk formatting
  TextSpan _buildFormattedLineSpan(String lineText) {
    final List<TextSpan> spans = [];

    // Pattern to match ***, **, or * (in order of priority)
    final RegExp formattingPattern = RegExp(r'\*\*\*([^*]+)\*\*\*|\*\*([^*]+)\*\*|\*([^*]+)\*');

    int lastEnd = 0;

    for (final match in formattingPattern.allMatches(lineText)) {
      // Add normal text before the formatted text
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: lineText.substring(lastEnd, match.start),
          style: style,
        ));
      }

      // Determine formatting based on which group matched
      String formattedText;
      TextStyle formattedStyle = style ?? const TextStyle();

      if (match.group(1) != null) {
        // *** = bold + italic
        formattedText = match.group(1)!;
        formattedStyle = formattedStyle.copyWith(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        );
      } else if (match.group(2) != null) {
        // ** = bold
        formattedText = match.group(2)!;
        formattedStyle = formattedStyle.copyWith(
          fontWeight: FontWeight.bold,
        );
      } else {
        // * = italic
        formattedText = match.group(3)!;
        formattedStyle = formattedStyle.copyWith(
          fontStyle: FontStyle.italic,
        );
      }

      spans.add(TextSpan(
        text: formattedText,
        style: formattedStyle,
      ));

      lastEnd = match.end;
    }

    // Add remaining normal text
    if (lastEnd < lineText.length) {
      spans.add(TextSpan(
        text: lineText.substring(lastEnd),
        style: style,
      ));
    }

    // If no formatting was applied, return a simple TextSpan
    if (spans.isEmpty) {
      return TextSpan(text: lineText, style: style);
    }

    return TextSpan(children: spans);
  }
}
