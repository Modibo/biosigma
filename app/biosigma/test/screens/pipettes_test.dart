// Pipettes de l'utilisateur (P2-01) : stockage, saisie, contrôle dans Dilute.
import 'package:biosigma/screens/lab/dilute_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:biosigma/widgets/pipette_widgets.dart';
import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _state([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return AppState(await AppStorageService.create());
}

Future<void> _pump(WidgetTester tester, AppState state, Widget screen) async {
  tester.view.physicalSize = const Size(800, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: state, child: MaterialApp(home: Scaffold(body: screen))),
  );
  await tester.pumpAndSettle();
}

Future<void> _dilute(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), '10'); // C1
  await tester.enterText(fields.at(1), '1'); // V1 = 1 mL
  await tester.enterText(fields.at(3), '10'); // V2 = 10 mL → diluant 9 mL
  await tester.tap(find.text('Calculer'));
  await tester.pumpAndSettle();
}

void main() {
  group('stockage', () {
    test('enregistrement, relecture, remplacement par nom, suppression', () async {
      final state = await _state();
      await state.savePipette(const Pipette(name: 'P1000', minUl: 100, maxUl: 1000));
      await state.savePipette(const Pipette(name: 'P1000', minUl: 200, maxUl: 1000)); // remplace
      await state.savePipette(const Pipette(name: 'P200', minUl: 20, maxUl: 200));
      expect(state.pipettes.map((p) => p.name), ['P1000', 'P200']);
      expect(state.pipettes.first.minUl, 200);

      final reopened = AppState(await AppStorageService.create());
      expect(reopened.pipettes.length, 2);

      await reopened.removePipette(reopened.pipettes.first);
      expect(AppState(await AppStorageService.create()).pipettes.map((p) => p.name), ['P200']);
    });

    test('données illisibles : quarantaine ; tout effacer supprime les pipettes', () async {
      SharedPreferences.setMockInitialValues({'biosigma.pipettes.v1': '{cassé'});
      final storage = await AppStorageService.create();
      expect(storage.loadPipettes(), isEmpty);
      await Future<void>.delayed(Duration.zero);
      expect(storage.quarantinedKeys(), ['biosigma.pipettes.v1']);

      final state = await _state();
      await state.savePipette(const Pipette(name: 'x', minUl: 1, maxUl: 2));
      await state.clearAllLocalData();
      expect(state.pipettes, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys().where((k) => k.startsWith('biosigma.')), isEmpty);
    });
  });

  group('Dilute — contrôle de pipetabilité', () {
    testWidgets('sans pipette : invitation à en enregistrer', (tester) async {
      await _pump(tester, await _state(), const DiluteScreen());
      await _dilute(tester);
      expect(find.text('Pipetabilité'), findsOneWidget);
      expect(find.textContaining('Aucune pipette enregistrée'), findsOneWidget);
    });

    testWidgets('avec une P1000 : 1 mL recommandé ; 9 mL non pipetable', (tester) async {
      final state = await _state();
      await state.savePipette(const Pipette(
          name: 'P1000 (test)', minUl: 100, maxUl: 1000, recommendedMinUl: 200));
      await _pump(tester, state, const DiluteScreen());
      await _dilute(tester);
      expect(find.textContaining('P1000 (test) — recommandé'), findsOneWidget);
      expect(find.textContaining('Non pipetable directement'), findsOneWidget);
      expect(find.textContaining('9000 µL'), findsOneWidget);
    });
  });

  group('saisie d\'une pipette', () {
    Future<AppState> open(WidgetTester tester) async {
      final state = await _state();
      await _pump(tester, state, Builder(builder: (context) => TextButton(
            onPressed: () => showAddPipetteDialog(context, state), child: const Text('ouvrir'))));
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();
      return state;
    }

    testWidgets('saisie valide enregistrée', (tester) async {
      final state = await open(tester);
      final f = find.byType(TextField);
      await tester.enterText(f.at(0), 'P200 labo');
      await tester.enterText(f.at(1), '20');
      await tester.enterText(f.at(2), '200');
      await tester.enterText(f.at(3), '40');
      await tester.enterText(f.at(4), '2026-09-01');
      await tester.enterText(f.at(5), '180');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      final p = state.pipettes.single;
      expect(p.name, 'P200 labo');
      expect(p.maxUl, 200);
      expect(p.recommendedMinUl, 40);
      expect(p.verificationValidDays, 180);
    });

    testWidgets('refus : nominal ≤ minimal, date sans durée, nom vide', (tester) async {
      final state = await open(tester);
      final f = find.byType(TextField);
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Donnez un nom'), findsOneWidget);

      await tester.enterText(f.at(0), 'X');
      await tester.enterText(f.at(1), '50');
      await tester.enterText(f.at(2), '10');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('le nominal doit dépasser'), findsOneWidget);

      await tester.enterText(f.at(2), '100');
      await tester.enterText(f.at(4), '2026-09-01');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ensemble la date'), findsOneWidget);
      expect(state.pipettes, isEmpty);
    });
  });
}
