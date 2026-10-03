// Décisions D-03 (interprétation toujours affichée, y compris ISTH-CIVD/4Ts)
// et D-04 (réglages sans effet retirés ou câblés).
import 'package:biosigma/data/calculator_registry_metabolic.dart';
import 'package:biosigma/data/calculator_registry_metabolic_additions.dart';
import 'package:biosigma/models/app_settings.dart';
import 'package:biosigma/models/local_threshold.dart';
import 'package:biosigma/screens/calculator_screen.dart';
import 'package:biosigma/screens/four_ts_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _state([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return AppState(await AppStorageService.create());
}

Future<void> _pump(WidgetTester tester, AppState state, Widget screen) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: state, child: MaterialApp(home: screen)),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapFirstRadio<T>(WidgetTester tester) async {
  final radio = find.byType(RadioListTile<T>).first;
  await tester.ensureVisible(radio);
  await tester.tap(radio);
  await tester.pump();
}

void main() {
  testWidgets("D-03 : l'interprétation du 4Ts s'affiche sans aucun réglage", (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final state = await _state();
    await _pump(tester, state, const FourTsScreen());

    await _tapFirstRadio<FourTsThrombocytopenia>(tester);
    await _tapFirstRadio<FourTsTiming>(tester);
    await _tapFirstRadio<FourTsThrombosis>(tester);
    await _tapFirstRadio<FourTsOtherCauses>(tester);
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();

    expect(find.text('Score incomplet'), findsNothing);
    expect(find.textContaining('Interprétation masquée'), findsNothing);
    expect(find.byIcon(Icons.info_outline), findsWidgets, reason: 'interprétation visible');
  });

  testWidgets("D-04 : l'équation LDL présélectionnée suit le réglage", (tester) async {
    final state = await _state();
    await state.updateSettings((s) => s.copyWith(ldlDefaultFriedewald: false));
    await _pump(tester, state, CalculatorScreen(definition: ldlPanelDefinition));
    expect(find.text(LdlFormula.sampson.label), findsWidgets);
    expect(find.text(LdlFormula.friedewald.label), findsNothing);
  });

  testWidgets('D-04 : les seuils locaux sont rappelés sous le résultat, sans comparaison',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final state = await _state();
    await state.saveThreshold(LocalThreshold(
      calculatorId: bmiMeta.id,
      label: 'Seuil de test',
      value: 25,
      unit: 'kg/m²',
      method: 'Méthode de test',
      validatedOn: DateTime.utc(2026, 10, 3),
      validatedBy: 'Dr Test',
    ));
    await _pump(tester, state, CalculatorScreen(definition: bmiDefinition));

    expect(find.text('Seuils locaux du laboratoire'), findsNothing, reason: 'rien avant le calcul');
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '70');
    await tester.enterText(fields.at(1), '175');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();

    expect(find.text('Seuils locaux du laboratoire'), findsOneWidget);
    expect(find.textContaining('Seuil de test : 25.0 kg/m²'), findsOneWidget);
    expect(find.textContaining('Dr Test'), findsOneWidget);
  });

  test("D-04 : d'anciens réglages contenant les clés retirées sont relus sans quarantaine",
      () async {
    SharedPreferences.setMockInitialValues({
      'biosigma.settings.v1':
          '{"decimalSeparator":"dot","displayPrecision":4,"historyEnabled":true,'
              '"localInterpretationsValidated":true,"ldlDefaultFriedewald":false,'
              '"sodiumCorrectionUsesKatz":false}',
    });
    final storage = await AppStorageService.create();
    final settings = storage.loadSettings();
    expect(settings.decimalSeparator, DecimalSeparator.dot);
    expect(settings.historyEnabled, isTrue);
    expect(settings.ldlDefaultFriedewald, isFalse);
    expect(storage.quarantinedKeys(), isEmpty);
  });
}
