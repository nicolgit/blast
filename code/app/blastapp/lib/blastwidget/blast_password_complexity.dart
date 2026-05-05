import 'package:flutter/material.dart';

class BlastPasswordComplexity extends StatelessWidget {
  const BlastPasswordComplexity({super.key, required this.currentPassword});

  final String currentPassword;

  @override
  Widget build(BuildContext context) {
    final complexity = _calculateComplexity(currentPassword);

    return LinearProgressIndicator(
      value: complexity / 10.0,
      backgroundColor: Colors.grey.shade300,
      color: _getColor(complexity),
      minHeight: 8,
    );
  }

  Color _getColor(int complexity) {
    if (complexity <= 3) return Colors.red;
    if (complexity <= 6) return Colors.orange;
    return Colors.green;
  }

  // Scores password complexity from 1 (weak) to 10 (strong) based on:
  // - Length: +1 for each threshold at 4, 8, 12, 16 chars (max 4 pts)
  // - Character variety: +1 each for lowercase, uppercase, digits, symbols (max 4 pts)
  // - Uniqueness: +1 for 8+ unique chars, +1 for 12+ unique chars (max 2 pts)
  int _calculateComplexity(String password) {
    if (password.isEmpty) return 1;

    int score = 0;

    // Length contribution
    if (password.length >= 4) score++;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // Character variety
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // Bonus for mixed characters beyond minimum
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars >= 8) score++;
    if (uniqueChars >= 12) score++;

    return score.clamp(1, 10);
  }
}
