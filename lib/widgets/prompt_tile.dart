import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sharpened_prompt.dart';
import '../providers/sharpen_provider.dart';
import '../screens/result_screen.dart';
import 'glass.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

void openResult(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResultScreen()));
}

// A saved prompt as a white card: the focus and date on top, the rough text
// under it. Used on the home screen and in History.
class PromptTile extends StatelessWidget {
  const PromptTile({super.key, required this.item, this.trailing});

  final SharpenedPrompt item;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      solid: true,
      radius: 22,
      padding: EdgeInsets.fromLTRB(18, 14, trailing == null ? 18 : 6, 14),
      onTap: () {
        context.read<SharpenProvider>().showSaved(item);
        openResult(context);
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.focus.label,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(formatDate(item.createdAt), style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.original,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
