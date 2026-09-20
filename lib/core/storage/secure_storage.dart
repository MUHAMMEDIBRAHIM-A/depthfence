import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local encrypted & persistent storage manager for DepthFence.
class SecureStorageVault {
  static const String _geminiKeyPref = 'depthfence_gemini_key';
  static const String _pendingQueuePref = 'depthfence_pending_queue';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Saves user-entered Gemini API key locally.
  Future<void> saveGeminiKey(String key) async {
    await init();
    await _prefs?.setString(_geminiKeyPref, key.trim());
  }

  /// Retrieves user-entered Gemini API key.
  Future<String?> getGeminiKey() async {
    await init();
    return _prefs?.getString(_geminiKeyPref);
  }

  /// Clears stored Gemini API key.
  Future<void> clearGeminiKey() async {
    await init();
    await _prefs?.remove(_geminiKeyPref);
  }

  /// Persists pending offline operations queue.
  Future<void> savePendingQueue(List<Map<String, dynamic>> queue) async {
    await init();
    final jsonList = queue.map((e) => jsonEncode(e)).toList();
    await _prefs?.setStringList(_pendingQueuePref, jsonList);
  }

  /// Retrieves pending offline operations queue.
  Future<List<Map<String, dynamic>>> getPendingQueue() async {
    await init();
    final rawList = _prefs?.getStringList(_pendingQueuePref) ?? [];
    return rawList.map((s) {
      try {
        return jsonDecode(s) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Failed to decode queue item: $e');
        return <String, dynamic>{};
      }
    }).where((m) => m.isNotEmpty).toList();
  }

  /// Clears offline operations queue.
  Future<void> clearPendingQueue() async {
    await init();
    await _prefs?.remove(_pendingQueuePref);
  }
}
