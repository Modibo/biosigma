// Navigation au clavier et annonces par les lecteurs d'écran.
import 'package:biosigma/data/calculator_registry.dart';
import 'package:biosigma/screens/calculator_screen.dart';
import 'package:biosigma/screens/lab/convert_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: state, child: MaterialApp(home: screen)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la touche Tab parcourt les contrôles de Convert sans rester bloquée', (tester) async {
    await _pump(tester, const ConvertScreen());
    final seen = <FocusNode?>{};
    for (var i = 0; i < 14; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      seen.add(FocusManager.instance.primaryFocus);
    }
    expect(seen.whereType<FocusNode>().length, greaterThanOrEqualTo(6),
        reason: 'le focus doit passer par plusieurs contrôles distincts');
  });

  testWidgets('au clavier : saisir une valeur puis activer « Convertir » avec Entrée/espace', (tester) async {
    await _pump(tester, const ConvertScreen());
    await tester.tap(find.text('Analyte'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '100');
    await tester.pump();
    // Tab jusqu'au bouton « Convertir », puis activation au clavier
    var focused = false;
    for (var i = 0; i < 60 && !focused; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final ctx = FocusManager.instance.primaryFocus?.context;
      final button = ctx?.findAncestorWidgetOfExactType<FilledButton>();
      if (button != null &&
          find.descendant(of: find.byWidget(button), matching: find.text('Convertir')).evaluate().isNotEmpty) {
        focused = true;
      }
    }
    expect(focused, isTrue, reason: 'le bouton Convertir doit être atteignable au clavier');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Résultat'), findsOneWidget);
  });

  testWidgets('le résultat est une région vive : annoncé par les lecteurs d\'écran à son apparition',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, CalculatorScreen(definition: allCalculators.firstWhere((d) => d.meta.id == 'bmi')));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '70');
    await tester.enterText(fields.at(1), '175');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.text('Résultat'));
    // un ancêtre porte l'indicateur « région vive »
    var current = node;
    var live = false;
    SemanticsNode? n = current;
    while (n != null) {
      // ignore: deprecated_member_use
      if (n.getSemanticsData().flagsCollection.isLiveRegion) live = true;
      n = n.parent;
    }
    expect(live, isTrue);
    handle.dispose();
  });

  testWidgets('les pastilles de mode annoncent leur état sélectionné', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const ConvertScreen());
    final chip = tester.getSemantics(find.widgetWithText(ChoiceChip, 'Unités'));
    // ignore: deprecated_member_use
    expect(chip.getSemanticsData().flagsCollection.isSelected.toString(), contains('isTrue'));
    handle.dispose();
  });
}
