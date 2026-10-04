// Plates-formes sans navigateur : pas de contrôles propres au web.
import 'diagnostic_model.dart';

Future<List<DiagnosticItem>> collectWebDiagnostics() async => const [
      DiagnosticItem('Environnement', 'application native (pas de contrôles web)', DiagnosticStatus.info),
    ];
