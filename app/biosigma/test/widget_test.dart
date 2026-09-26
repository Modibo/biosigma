// Test de parcours bout en bout : accueil -> recherche -> calculateur ->
// résultat. Vérifie que l'application démarre, affiche le catalogue, et
// qu'un calcul réel (QUICKI) produit un résultat affiché à l'écran.
import 'package:biosigma/app.dart';
import 'package:biosigma/data/quiz/quiz_renal.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await AppStorageService.create();
  final appState = AppState(storage);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: appState, child: const BioSigmaApp()),
  );
  await tester.pumpAndSettle();
  return appState;
}

void main() {
  testWidgets("L'accueil affiche le titre et la recherche", (tester) async {
    await _pumpApp(tester);
    expect(find.text('BioSigma'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('DFG — panel CKD-EPI'), findsOneWidget);
  });

  testWidgets('La recherche filtre le catalogue (QUICKI)', (tester) async {
    await _pumpApp(tester);
    await tester.enterText(find.byType(TextField), 'QUICKI');
    await tester.pumpAndSettle();
    expect(find.textContaining('QUICKI'), findsWidgets);
  });

  testWidgets('Parcours complet : ouvrir QUICKI, saisir, calculer, voir le résultat',
      (tester) async {
    await _pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'QUICKI');
    await tester.pumpAndSettle();
    // Cible précisément la tuile de résultat (et non le champ de
    // recherche, qui contient aussi la valeur saisie "QUICKI").
    await tester.tap(find.widgetWithText(ListTile, 'QUICKI'));
    await tester.pumpAndSettle();

    // Écran calculateur générique : "Outil d'aide au calcul" doit être visible.
    expect(find.textContaining("Outil d'aide au calcul"), findsOneWidget);

    final numericFields = find.byType(TextFormField);
    expect(numericFields, findsWidgets);

    // Insulinémie à jeun = 15 µU/mL (unité canonique par défaut).
    // Glycémie à jeun = 5,0 mmol/L (unité canonique par défaut du champ).
    await tester.enterText(numericFields.at(0), '15');
    await tester.enterText(numericFields.at(1), '5');
    await tester.pumpAndSettle();

    // Confirme le prélèvement à jeun.
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Calculer'));
    await tester.pumpAndSettle();

    // QUICKI(15 µU/mL, 90 mg/dL) ≈ 0,3195 — affiché avec la précision de la formule.
    expect(find.textContaining('0,3'), findsOneWidget);
    expect(find.text('Score incomplet'), findsNothing);
  });

  testWidgets('Réglages : bascule décimale et retour', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byTooltip('Réglages'));
    await tester.pumpAndSettle();
    expect(find.text('Réglages'), findsWidgets);
    expect(find.text('Point (1.50)'), findsOneWidget);
  });

  testWidgets('Références : la liste des formules est consultable hors connexion',
      (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byTooltip('Références et limites'));
    await tester.pumpAndSettle();
    expect(find.text('Références et limites'), findsOneWidget);
    expect(find.textContaining('Formule, version et limites'), findsWidgets);
  });

  testWidgets('Quiz de formation : parcours complet avec toutes les bonnes réponses',
      (tester) async {
    // Fenêtre de test agrandie : le contenu d'une question (énoncé + 4
    // options + explication + bouton) dépasse la taille par défaut, ce qui
    // ferait défiler le bouton hors-écran (et donc hors des finders) entre
    // deux questions. Un écran réel scrolle sans problème ; ceci évite
    // simplement de coupler ce test à la logique de défilement.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpApp(tester);

    await tester.tap(find.widgetWithText(ListTile, quizRenal.title));
    await tester.pumpAndSettle();

    expect(find.textContaining('Auto-évaluation pédagogique'), findsOneWidget);

    for (final question in quizRenal.questions) {
      expect(find.text(question.prompt), findsOneWidget, reason: 'prompt de ${question.id}');
      final options = find.byType(RadioListTile<int>);
      expect(options, findsNWidgets(4), reason: 'options de ${question.id}');
      await tester.tap(options.at(question.correctIndex));
      await tester.pump();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Correct.'), findsOneWidget, reason: 'correction de ${question.id}');

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
    }

    // Score final : toutes les réponses étaient correctes.
    expect(find.text('${quizRenal.questions.length} / ${quizRenal.questions.length}'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Retour à la formation'));
    await tester.pumpAndSettle();

    // Le score revient sur l'accueil sous forme de badge.
    expect(find.text('${quizRenal.questions.length}/${quizRenal.questions.length}'), findsOneWidget);
  });
}
