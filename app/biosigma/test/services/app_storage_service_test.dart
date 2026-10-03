// Tests du stockage local (backlog P0-06) : une donnée illisible ne doit
// jamais être détruite en silence ; elle est mise en quarantaine avant que
// la prochaine écriture n'écrase la clé d'origine.
import 'package:biosigma/models/app_settings.dart';
import 'package:biosigma/models/history_entry.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _historyKey = 'biosigma.history.v1';
const _thresholdsKey = 'biosigma.thresholds.v1';
const _quizKey = 'biosigma.quiz_attempts.v1';
const _settingsKey = 'biosigma.settings.v1';

Future<(AppStorageService, SharedPreferences)> _open(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return (AppStorageService(prefs), prefs);
}

HistoryEntry _entry(String id) => HistoryEntry(
      id: id,
      calculatorId: 'bmi',
      calculatorName: 'IMC',
      timestamp: DateTime.utc(2026, 10, 3, 12),
      echoedInputs: const {'Poids': '70 kg'},
      resultSummary: const ['IMC : 22,86 kg/m²'],
    );

void main() {
  group('lecture sans effacement silencieux', () {
    test("des données valides sont relues telles quelles, sans quarantaine", () async {
      final (storage, prefs) = await _open({});
      await storage.appendHistoryEntry(_entry('a'));
      expect(storage.loadHistory().map((e) => e.id), ['a']);
      expect(storage.quarantinedKeys(), isEmpty);
      expect(prefs.getKeys().any((k) => k.startsWith(AppStorageService.quarantinePrefix)), isFalse);
    });

    test('une clé absente donne une liste vide sans quarantaine', () async {
      final (storage, _) = await _open({});
      expect(storage.loadHistory(), isEmpty);
      expect(storage.loadThresholds(), isEmpty);
      expect(storage.loadQuizAttempts(), isEmpty);
      expect(storage.quarantinedKeys(), isEmpty);
    });

    test("un JSON invalide dans l'historique est mis en quarantaine, puis survit à une nouvelle écriture",
        () async {
      const corrupted = '[{"id":"x","calculatorId":"bmi",';
      final (storage, prefs) = await _open({_historyKey: corrupted});

      expect(storage.loadHistory(), isEmpty);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString('${AppStorageService.quarantinePrefix}$_historyKey'), corrupted);
      expect(storage.quarantinedKeys(), [_historyKey]);

      // La prochaine écriture remplace la clé d'origine, pas la copie.
      await storage.appendHistoryEntry(_entry('b'));
      expect(storage.loadHistory().map((e) => e.id), ['b']);
      expect(prefs.getString('${AppStorageService.quarantinePrefix}$_historyKey'), corrupted);
    });

    test('un JSON valide mais de forme inattendue est aussi mis en quarantaine', () async {
      const wrongShape = '["pas","un","objet"]';
      final (storage, prefs) = await _open({_historyKey: wrongShape});
      expect(storage.loadHistory(), isEmpty);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString('${AppStorageService.quarantinePrefix}$_historyKey'), wrongShape);
    });

    test('une entrée incomplète (champ manquant) met toute la liste en quarantaine', () async {
      const missingField = '[{"id":"x"}]';
      final (storage, prefs) = await _open({_historyKey: missingField});
      expect(storage.loadHistory(), isEmpty);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString('${AppStorageService.quarantinePrefix}$_historyKey'), missingField);
    });

    test('seuils locaux et scores de quiz suivent la même règle', () async {
      final (storage, prefs) = await _open({_thresholdsKey: '{pas du json', _quizKey: '42'});
      expect(storage.loadThresholds(), isEmpty);
      expect(storage.loadQuizAttempts(), isEmpty);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString('${AppStorageService.quarantinePrefix}$_thresholdsKey'), '{pas du json');
      expect(prefs.getString('${AppStorageService.quarantinePrefix}$_quizKey'), '42');
      expect(storage.quarantinedKeys().toSet(), {_thresholdsKey, _quizKey});
    });

    test('des réglages illisibles reviennent aux valeurs par défaut avec copie de quarantaine',
        () async {
      final (storage, prefs) = await _open({_settingsKey: 'n-importe-quoi'});
      final settings = storage.loadSettings();
      expect(settings.decimalSeparator, const AppSettings().decimalSeparator);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString('${AppStorageService.quarantinePrefix}$_settingsKey'), 'n-importe-quoi');
    });
  });

  group('suppression totale', () {
    test('clearAllLocalData efface aussi les copies de quarantaine', () async {
      final (storage, prefs) = await _open({_historyKey: '{invalide', _quizKey: '42'});
      storage.loadHistory();
      storage.loadQuizAttempts();
      await Future<void>.delayed(Duration.zero);
      expect(storage.quarantinedKeys(), isNotEmpty);

      await storage.clearAllLocalData();

      expect(storage.quarantinedKeys(), isEmpty);
      expect(prefs.getKeys().where((k) => k.startsWith('biosigma.')), isEmpty);
    });
  });
}
