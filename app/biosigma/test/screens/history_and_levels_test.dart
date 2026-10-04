// Écran d'historique (rejeu explicite) et niveaux de résultat (P1-16).
import 'package:biosigma/data/calculator_registry.dart';
import 'package:biosigma/models/calculation_record.dart';
import 'package:biosigma/models/history_entry.dart';
import 'package:biosigma/screens/history_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:biosigma/widgets/warning_list.dart';
import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../golden/golden_inputs.dart';
import '../golden/golden_support.dart';

Future<AppState> _stateWith(List<CalculationRecord> records) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await AppStorageService.create();
  for (final r in records.reversed) {
    await storage.appendRecord(r);
  }
  return AppState(storage);
}

CalculationRecord _bmiRecord() {
  final def = allCalculators.firstWhere((d) => d.meta.id == 'bmi');
  final values = buildGoldenValues(def, goldenInputs['bmi']!);
  return CalculationRecord.fromCalculation(
      definition: def, values: values, result: def.compute(values), now: DateTime.utc(2026, 10, 4, 9));
}

Future<void> _pump(WidgetTester tester, AppState state, Widget screen) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: state, child: MaterialApp(home: screen)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('historique vide : message', (tester) async {
    await _pump(tester, await _stateWith([]), const HistoryScreen());
    expect(find.textContaining('Aucun calcul enregistré'), findsOneWidget);
  });

  testWidgets('enregistrement v2 : version affichée, rejeu identique', (tester) async {
    await _pump(tester, await _stateWith([_bmiRecord()]), const HistoryScreen());
    await tester.tap(find.textContaining('Indice de masse corporelle'));
    await tester.pumpAndSettle();
    expect(find.textContaining('METAB_BMI_001 · version 1'), findsOneWidget);
    expect(find.textContaining('arrondi FMT_ARRONDI_001'), findsOneWidget);

    await tester.tap(find.text('Rejouer avec l\'équation actuelle'));
    await tester.pumpAndSettle();
    expect(find.textContaining('résultats identiques'), findsOneWidget);
  });

  testWidgets('rejeu : un enregistrement dont le résultat diffère est signalé, sans être modifié',
      (tester) async {
    final r = _bmiRecord();
    final altered = CalculationRecord(
      id: r.id,
      timestamp: r.timestamp,
      equationId: r.equationId,
      equationName: r.equationName,
      equationStableId: r.equationStableId,
      equationVersion: r.equationVersion,
      equationVersionLabel: r.equationVersionLabel,
      appVersion: r.appVersion,
      roundingRule: r.roundingRule,
      rawInputs: r.rawInputs,
      echoedInputs: r.echoedInputs,
      results: [
        RecordedResult(label: r.results.first.label, value: 99.9, unit: r.results.first.unit, precision: 2),
      ],
      resultSummary: r.resultSummary,
    );
    await _pump(tester, await _stateWith([altered]), const HistoryScreen());
    await tester.tap(find.textContaining('Indice de masse corporelle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rejouer avec l\'équation actuelle'));
    await tester.pumpAndSettle();
    expect(find.textContaining('DIFFÉRENTS'), findsOneWidget);
    expect(find.textContaining('n\'est pas altéré'), findsOneWidget);
  });

  testWidgets('enregistrement ancien format : non rejouable, expliqué', (tester) async {
    final legacy = CalculationRecord.fromLegacy(HistoryEntry(
      id: 'o',
      calculatorId: 'bmi',
      calculatorName: 'IMC',
      timestamp: DateTime.utc(2026, 1, 1),
      echoedInputs: const {'Poids': '70 kg'},
      resultSummary: const ['IMC : 22.86 kg/m²'],
    ));
    await _pump(tester, await _stateWith([legacy]), const HistoryScreen());
    expect(find.textContaining('ancien format'), findsOneWidget);
    await tester.tap(find.text('IMC'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ne peut pas être rejoué'), findsOneWidget);
    expect(find.text('Rejouer avec l\'équation actuelle'), findsNothing);
  });

  group('niveaux de résultat (P1-16)', () {
    Future<void> pumpList(WidgetTester tester, List<CalculationWarning> w) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SingleChildScrollView(child: WarningList(warnings: w)))));

    testWidgets('alertes et repères d\'interprétation sont séparés et étiquetés', (tester) async {
      await pumpList(tester, const [
        CalculationWarning('Interprétation générale', severity: WarningSeverity.info),
        CalculationWarning('Triglycérides élevés', severity: WarningSeverity.caution),
        CalculationWarning('Hors domaine', severity: WarningSeverity.blocking),
      ]);
      expect(find.text('Alertes'), findsOneWidget);
      expect(find.text('Informations et repères d\'interprétation'), findsOneWidget);
      expect(find.textContaining('non validés localement'), findsOneWidget);
      // les alertes sont affichées avant les repères
      final alertY = tester.getTopLeft(find.text('Triglycérides élevés')).dy;
      final infoY = tester.getTopLeft(find.text('Interprétation générale')).dy;
      expect(alertY, lessThan(infoY));
    });

    testWidgets('pas d\'en-tête vide : seulement des infos, ou seulement des alertes', (tester) async {
      await pumpList(tester, const [CalculationWarning('Info', severity: WarningSeverity.info)]);
      expect(find.text('Alertes'), findsNothing);
      await pumpList(tester, const [CalculationWarning('Alerte', severity: WarningSeverity.caution)]);
      expect(find.text('Informations et repères d\'interprétation'), findsNothing);
      await pumpList(tester, const []);
      expect(find.text('Alertes'), findsNothing);
    });
  });
}
