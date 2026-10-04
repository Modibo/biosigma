// Modules Lab de la phase 1 : onglet, Convert, Dilute.
import 'package:biosigma/screens/lab/convert_screen.dart';
import 'package:biosigma/screens/lab/dilute_screen.dart';
import 'package:biosigma/screens/lab_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: state, child: MaterialApp(home: Scaffold(body: screen))),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('l\'onglet Lab ouvre Convert et Dilute ; les modules prévus ne s\'ouvrent pas',
      (tester) async {
    await _pump(tester, const DefaultTabController(length: 1, child: LabScreen()));
    expect(find.text('Convert'), findsOneWidget);
    expect(find.text('Dilute'), findsOneWidget);
    expect(find.text('Prepare'), findsOneWidget);
    expect(find.textContaining('aucune valeur n\'est inventée'), findsOneWidget);

    await tester.tap(find.text('Prepare'));
    await tester.pumpAndSettle();
    expect(find.byType(LabScreen), findsOneWidget);

    await tester.tap(find.text('Dilute'));
    await tester.pumpAndSettle();
    expect(find.byType(DiluteScreen), findsOneWidget);
  });

  testWidgets('Convert : refuse sans masse molaire, puis convertit avec la masse molaire saisie',
      (tester) async {
    await _pump(tester, const ConvertScreen());
    await tester.enterText(find.byType(TextFormField).at(0), '100');
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.textContaining('masse molaire (g/mol) est requise'), findsOneWidget);
    expect(find.text('Résultat'), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(1), '180,16');
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.text('Résultat'), findsOneWidget);
    expect(find.text('5,551'), findsOneWidget); // 1000 / 180,16 = 5,5506
    expect(find.textContaining('ne la vérifie pas'), findsOneWidget);
  });

  testWidgets('Convert : « 1.5 » est refusé en mode virgule (pas de facteur 10)', (tester) async {
    await _pump(tester, const ConvertScreen());
    await tester.enterText(find.byType(TextFormField).at(0), '1.5');
    await tester.pump();
    expect(find.textContaining('Séparateur ambigu'), findsOneWidget);
  });

  testWidgets('Dilute simple : 10 mg/dL, 1 mL dans 10 mL → C2 = 1, F = 10', (tester) async {
    await _pump(tester, const DiluteScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '10'); // C1
    await tester.enterText(fields.at(1), '1'); // V1
    await tester.enterText(fields.at(3), '10'); // V2
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('C2 (concentration finale)'), findsOneWidget);
    expect(find.text('1,000'), findsWidgets);
    expect(find.text('10,0000'), findsOneWidget); // facteur
    expect(find.textContaining('ambigu'), findsOneWidget); // notation 1/F
  });

  testWidgets('Dilute simple : valeurs qui ne forment pas une dilution → message', (tester) async {
    await _pump(tester, const DiluteScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '1'); // C1 = 1
    await tester.enterText(fields.at(1), '5'); // V1 = 5
    await tester.enterText(fields.at(3), '1'); // V2 = 1 → C2 = 5 > C1
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ne décrivent pas une dilution'), findsOneWidget);
    expect(find.text('Résultat'), findsNothing);
  });

  testWidgets('Dilute en série : tableau de 4 tubes', (tester) async {
    await _pump(tester, const DiluteScreen());
    await tester.tap(find.text('En série'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '100'); // concentration de départ
    await tester.enterText(fields.at(1), '2'); // facteur
    await tester.enterText(fields.at(2), '4'); // tubes
    await tester.enterText(fields.at(3), '1'); // volume final
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('1/16'), findsOneWidget);
    expect(find.textContaining('6,250'), findsWidgets);
  });

  testWidgets('Hors linéarité : résultat dilué hors intervalle → aucun résultat présenté',
      (tester) async {
    await _pump(tester, const DiluteScreen());
    await tester.tap(find.text('Hors linéarité'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '250'); // résultat dilué
    await tester.enterText(fields.at(2), '2 ; 5'); // facteurs → 10
    await tester.enterText(fields.at(4), '10'); // min
    await tester.enterText(fields.at(5), '200'); // max
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('hors de l\'intervalle de linéarité'), findsOneWidget);
    expect(find.textContaining('non calculé'), findsOneWidget);
  });

  testWidgets('Hors linéarité : résultat dilué dans l\'intervalle → résultat × facteur',
      (tester) async {
    await _pump(tester, const DiluteScreen());
    await tester.tap(find.text('Hors linéarité'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '150');
    await tester.enterText(fields.at(2), '2 ; 5');
    await tester.enterText(fields.at(4), '10');
    await tester.enterText(fields.at(5), '200');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('1500'), findsOneWidget);
  });
}
