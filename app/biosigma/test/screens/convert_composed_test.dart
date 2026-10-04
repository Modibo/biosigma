// P1-10 : mode « Unités composées » de Convert (analyse dimensionnelle).
import 'package:biosigma/screens/lab/convert_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 3500);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: state,
    child: const MaterialApp(home: ConvertScreen()),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Unités composées'));
  await tester.pumpAndSettle();
}

Future<void> _setUnits(WidgetTester tester, String from, String to) async {
  await tester.enterText(find.widgetWithText(TextField, 'Unité de départ'), from);
  await tester.enterText(find.widgetWithText(TextField, 'Unité d\'arrivée'), to);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('12 mg/kg/d → µg/kg/min = 8,333 (unité hors des listes)', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextFormField).first, '12');
    await tester.pumpAndSettle();
    expect(find.textContaining('Lu : '), findsWidgets);
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.text('Résultat'), findsOneWidget);
    expect(find.text('8,333'), findsOneWidget);
  });

  testWidgets('la dimension lue est affichée sous chaque unité', (tester) async {
    await _pump(tester);
    await _setUnits(tester, 'mg/dL', 'g/L');
    expect(find.text('Lu : concentration massique (M·L⁻³)'), findsNWidgets(2));
  });

  testWidgets('dimensions incompatibles : explication, aucun résultat', (tester) async {
    await _pump(tester);
    await _setUnits(tester, 'mg/dL', 'mmHg');
    expect(find.textContaining('Les dimensions ne sont pas compatibles'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '5');
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.text('Résultat'), findsNothing);
    expect(find.textContaining('Conversion impossible'), findsWidgets);
  });

  testWidgets('masse → mole : le champ de masse molaire apparaît ; sans lui, refus ; avec lui, 88,4', (tester) async {
    await _pump(tester);
    await _setUnits(tester, 'mg/dL', 'µmol/L');
    expect(find.text('Masse molaire (g/mol)'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '1');
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.textContaining('masse molaire (g/mol) est requise'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Masse molaire (g/mol)'), '113,12');
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.text('88,40'), findsOneWidget);
  });

  testWidgets('unité illisible : message de lecture, et refus au calcul', (tester) async {
    await _pump(tester);
    await _setUnits(tester, 'zzz', 'g/L');
    expect(find.textContaining('n\'est pas une unité reconnue'), findsWidgets);
    await tester.enterText(find.byType(TextFormField).first, '5');
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.text('Résultat'), findsNothing);
  });

  testWidgets('saisie rapide en mode composé : « 5 G/L en /µL » remplit valeur et unités → 5000', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byKey(const ValueKey('quick-entry')), '5 G/L en /µL');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('Lu : 5 G/L → /µL'), findsOneWidget);
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    expect(find.text('5000'), findsWidgets);
  });

  testWidgets('les modes Unités et Analyte restent inchangés (la saisie rapide y fonctionne toujours)', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Unités'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('quick-entry')), '100 mg/dl en g/l');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('Lu : 100'), findsOneWidget);
  });
}
