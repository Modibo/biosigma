// P1-16 : la liste des messages sépare alertes, précisions analytiques,
// repères d'interprétation et recommandations publiées.
import 'package:biosigma/widgets/warning_list.dart';
import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _show(WidgetTester tester, List<CalculationWarning> w) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: WarningList(warnings: w)),
      ),
    ),
  );
}

CalculationWarning _i(String m) =>
    CalculationWarning(m, severity: WarningSeverity.info);

void main() {
  testWidgets(
    'les quatre blocs apparaissent dans l\'ordre, chacun avec son message',
    (tester) async {
      await _show(tester, [
        _i('Anticoagulation orale recommandée (recommandation de classe I).'),
        _i('Stade KDIGO G2 : DFG légèrement diminué.'),
        _i('Aucun intervalle de référence n\'est comparé.'),
        const CalculationWarning(
          'Triglycérides trop élevés.',
          severity: WarningSeverity.blocking,
        ),
      ]);
      final titles = [
        'Alertes',
        'Précisions analytiques et limites',
        'Informations et repères d\'interprétation',
        'Recommandations publiées (aide à la décision)',
      ];
      final ys = [for (final t in titles) tester.getTopLeft(find.text(t)).dy];
      expect([...ys]..sort(), ys, reason: 'ordre des blocs');
      expect(find.textContaining('ne formule aucune décision'), findsOneWidget);
      expect(
        find.textContaining('Aucun intervalle de référence'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'un seul niveau présent : seuls son titre et ses messages s\'affichent',
    (tester) async {
      await _show(tester, [_i('Stade KDIGO G1 : DFG normal.')]);
      expect(
        find.text('Informations et repères d\'interprétation'),
        findsOneWidget,
      );
      expect(find.text('Alertes'), findsNothing);
      expect(
        find.text('Recommandations publiées (aide à la décision)'),
        findsNothing,
      );
      expect(find.text('Précisions analytiques et limites'), findsNothing);
    },
  );
}
