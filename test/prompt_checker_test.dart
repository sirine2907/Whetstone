import 'package:flutter_test/flutter_test.dart';
import 'package:whetstone/data/templates.dart';
import 'package:whetstone/models/sharpened_prompt.dart';
import 'package:whetstone/services/local_sharpener.dart';
import 'package:whetstone/services/prompt_checker.dart';

void main() {
  group('PromptChecker', () {
    test('empty prompt scores zero', () {
      expect(PromptChecker.score(''), 0);
    });

    test('a vague prompt only finds the task', () {
      expect(PromptChecker.score('explain recursion'), 1);
    });

    test('a complete prompt scores five', () {
      const prompt =
          'You are a teacher. Explain recursion because my students are new. '
          'Use a numbered list and keep it under 100 words.';
      expect(PromptChecker.score(prompt), 5);
    });

    test('an unfilled blank does not count, but a filled one does', () {
      expect(PromptChecker.score('Context: [who this is for]'), 0);
      expect(PromptChecker.score('Context: for my students'), 1);
    });

    test('a blank does not hide the words before it', () {
      expect(PromptChecker.score('write a post about [topic]'), 1);
    });
  });

  group('LocalSharpener', () {
    test('picks a role that fits the prompt', () {
      final text = LocalSharpener.sharpen('fix my flutter app', SharpenFocus.clear);
      expect(text, contains('software engineer'));
    });

    test('capitalizes the task and removes the trailing punctuation', () {
      final text = LocalSharpener.sharpen('explain recursion!!', SharpenFocus.clear);
      expect(text, contains('Explain recursion.'));
    });

    test('does not crash on a prompt of only punctuation', () {
      expect(LocalSharpener.sharpen('...', SharpenFocus.clear), isNotEmpty);
    });

    test('every focus gives a better score than the rough prompt', () {
      const rough = 'plan a birthday party';
      for (final focus in SharpenFocus.values) {
        final text = LocalSharpener.sharpen(rough, focus);
        expect(PromptChecker.score(text), greaterThan(PromptChecker.score(rough)));
      }
    });
  });

  group('templates', () {
    test('filled blanks replace the placeholders', () {
      final template = templates.first;
      final text = template.fill({'who': 'Sam', 'ask': 'a call', 'why': 'we met'});
      expect(text, contains('Sam'));
      expect(text, isNot(contains('{')));
    });

    test('empty blanks show the field label in brackets', () {
      final template = templates.first;
      expect(template.fill({}), contains('[${template.fields.first.label}]'));
    });

    test('every field in every template is used in its body', () {
      for (final template in templates) {
        for (final field in template.fields) {
          expect(template.body, contains('{${field.key}}'), reason: template.title);
        }
      }
    });
  });
}
