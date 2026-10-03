import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/history_entry.dart';
import '../models/local_threshold.dart';
import '../models/quiz_attempt.dart';

/// Persistance locale unique de BioSigma, via `shared_preferences`.
///
/// Aucune donnée nominative n'est jamais stockée. L'historique est
/// désactivé par défaut (cf. [AppSettings.historyEnabled]) et entièrement
/// supprimable en un geste ([clearAllLocalData]). Aucun accès réseau.
class AppStorageService {
  AppStorageService(this._prefs);

  static const _settingsKey = 'biosigma.settings.v1';
  static const _historyKey = 'biosigma.history.v1';
  static const _favoritesKey = 'biosigma.favorites.v1';
  static const _thresholdsKey = 'biosigma.thresholds.v1';
  static const _quizAttemptsKey = 'biosigma.quiz_attempts.v1';
  /// Préfixe des copies de sauvegarde créées quand une donnée stockée est
  /// illisible (voir [_quarantine]). Une seule copie par clé d'origine.
  static const quarantinePrefix = 'biosigma.quarantine.';
  static const _maxHistoryEntries = 200;
  static const _maxQuizAttempts = 200;

  final SharedPreferences _prefs;

  static Future<AppStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppStorageService(prefs);
  }

  /// Une donnée stockée est illisible (JSON invalide, schéma inattendu) :
  /// on en garde une copie brute sous une clé de quarantaine AVANT que la
  /// prochaine écriture n'écrase la clé d'origine. Rien n'est supprimé en
  /// silence ; la copie est effacée par [clearAllLocalData].
  void _quarantine(String key, String raw) {
    unawaited(_prefs.setString('$quarantinePrefix$key', raw));
  }

  /// Clés dont une donnée illisible a été mise en quarantaine.
  List<String> quarantinedKeys() => _prefs
      .getKeys()
      .where((k) => k.startsWith(quarantinePrefix))
      .map((k) => k.substring(quarantinePrefix.length))
      .toList(growable: false);

  /// Décode une liste JSON ; en cas d'échec, met la donnée brute en
  /// quarantaine et renvoie une liste vide.
  List<T> _decodeList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null) return <T>[];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      _quarantine(key, raw);
      return <T>[];
    }
  }

  // --- Réglages ---

  AppSettings loadSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _quarantine(_settingsKey, raw);
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // --- Favoris (liste d'ids de calculateurs) ---

  Set<String> loadFavorites() {
    final raw = _prefs.getStringList(_favoritesKey);
    return raw == null ? <String>{} : raw.toSet();
  }

  Future<void> saveFavorites(Set<String> favoriteIds) async {
    await _prefs.setStringList(_favoritesKey, favoriteIds.toList());
  }

  // --- Historique (facultatif) ---

  List<HistoryEntry> loadHistory() => _decodeList(_historyKey, HistoryEntry.fromJson);

  Future<void> appendHistoryEntry(HistoryEntry entry) async {
    final current = loadHistory().toList();
    current.insert(0, entry);
    final trimmed = current.length > _maxHistoryEntries
        ? current.sublist(0, _maxHistoryEntries)
        : current;
    await _prefs.setString(
      _historyKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  // --- Seuils locaux ---

  List<LocalThreshold> loadThresholds() =>
      _decodeList(_thresholdsKey, LocalThreshold.fromJson);

  Future<void> saveThresholds(List<LocalThreshold> thresholds) async {
    await _prefs.setString(
      _thresholdsKey,
      jsonEncode(thresholds.map((e) => e.toJson()).toList()),
    );
  }

  // --- Scores de quiz (formation) ---

  List<QuizAttempt> loadQuizAttempts() =>
      _decodeList(_quizAttemptsKey, QuizAttempt.fromJson);

  Future<void> appendQuizAttempt(QuizAttempt attempt) async {
    final current = loadQuizAttempts().toList();
    current.insert(0, attempt);
    final trimmed = current.length > _maxQuizAttempts
        ? current.sublist(0, _maxQuizAttempts)
        : current;
    await _prefs.setString(
      _quizAttemptsKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearQuizAttempts() async {
    await _prefs.remove(_quizAttemptsKey);
  }

  // --- Suppression totale ---

  /// Supprime toutes les données locales de BioSigma (réglages, favoris,
  /// historique, seuils, scores de quiz, copies de quarantaine) — action
  /// explicite depuis l'écran Paramètres.
  Future<void> clearAllLocalData() async {
    await _prefs.remove(_settingsKey);
    await _prefs.remove(_historyKey);
    await _prefs.remove(_favoritesKey);
    await _prefs.remove(_thresholdsKey);
    await _prefs.remove(_quizAttemptsKey);
    for (final key in quarantinedKeys()) {
      await _prefs.remove('$quarantinePrefix$key');
    }
  }
}
