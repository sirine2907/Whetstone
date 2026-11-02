import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sharpened_prompt.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider() {
    _load();
  }

  static const _storageKey = 'history';
  static const _maxItems = 100;

  List<SharpenedPrompt> items = [];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? [];
    items = saved
        .map((text) => SharpenedPrompt.fromJson(jsonDecode(text) as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  void add(SharpenedPrompt item) {
    items.insert(0, item); // newest first
    // Starred items are never dropped, only the oldest unstarred ones.
    while (items.length > _maxItems) {
      final lastUnstarred = items.lastIndexWhere((entry) => !entry.starred);
      if (lastUnstarred == -1) break;
      items.removeAt(lastUnstarred);
    }
    notifyListeners();
    _save();
  }

  void toggleStar(String id) {
    final item = items.firstWhere((entry) => entry.id == id);
    item.starred = !item.starred;
    notifyListeners();
    _save();
  }

  void remove(String id) {
    items.removeWhere((entry) => entry.id == id);
    notifyListeners();
    _save();
  }

  void clear() {
    items.clear();
    notifyListeners();
    _save();
  }
}
