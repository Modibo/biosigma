// Mode Expert : propagation d'incertitude (GUM). Valeurs de référence calculées
// hors du code (Python) : dilution C1 100 ± 1, V1 10 ± 0,05, V2 100 ± 0,1.
import 'package:biosigma/screens/lab/uncertainty_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: state,
    child: const MaterialApp(home: UncertaintyScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dilution : C2 = 10, u_c = 0,1122, U (k = 2) = 0,2245', (tester) async {
    await _pump(tester);
    final f = find.byType(TextFormField);
    await tester.enterText(f.at(0), '100');
    await tester.enterText(f.at(1), '1');
    await tester.enterText(f.at(2), '10');
    await tester.enterText(f.at(3), '0,05');
    await tester.enterText(f.at(4), '100');
    await tester.enterText(f.at(5), '0,1');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();

    expect(find.text('Résultat'), findsOneWidget);
    expect(find.text('0,1122'), findsOneWidget);
    expect(find.text('0,2245'), findsOneWidget);
    expect(find.textContaining('non corrélées'), findsWidgets);
  });

  testWidgets('une incertitude-type manquante est refusée, aucun résultat', (tester) async {
    await _pump(tester);
    final f = find.byType(TextFormField);
    await tester.enterText(f.at(0), '100');
    await tester.enterText(f.at(2), '10');
    await tester.enterText(f.at(4), '100');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('Résultat'), findsNothing);
    expect(find.textContaining('Incertitude-type requise'), findsWidgets);
  });

  testWidgets('somme pondérée : x1 + x2 − x3 → 12 ± 0,2291', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Somme pondérée'));
    await tester.pumpAndSettle();
    final f = find.byType(TextFormField);
    // Par grandeur : valeur, incertitude-type, coefficient (valeur absolue) ; puis k.
    final inputs = [('10', '0,1'), ('5', '0,2'), ('3', '0,05')];
    for (var i = 0; i < 3; i++) {
      await tester.enterText(f.at(i * 3), inputs[i].$1);
      await tester.enterText(f.at(i * 3 + 1), inputs[i].$2);
    }
    await tester.tap(find.text('Retranchée (−)').last);
    await tester.pump();
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.text('12,0000'), findsOneWidget);
    expect(find.text('0,2291'), findsOneWidget);
  });

  testWidgets('aide : u = a/√3 pour a = 0,5 → 0,28868', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Évaluer une incertitude-type'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Type B : demi-largeur a (loi rectangulaire)'), '0,5');
    await tester.tap(find.text('Calculer u (type B)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('0,28868'), findsOneWidget);
  });
}
