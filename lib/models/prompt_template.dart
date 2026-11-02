import 'package:flutter/material.dart';

enum TemplateCategory {
  writing('Writing'),
  code('Code'),
  work('Work'),
  study('Study');

  const TemplateCategory(this.label);

  final String label;
}

// One blank the user fills in, like "Topic". [key] matches {key} in the body.
class TemplateField {
  const TemplateField(this.key, this.label, this.hint);

  final String key;
  final String label;
  final String hint;
}

class PromptTemplate {
  const PromptTemplate({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.fields,
    required this.body,
  });

  final String title;
  final String description;
  final TemplateCategory category;
  final IconData icon;
  final List<TemplateField> fields;
  final String body;

  // Puts the user's answers into the body. Blanks stay visible as [Label].
  String fill(Map<String, String> values) {
    var text = body;
    for (final field in fields) {
      final value = values[field.key]?.trim() ?? '';
      text = text.replaceAll('{${field.key}}', value.isEmpty ? '[${field.label}]' : value);
    }
    return text;
  }
}
