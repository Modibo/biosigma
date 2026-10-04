// Impression / export (P3-05, D-11) : confirmation obligatoire, contenu du rapport.
import 'package:biosigma/data/calculator_registry.dart';
import 'package:biosigma/screens/calculator_screen.dart';
import 'package:biosigma/screens/lab/convert_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? _clipboard;

void _mockClipboard(WidgetTester tester) {
  _clipboard = null;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.setData') {
      _clipboard = (call.arguments as Map)['text'] as String?;
    }
    return null;
  });
  addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
}

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: state, child: MaterialApp(home: screen)),
  );
  await tester.pumpAndSettle();
}

Future<void> _bmiResult(WidgetTester tester) async {
  await _pump(tester, CalculatorScreen(definition: allCalculators.firstWhere((d) => d.meta.id == 'bmi')));
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), '70');
  await tester.enterText(fields.at(1), '175');
  await tester.tap(find.text('Calculer'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la confirmation est obligatoire : sans case cochée, rien ne peut être copié ni imprimé',
      (tester) async {
    _mockClipboard(tester);
    await _bmiResult(tester);
    await tester.tap(find.text('Imprimer / exporter'));
    await tester.pumpAndSettle();
    expect(find.text('Imprimer ou exporter ce résultat'), findsOneWidget);
    expect(find.textContaining('aucune identité de patient'), findsWidgets);

    final copy = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Copier le texte'));
    expect(copy.onPressed, isNull);
    final print = tester.widget<FilledButton>(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    expect(print.onPressed, isNull);
    expect(_clipboard, isNull);
  });

  testWidgets('Annuler ne copie rien', (tester) async {
    _mockClipboard(tester);
    await _bmiResult(tester);
    await tester.tap(find.text('Imprimer / exporter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text('Imprimer ou exporter ce résultat'), findsNothing);
    expect(_clipboard, isNull);
  });

  testWidgets('confirmé : le rapport texte contient version, statut, entrées, résultat et la référence saisie',
      (tester) async {
    _mockClipboard(tester);
    await _bmiResult(tester);
    await tester.tap(find.text('Imprimer / exporter'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Référence libre (facultatif)'), 'ECH-0042');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Copier le texte'));
    await tester.pumpAndSettle();

    expect(_clipboard, isNotNull);
    expect(_clipboard, contains('Référence : ECH-0042'));
    expect(_clipboard, contains('METAB_BMI_001 · version 1 · statut de validation : NON VALIDÉ'));
    expect(_clipboard, contains('IMC'));
    expect(_clipboard, contains('22,9')); // virgule décimale par défaut
    expect(_clipboard, contains('aucune identité de patient'));
    expect(find.text('Rapport copié dans le presse-papiers.'), findsOneWidget);
  });

  testWidgets('hors web : « Copier le rapport » remplace l\'impression et le dit', (tester) async {
    _mockClipboard(tester);
    await _bmiResult(tester);
    await tester.tap(find.text('Imprimer / exporter'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copier le rapport'));
    await tester.pumpAndSettle();
    expect(_clipboard, contains('BioSigma — '));
    expect(find.textContaining('L\'impression n\'est pas disponible ici'), findsOneWidget);
  });

  testWidgets('les résultats des modules Lab (Convert) ont aussi le bouton', (tester) async {
    _mockClipboard(tester);
    await _pump(tester, const ConvertScreen());
    await tester.tap(find.text('Analyte'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '100');
    await tester.tap(find.text('Convertir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Imprimer / exporter'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Copier le texte'));
    await tester.pumpAndSettle();
    expect(_clipboard, contains('Formule brute : C6H12O6'));
    expect(_clipboard, contains('5,551'));
    expect(_clipboard, contains('Statut de la base : NON VALIDÉ'));
  });
}
