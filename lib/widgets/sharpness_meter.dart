import 'package:flutter/material.dart';

import '../services/prompt_checker.dart';
import '../theme.dart';

// Five little bars, one for each part of a good prompt. The parts that were
// found light up in the same pink as the glossy shapes.
class SharpnessMeter extends StatelessWidget {
  const SharpnessMeter({super.key, required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final glass = GlassColors.of(context);
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
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: part.found ? null : glass.glassBorder,
                        gradient: part.found
                            ? const LinearGradient(colors: [AppColors.orbPink, AppColors.orbViolet])
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      part.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
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
