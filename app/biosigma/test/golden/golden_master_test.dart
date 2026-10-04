// « Golden master » de non-régression (backlog P0-02).
//
// Fige, pour les 59 équations du catalogue, les résultats, unités, entrées
// échoïsées et avertissements produits par le code à la version
// `baseline-v1.6.0` (commit cf1beae). Ce n'est PAS une validation
// scientifique : toute différence signale une modification — voulue ou
// non — du comportement observable, qui doit être approuvée explicitement.
//
// Mise à jour volontaire du fichier de référence (après approbation d'un
// changement) :
//   GOLDEN_UPDATE=1 flutter test test/golden/golden_master_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:biosigma/data/calculator_registry.dart';
import 'package:biosigma/models/calculator_definition.dart';
import 'package:biosigma/models/calculator_field.dart';
import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_inputs.dart';
import 'golden_support.dart';

const _fixturePath = 'test/golden/fixtures/baseline-v1.6.0.json';

/// Tolérance relative pour la comparaison des nombres (écart d'arrondi
/// flottant entre plateformes, jamais une modification de formule).
const _relativeTolerance = 1e-12;

class _Case {
  _Case(this.id, this.inputs, this.run);
  final String id;
  final Map<String, Object?> inputs;
  final CalculationResult Function() run;
}

Map<String, Object?> _describeInputs(CalculatorDefinition def, Map<String, dynamic> values) {
  final out = <String, Object?>{};
  for (final f in def.fields) {
    final v = values[f.id];
    out[f.id] = switch (f.kind) {
      FieldKind.numberWithUnit || FieldKind.numberFixedUnit =>
        '${(v as NumericEntry).value} ${v.unit}',
      FieldKind.enumSelect =>
        v == null ? null : f.enumOptions!.firstWhere((o) => o.value == v).label,
      _ => v,
    };
  }
  return out;
}

List<_Case> _buildCases() {
  final cases = <_Case>[];
  for (final def in allCalculators) {
    final id = def.meta.id;
    final base = goldenInputs[id];
    if (base == null) continue;

    void add(String caseId, Map<String, dynamic> values) {
      cases.add(_Case(caseId, _describeInputs(def, values), () => def.compute(values)));
    }

    add(id, buildGoldenValues(def, base));

    // Une variante par option de chaque liste de choix (autres champs inchangés).
    for (final f in def.fields.where((f) => f.kind == FieldKind.enumSelect)) {
      final current = base[f.id] is E ? (base[f.id] as E).index : -1;
      for (var i = 0; i < f.enumOptions!.length; i++) {
        if (i == current) continue;
        add('$id#${f.id}=$i', buildGoldenValues(def, base, enumField: f.id, enumIndex: i));
      }
    }

    // Une variante par unité alternative de chaque champ à unité choisie
    // (même nombre saisi dans une autre unité : protège les facteurs de
    // conversion tels qu'utilisés par l'équation).
    for (final f in def.fields.where((f) => f.kind == FieldKind.numberWithUnit)) {
      final given = base[f.id];
      if (given is! N) continue;
      final current = given.unit ?? defaultUnitOf(f);
      for (final u in UnitRegistry.unitsFor(f.analyte!)) {
        if (u == current) continue;
        add('$id#${f.id}@$u', buildGoldenValues(def, base, unitField: f.id, unit: u));
      }
    }
  }

  // Scores guidés (écrans dédiés, hors registre générique).
  cases.addAll([
    _Case('isth_dic_score', {
      'underlyingDisorderPresent': true, 'platelets': '80 G/L',
      'fibrinMarker': FibrinMarkerIncrease.moderate.name, 'ptProlongation': '4.0 s',
      'fibrinogen': '0.8 g/L',
    }, () => calculateIsthDicScore(
          underlyingDisorderPresent: true,
          plateletCountGL: 80,
          fibrinMarkerIncrease: FibrinMarkerIncrease.moderate,
          ptProlongationSeconds: 4.0,
          fibrinogenValue: 0.8,
          fibrinogenUnit: 'g/L',
        )),
    _Case('isth_dic_score#fibrinogen@mg/dL', {
      'underlyingDisorderPresent': true, 'fibrinogen': '80 mg/dL',
    }, () => calculateIsthDicScore(
          underlyingDisorderPresent: true,
          plateletCountGL: 80,
          fibrinMarkerIncrease: FibrinMarkerIncrease.strong,
          ptProlongationSeconds: 7.0,
          fibrinogenValue: 80,
          fibrinogenUnit: 'mg/dL',
        )),
    _Case('isth_dic_score#sans_contexte', {'underlyingDisorderPresent': false},
        () => calculateIsthDicScore(underlyingDisorderPresent: false)),
    _Case('isth_dic_score#incomplet', {'underlyingDisorderPresent': true},
        () => calculateIsthDicScore(underlyingDisorderPresent: true, plateletCountGL: 80)),
    _Case('four_ts_score', {'critères': '2,2,2,2'}, () => calculateFourTsScore(
          thrombocytopenia: FourTsThrombocytopenia.twoPoints,
          timing: FourTsTiming.twoPoints,
          thrombosisSequelae: FourTsThrombosis.twoPoints,
          otherCauses: FourTsOtherCauses.twoPoints,
        )),
    _Case('four_ts_score#intermediaire', {'critères': '1,1,1,1'}, () => calculateFourTsScore(
          thrombocytopenia: FourTsThrombocytopenia.onePoint,
          timing: FourTsTiming.onePoint,
          thrombosisSequelae: FourTsThrombosis.onePoint,
          otherCauses: FourTsOtherCauses.onePoint,
        )),
    _Case('four_ts_score#faible', {'critères': '0,0,0,0'}, () => calculateFourTsScore(
          thrombocytopenia: FourTsThrombocytopenia.zeroPoint,
          timing: FourTsTiming.zeroPoint,
          thrombosisSequelae: FourTsThrombosis.zeroPoint,
          otherCauses: FourTsOtherCauses.zeroPoint,
        )),
    _Case('four_ts_score#incomplet', {'critères': 'manquants'},
        () => calculateFourTsScore(thrombocytopenia: FourTsThrombocytopenia.twoPoints)),
  ]);
  return cases;
}

