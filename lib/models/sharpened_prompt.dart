// How the user wants the rough prompt improved.
enum SharpenFocus {
  clear('Clear', 'Short and direct'),
  detailed('Detailed', 'Spells out depth and examples'),
  structured('Structured', 'Labelled sections');

  const SharpenFocus(this.label, this.description);

  final String label;
  final String description;
}

// One finished result: what the user typed and what they got back.
class SharpenedPrompt {
  SharpenedPrompt({
    required this.id,
    required this.original,
    required this.sharpened,
    required this.focus,
    required this.usedClaude,
    required this.createdAt,
    this.starred = false,
  });

  final String id;
  final String original;
  final String sharpened;
  final SharpenFocus focus;
  final bool usedClaude; // false means it came from the offline sharpener
  final DateTime createdAt;
  bool starred;

  Map<String, dynamic> toJson() => {
    'id': id,
    'original': original,
    'sharpened': sharpened,
    'focus': focus.name,
    'usedClaude': usedClaude,
    'createdAt': createdAt.toIso8601String(),
    'starred': starred,
  };

  factory SharpenedPrompt.fromJson(Map<String, dynamic> json) {
    return SharpenedPrompt(
      id: json['id'] as String,
      original: json['original'] as String,
      sharpened: json['sharpened'] as String,
      focus: SharpenFocus.values.byName(json['focus'] as String),
      usedClaude: json['usedClaude'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      starred: json['starred'] as bool,
    );
  }
}
