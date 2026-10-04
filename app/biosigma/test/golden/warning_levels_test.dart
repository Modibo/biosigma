// Revue du niveau de chaque message d'information (backlog P1-16) : instantané
// des niveaux attribués aux messages produits par les cas du golden master.
// Un message nouveau ou dont le classement change fait échouer le test ; la
// mise à jour est volontaire (après relecture) :
//   GOLDEN_UPDATE=1 flutter test test/golden/warning_levels_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter_test/flutter_test.dart';

const _golden = 'test/golden/fixtures/baseline-v1.6.0.json';
const _snapshot = 'test/golden/fixtures/warning-levels.json';

Map<String, Map<String, List<String>>> _current() {
  final cases = (jsonDecode(File(_golden).readAsStringSync()) as Map<String, dynamic>)['cases']
      as Map<String, dynamic>;
  final out = <String, Map<String, Set<String>>>{};
  for (final entry in cases.entries) {
    final id = entry.key.split('#').first;
    final warnings = ((entry.value as Map)['outcome'] as Map)['warnings'] as List? ?? const [];
    for (final w in warnings.cast<Map<String, dynamic>>()) {
      if (w['severity'] != 'info') continue;
      final message = w['message'] as String;
      final level = levelOfInfo(CalculationWarning(message, severity: WarningSeverity.info));
      final head = message.length > 80 ? '${message.substring(0, 80)}…' : message;
      out.putIfAbsent(id, () => {}).putIfAbsent(level.name, () => {}).add(head);
    }
  }
  return {
    for (final id in (out.keys.toList()..sort()))
      id: {
        for (final l in (out[id]!.keys.toList()..sort())) l: (out[id]![l]!.toList()..sort()),
      },
  };
}

void main() {
  test('les niveaux des messages du golden master sont ceux relus', () {
    final current = _current();
    if (Platform.environment['GOLDEN_UPDATE'] == '1') {
      File(_snapshot).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(current)}\n');
      return;
    }
    final saved = jsonDecode(File(_snapshot).readAsStringSync()) as Map<String, dynamic>;
    expect(jsonDecode(jsonEncode(current)), saved,
        reason: 'niveau de message modifié ou message nouveau : relire puis mettre à jour');
  });

  test('seules ces équations produisent une « aide à la décision » (recommandations publiées)', () {
    final decision = {
      for (final e in _current().entries)
        if (e.value.containsKey('decisionSupport')) e.key,
    };
    expect(decision, {
      'cha2ds2_vasc_score', 'padua_prediction_score', 'caprini_score',
      'has_bled_score', 'estimated_average_glucose_adag', 'inr',
    });
  });

  test('les équations dont tous les messages sont des recommandations sont connues (un ajout est relu)', () {
    final onlyDecision = {
      for (final e in _current().entries)
        if (e.value.keys.toSet().difference({'decisionSupport'}).isEmpty) e.key,
    };
    expect(onlyDecision, {
      'inr', 'estimated_average_glucose_adag', 'cha2ds2_vasc_score', 'padua_prediction_score',
      'caprini_score', 'has_bled_score',
    });
  });
}
