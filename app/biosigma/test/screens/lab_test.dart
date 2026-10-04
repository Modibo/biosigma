// Modules Lab de la phase 1 : onglet, Convert, Dilute.
import 'package:biosigma/screens/lab/convert_screen.dart';
import 'package:biosigma/screens/lab/count_screen.dart';
import 'package:biosigma/screens/lab/dilute_screen.dart';
import 'package:biosigma/screens/lab/microbiology_screen.dart';
import 'package:biosigma/screens/lab/prepare_screen.dart';
import 'package:biosigma/screens/lab/quality_screen.dart';
import 'package:biosigma/screens/lab/smart_solver_screen.dart';
import 'package:biosigma_core/biosigma_core.dart';
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
  testWidgets('l\'onglet Lab propose les huit modules et ouvre chacun', (tester) async {
    await _pump(tester, const DefaultTabController(length: 1, child: LabScreen()));
    for (final t in ['Convert', 'Dilute', 'Prepare', 'Count', 'Microbiology', 'Quality', 'Incertitude (mode Expert)', 'Smart Solver']) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(find.text('Prévus — pas encore disponibles'), findsNothing);

    await tester.tap(find.text('Prepare'));
    await tester.pumpAndSettle();
    expect(find.byType(PrepareScreen), findsOneWidget);
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

  testWidgets('Prepare : 9 g/L dans 500 mL → 4,500 g (sans masse molaire)', (tester) async {
    await _pump(tester, const PrepareScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '9');
    await tester.enterText(fields.at(1), '500');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('4,500'), findsOneWidget);
    expect(find.textContaining('Pureté non précisée'), findsOneWidget);
  });

  testWidgets('Prepare : 0,9 % m/v dans 500 mL → 4,500 g', (tester) async {
    await _pump(tester, const PrepareScreen());
    await tester.tap(find.text('Pourcentage'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '0,9');
    await tester.enterText(fields.at(1), '500');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('4,500'), findsOneWidget);
  });

  testWidgets('Prepare : tampon pH = pKa → rapport 1', (tester) async {
    await _pump(tester, const PrepareScreen());
    await tester.tap(find.text('Tampon'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '7');
    await tester.enterText(fields.at(1), '7');
    await tester.enterText(fields.at(2), '100');
    await tester.enterText(fields.at(3), '1');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('1,0000'), findsOneWidget);
    expect(find.textContaining('pH-mètre'), findsOneWidget);
  });

  testWidgets('Count : 100 cellules, 1 mm² × 0,1 mm → 1000 cellules/µL', (tester) async {
    await _pump(tester, const CountScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '100');
    await tester.enterText(fields.at(1), '1');
    await tester.enterText(fields.at(2), '0,1');
    await tester.enterText(fields.at(3), '1');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('1000'), findsOneWidget);
    expect(find.textContaining('10.0 %'), findsOneWidget);
  });

  testWidgets('Count : compteur tactile 3 neutrophiles + 1 lymphocyte → 75,0 % et annulation', (tester) async {
    await _pump(tester, const CountScreen());
    await tester.tap(find.text('Formule'));
    await tester.pumpAndSettle();
    final plus = find.byIcon(Icons.add);
    for (var i = 0; i < 3; i++) {
      await tester.tap(plus.at(0));
    }
    await tester.tap(plus.at(1));
    await tester.pumpAndSettle();
    expect(find.text('Cellules comptées : 4'), findsOneWidget);

    await tester.tap(find.text('Annuler le dernier')); // retire le lymphocyte
    await tester.pumpAndSettle();
    expect(find.text('Cellules comptées : 3'), findsOneWidget);
    await tester.tap(plus.at(1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('75,0'), findsOneWidget);
    expect(find.text('25,0'), findsOneWidget);
  });

  testWidgets('Count : formule sans aucune cellule → message', (tester) async {
    await _pump(tester, const CountScreen());
    await tester.tap(find.text('Formule'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune cellule comptée.'), findsOneWidget);
  });

  testWidgets('Microbiology : 150 colonies, 10^-3, 0,1 mL → 1500000 UFC/mL', (tester) async {
    await _pump(tester, const MicrobiologyScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '150');
    await tester.enterText(fields.at(1), '3');
    await tester.enterText(fields.at(2), '0,1');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('1500000'), findsWidgets);
    expect(find.textContaining('Intervalle de dénombrement non précisé'), findsOneWidget);
  });

  testWidgets('Microbiology : boîte hors intervalle saisi → aucun résultat', (tester) async {
    await _pump(tester, const MicrobiologyScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '500');
    await tester.enterText(fields.at(1), '3');
    await tester.enterText(fields.at(2), '0,1');
    await tester.enterText(fields.at(3), '30');
    await tester.enterText(fields.at(4), '300');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucune boîte exploitable'), findsOneWidget);
  });

  testWidgets('Quality : série, cible et ETa → CV 1,41 % et Sigma 5,63, sans verdict', (tester) async {
    await _pump(tester, const QualityScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '98;100;102;100;100');
    await tester.enterText(fields.at(3), '98');
    await tester.enterText(fields.at(4), '10');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('1,41'), findsWidgets);
    expect(find.text('5,63'), findsOneWidget);
    expect(find.textContaining('aucune interprétation'), findsWidgets);
  });

  testWidgets('Quality : valeur illisible dans la liste → message', (tester) async {
    await _pump(tester, const QualityScreen());
    await tester.enterText(find.byType(TextFormField).at(0), '98;abc;100');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Valeur illisible'), findsOneWidget);
  });

  testWidgets('Smart Solver : propose Dilute, à confirmer ; ne calcule rien', (tester) async {
    LabModule? opened;
    await _pump(tester, SmartSolverScreen(openModule: (m) => opened = m));
    await tester.enterText(find.byType(TextField), 'Diluer 100 µL de sérum dans 900 µL de diluant');
    await tester.pump();
    await tester.tap(find.text('Analyser'));
    await tester.pumpAndSettle();
    expect(find.text('Module proposé — à confirmer'), findsOneWidget);
    expect(find.textContaining('100 µL'), findsWidgets);
    expect(find.text('Résultat'), findsNothing);
    expect(opened, isNull);

    await tester.tap(find.text('Ouvrir Dilute'));
    expect(opened, LabModule.dilute);
  });

  testWidgets('Smart Solver : phrase non reconnue → aucun module', (tester) async {
    await _pump(tester, SmartSolverScreen(openModule: (_) {}));
    await tester.enterText(find.byType(TextField), 'bonjour');
    await tester.pump();
    await tester.tap(find.text('Analyser'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucun module reconnu'), findsOneWidget);
  });

  testWidgets('Convert : choix de la grandeur « Température » → 37 °C = 98,60 °F', (tester) async {
    await _pump(tester, const ConvertScreen());
    await tester.tap(find.text('Concentration (masse, mol, éq par volume)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Température').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '37');
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.text('98,60'), findsOneWidget);
    expect(find.text('Masse molaire (g/mol)'), findsNothing, reason: 'aucune masse molaire demandée');
  });

  testWidgets('Convert : un enzyme n\'exige aucune masse molaire (40 U/L → 0,6667 µkat/L)', (tester) async {
    await _pump(tester, const ConvertScreen());
    await tester.tap(find.text('Concentration (masse, mol, éq par volume)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activité enzymatique (par volume)').last);
    await tester.pumpAndSettle();
    expect(find.text('Masse molaire (g/mol)'), findsNothing);
    await tester.enterText(find.byType(TextFormField).at(0), '40');
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.text('Résultat'), findsOneWidget);
  });

  testWidgets('Convert analytes : glucose par défaut, masse molaire calculée affichée', (tester) async {
    await _pump(tester, const ConvertScreen());
    await tester.tap(find.text('Analyte'));
    await tester.pumpAndSettle();
    expect(find.textContaining('C6H12O6'), findsOneWidget);
    expect(find.textContaining('180,156 g/mol'), findsOneWidget);
    expect(find.textContaining('NON VALIDÉ'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '100');
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.text('5,551'), findsOneWidget);
    expect(find.textContaining('facteur arrondi'), findsOneWidget);
  });

  testWidgets('Convert analytes : changer d\'analyte met à jour la formule et les unités', (tester) async {
    await _pump(tester, const ConvertScreen());
    await tester.tap(find.text('Analyte'));
    await tester.pumpAndSettle();
    // filtre par saisie (le menu est long : on tape le début du nom)
    await tester.enterText(
        find.descendant(of: find.byType(DropdownMenu<String>), matching: find.byType(TextField)), 'Sodium');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sodium (Na⁺)').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Formule brute : Na'), findsOneWidget);
    expect(find.textContaining('valence 1'), findsOneWidget);
    expect(find.textContaining('C6H12O6'), findsNothing);
  });
}
