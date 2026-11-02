import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sharpened_prompt.dart';
import '../services/prompt_checker.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.result, required this.onSharpenAgain});

  final SharpenedPrompt result;
  final VoidCallback onSharpenAgain;

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: result.sharpened));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final before = PromptChecker.score(result.original);
    final after = PromptChecker.score(result.sharpened);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Sharpened', style: theme.textTheme.titleLarge)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$before/5 → $after/5',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              result.usedClaude
                  ? '${result.focus.label} rewrite by Claude'
                  : '${result.focus.label} offline draft. Fill in the [brackets]',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SelectableText(result.sharpened, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(context),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSharpenAgain,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Use as input'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
