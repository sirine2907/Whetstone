// A good prompt usually has these five parts. This is a simple keyword check,
// not real language understanding: it gives a quick hint about what is missing.
class PromptPart {
  const PromptPart(this.name, this.hint, this.found);

  final String name;
  final String hint;
  final bool found;
}

class PromptChecker {
  static final _role = RegExp(r"\b(act as|you are|you're|imagine you|as an? [a-z]+)\b");
  static final _task = RegExp(
    r'\b(write|create|explain|summari[sz]e|review|fix|make|build|plan|list|compare|translate|draft|rewrite|design|analy[sz]e|help|give|suggest|find|turn)\b',
  );
  static final _context = RegExp(
    r"\b(because|context|background|audience|i am|i'm|my|our|we are|we're|the goal|so that|target)\b",
  );
  static final _format = RegExp(
    r'\b(bullets?|table|list|steps?|json|markdown|format|paragraphs?|sections?|outline|headings?)\b',
  );
  static final _limits = RegExp(
    r"\b(under|at most|no more than|avoid|don't|do not|must|only|words|tone|limit|keep|requirements?)\b",
  );

  static List<PromptPart> check(String prompt) {
    final text = prompt.toLowerCase();
    return [
      PromptPart('Role', 'Who should the AI act as?', _role.hasMatch(text)),
      PromptPart('Task', 'What should it actually do?', _task.hasMatch(text)),
      PromptPart('Context', 'Who is this for and why?', _context.hasMatch(text)),
      PromptPart('Format', 'What should the answer look like?', _format.hasMatch(text)),
      PromptPart('Limits', 'Any length, tone or rules?', _limits.hasMatch(text)),
    ];
  }

  static int score(String prompt) {
    return check(prompt).where((part) => part.found).length;
  }
}
