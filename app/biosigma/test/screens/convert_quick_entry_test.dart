// P5-01 / T-SAI-002 : saisie rapide « valeur unité en unité » sur l'écran Convert.
import 'package:biosigma/screens/lab/convert_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 3500);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: state,
      child: const MaterialApp(home: ConvertScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _quick(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const ValueKey('quick-entry')), text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    '« 100 mg/dl en g/l » remplit valeur et unités puis convertit : 1 g/L',
    (tester) async {
      await _pump(tester);
      await _quick(tester, '100 mg/dl en g/l');
      expect(find.textContaining('Lu : 100'), findsOneWidget);
      expect(find.textContaining('casse corrigée'), findsWidgets);
      await tester.tap(find.text('Convertir'));
      await tester.pumpAndSettle();
      expect(find.text('Résultat'), findsOneWidget);
      expect(find.textContaining('1,000'), findsWidgets);
    },
  );

  testWidgets(
    'une unité inconnue n\'est pas devinée : message et propositions, rien n\'est converti',
    (tester) async {
      await _pump(tester);
      await _quick(tester, '5 mmoll');
      expect(find.textContaining('non reconnue'), findsOneWidget);
      expect(find.text('mmol/L'), findsWidgets);
      expect(find.text('Vouliez-vous dire :'), findsOneWidget);
      await tester.tap(find.widgetWithText(ActionChip, 'mmol/L'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Lu : 5'), findsOneWidget);
    },
  );

  testWidgets(
    '« 1.5 g/dL » en mode virgule : séparateur ambigu refusé, pas de facteur 10',
    (tester) async {
      await _pump(tester);
      await _quick(tester, '1.5 g/dL');
      expect(find.textContaining('Séparateur ambigu'), findsWidgets);
      expect(find.textContaining('Lu :'), findsNothing);
    },
  );

  testWidgets(
    'deux familles différentes : conversion refusée avec explication',
    (tester) async {
      await _pump(tester);
      await _quick(tester, '10 mg/dL en mmHg');
      expect(
        find.textContaining('n\'appartient pas à la famille'),
        findsOneWidget,
      );
      expect(find.textContaining('Lu :'), findsNothing);
    },
  );

  testWidgets(
    '« G/L » : mise en garde sur la lecture (cellules, pas grammes par litre)',
    (tester) async {
      await _pump(tester);
      await _quick(tester, '5 G/L');
      expect(find.textContaining('écrivez « g/L »'), findsOneWidget);
    },
  );

  testWidgets('sans unité : consigne de saisie', (tester) async {
    await _pump(tester);
    await _quick(tester, '12');
    expect(find.textContaining('suivie de son unité'), findsOneWidget);
  });
}
