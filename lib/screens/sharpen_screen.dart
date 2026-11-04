import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sharpened_prompt.dart';
import '../providers/history_provider.dart';
import '../providers/nav_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sharpen_provider.dart';
import '../services/prompt_checker.dart';
import '../theme.dart';
import '../widgets/glass.dart';
import '../widgets/glossy_shapes.dart';
import '../widgets/prompt_tile.dart';
import '../widgets/sharpness_meter.dart';

const _examples = [
  'help me write an email asking for a raise',
  'explain recursion',
  'fix my flutter app crashing on startup',
];

// One icon per focus mode for the three tiles.
const _focusIcons = {
  SharpenFocus.clear: Icons.bolt_rounded,
  SharpenFocus.detailed: Icons.notes_rounded,
  SharpenFocus.structured: Icons.view_agenda_outlined,
};

class SharpenScreen extends StatelessWidget {
  const SharpenScreen({super.key});

  Future<void> _runSharpen(BuildContext context) async {
    final sharpen = context.read<SharpenProvider>();
    final history = context.read<HistoryProvider>();
    final apiKey = context.read<SettingsProvider>().apiKey;

    if (sharpen.inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Type a rough idea first')));
      return;
    }

    // The result screen opens straight away and fills in as text arrives.
    openResult(context);
    final result = await sharpen.sharpen(apiKey: apiKey);
    if (result != null) {
      history.add(result);
    }
  }

  void _showTips(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What makes a prompt sharp', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            for (final part in PromptChecker.check('')) ...[
              Text(part.name, style: theme.textTheme.titleMedium),
              Text(part.hint, style: theme.textTheme.bodySmall),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sharpen = context.watch<SharpenProvider>();
    final hasKey = context.watch<SettingsProvider>().hasApiKey;
    final recent = context.watch<HistoryProvider>().items.take(2).toList();

    return ListView(
      // Extra space at the bottom so the floating nav bar doesn't cover anything.
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        Row(
          children: [
            const GlossyOrb(
              size: 46,
              child: Icon(Icons.auto_awesome, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Whetstone',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text('What should we sharpen today?', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            RoundIconButton(
              icon: Icons.lightbulb_outline_rounded,
              tooltip: 'Prompt tips',
              onPressed: () => _showTips(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(top: -10, right: -4, child: GlossySparkle(size: 64)),
              const Positioned(top: 44, right: 54, child: GlossySparkle(size: 30)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rough idea in,\nsharp prompt out',
                    style: theme.textTheme.headlineMedium?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sharpen.inputController,
                    minLines: 3,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Type your rough idea, messy is fine…',
                      fillColor: GlassColors.of(context).bubble,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Rebuilds only the meter and the examples as the user types.
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: sharpen.inputController,
                    builder: (context, value, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SharpnessMeter(prompt: value.text),
                          if (value.text.isEmpty) ...[
                            const SizedBox(height: 14),
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
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final focus in SharpenFocus.values) ...[
              if (focus != SharpenFocus.clear) const SizedBox(width: 10),
              Expanded(
                child: _FocusTile(
                  focus: focus,
                  selected: sharpen.focus == focus,
                  onTap: () => sharpen.setFocus(focus),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(sharpen.focus.description, style: theme.textTheme.bodySmall),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: sharpen.isLoading ? null : () => _runSharpen(context),
            child: Text(sharpen.isLoading ? 'Sharpening…' : 'Sharpen'),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            hasKey
                ? 'Uses Claude with your API key.'
                : 'No API key yet, so you get an offline draft.',
            style: theme.textTheme.bodySmall,
          ),
        ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Text('Recent', style: theme.textTheme.titleLarge)),
              TextButton(
                onPressed: () => context.read<NavProvider>().goTo(2),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final item in recent) ...[PromptTile(item: item), const SizedBox(height: 10)],
        ],
      ],
    );
  }
}

class _FocusTile extends StatelessWidget {
  const _FocusTile({required this.focus, required this.selected, required this.onTap});

  final SharpenFocus focus;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      solid: selected,
      radius: 22,
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlossyOrb(size: 34, child: Icon(_focusIcons[focus], size: 18, color: Colors.white)),
          const SizedBox(height: 14),
          Text(
            focus.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