Map<String, Object?> _outcome(_Case c) {
  try {
    final r = c.run();
    return {
      'complete': r.isComplete,
      'values': [
        for (final v in r.values)
          {'label': v.label, 'value': v.value, 'unit': v.unit, 'precision': v.precision},
      ],
      'warnings': [
        for (final w in r.warnings) {'severity': w.severity.name, 'message': w.message},
      ],
      'echoed': r.echoedInputs,
    };
  } on CalculationInputException catch (e) {
    return {
      'error': [
        for (final err in e.errors) {'field': err.fieldId, 'message': err.message},
      ],
    };
  } catch (e) {
    return {'exception': e.runtimeType.toString()};
  }
}

/// Compare deux structures JSON ; les nombres à virgule sont comparés avec
/// la tolérance relative documentée, tout le reste exactement.
String? _diff(Object? expected, Object? actual, String path) {
  if (expected is num && actual is num) {
    final a = expected.toDouble(), b = actual.toDouble();
    if (a == b) return null;
    final scale = a.abs() > b.abs() ? a.abs() : b.abs();
    if (scale > 0 && (a - b).abs() / scale <= _relativeTolerance) return null;
    return '$path : attendu $expected, obtenu $actual';
  }
  if (expected is Map && actual is Map) {
    for (final k in {...expected.keys, ...actual.keys}) {
      final d = _diff(expected[k], actual[k], '$path.$k');
      if (d != null) return d;
    }
    return null;
  }
  if (expected is List && actual is List) {
    if (expected.length != actual.length) {
      return '$path : ${expected.length} éléments attendus, ${actual.length} obtenus';
    }
    for (var i = 0; i < expected.length; i++) {
      final d = _diff(expected[i], actual[i], '$path[$i]');
      if (d != null) return d;
    }
    return null;
  }
  return expected == actual ? null : '$path : attendu ${jsonEncode(expected)}, obtenu ${jsonEncode(actual)}';
}

void main() {
  final cases = _buildCases();
  final current = <String, Object?>{
    for (final c in cases) c.id: {'inputs': c.inputs, 'outcome': _outcome(c)},
  };

  test('le golden master couvre les 59 équations du catalogue', () {
    final covered = {for (final c in cases) c.id.split('#').first};
    final missing = CalculatorCatalog.all.map((m) => m.id).where((id) => !covered.contains(id));
    expect(missing, isEmpty, reason: 'équations sans cas de référence');
    expect(CalculatorCatalog.all.length, 59);
  });

  test('les résultats actuels sont identiques au golden master baseline-v1.6.0', () {
    final file = File(_fixturePath);
    if (Platform.environment['GOLDEN_UPDATE'] == '1') {
      file.createSync(recursive: true);
      file.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert({'baseline': 'baseline-v1.6.0', 'cases': current})}\n',
      );
      return;
    }
    expect(file.existsSync(), isTrue, reason: 'fichier de référence absent : $_fixturePath');
    final reference = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final expectedCases = reference['cases'] as Map<String, dynamic>;

    final added = current.keys.where((k) => !expectedCases.containsKey(k)).toList();
    final removed = expectedCases.keys.where((k) => !current.containsKey(k)).toList();
    expect(added, isEmpty, reason: 'cas ajoutés sans mise à jour approuvée du golden master');
    expect(removed, isEmpty, reason: 'cas supprimés sans mise à jour approuvée du golden master');

    final differences = <String>[];
    for (final id in expectedCases.keys) {
      final d = _diff(expectedCases[id], jsonDecode(jsonEncode(current[id])), id);
      if (d != null) differences.add(d);
    }
    expect(differences, isEmpty,
        reason: 'Résultats modifiés depuis baseline-v1.6.0 :\n${differences.take(25).join('\n')}');
  });
}
