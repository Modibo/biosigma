@TestOn('browser')
library;

// Contrôles de diagnostic dans un vrai navigateur (--platform chrome).
import 'package:biosigma/services/diagnostic_model.dart';
import 'package:biosigma/services/diagnostic_service_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les contrôles web renvoient navigateur, service worker, stockage et presse-papiers', () async {
    final items = await collectWebDiagnostics();
    String? value(String label) => items.where((i) => i.label.startsWith(label)).map((i) => i.value).firstOrNull;
    expect(value('Navigateur'), isNotEmpty);
    expect(items.any((i) => i.label.startsWith('Service worker')), isTrue);
    expect(items.any((i) => i.label.startsWith('Caches')), isTrue);
    final storage = items.firstWhere((i) => i.label.startsWith('Stockage local'));
    expect(storage.status, DiagnosticStatus.ok, reason: storage.value);
    expect(items.any((i) => i.label == 'Presse-papiers'), isTrue);
    expect(items.any((i) => i.label.startsWith('Préférence')), isTrue);
  });
}
