// P2-06 (sperme, OMS 6e éd.) et P2-08 (McFarland) : écrans.
import 'package:biosigma/screens/lab/count_screen.dart';
import 'package:biosigma/screens/lab/microbiology_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(800, 4500);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Count : sperme (OMS)', () {
    Future<void> open(WidgetTester tester) async {
      await _pump(tester, const CountScreen());
      await tester.tap(find.text('Sperme (OMS)'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      '1 : 20, 1 grille, 210 et 198, volume 3 mL → 40,8 ×10⁶/mL, total 122',
      (tester) async {
        await open(tester);
        final f = find.byType(TextFormField);
        await tester.enterText(f.at(0), '210');
        await tester.enterText(f.at(1), '198');
        await tester.enterText(f.at(2), '3');
        await tester.tap(find.text('Calculer'));
        await tester.pumpAndSettle();
        expect(find.text('Résultat'), findsOneWidget);
        expect(find.text('40,80'), findsOneWidget);
        expect(find.text('122'), findsOneWidget);
        expect(find.textContaining('Couple 1'), findsWidgets);
        expect(find.textContaining('accepté'), findsWidgets);
      },
    );

    testWidgets(
      'écart trop grand : pas de concentration, consigne de recompter, ajout d\'un deuxième comptage',
      (tester) async {
        await open(tester);
        final f = find.byType(TextFormField);
        await tester.enterText(f.at(0), '120');
        await tester.enterText(f.at(1), '60');
        await tester.tap(find.text('Calculer'));
        await tester.pumpAndSettle();
        expect(find.textContaining('nouvelle chambre'), findsWidgets);
        expect(find.text('40,80'), findsNothing);
        await tester.tap(
          find.text('Ajouter un nouveau comptage (écart trop grand)'),
        );
        await tester.pumpAndSettle();
        final g = find.byType(TextFormField);
        await tester.enterText(g.at(2), '100');
        await tester.enterText(g.at(3), '95');
        await tester.tap(find.text('Calculer'));
        await tester.pumpAndSettle();
        expect(find.text('19,50'), findsOneWidget);
      },
    );

    testWidgets(
      'comptage non entier ou absent : refus au champ, aucun résultat',
      (tester) async {
        await open(tester);
        final f = find.byType(TextFormField);
        await tester.enterText(f.at(0), '210,5');
        await tester.enterText(f.at(1), '198');
        await tester.tap(find.text('Calculer'));
        await tester.pumpAndSettle();
        expect(find.textContaining('nombre entier'), findsOneWidget);
        expect(find.text('Résultat'), findsNothing);
      },
    );

    testWidgets(
      'les repères OMS (tableau 8.3) sont consultables avec la mise en garde',
      (tester) async {
        await open(tester);
        await tester.tap(
          find.text('Population de référence de l\'OMS (tableau 8.3)'),
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
            'Concentration en spermatozoïdes : 5e centile 16',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'pas une limite entre hommes fertiles et infertiles',
          ),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'l\'aide de la dilution indique l\'observation à l\'état frais et les volumes',
      (tester) async {
        await open(tester);
        expect(find.textContaining('40–200 par champ ×400'), findsOneWidget);
        expect(
          find.textContaining('50 µL de sperme + 950 µL de fixateur'),
          findsOneWidget,
        );
      },
    );
  });

  group('Microbiology : McFarland', () {
    Future<void> open(WidgetTester tester) async {
      await _pump(tester, const MicrobiologyScreen());
      await tester.tap(find.text('McFarland'));
      await tester.pumpAndSettle();
    }

    testWidgets('0,5 → 1,5 × 10⁸ UFC/mL approximatif, avec la mise en garde', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.text('Calculer'));
      await tester.pumpAndSettle();
      expect(find.text('Résultat'), findsOneWidget);
      expect(find.textContaining('pas un dénombrement'), findsWidgets);
      expect(find.textContaining('150'), findsWidgets);
    });

    testWidgets('autre standard : refusé, aucune extrapolation', (
      tester,
    ) async {
      await open(tester);
      await tester.enterText(find.byType(TextFormField).first, '1');
      await tester.tap(find.text('Calculer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('embarquée ni extrapolée pour 1,0'), findsOneWidget);
      expect(find.text('Résultat'), findsNothing);
    });

    testWidgets('cible 500000 UFC/mL → dilution 300', (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextFormField).at(1), '500000');
      await tester.tap(find.text('Calculer'));
      await tester.pumpAndSettle();
      expect(find.text('300,0'), findsOneWidget);
    });
  });
}
