// Recherche universelle : ouverture depuis la barre, résultats, navigation.
import 'package:biosigma/app.dart';
import 'package:biosigma/screens/calculator_screen.dart';
import 'package:biosigma/screens/lab/convert_screen.dart';
import 'package:biosigma/screens/lab/dilute_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _openSearch(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(ChangeNotifierProvider.value(value: state, child: const BioSigmaApp()));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Rechercher partout'));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).last, text);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la loupe de la barre ouvre la recherche, avec des exemples', (tester) async {
    await _openSearch(tester);
    expect(find.textContaining('Exemples'), findsOneWidget);
    expect(find.text('Calcul, analyte, unité, module… ou une phrase'), findsOneWidget);
  });

  testWidgets('« dfg » : résultats CKD-EPI ; un tap ouvre le calcul', (tester) async {
    await _openSearch(tester);
    await _type(tester, 'dfg');
    expect(find.textContaining('CKD-EPI'), findsWidgets);
    await tester.tap(find.textContaining('CKD-EPI créatinine 2021').first);
    await tester.pumpAndSettle();
    expect(find.byType(CalculatorScreen), findsOneWidget);
  });

  testWidgets('« glucose » : l\'analyte ouvre Convert prérempli (formule et masse molaire)', (tester) async {
    await _openSearch(tester);
    await _type(tester, 'glucose');
    await tester.tap(find.text('Glucose').first);
    await tester.pumpAndSettle();
    expect(find.byType(ConvertScreen), findsOneWidget);
    expect(find.textContaining('C6H12O6'), findsOneWidget);
    expect(find.textContaining('180,156 g/mol'), findsOneWidget);
  });

  testWidgets('« sodium » : l\'analyte ouvre Convert sur le sodium', (tester) async {
    await _openSearch(tester);
    await _type(tester, 'sodium');
    await tester.tap(find.text('Sodium (Na⁺)').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Formule brute : Na'), findsOneWidget);
  });

  testWidgets('« mmhg » : l\'unité ouvre Convert sur la grandeur Pression', (tester) async {
    await _openSearch(tester);
    await _type(tester, 'mmhg');
    expect(find.textContaining('Unité (Convert)'), findsWidgets);
    await tester.tap(find.text('mmHg').first);
    await tester.pumpAndSettle();
    expect(find.byType(ConvertScreen), findsOneWidget);
    expect(find.text('Pression (gaz du sang…)'), findsOneWidget);
  });

  testWidgets('« dilution » : le module Dilute s\'ouvre', (tester) async {
    await _openSearch(tester);
    await _type(tester, 'dilution');
    await tester.tap(find.text('Dilute').first);
    await tester.pumpAndSettle();
    expect(find.byType(DiluteScreen), findsOneWidget);
  });

  testWidgets('une phrase propose un module à confirmer, sans calculer', (tester) async {
    await _openSearch(tester);
    await _type(tester, 'je veux diluer 100 µL de sérum dans 900 µL de diluant');
    expect(find.textContaining('à confirmer'), findsOneWidget);
    expect(find.text('Résultat'), findsNothing);
  });

  testWidgets('aucun résultat : message', (tester) async {
    await _openSearch(tester);
    await _type(tester, 'qqqqqqq');
    expect(find.textContaining('Aucun résultat'), findsOneWidget);
  });

  testWidgets('Convert : ouverture directe sur une unité inconnue de la liste = comportement par défaut', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final state = AppState(await AppStorageService.create());
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: state, child: const MaterialApp(home: ConvertScreen(initialUnit: 'unite-inconnue'))));
    await tester.pumpAndSettle();
    expect(find.text('Concentration (masse, mol, éq par volume)'), findsOneWidget);
  });
}
