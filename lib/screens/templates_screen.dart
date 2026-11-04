import 'package:flutter/material.dart';

import '../data/templates.dart';
import '../models/prompt_template.dart';
import '../widgets/glass.dart';
import '../widgets/glossy_shapes.dart';
import 'template_detail_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  TemplateCategory? _category; // null means "All"
  String _search = '';

  List<PromptTemplate> get _visibleTemplates {
    final query = _search.toLowerCase();
    return templates.where((template) {
      final matchesCategory = _category == null || template.category == _category;
      final matchesSearch =
          template.title.toLowerCase().contains(query) ||
          template.description.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = _visibleTemplates;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
      children: [
        Text('Templates', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          '${templates.length} ready made prompts with blanks to fill in',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 18),
        TextField(
          onChanged: (value) => setState(() => _search = value),
          decoration: const InputDecoration(
            hintText: 'Search templates',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: _category == null,
              onSelected: (_) => setState(() => _category = null),
            ),
            for (final category in TemplateCategory.values)
              ChoiceChip(
                label: Text(category.label),
                selected: _category == category,
                onSelected: (_) => setState(() => _category = category),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text('No templates match that search.', style: theme.textTheme.bodySmall),
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visible.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 168,
          ),
          itemBuilder: (context, index) => _TemplateCard(template: visible[index]),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template});

  final PromptTemplate template;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => TemplateDetailScreen(template: template)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlossyOrb(size: 40, child: Icon(template.icon, size: 19, color: Colors.white)),
              const Spacer(),
              Text(template.category.label, style: theme.textTheme.labelMedium),
            ],
          ),
          const Spacer(),
          Text(
            template.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, height: 1.25),
          ),
          const SizedBox(height: 4),
          Text(
            template.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
