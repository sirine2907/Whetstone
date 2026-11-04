import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/prompt_template.dart';
import '../providers/nav_provider.dart';
import '../providers/sharpen_provider.dart';
import '../widgets/glass.dart';
import '../widgets/glossy_shapes.dart';

class TemplateDetailScreen extends StatefulWidget {
  const TemplateDetailScreen({super.key, required this.template});

  final PromptTemplate template;

  @override
  State<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen> {
  final Map<String, String> _values = {};

  String get _filledPrompt => widget.template.fill(_values);

  void _copy() {
    Clipboard.setData(ClipboardData(text: _filledPrompt));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  // Puts the prompt in the Sharpen tab's input and goes back there.
  void _sendToSharpen() {
    context.read<SharpenProvider>().loadDraft(_filledPrompt);
    context.read<NavProvider>().goToSharpen();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final template = widget.template;

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  GlassHeader(
                    title: template.category.label,
                    trailing: RoundIconButton(
                      icon: Icons.copy_rounded,
                      tooltip: 'Copy prompt',
                      onPressed: _copy,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        Row(
                          children: [
                            GlossyOrb(
                              size: 52,
                              child: Icon(template.icon, size: 24, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                template.title,
                                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 28),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          template.description,
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 22),
                        for (final field in template.fields) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 6),
                            child: Text(field.label, style: theme.textTheme.labelMedium),
                          ),
                          TextField(
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(hintText: field.hint),
                            onChanged: (value) => setState(() => _values[field.key] = value),
                          ),
                          const SizedBox(height: 14),
                        ],
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 6),
                          child: Text('Preview', style: theme.textTheme.labelMedium),
                        ),
                        GlassCard(
                          solid: true,
                          radius: 22,
                          child: SelectableText(_filledPrompt, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _sendToSharpen,
                        child: const Text('Send to Sharpen'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
