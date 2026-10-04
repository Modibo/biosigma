// Enregistrement de calcul v2 (P1-14) : reproductibilité (T-TRC-001) et
// migration de l'historique v1 → v2 (T-MIG-001).
import 'dart:convert';

import 'package:biosigma/app_version.dart';
import 'package:biosigma/data/calculator_registry.dart';
import 'package:biosigma/models/calculation_record.dart';
import 'package:biosigma/models/history_entry.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/services/record_replay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../golden/golden_inputs.dart';
import '../golden/golden_support.dart';

const _v1 = 'biosigma.history.v1';
const _v2 = 'biosigma.history.v2';

Future<(AppStorageService, SharedPreferences)> _open(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return (AppStorageService(prefs), prefs);
}

String _legacyJson() => jsonEncode([
      HistoryEntry(
        id: 'old1',
        calculatorId: 'bmi',
        calculatorName: 'IMC',
        timestamp: DateTime.utc(2026, 1, 2, 3),
        echoedInputs: const {'Poids': '70 kg'},
        resultSummary: const ['IMC : 22.86 kg/m²'],
      ).toJson(),
    ]);

void main() {
  group('T-TRC-001 — un calcul rejoué depuis son enregistrement reproduit le résultat', () {
    test('pour chaque équation du catalogue (entrées canoniques du golden master)', () {
      var replayed = 0;
      for (final def in allCalculators) {
        final base = goldenInputs[def.meta.id];
        if (base == null) continue;
        final values = buildGoldenValues(def, base);
        final original = def.compute(values);

        final record = CalculationRecord.fromCalculation(
          definition: def,
          values: values,
          result: original,
          now: DateTime.utc(2026, 10, 4),
        );
        // aller-retour par le stockage (JSON)
        final restored =
            CalculationRecord.fromJson(jsonDecode(jsonEncode(record.toJson())) as Map<String, dynamic>);

        expect(restored.replayable, isTrue, reason: def.meta.id);
        final again = RecordReplay.replay(def, restored)!;
        expect(again.values.length, original.values.length, reason: def.meta.id);
        for (var i = 0; i < original.values.length; i++) {
          expect(again.values[i].value, original.values[i].value, reason: '${def.meta.id} #$i');
          expect(restored.results[i].value, original.values[i].value, reason: '${def.meta.id} #$i');
          expect(again.values[i].unit, original.values[i].unit);
        }
        replayed++;
      }
      expect(replayed, 59);
    });

    test('l\'enregistrement porte équation, version, application et règle d\'arrondi', () {
      final def = allCalculators.firstWhere((d) => d.meta.id == 'bmi');
      final values = buildGoldenValues(def, goldenInputs['bmi']!);
      final r = CalculationRecord.fromCalculation(
        definition: def,
        values: values,
        result: def.compute(values),
        now: DateTime.utc(2026, 10, 4),
      );
      expect(r.equationId, 'bmi');
      expect(r.equationStableId, 'METAB_BMI_001');
      expect(r.equationVersion, 1);
      expect(r.appVersion, kAppVersion);
      expect(r.roundingRule, 'FMT_ARRONDI_001');
      expect(r.legacy, isFalse);
      expect(r.complete, isTrue);
    });

    test('la valeur enregistrée est brute (non arrondie)', () {
      final def = allCalculators.firstWhere((d) => d.meta.id == 'bmi');
      final values = buildGoldenValues(def, goldenInputs['bmi']!);
      final result = def.compute(values);
      final r = CalculationRecord.fromCalculation(
          definition: def, values: values, result: result, now: DateTime.utc(2026, 10, 4));
      expect(r.results.first.value, result.values.first.value);
      // l'affichage est arrondi, l'enregistrement garde la valeur complète
      final shown = double.parse(r.resultSummary.first.split(' : ').last.split(' ').first);
      expect(r.results.first.value, isNot(shown));
      expect((r.results.first.value! - shown).abs(), lessThan(0.05));
    });

    test('un enregistrement ancien ou d\'une autre équation n\'est pas rejouable', () {
      final def = allCalculators.firstWhere((d) => d.meta.id == 'bmi');
      final legacy = CalculationRecord.fromLegacy(HistoryEntry(
        id: 'x',
        calculatorId: 'bmi',
        calculatorName: 'IMC',
        timestamp: DateTime.utc(2026),
        echoedInputs: const {},
        resultSummary: const [],
      ));
      expect(legacy.replayable, isFalse);
      expect(RecordReplay.replay(def, legacy), isNull);

      final other = allCalculators.firstWhere((d) => d.meta.id == 'ct_hdl_ratio');
      final values = buildGoldenValues(def, goldenInputs['bmi']!);
      final record = CalculationRecord.fromCalculation(
          definition: def, values: values, result: def.compute(values), now: DateTime.utc(2026));
      expect(RecordReplay.replay(other, record), isNull);
    });

    test('schéma inconnu refusé à la lecture', () {
      expect(() => CalculationRecord.fromJson({'schema': 3}), throwsFormatException);
    });
  });

  group('T-MIG-001 — migration de l\'historique v1 → v2', () {
    test('v1 converti, marqué « ancien format », v1 laissé intact', () async {
      final (storage, prefs) = await _open({_v1: _legacyJson()});
      final records = storage.loadRecords();
      expect(records.length, 1);
      expect(records.single.legacy, isTrue);
      expect(records.single.equationId, 'bmi');
      expect(records.single.equationStableId, 'METAB_BMI_001');
      expect(records.single.equationVersion, isNull);
      expect(records.single.resultSummary, ['IMC : 22.86 kg/m²']);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString(_v1), _legacyJson(), reason: 'v1 non modifié');
      expect(prefs.containsKey(_v2), isTrue);
    });

    test('idempotente : une seconde lecture ne duplique rien', () async {
      final (storage, _) = await _open({_v1: _legacyJson()});
      storage.loadRecords();
      await Future<void>.delayed(Duration.zero);
      expect(storage.loadRecords().length, 1);
    });

    test('un ajout après migration conserve les anciens enregistrements', () async {
      final (storage, _) = await _open({_v1: _legacyJson()});
      final def = allCalculators.firstWhere((d) => d.meta.id == 'bmi');
      final values = buildGoldenValues(def, goldenInputs['bmi']!);
      await storage.appendRecord(CalculationRecord.fromCalculation(
          definition: def, values: values, result: def.compute(values), now: DateTime.utc(2026, 10, 4)));
      final records = storage.loadRecords();
      expect(records.length, 2);
      expect(records.first.legacy, isFalse);
      expect(records.last.id, 'old1');
    });

    test('v1 corrompu : quarantaine, aucun plantage, aucune perte', () async {
      const corrupted = '[{"id":"x",';
      final (storage, prefs) = await _open({_v1: corrupted});
      expect(storage.loadRecords(), isEmpty);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString('${AppStorageService.quarantinePrefix}$_v1'), corrupted);
      expect(prefs.getString(_v1), corrupted, reason: 'v1 non supprimé');
    });

    test('v2 de schéma inattendu : quarantaine', () async {
      const odd = '[{"schema":9}]';
      final (storage, prefs) = await _open({_v2: odd});
      expect(storage.loadRecords(), isEmpty);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getString('${AppStorageService.quarantinePrefix}$_v2'), odd);
    });

    test('rien en stockage : liste vide, aucune clé créée', () async {
      final (storage, prefs) = await _open({});
      expect(storage.loadRecords(), isEmpty);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.containsKey(_v2), isFalse);
    });

    test('effacer l\'historique supprime v1 et v2 ; tout effacer aussi', () async {
      final (storage, prefs) = await _open({_v1: _legacyJson()});
      storage.loadRecords();
      await Future<void>.delayed(Duration.zero);
      await storage.clearHistory();
      expect(prefs.containsKey(_v1), isFalse);
      expect(prefs.containsKey(_v2), isFalse);

      final (s2, p2) = await _open({_v1: _legacyJson()});
      s2.loadRecords();
      await Future<void>.delayed(Duration.zero);
      await s2.clearAllLocalData();
      expect(p2.getKeys().where((k) => k.startsWith('biosigma.')), isEmpty);
    });
  });
}
