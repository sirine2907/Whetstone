import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../providers/sharpen_provider.dart';
import '../services/prompt_checker.dart';
import '../widgets/glass.dart';
import '../widgets/glossy_shapes.dart';

// Shows a sharpen run like a short chat: your rough prompt on the right,
// the sharpened one on the left. It watches SharpenProvider, so it also
// shows the text while it is still streaming in.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  void _useOffline(BuildContext context) {
    final result = context.read<SharpenProvider>().sharpenOffline();
    if (result != null) {
      context.read<HistoryProvider>().add(result);
    }
  }

  // Puts the sharpened text back in the input so it can be edited.
  void _editAgain(BuildContext context, String text) {
    context.read<SharpenProvider>().loadDraft(text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sharpen = context.watch<SharpenProvider>();
    final history = context.watch<HistoryProvider>();
    final result = sharpen.result;

    final original = result?.original ?? sharpen.inputController.text.trim();
    final isSaved = result != null && history.items.any((item) => item.id == result.id);

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  GlassHeader(
                    title: '${sharpen.focus.label} prompt',
                    trailing: isSaved
                        ? RoundIconButton(
                            icon: result.starred ? Icons.star_rounded : Icons.star_outline_rounded,
                            tooltip: result.starred ? 'Remove star' : 'Star',
                            onPressed: () => history.toggleStar(result.id),
                          )
                        : null,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      children: [
                        _Bubble(
                          fromUser: true,
                          child: Text(original, style: theme.textTheme.bodyMedium),
                        ),
                        if (sharpen.isLoading)
                          _Bubble(
                            child: sharpen.streamedText.isEmpty
                                ? Text('Sharpening…', style: theme.textTheme.bodySmall)
                                : Text(sharpen.streamedText, style: theme.textTheme.bodyMedium),
                          ),
                        if (sharpen.errorMessage != null)
                          _Bubble(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sharpen.errorMessage!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _useOffline(context),
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                  child: const Text('Use an offline draft instead'),
                                ),
                              ],
                            ),
                          ),
                        if (result != null) ...[
                          _ScoreBubble(
                            before: PromptChecker.score(result.original),
                            after: PromptChecker.score(result.sharpened),
                          ),
                          _Bubble(
                            child: SelectableText(
                              result.sharpened,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              result.usedClaude
                                  ? '${result.focus.label} rewrite by Claude'
                                  : '${result.focus.label} offline draft. Fill in the [brackets]',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (result != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              radius: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
                              onTap: () => _editAgain(context, result.sharpened),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    size: 22,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Edit and sharpen again', style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          RoundIconButton(
                            icon: Icons.copy_rounded,
                            tooltip: 'Copy',
                            size: 62,
                            onPressed: () => _copy(context, result.sharpened),
                          ),
                        ],
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.child, this.fromUser = false});

  final Widget child;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    // Bubbles take at most 82% of the width, like in a messaging app.
    final maxWidth = MediaQuery.sizeOf(context).width.clamp(0.0, 640.0) * 0.82;

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            solid: true,
            radius: 22,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: child,
          ),
        ),
      ),
    );
  }
}

// The score before and after, drawn as a row of bars like a voice message.
class _ScoreBubble extends StatelessWidget {
  const _ScoreBubble({required this.before, required this.after});

  final int before;
  final int after;

  // Fixed bar heights so the "wave" looks the same every time.
  static const _barHeights = <double>[
    8, 14, 22, 12, 26, 18, 10, 22, 28, 16, 12, 24, 18, 8, //
    20, 26, 14, 10, 22, 16, 12, 24, 18, 10, 14, 8,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // How many bars are dark depends on the new score out of 5.
    final litBars = (_barHeights.length * after / 5).round();

    return _Bubble(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GlossyOrb(size: 38, child: Icon(Icons.auto_awesome, size: 18, color: Colors.white)),
          const SizedBox(width: 12),
          for (var i = 0; i < _barHeights.length; i++)
            Container(
              width: 2.5,
              height: _barHeights[i],
              margin: const EdgeInsets.symmetric(horizontal: 1.4),
              decoration: BoxDecoration(
                color: i < litBars
                    ? colors.onSurface
                    : colors.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          const SizedBox(width: 12),
          Text(
            '$before/5 → $after/5',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurface),
          ),
        ],
      ),
    );
  }
}
