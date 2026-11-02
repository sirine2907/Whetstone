import 'package:flutter/material.dart';

import '../models/sharpened_prompt.dart';
import '../services/claude_service.dart';
import '../services/local_sharpener.dart';

class SharpenProvider extends ChangeNotifier {
  SharpenProvider({ClaudeService? claudeService})
    : _claude = claudeService ?? ClaudeService();

  final ClaudeService _claude;

  // The controller lives here so the Templates and History screens can put
  // text into the Sharpen screen's input box.
  final inputController = TextEditingController();

  SharpenFocus focus = SharpenFocus.clear;
  bool isLoading = false;
  String streamedText = ''; // what has arrived so far while loading
  SharpenedPrompt? result;
  String? errorMessage;

  void setFocus(SharpenFocus newFocus) {
    focus = newFocus;
    notifyListeners();
  }

  // Replaces the input and clears the old result, ready for a new run.
  void loadDraft(String text) {
    inputController.text = text;
    result = null;
    errorMessage = null;
    notifyListeners();
  }

  // Shows an old result from History again.
  void showSaved(SharpenedPrompt saved) {
    inputController.text = saved.original;
    focus = saved.focus;
    result = saved;
    errorMessage = null;
    notifyListeners();
  }

  // Returns the finished result, or null if there was an error.
  Future<SharpenedPrompt?> sharpen({String? apiKey}) async {
    final rough = inputController.text.trim();
    if (rough.isEmpty || isLoading) return null;

    if (apiKey == null || apiKey.isEmpty) {
      return sharpenOffline();
    }

    isLoading = true;
    streamedText = '';
    result = null;
    errorMessage = null;
    notifyListeners();

    try {
      final stream = _claude.sharpen(apiKey: apiKey, rough: rough, focus: focus);
      await for (final piece in stream) {
        streamedText += piece;
        notifyListeners();
      }
      if (streamedText.trim().isEmpty) {
        throw ClaudeException('Claude sent back an empty answer. Please try again.');
      }
      result = _buildResult(rough, streamedText.trim(), usedClaude: true);
      return result;
    } on ClaudeException catch (error) {
      errorMessage = error.message;
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Also used by the "Use offline draft" button when a Claude request fails.
  SharpenedPrompt? sharpenOffline() {
    final rough = inputController.text.trim();
    if (rough.isEmpty) return null;

    final text = LocalSharpener.sharpen(rough, focus);
    result = _buildResult(rough, text, usedClaude: false);
    errorMessage = null;
    notifyListeners();
    return result;
  }

  SharpenedPrompt _buildResult(String rough, String text, {required bool usedClaude}) {
    final now = DateTime.now();
    return SharpenedPrompt(
      id: now.microsecondsSinceEpoch.toString(),
      original: rough,
      sharpened: text,
      focus: focus,
      usedClaude: usedClaude,
      createdAt: now,
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}
