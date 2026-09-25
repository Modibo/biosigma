import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/history_entry.dart';
import '../models/local_threshold.dart';

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
  static const _maxHistoryEntries = 200;

  final SharedPreferences _prefs;

  static Future<AppStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppStorageService(prefs);
  }

  // --- Réglages ---

  AppSettings loadSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
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

  List<HistoryEntry> loadHistory() {
    final raw = _prefs.getString(_historyKey);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

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

  List<LocalThreshold> loadThresholds() {
    final raw = _prefs.getString(_thresholdsKey);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => LocalThreshold.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveThresholds(List<LocalThreshold> thresholds) async {
    await _prefs.setString(
      _thresholdsKey,
      jsonEncode(thresholds.map((e) => e.toJson()).toList()),
    );
  }

  // --- Suppression totale ---

  /// Supprime toutes les données locales de BioSigma (réglages, favoris,
  /// historique, seuils) — action explicite depuis l'écran Paramètres.
  Future<void> clearAllLocalData() async {
    await _prefs.remove(_settingsKey);
    await _prefs.remove(_historyKey);
    await _prefs.remove(_favoritesKey);
    await _prefs.remove(_thresholdsKey);
  }
}
