import '../models/sharpened_prompt.dart';

// Works with no internet and no API key. It can't understand the prompt, so it
// wraps it in a good structure and leaves [brackets] for the user to fill in.
class LocalSharpener {
  static String sharpen(String rough, SharpenFocus focus) {
    final task = _cleanUp(rough);
    final role = _pickRole(task);

    switch (focus) {
      case SharpenFocus.clear:
        return 'You are $role.\n\n'
            '$task.\n\n'
            'Context: [who this is for and why it matters]\n\n'
            'Keep the answer short and in plain language. If something '
            'important is missing, ask me one question before you start.';
      case SharpenFocus.detailed:
        return 'You are $role.\n\n'
            '$task.\n\n'
            'Context: [who this is for and why it matters]\n'
            'What I already know or tried: [add details]\n\n'
            'Go into depth. Explain your reasoning, give at least one concrete '
            'example, and point out common mistakes. If you have to assume '
            'something, say what you assumed.';
      case SharpenFocus.structured:
        return 'Role: $role\n\n'
            'Task: $task.\n\n'
            'Context: [who this is for and why it matters]\n\n'
            'Requirements:\n'
            '- [anything the answer must include]\n'
            '- [anything it must avoid]\n\n'
            'Output format:\n'
            '1. A one-paragraph summary\n'
            '2. The main answer as a numbered list\n'
            '3. The next step I should take';
    }
  }

  static String _cleanUp(String rough) {
    var text = rough.trim();
    while (text.endsWith('.') || text.endsWith('!') || text.endsWith('?')) {
      text = text.substring(0, text.length - 1);
    }
    if (text.isEmpty) return rough.trim(); // the prompt was only punctuation
    return text[0].toUpperCase() + text.substring(1);
  }

  static String _pickRole(String task) {
    final text = task.toLowerCase();
    if (_hasAny(text, ['code', 'bug', 'function', 'api', 'flutter', 'python', 'app', 'error'])) {
      return 'an experienced software engineer';
    }
    if (_hasAny(text, ['email', 'letter', 'message', 'blog', 'post', 'article'])) {
      return 'a skilled professional writer';
    }
    if (_hasAny(text, ['learn', 'study', 'exam', 'explain', 'understand', 'teach'])) {
      return 'a patient teacher';
    }
    if (_hasAny(text, ['business', 'marketing', 'startup', 'sales', 'customer', 'plan'])) {
      return 'a practical business strategist';
    }
    return 'a knowledgeable expert on this topic';
  }

  static bool _hasAny(String text, List<String> words) {
    return words.any((word) => text.contains(word));
  }
}
