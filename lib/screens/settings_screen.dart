import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass.dart';
import '../widgets/glossy_shapes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showApiKeyDialog(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final controller = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Claude API key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create one at console.anthropic.com. It stays on this device, in secure storage.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'sk-ant-…'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true && controller.text.trim().isNotEmpty) {
      await settings.saveApiKey(controller.text);
    }
    controller.dispose();
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final history = context.read<HistoryProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This deletes every saved prompt, including starred ones.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      history.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final historyCount = context.watch<HistoryProvider>().items.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
      children: [
        Text('Settings', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 24),
        const _SectionLabel('Appearance'),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (selection) => settings.setThemeMode(selection.first),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Claude'),
        GlassCard(
          child: Stack(
            children: [
              const Positioned(top: 0, right: 0, child: GlossySparkle(size: 40)),
              Padding(
                padding: const EdgeInsets.only(right: 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.hasApiKey ? 'API key saved' : 'No API key',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.hasApiKey
                          ? 'Prompts are sent to Claude and billed to your account.'
                          : 'Without a key, Whetstone makes offline drafts and nothing leaves this device.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton(
                          style: FilledButton.styleFrom(minimumSize: const Size(0, 46)),
                          onPressed: () => _showApiKeyDialog(context),
                          child: Text(settings.hasApiKey ? 'Replace key' : 'Add key'),
                        ),
                        if (settings.hasApiKey) ...[
                          const SizedBox(width: 10),
                          TextButton(onPressed: settings.removeApiKey, child: const Text('Remove')),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Data'),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: ListTile(
            title: Text('Clear history', style: theme.textTheme.titleMedium),
            subtitle: Text('$historyCount saved', style: theme.textTheme.bodySmall),
            trailing: const Icon(Icons.delete_outline),
            enabled: historyCount > 0,
            onTap: () => _confirmClearHistory(context),
          ),
        ),
        const SizedBox(height: 24),
        Center(child: Text('Whetstone 1.0.0', style: theme.textTheme.bodySmall)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
