import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/prompt_template.dart';
import '../providers/nav_provider.dart';
import '../providers/sharpen_provider.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
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
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(template.title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(template.description, style: theme.textTheme.bodySmall),
              const SizedBox(height: 20),
              for (final field in template.fields) ...[
                Text(field.label, style: theme.textTheme.labelMedium),
                const SizedBox(height: 6),
                TextField(
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(hintText: field.hint),
                  onChanged: (value) => setState(() => _values[field.key] = value),
                ),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 6),
              Text('Preview', style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: SelectableText(_filledPrompt, style: theme.textTheme.bodyMedium),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _sendToSharpen,
                  child: const Text('Send to Sharpen'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _copy,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy prompt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
