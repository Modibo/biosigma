// Importe un registre de validation rempli (CSV) vers validation_data.dart.
//
// Usage : dart run tool/import_validations.dart ../../docs/biosigma-lab/registre-validation.csv
//
// - Seules les lignes avec une décision ET complètes sont importées.
// - Toute ligne refusée est listée avec sa raison ; le code de sortie est 1.
// - Avec --partial, les lignes valides sont tout de même écrites (les refusées restent à corriger).
// - Sans --partial, RIEN n'est écrit s'il y a au moins un problème.
import 'dart:io';

import 'package:biosigma_core/biosigma_core.dart';

void main(List<String> args) {
  final partial = args.contains('--partial');
  final paths = args.where((a) => !a.startsWith('--')).toList();
  if (paths.isEmpty) {
    stderr.writeln('Usage : dart run tool/import_validations.dart <registre.csv> [--partial]');
    exit(2);
  }
  final csv = File(paths.first).readAsStringSync();
  final result = importValidationCsv(csv, knownVersions: validationKnownVersions());

  stdout.writeln('Fiches complètes : ${result.records.length}');
  stdout.writeln('Lignes sans décision (non validées) : ${result.skippedBlank}');
  stdout.writeln('Lignes refusées : ${result.problems.length}');
  for (final p in result.problems) {
    stdout.writeln('  ✗ $p');
  }
  if (result.problems.isNotEmpty && !partial) {
    stderr.writeln('Aucun fichier écrit (corriger le registre, ou utiliser --partial).');
    exit(1);
  }
  File('lib/src/registry/validation_data.dart').writeAsStringSync(generateValidationDart(result.records));
  stdout.writeln('validation_data.dart écrit : ${result.records.length} fiche(s).');
  if (result.problems.isNotEmpty) exit(1);
}
