import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sharpened_prompt.dart';
import '../providers/history_provider.dart';
import '../widgets/prompt_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _starredOnly = false;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allItems = context.watch<HistoryProvider>().items;

    final query = _search.toLowerCase();
    final items = allItems.where((item) {
      final matchesStar = !_starredOnly || item.starred;
      final matchesSearch =
          item.original.toLowerCase().contains(query) ||
          item.sharpened.toLowerCase().contains(query);
      return matchesStar && matchesSearch;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
      children: [
        Text('History', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('${allItems.length} saved on this device', style: theme.textTheme.bodySmall),
        const SizedBox(height: 18),
        TextField(
          onChanged: (value) => setState(() => _search = value),
          decoration: const InputDecoration(
            hintText: 'Search history',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: !_starredOnly,
              onSelected: (_) => setState(() => _starredOnly = false),
            ),
            ChoiceChip(
              label: const Text('Starred'),
              selected: _starredOnly,
              onSelected: (_) => setState(() => _starredOnly = true),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                allItems.isEmpty ? 'Prompts you sharpen will show up here.' : 'Nothing matches.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        for (final item in items) ...[_HistoryTile(item: item), const SizedBox(height: 10)],
      ],
    );
  }
}

// A prompt tile you can swipe away, with a star button on the right.
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final SharpenedPrompt item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = context.read<HistoryProvider>();

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => history.remove(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
      ),
      child: PromptTile(
        item: item,
        trailing: IconButton(
          tooltip: item.starred ? 'Remove star' : 'Star',
          onPressed: () => history.toggleStar(item.id),
          icon: Icon(
            item.starred ? Icons.star_rounded : Icons.star_outline_rounded,
            color: item.starred ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
