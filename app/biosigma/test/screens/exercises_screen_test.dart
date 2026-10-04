// P5-05 : écran d'exercices de calcul (mode enseignement).
import 'package:biosigma/screens/exercises_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, {int seed = 11, String kind = 'anion_gap'}) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: state,
    child: MaterialApp(home: ExercisesScreen(initialSeed: seed, initialKindId: kind)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('énoncé, mention d\'entraînement et numéro affichés', (tester) async {
    await _pump(tester);
    final e = ExerciseGenerator.generate('anion_gap', 11);
    expect(find.text(e.statement), findsOneWidget);
    expect(find.textContaining('exercice d\'entraînement uniquement'), findsOneWidget);
    expect(find.text('Exercice n° 11'), findsOneWidget);
    expect(find.text('Solution détaillée'), findsNothing, reason: 'pas de corrigé avant réponse');
  });

  testWidgets('bonne réponse : « Correct », corrigé et solution disponibles', (tester) async {
    await _pump(tester);
    final e = ExerciseGenerator.generate('anion_gap', 11);
    await tester.enterText(find.byType(TextFormField).first, e.expectedRounded.toStringAsFixed(0));
    await tester.tap(find.text('Vérifier'));
    await tester.pumpAndSettle();
    expect(find.text('Correct.'), findsOneWidget);
    expect(find.textContaining('Corrigé : ${e.expectedRounded.toStringAsFixed(0)}'), findsOneWidget);
    expect(find.textContaining('1 bonne réponse sur 1'), findsOneWidget);
    await tester.tap(find.text('Solution détaillée'));
    await tester.pumpAndSettle();
    expect(find.text(e.solution.first), findsOneWidget);
  });

  testWidgets('mauvaise réponse : signalée, corrigé donné, score 0 sur 1', (tester) async {
    await _pump(tester);
    final e = ExerciseGenerator.generate('anion_gap', 11);
    await tester.enterText(find.byType(TextFormField).first, (e.expectedRounded + 5).toStringAsFixed(0));
    await tester.tap(find.text('Vérifier'));
    await tester.pumpAndSettle();
    expect(find.text('Réponse différente du corrigé.'), findsOneWidget);
    expect(find.textContaining('0 bonne réponse sur 1'), findsOneWidget);
  });

  testWidgets('réponse vide : consigne, et rien n\'est compté', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Vérifier'));
    await tester.pumpAndSettle();
    expect(find.text('Saisissez un nombre.'), findsOneWidget);
    expect(find.textContaining('sur 0'), findsOneWidget);
  });

  testWidgets('« Nouvel exercice » change le numéro et efface la réponse', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Nouvel exercice'));
    await tester.pumpAndSettle();
    expect(find.text('Exercice n° 11'), findsNothing);
    expect(find.text('Correct.'), findsNothing);
  });
}
