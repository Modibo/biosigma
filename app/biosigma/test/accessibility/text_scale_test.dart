// Agrandissement du texte jusqu'à 200 % et petits écrans (WCAG 1.4.4, 1.4.10) :
// aucun débordement de mise en page ne doit se produire.
import 'package:biosigma/data/calculator_registry.dart';
import 'package:biosigma/screens/calculator_screen.dart';
import 'package:biosigma/screens/lab/convert_screen.dart';
import 'package:biosigma/screens/lab/count_screen.dart';
import 'package:biosigma/screens/lab/dilute_screen.dart';
import 'package:biosigma/screens/lab/microbiology_screen.dart';
import 'package:biosigma/screens/lab/prepare_screen.dart';
import 'package:biosigma/screens/lab/quality_screen.dart';
import 'package:biosigma/screens/lab/smart_solver_screen.dart';
import 'package:biosigma/screens/lab_screen.dart';
import 'package:biosigma/screens/universal_search_screen.dart';
import 'package:biosigma/screens/settings_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:biosigma/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget screen, {required double scale, required Size size}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: state,
    child: MaterialApp(
      theme: AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: screen,
    ),
  ));
  await tester.pumpAndSettle();
}

final Map<String, Widget Function()> _screens = {
  'Lab (accueil)': () => const DefaultTabController(length: 1, child: Scaffold(body: LabScreen())),
  'Réglages': () => const Scaffold(body: SettingsScreen()),
  'Convert': () => const ConvertScreen(),
  'Dilute': () => const DiluteScreen(),
  'Prepare': () => const PrepareScreen(),
  'Count': () => const CountScreen(),
  'Microbiology': () => const MicrobiologyScreen(),
  'Quality': () => const QualityScreen(),
  'Smart Solver': () => SmartSolverScreen(openModule: (_) {}),
  'recherche': () => const UniversalSearchScreen(),
  'calculateur (QUICKI)': () =>
      CalculatorScreen(definition: allCalculators.firstWhere((d) => d.meta.id == 'quicki')),
};

void main() {
  const cases = <(String, double, Size)>[
    ('téléphone 360 px, texte 200 %', 2.0, Size(360, 740)),
    ('petit écran 320 px, texte 100 %', 1.0, Size(320, 640)),
    ('petit écran 320 px, texte 200 %', 2.0, Size(320, 640)),
  ];
  for (final (label, scale, size) in cases) {
    for (final entry in _screens.entries) {
      testWidgets('${entry.key} — $label', (tester) async {
        await _pump(tester, entry.value(), scale: scale, size: size);
        expect(tester.takeException(), isNull, reason: 'débordement ou erreur de mise en page');
      });
    }
  }
}
