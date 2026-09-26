import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/history_entry.dart';
import '../models/local_threshold.dart';
import '../models/quiz_attempt.dart';
import '../services/app_storage_service.dart';

/// État applicatif partagé (réglages, favoris, historique, seuils
/// locaux), chargé une fois au démarrage depuis [AppStorageService] et
/// tenu à jour en mémoire. Notifie les écrans abonnés via `provider`.
class AppState extends ChangeNotifier {
  AppState(this._storage)
      : settings = _storage.loadSettings(),
        favoriteIds = _storage.loadFavorites(),
        history = _storage.loadHistory(),
        thresholds = _storage.loadThresholds(),
        quizAttempts = _storage.loadQuizAttempts();

  final AppStorageService _storage;

  AppSettings settings;
  Set<String> favoriteIds;
  List<HistoryEntry> history;
  List<LocalThreshold> thresholds;
  List<QuizAttempt> quizAttempts;

  Future<void> updateSettings(AppSettings Function(AppSettings) update) async {
    settings = update(settings);
    await _storage.saveSettings(settings);
    notifyListeners();
  }

  bool isFavorite(String calculatorId) => favoriteIds.contains(calculatorId);

  Future<void> toggleFavorite(String calculatorId) async {
    final next = Set<String>.from(favoriteIds);
    if (!next.add(calculatorId)) next.remove(calculatorId);
    favoriteIds = next;
    await _storage.saveFavorites(favoriteIds);
    notifyListeners();
  }

  Future<void> recordHistoryEntry(HistoryEntry entry) async {
    if (!settings.historyEnabled) return;
    await _storage.appendHistoryEntry(entry);
    history = _storage.loadHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storage.clearHistory();
    history = const [];
    notifyListeners();
  }

  Future<void> saveThreshold(LocalThreshold threshold) async {
    final next = thresholds
        .where((t) => !(t.calculatorId == threshold.calculatorId && t.label == threshold.label))
        .toList()
      ..add(threshold);
    thresholds = next;
    await _storage.saveThresholds(thresholds);
    notifyListeners();
  }

  Future<void> removeThreshold(LocalThreshold threshold) async {
    thresholds = thresholds
        .where((t) => !(t.calculatorId == threshold.calculatorId && t.label == threshold.label))
        .toList();
    await _storage.saveThresholds(thresholds);
    notifyListeners();
  }

  List<LocalThreshold> thresholdsFor(String calculatorId) =>
      thresholds.where((t) => t.calculatorId == calculatorId).toList(growable: false);

  /// Enregistre le résultat d'une tentative de quiz. Toujours sauvegardé
  /// localement (score anonyme, sans lien avec l'historique de calcul et
  /// son réglage d'activation) — jamais transmis en ligne.
  Future<void> recordQuizAttempt(QuizAttempt attempt) async {
    await _storage.appendQuizAttempt(attempt);
    quizAttempts = _storage.loadQuizAttempts();
    notifyListeners();
  }

  Future<void> clearQuizAttempts() async {
    await _storage.clearQuizAttempts();
    quizAttempts = const [];
    notifyListeners();
  }

  /// Meilleure tentative enregistrée pour un module donné, ou `null` si le
  /// module n'a jamais été tenté.
  QuizAttempt? bestAttemptFor(String moduleId) {
    final attempts = quizAttempts.where((a) => a.moduleId == moduleId);
    if (attempts.isEmpty) return null;
    return attempts.reduce((a, b) => a.ratio >= b.ratio ? a : b);
  }

  /// Supprime toutes les données locales et réinitialise l'état en mémoire.
  Future<void> clearAllLocalData() async {
    await _storage.clearAllLocalData();
    settings = const AppSettings();
    favoriteIds = <String>{};
    history = const [];
    thresholds = const [];
    quizAttempts = const [];
    notifyListeners();
  }
}
