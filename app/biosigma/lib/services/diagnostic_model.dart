/// Résultat d'un contrôle de diagnostic.
enum DiagnosticStatus {
  ok('OK'),
  warning('À VÉRIFIER'),
  fail('ÉCHEC'),
  info('INFO');

  const DiagnosticStatus(this.label);
  final String label;
}

class DiagnosticItem {
  const DiagnosticItem(this.label, this.value, this.status);
  final String label;
  final String value;
  final DiagnosticStatus status;
}

/// Rapport texte copiable (aucune donnée de calcul ni de patient : seulement
/// l'état de l'appareil et du navigateur).
String diagnosticReportText(String appVersion, DateTime now, List<DiagnosticItem> items) {
  final b = StringBuffer()
    ..writeln('Diagnostic BioSigma $appVersion — ${now.toIso8601String()}')
    ..writeln();
  for (final i in items) {
    b.writeln('[${i.status.label}] ${i.label} : ${i.value}');
  }
  return b.toString();
}
