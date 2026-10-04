// Choix de la chambre de numération (Malassez, Neubauer améliorée, personnalisée).
import 'package:biosigma/screens/lab/count_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 4500);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: state,
      child: const MaterialApp(home: CountScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, String label, String option) async {
  await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'le choix de la chambre est proposé, avec Malassez, Neubauer améliorée et Personnalisée',
    (tester) async {
      await _open(tester);
      expect(find.text('Chambre de numération'), findsOneWidget);
      await tester.tap(
        find.widgetWithText(
          DropdownButtonFormField<String>,
          'Chambre de numération',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Malassez'), findsOneWidget);
      expect(find.text('Neubauer améliorée'), findsOneWidget);
      expect(find.textContaining('Personnalisée'), findsWidgets);
    },
  );

  testWidgets(
    'Malassez : 120 cellules dans 10 rectangles, sans dilution → 1200 cellules/µL',
    (tester) async {
      await _open(tester);
      await _choose(tester, 'Chambre de numération', 'Malassez');
      expect(find.textContaining('Profondeur 0,2 mm'), findsWidgets);
      expect(
        find.textContaining('Surface comptée (mm²)'),
        findsNothing,
        reason: 'géométrie fournie par la chambre',
      );
      final f = find.byType(TextFormField);
      await tester.enterText(f.at(0), '10'); // unités comptées
      await tester.pumpAndSettle();
      expect(find.textContaining('volume compté : 0,1 µL'), findsOneWidget);
      await tester.enterText(f.at(1), '120'); // cellules
      await tester.enterText(f.at(2), '1'); // dilution
      await tester.tap(find.text('Calculer'));
      await tester.pumpAndSettle();
      expect(find.text('Résultat'), findsOneWidget);
      expect(find.text('1200'), findsWidgets);
      expect(find.textContaining('Chambre'), findsWidgets);
    },
  );

  testWidgets('Malassez : plus de 100 rectangles refusé', (tester) async {
    await _open(tester);
    await _choose(tester, 'Chambre de numération', 'Malassez');
    final f = find.byType(TextFormField);
    await tester.enterText(f.at(0), '101');
    await tester.enterText(f.at(1), '5');
    await tester.enterText(f.at(2), '1');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('compte au plus 100'), findsOneWidget);
    expect(find.text('Résultat'), findsNothing);
  });

  testWidgets(
    'Neubauer améliorée : 1 grille, 200 cellules, dilution 20 → 40000 /µL',
    (tester) async {
      await _open(tester);
      await _choose(tester, 'Chambre de numération', 'Neubauer améliorée');
      final f = find.byType(TextFormField);
      await tester.enterText(f.at(0), '1');
      await tester.enterText(f.at(1), '200');
      await tester.enterText(f.at(2), '20');
      await tester.tap(find.text('Calculer'));
      await tester.pumpAndSettle();
      expect(find.text('40000'), findsWidgets);
    },
  );

  testWidgets(
    'Personnalisée (par défaut) : surface et profondeur saisies, comme avant',
    (tester) async {
      await _open(tester);
      expect(find.text('Surface comptée (mm²)'), findsOneWidget);
      expect(find.text('Profondeur de la chambre (mm)'), findsOneWidget);
      final f = find.byType(TextFormField);
      await tester.enterText(f.at(0), '100');
      await tester.enterText(f.at(1), '1');
      await tester.enterText(f.at(2), '0,1');
      await tester.enterText(f.at(3), '1');
      await tester.tap(find.text('Calculer'));
      await tester.pumpAndSettle();
      expect(find.text('1000'), findsWidgets);
    },
  );

  testWidgets(
    'revenir à Personnalisée depuis Malassez rend les champs de surface et de profondeur',
    (tester) async {
      await _open(tester);
      await _choose(tester, 'Chambre de numération', 'Malassez');
      await _choose(
        tester,
        'Chambre de numération',
        'Personnalisée (surface et profondeur saisies)',
      );
      expect(find.text('Surface comptée (mm²)'), findsOneWidget);
    },
  );

  testWidgets(
    'toutes les chambres vérifiées sont proposées (14) en plus de « Personnalisée »',
    (tester) async {
      await _open(tester);
      await tester.tap(
        find.widgetWithText(
          DropdownButtonFormField<String>,
          'Chambre de numération',
        ),
      );
      await tester.pumpAndSettle();
      for (final n in [
        'Neubauer améliorée',
        'Neubauer',
        'Bürker',
        'Bürker-Türk',
        'Thoma',
        'Thoma nouvelle',
        'Fuchs-Rosenthal',
        'Nageotte',
        'Malassez',
        'Makler (sperme)',
        'Petroff-Hausser (profondeur 0,02 mm)',
        'Neubauer améliorée, profondeur 0,01 mm (Petroff)',
        'Neubauer améliorée, profondeur 0,02 mm (Petroff)',
        'Thoma (Helber), profondeur 0,02 mm',
      ]) {
        expect(find.text(n), findsOneWidget, reason: n);
      }
    },
  );

  testWidgets(
    'Fuchs-Rosenthal : 2 grands carrés (0,4 µL), 8 cellules, sans dilution → 20 cellules/µL ; usage affiché',
    (tester) async {
      await _open(tester);
      await _choose(tester, 'Chambre de numération', 'Fuchs-Rosenthal');
      expect(
        find.textContaining('Usage : liquide cérébro-spinal'),
        findsOneWidget,
      );
      expect(find.textContaining('Profondeur 0,2 mm'), findsWidgets);
      final f = find.byType(TextFormField);
      await tester.enterText(f.at(0), '2');
      await tester.pumpAndSettle();
      expect(find.textContaining('volume compté : 0,4 µL'), findsOneWidget);
      await tester.enterText(f.at(1), '8');
      await tester.enterText(f.at(2), '1');
      await tester.tap(find.text('Calculer'));
      await tester.pumpAndSettle();
      expect(find.text('20,00'), findsWidgets);
    },
  );

  testWidgets(
    'Makler : une bande de 10 carrés, 150 spermatozoïdes → 150 000 cellules/µL (150 ×10⁶/mL)',
    (tester) async {
      await _open(tester);
      await _choose(tester, 'Chambre de numération', 'Makler (sperme)');
      final f = find.byType(TextFormField);
      await tester.enterText(f.at(0), '1');
      await tester.enterText(f.at(1), '150');
      await tester.enterText(f.at(2), '1');
      await tester.tap(find.text('Calculer'));
      await tester.pumpAndSettle();
      expect(find.text('150000'), findsWidgets);
    },
  );
}
