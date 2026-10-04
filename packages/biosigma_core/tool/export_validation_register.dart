// Écrit le registre de validation vierge (CSV) à remplir par le validateur.
// Usage : dart run tool/export_validation_register.dart ../../docs/biosigma-lab/registre-validation.csv
import 'dart:io';

import 'package:biosigma_core/biosigma_core.dart';

void main(List<String> args) {
  final path = args.isEmpty ? 'registre-validation.csv' : args.first;
  File(path).writeAsStringSync(exportValidationRegisterCsv());
  final n = validationKnownVersions().length;
  stdout.writeln('Registre écrit : $path ($n éléments, colonne « decision » vide : rien n\'est validé).');
}
