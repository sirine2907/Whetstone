import 'package:flutter/material.dart';

import '../services/prompt_checker.dart';

// Five little ticks, one for each part of a good prompt.
class SharpnessMeter extends StatelessWidget {
  const SharpnessMeter({super.key, required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final parts = PromptChecker.check(prompt);
    final score = parts.where((part) => part.found).length;

    return Row(
      children: [
        for (final part in parts)
          Expanded(
            child: Tooltip(
              message: part.hint,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: part.found ? colors.secondary : colors.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      part.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: part.found ? FontWeight.w600 : FontWeight.w400,
                        color: part.found ? colors.onSurface : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(width: 2),
        Text('$score/5', style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
