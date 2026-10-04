// Accessibilité automatisée (backlog P6-01, cible de travail WCAG 2.1 AA —
// décision D-15 à confirmer) : zones tactiles, étiquettes sémantiques, contraste
// du texte, sur les écrans principaux en thème clair et sombre.
import 'package:biosigma/app.dart';
import 'package:biosigma/data/calculator_registry.dart';
import 'package:biosigma/screens/calculator_screen.dart';
import 'package:biosigma/screens/lab/convert_screen.dart';
import 'package:biosigma/screens/lab/count_screen.dart';
import 'package:biosigma/screens/lab/dilute_screen.dart';
import 'package:biosigma/screens/lab/microbiology_screen.dart';
import 'package:biosigma/screens/lab/prepare_screen.dart';
import 'package:biosigma/screens/lab/quality_screen.dart';
import 'package:biosigma/screens/lab/smart_solver_screen.dart';
import 'package:biosigma/screens/lab/uncertainty_screen.dart';
import 'package:biosigma/screens/exercises_screen.dart';
import 'package:biosigma/screens/universal_search_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:biosigma/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget screen, {bool dark = false}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: state,
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: screen,
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _check(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}

final Map<String, Widget Function()> _screens = {
  'accueil (onglets)': () => const BioSigmaApp(),
  'recherche universelle': () => const UniversalSearchScreen(),
  'Convert': () => const ConvertScreen(),
  'Dilute': () => const DiluteScreen(),
  'Prepare': () => const PrepareScreen(),
  'Count': () => const CountScreen(),
  'Microbiology': () => const MicrobiologyScreen(),
  'Quality': () => const QualityScreen(),
  'Smart Solver': () => SmartSolverScreen(openModule: (_) {}),
  'Incertitude': () => const UncertaintyScreen(),
  'Exercices de calcul': () => const ExercisesScreen(initialSeed: 1, initialKindId: 'bmi'),
  'calculateur (IMC)': () =>
      CalculatorScreen(definition: allCalculators.firstWhere((d) => d.meta.id == 'bmi')),
};

void main() {
  for (final dark in [false, true]) {
    for (final entry in _screens.entries) {
      testWidgets('${entry.key} — ${dark ? 'thème sombre' : 'thème clair'}', (tester) async {
        // BioSigmaApp a son propre thème : on le pilote par le mode de la plateforme.
        if (entry.key == 'accueil (onglets)') {
          tester.platformDispatcher.platformBrightnessTestValue = dark ? Brightness.dark : Brightness.light;
          addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
          tester.view.physicalSize = const Size(800, 2400);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          SharedPreferences.setMockInitialValues({});
          final state = AppState(await AppStorageService.create());
          await tester.pumpWidget(ChangeNotifierProvider.value(value: state, child: entry.value()));
          await tester.pumpAndSettle();
        } else {
          await _pump(tester, entry.value(), dark: dark);
        }
        await _check(tester);
      });
    }
  }
}
