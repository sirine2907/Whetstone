import 'package:flutter/material.dart';

import '../models/prompt_template.dart';

const templates = [
  // Writing
  PromptTemplate(
    title: 'Cold Outreach Email',
    description: 'A short first email that gets a reply',
    category: TemplateCategory.writing,
    icon: Icons.mail_outline,
    fields: [
      TemplateField('who', 'Who it goes to', 'a hiring manager at a fintech startup'),
      TemplateField('ask', 'What you want', 'a 15 minute call about the junior role'),
      TemplateField('why', 'Why you', 'I built two Flutter apps in the same space'),
    ],
    body: 'Write a cold email to {who}. The goal is {ask}. The reason they should '
        'care: {why}.\n\nKeep it under 120 words, sound like a real person, and end '
        'with one easy question. Give me three subject line options as well.',
  ),
  PromptTemplate(
    title: 'Blog Post Outline',
    description: 'Headings and key points before you write',
    category: TemplateCategory.writing,
    icon: Icons.article_outlined,
    fields: [
      TemplateField('topic', 'Topic', 'why small apps are good for learning'),
      TemplateField('reader', 'Reader', 'people starting their first coding job'),
    ],
    body: 'Create an outline for a blog post about {topic}, written for {reader}.'
        '\n\nInclude a hook for the opening, 4 to 6 section headings with two key '
        'points each, and a closing thought. Do not write the full post yet.',
  ),
  PromptTemplate(
    title: 'Say It Plainly',
    description: 'Turn stiff text into normal language',
    category: TemplateCategory.writing,
    icon: Icons.short_text,
    fields: [
      TemplateField('text', 'Your text', 'paste the paragraph here'),
      TemplateField('reader', 'Reader', 'customers with no technical background'),
    ],
    body: 'Rewrite the text below so {reader} can understand it on the first read. '
        'Use short sentences and everyday words, and keep every fact.\n\nText:\n{text}',
  ),

  // Code
  PromptTemplate(
    title: 'Track Down a Bug',
    description: 'Give the details needed to find the cause',
    category: TemplateCategory.code,
    icon: Icons.bug_report_outlined,
    fields: [
      TemplateField('stack', 'Tech stack', 'Flutter 3.38 with Provider'),
      TemplateField('expected', 'What should happen', 'the list refreshes after saving'),
      TemplateField('actual', 'What happens', 'the old items stay until a restart'),
      TemplateField('code', 'Relevant code', 'paste the code or the error here'),
    ],
    body: 'I have a bug in a {stack} project.\n\nExpected: {expected}\nActual: {actual}'
        '\n\nCode or error:\n{code}\n\nList the most likely causes in order, tell me '
        'how to confirm each one, then show the fix for the most likely cause.',
  ),
  PromptTemplate(
    title: 'Walk Me Through This Code',
    description: 'Understand code you did not write',
    category: TemplateCategory.code,
    icon: Icons.code,
    fields: [
      TemplateField('level', 'Your level', 'junior developer, new to Dart'),
      TemplateField('code', 'The code', 'paste the code here'),
    ],
    body: 'Explain this code to me. My level: {level}.\n\nStart with one sentence on '
        'what it does overall, then go through it step by step. Point out anything '
        'unusual or risky.\n\nCode:\n{code}',
  ),
  PromptTemplate(
    title: 'Pull Request Review',
    description: 'A second pair of eyes before you merge',
    category: TemplateCategory.code,
    icon: Icons.rule,
    fields: [
      TemplateField('goal', 'What the change does', 'adds search to the history screen'),
      TemplateField('diff', 'The diff', 'paste the diff here'),
    ],
    body: 'Review this change as a senior developer. The change is meant to: {goal}.'
        '\n\nReport real bugs first, then edge cases, then readability. For each one, '
        'quote the line and suggest a fix. If something is fine, do not comment on it.'
        '\n\nDiff:\n{diff}',
  ),

  // Work
  PromptTemplate(
    title: 'Meeting Notes to Actions',
    description: 'Decisions and owners from messy notes',
    category: TemplateCategory.work,
    icon: Icons.groups_outlined,
    fields: [
      TemplateField('notes', 'Your notes', 'paste the meeting notes here'),
    ],
    body: 'Turn these meeting notes into a clean summary.\n\nReturn three sections: '
        'Decisions, Action items as a table with owner and due date, and Open questions. '
        'If an owner or date is missing, write "not set" instead of guessing.'
        '\n\nNotes:\n{notes}',
  ),
  PromptTemplate(
    title: 'Weigh Two Options',
    description: 'Compare a choice and get a recommendation',
    category: TemplateCategory.work,
    icon: Icons.balance,
    fields: [
      TemplateField('a', 'Option A', 'take the remote job'),
      TemplateField('b', 'Option B', 'stay and ask for a promotion'),
      TemplateField('matters', 'What matters to you', 'learning fast and steady income'),
    ],
    body: 'Help me decide between {a} and {b}. What matters most to me: {matters}.'
        '\n\nCompare them in a table, name the biggest risk of each, then give a clear '
        'recommendation and say what would change your mind.',
  ),
  PromptTemplate(
    title: 'Weekly Status Update',
    description: 'A short update your team will read',
    category: TemplateCategory.work,
    icon: Icons.event_note_outlined,
    fields: [
      TemplateField('done', 'What you finished', 'shipped login, fixed two crashes'),
      TemplateField('next', 'What is next', 'start on notifications'),
      TemplateField('blocked', 'Any blockers', 'waiting on the API docs'),
    ],
    body: 'Write my weekly status update for my team.\n\nDone: {done}\nNext: {next}'
        '\nBlocked: {blocked}\n\nUse three short bullet sections and keep it under '
        '100 words. Lead with the result, not the effort.',
  ),

  // Study
  PromptTemplate(
    title: 'Teach Me a Concept',
    description: 'From a simple idea up to the details',
    category: TemplateCategory.study,
    icon: Icons.school_outlined,
    fields: [
      TemplateField('concept', 'Concept', 'database indexes'),
      TemplateField('know', 'What you already know', 'basic SQL queries'),
    ],
    body: 'Teach me {concept}. I already know {know}.\n\nStart with an everyday '
        'comparison, then the real explanation, then one worked example. Finish with '
        'three questions to check that I understood, and hold the answers until I reply.',
  ),
  PromptTemplate(
    title: 'Study Plan',
    description: 'A realistic schedule up to a deadline',
    category: TemplateCategory.study,
    icon: Icons.calendar_month_outlined,
    fields: [
      TemplateField('goal', 'Goal', 'pass the networking exam'),
      TemplateField('time', 'Time you have', '3 weeks, about an hour a day'),
      TemplateField('weak', 'Weak spots', 'subnetting and routing'),
    ],
    body: 'Make a study plan for this goal: {goal}. Time available: {time}. My weak '
        'spots: {weak}.\n\nGive me a day by day table with the topic, a concrete task, '
        'and how I check my progress. Leave time for review before the end.',
  ),
  PromptTemplate(
    title: 'Flashcards From Notes',
    description: 'Question and answer cards to revise with',
    category: TemplateCategory.study,
    icon: Icons.style_outlined,
    fields: [
      TemplateField('notes', 'Your notes', 'paste the chapter or notes here'),
      TemplateField('count', 'How many cards', '15'),
    ],
    body: 'Make {count} flashcards from the notes below. Each card tests one idea, with '
        'a question on the front and a short answer on the back. Use only what is in '
        'the notes, and return them as a two column table.\n\nNotes:\n{notes}',
  ),
];
