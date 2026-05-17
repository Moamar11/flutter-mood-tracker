import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mood_entry.dart';

/// Key used to store entries in SharedPreferences.
const _kEntriesKey = 'mood_entries';

/// Central state container for the mood tracker.
///
/// Uses [ChangeNotifier] so widgets can listen and rebuild whenever state
/// changes.  Persistence is handled via [SharedPreferences] so entries
/// survive page refreshes.
class MoodController extends ChangeNotifier {
  MoodController() {
    _loadEntries();
  }

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<MoodEntry> _entries = [];
  bool _isLoading = true;

  /// All entries, sorted newest-first.
  List<MoodEntry> get entries => _entries;

  /// Whether the initial load from storage is still in progress.
  bool get isLoading => _isLoading;

  /// The 7 most recent entries (newest-first) shown in the timeline.
  List<MoodEntry> get recentEntries =>
      _entries.take(7).toList();

  // ---------------------------------------------------------------------------
  // Persistence helpers
  // ---------------------------------------------------------------------------

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kEntriesKey);
      if (raw != null) {
        final list = (jsonDecode(raw) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(MoodEntry.fromJson)
            .toList();
        _entries = list
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (_) {
      // Corrupt data – start fresh.
      _entries = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString(_kEntriesKey, raw);
    } catch (_) {
      // Silently ignore write errors in web.
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Logs a new mood entry.
  Future<void> logMood(MoodType mood, {String? note}) async {
    final entry = MoodEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      mood: mood,
      timestamp: DateTime.now(),
      note: note,
    );
    _entries = [entry, ..._entries]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
    await _saveEntries();
  }

  /// Clears all stored entries.
  Future<void> clearAll() async {
    _entries = [];
    notifyListeners();
    await _saveEntries();
  }
}
