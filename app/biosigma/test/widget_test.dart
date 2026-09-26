// Test de parcours bout en bout : accueil -> recherche -> calculateur ->
// résultat, et navigation entre les cinq onglets (Calcul, Entraînement,
// Références, Réglages, À propos). Vérifie que l'application démarre,
// affiche le catalogue, et qu'un calcul réel (QUICKI) produit un résultat
// affiché à l'écran.
//
// Remarque sur les finders : les cinq onglets sont maintenus en vie
// (`AutomaticKeepAliveClientMixin`) pour préserver leur état (recherche en
// cours, défilement) au changement d'onglet — leur contenu reste donc
// construit simultanément. Chaque écran d'onglet n'a plus son propre AppBar
// (le titre « Réglages », « Entraînement », etc. n'apparaît donc qu'une
// fois, dans le `TabBar` partagé) : les taps de changement d'onglet sont
// scopés à ce `TabBar` par prudence, et les vérifications de contenu
// utilisent des textes propres à l'écran visé plutôt que son seul titre.
import 'package:biosigma/app.dart';
import 'package:biosigma/data/quiz/quiz_renal.dart';
import 'package:biosigma/screens/quiz_module_screen.dart';
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

Future<void> _tapTab(WidgetTester tester, String label) async {
  final tabFinder = find.descendant(
    of: find.byType(TabBar),
    matching: find.text(label),
  );
  await tester.tap(tabFinder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets("L'onglet Calcul affiche le titre, la recherche et la barre d'onglets",
      (tester) async {
    await _pumpApp(tester);
    expect(find.text('BioSigma'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('DFG — panel CKD-EPI'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    for (final label in ['Calcul', 'Entraînement', 'Références', 'Réglages', 'À propos']) {
      expect(find.descendant(of: find.byType(TabBar), matching: find.text(label)), findsOneWidget,
          reason: 'onglet $label');
    }
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
    expect(find.textContaining("Outil d'aide au calcul"), findsWidgets);

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
    // Recherche la valeur exacte affichée (et non un simple "contient 0,3") : le
    // QUICKI n'ayant aucun seuil consensuel reconnu par une société savante,
    // l'interprétation toujours affichée à côté du résultat mentionne aussi des
    // valeurs "0,3x" à titre informatif, ce qui rendrait un finder trop large
    // ambigu (plusieurs correspondances).
    expect(find.text('0,3194'), findsOneWidget);
    expect(find.text('Score incomplet'), findsNothing);
  });

  testWidgets('Réglages : bascule décimale', (tester) async {
    await _pumpApp(tester);
    await _tapTab(tester, 'Réglages');
    expect(find.text('Point (1.50)'), findsOneWidget);
  });

  testWidgets('À propos : mission, avertissements, auteur et contact sont affichés',
      (tester) async {
    // Le contenu de l'écran À propos dépasse la petite fenêtre de test par
    // défaut : agrandir plutôt que de multiplier les finders skipOffstage.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpApp(tester);
    await _tapTab(tester, 'À propos');
    expect(find.textContaining('Dr Modibo Mouctar Coulibaly'), findsOneWidget);
    expect(find.textContaining('Sominé Dolo'), findsOneWidget);
    expect(find.text('coulibalymodibom@gmail.com'), findsOneWidget);
    expect(find.textContaining("pas un dispositif de diagnostic"), findsOneWidget);
    // Le geste de copie (Clipboard.setData) est vérifié visuellement plutôt
    // qu'ici : les canaux de plateforme ne sont pas simulés de façon fiable
    // dans ce harnais de test pour cette interaction précise.
  });

  testWidgets('Références : la liste des formules affiche leur nom, la version et les limites',
      (tester) async {
    await _pumpApp(tester);
    await _tapTab(tester, 'Références');
    expect(find.textContaining('Formule, version et limites'), findsWidgets);
    // Le nom complet d'au moins une formule doit être visible au-dessus de
    // sa fiche technique (pas seulement son titre générique).
    expect(find.textContaining('CKD-EPI créatinine 2021'), findsWidgets);
  });

  testWidgets('Entraînement : série de questions tirée de la banque rénale, score final',
      (tester) async {
    // Le contenu d'une question (énoncé + 4 options + explication + bouton)
    // dépasse la taille par défaut de la fenêtre de test, et la position de
    // défilement change d'une question à l'autre : agrandir la fenêtre
    // plutôt que de gérer le défilement, comme pour les autres écrans denses.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpApp(tester);
    await _tapTab(tester, 'Entraînement');

    expect(find.textContaining('essentiellement des cas cliniques'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, quizRenal.title));
    await tester.pumpAndSettle();

    final quizScreen = find.byType(QuizModuleScreen);
    expect(quizScreen, findsOneWidget);
    expect(find.descendant(of: quizScreen, matching: find.textContaining('Auto-évaluation pédagogique')),
        findsOneWidget);

    final sessionLength =
        quizRenal.poolSize < kQuizSessionSize ? quizRenal.poolSize : kQuizSessionSize;
    final byPrompt = {for (final q in quizRenal.questions) q.prompt: q};

    for (var i = 0; i < sessionLength; i++) {
      final promptTexts = tester
          .widgetList<Text>(find.descendant(of: quizScreen, matching: find.byType(Text)))
          .map((t) => t.data)
          .whereType<String>()
          .where(byPrompt.containsKey);
      expect(promptTexts, hasLength(1), reason: 'question ${i + 1}/$sessionLength introuvable');
      final question = byPrompt[promptTexts.first]!;

      final options = find.descendant(of: quizScreen, matching: find.byType(RadioListTile<int>));
      expect(options, findsNWidgets(4), reason: 'options de ${question.id}');
      await tester.tap(options.at(question.correctIndex));
      await tester.pump();

      final actionButton = find.descendant(of: quizScreen, matching: find.byType(FilledButton));
      await tester.tap(actionButton);
      await tester.pumpAndSettle();
      expect(find.descendant(of: quizScreen, matching: find.text('Correct.')), findsOneWidget,
          reason: 'correction de ${question.id}');

      await tester.tap(find.descendant(of: quizScreen, matching: find.byType(FilledButton)));
      await tester.pumpAndSettle();
    }

    // Score final : toutes les réponses étaient correctes.
    expect(find.text('$sessionLength / $sessionLength'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, "Retour à l'entraînement"));
    await tester.pumpAndSettle();

    // Le score revient sur l'écran Entraînement sous forme de badge.
    expect(find.text('$sessionLength/$sessionLength'), findsOneWidget);
  });
}
