import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sharpened_prompt.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sharpen_provider.dart';
import '../widgets/result_card.dart';
import '../widgets/sharpness_meter.dart';

const _examples = [
  'help me write an email asking for a raise',
  'explain recursion',
  'fix my flutter app crashing on startup',
];

class SharpenScreen extends StatelessWidget {
  const SharpenScreen({super.key});

  Future<void> _runSharpen(BuildContext context) async {
    final sharpen = context.read<SharpenProvider>();
    final history = context.read<HistoryProvider>();
    final apiKey = context.read<SettingsProvider>().apiKey;

    final result = await sharpen.sharpen(apiKey: apiKey);
    if (result != null) {
      history.add(result);
    }
  }

  void _runOffline(BuildContext context) {
    final sharpen = context.read<SharpenProvider>();
    final result = sharpen.sharpenOffline();
    if (result != null) {
      context.read<HistoryProvider>().add(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sharpen = context.watch<SharpenProvider>();
    final hasKey = context.watch<SettingsProvider>().hasApiKey;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text('What do you want\nto ask?', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        TextField(
          controller: sharpen.inputController,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Type your rough idea, messy is fine…',
          ),
        ),
        const SizedBox(height: 12),
        // Rebuilds only the meter and the examples as the user types.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: sharpen.inputController,
          builder: (context, value, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SharpnessMeter(prompt: value.text),
                if (value.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Or try one', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final example in _examples)
                        ActionChip(
                          label: Text(example),
                          onPressed: () => sharpen.loadDraft(example),
                        ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SharpenFocus>(
            showSelectedIcon: false,
            segments: [
              for (final focus in SharpenFocus.values)
                ButtonSegment(value: focus, label: Text(focus.label)),
            ],
            selected: {sharpen.focus},
            onSelectionChanged: (selection) => sharpen.setFocus(selection.first),
          ),
        ),
        const SizedBox(height: 6),
        Text(sharpen.focus.description, style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: sharpen.isLoading ? null : () => _runSharpen(context),
            child: Text(sharpen.isLoading ? 'Sharpening…' : 'Sharpen'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasKey
              ? 'Uses Claude with your API key.'
              : 'No API key yet, so you get an offline draft. Add a key in Settings to use Claude.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        if (sharpen.errorMessage != null)
          _ErrorBox(
            message: sharpen.errorMessage!,
            onUseOffline: () => _runOffline(context),
          ),
        if (sharpen.isLoading)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: sharpen.streamedText.isEmpty
                  ? const LinearProgressIndicator()
                  : Text(sharpen.streamedText, style: theme.textTheme.bodyMedium),
            ),
          ),
        if (sharpen.result != null)
          ResultCard(
            result: sharpen.result!,
            onSharpenAgain: () => sharpen.loadDraft(sharpen.result!.sharpened),
          ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onUseOffline});

  final String message;
  final VoidCallback onUseOffline;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: TextStyle(color: colors.error)),
          TextButton(
            onPressed: onUseOffline,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('Use an offline draft instead'),
          ),
        ],
      ),
    );
  }
}
