// Diagnostic de l'appareil (P6-03).
import 'package:biosigma/app_version.dart';
import 'package:biosigma/screens/about_screen.dart';
import 'package:biosigma/screens/diagnostic_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/services/diagnostic_model.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Widget screen, [Map<String, Object> initial = const {}]) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(initial);
  final state = AppState(await AppStorageService.create());
  await tester.pumpWidget(ChangeNotifierProvider.value(value: state, child: MaterialApp(home: screen)));
  await tester.pumpAndSettle();
}

void main() {
  test('rapport texte : version, date et un contrôle par ligne avec son statut', () {
    final text = diagnosticReportText('9.9.9', DateTime.utc(2026, 10, 4, 12), const [
      DiagnosticItem('Service worker', 'actif', DiagnosticStatus.ok),
      DiagnosticItem('Stockage', 'indisponible', DiagnosticStatus.fail),
    ]);
    expect(text, contains('Diagnostic BioSigma 9.9.9 — 2026-10-04T12:00:00.000Z'));
    expect(text, contains('[OK] Service worker : actif'));
    expect(text, contains('[ÉCHEC] Stockage : indisponible'));
  });

  testWidgets('l\'écran affiche la version, l\'écran, l\'historique et le contrôle de plateforme', (tester) async {
    await _pump(tester, const DiagnosticScreen());
    expect(find.text('Version de BioSigma'), findsOneWidget);
    expect(find.text(kAppVersion), findsOneWidget);
    expect(find.text('Historique enregistré'), findsOneWidget);
    expect(find.text('0 entrée(s)'), findsOneWidget);
    expect(find.text('Environnement'), findsOneWidget); // plateforme non web
    expect(find.textContaining('n\'est jamais envoyé'), findsOneWidget);
  });

  testWidgets('données illisibles mises de côté : signalé', (tester) async {
    SharedPreferences.setMockInitialValues({'biosigma.history.v1': '{cassé'});
    final storage = await AppStorageService.create();
    storage.loadHistory(); // déclenche la quarantaine
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    final state = AppState(storage);
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ChangeNotifierProvider.value(value: state, child: const MaterialApp(home: DiagnosticScreen())));
    await tester.pumpAndSettle();
    expect(find.textContaining('oui (voir la documentation)'), findsOneWidget);
  });

  testWidgets('copier le rapport : le texte copié contient les contrôles', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await _pump(tester, const DiagnosticScreen());
    await tester.tap(find.text('Copier le rapport de diagnostic'));
    await tester.pumpAndSettle();
    expect(copied, contains('Diagnostic BioSigma $kAppVersion'));
    expect(copied, contains('[INFO] Version de BioSigma : $kAppVersion'));
    expect(find.text('Rapport copié dans le presse-papiers.'), findsOneWidget);
  });

  testWidgets('À propos : le bouton ouvre le diagnostic', (tester) async {
    await _pump(tester, const Scaffold(body: AboutScreen()));
    await tester.ensureVisible(find.text('Diagnostic de l\'appareil'));
    await tester.tap(find.text('Diagnostic de l\'appareil'));
    await tester.pumpAndSettle();
    expect(find.byType(DiagnosticScreen), findsOneWidget);
  });
}
