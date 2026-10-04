import 'validation.dart';

/// Résultat de la lecture d'un registre de validation (CSV).
class ValidationImportResult {
  const ValidationImportResult({
    required this.records,
    required this.problems,
    required this.skippedBlank,
  });

  /// Fiches complètes et cohérentes, prêtes à être enregistrées.
  final List<ValidationRecord> records;

  /// Lignes refusées, avec la raison (« ligne 12 (METAB_BMI_001) : … »).
  final List<String> problems;

  /// Lignes sans décision : non validées, sans que ce soit une erreur.
  final int skippedBlank;
}

/// Découpe un CSV (séparateur « ; » ou « , » détecté sur l'en-tête, champs
/// entre guillemets, guillemets doublés, fins de ligne CRLF ou LF).
List<List<String>> parseCsv(String text) {
  final firstLine = text.split(RegExp(r'\r?\n')).first;
  final sep = ';'.allMatches(firstLine).length > ','.allMatches(firstLine).length ? ';' : ',';
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"') {
      inQuotes = true;
    } else if (c == sep) {
      row.add(field.toString());
      field.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(field.toString());
      field.clear();
      if (row.any((f) => f.trim().isNotEmpty)) rows.add(row);
      row = <String>[];
    } else {
      field.write(c);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    if (row.any((f) => f.trim().isNotEmpty)) rows.add(row);
  }
  return rows;
}

DateTime? _parseDate(String s) {
  final t = s.trim();
  final iso = DateTime.tryParse(t);
  if (iso != null) return DateTime.utc(iso.year, iso.month, iso.day);
  final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(t);
  if (m == null) return null;
  final d = int.parse(m[1]!), mo = int.parse(m[2]!), y = int.parse(m[3]!);
  if (mo < 1 || mo > 12 || d < 1 || d > 31) return null;
  final date = DateTime.utc(y, mo, d);
  return date.month == mo && date.day == d ? date : null;
}

ValidationDecision? _parseDecision(String s) {
  switch (s.trim().toLowerCase()) {
    case 'approved':
    case 'approuvé':
    case 'approuve':
    case 'oui':
    case 'validé':
    case 'valide':
      return ValidationDecision.approved;
    case 'rejected':
    case 'rejeté':
    case 'rejete':
    case 'non':
      return ValidationDecision.rejected;
  }
  return null;
}

/// Lit un registre de validation rempli par le validateur.
///
/// Règles (gouvernance D-12) : une ligne **sans décision** n'est pas une
/// validation (ignorée) ; une ligne **avec décision** doit être complète
/// (référence de fiche, date valide, validateur, relecteur, approbateur,
/// périmètre, sources consultées, ≥ 2 cas indépendants) ; l'identifiant doit
/// exister dans [knownVersions] (id → version courante) et la version
/// indiquée doit être la version courante ; un même élément ne peut pas
/// apparaître deux fois avec une décision. Une ligne refusée n'entraîne
/// jamais l'enregistrement partiel de ses champs.
ValidationImportResult importValidationCsv(String csv, {required Map<String, int> knownVersions}) {
  final rows = parseCsv(csv);
  if (rows.isEmpty) {
    return const ValidationImportResult(records: [], problems: ['Fichier vide.'], skippedBlank: 0);
  }
  final header = [for (final h in rows.first) h.trim().toLowerCase()];
  int col(String name) => header.indexOf(name);
  const required = [
    'item_id', 'item_version', 'validator', 'reviewer', 'approver', 'date', 'scope',
    'sources_reviewed', 'independent_cases', 'sheet_ref', 'decision',
  ];
  final missingCols = [for (final r in required) if (col(r) < 0) r];
  if (missingCols.isNotEmpty) {
    return ValidationImportResult(
        records: const [], problems: ['Colonnes absentes : ${missingCols.join(', ')}.'], skippedBlank: 0);
  }

  final records = <ValidationRecord>[];
  final problems = <String>[];
  final seen = <String>{};
  var blank = 0;
  for (var i = 1; i < rows.length; i++) {
    final r = rows[i];
    String get(String name) {
      final c = col(name);
      return c < r.length ? r[c].trim() : '';
    }

    final id = get('item_id');
    final where = 'ligne ${i + 1} (${id.isEmpty ? '?' : id})';
    final decisionText = get('decision');
    if (decisionText.isEmpty) {
      blank++;
      continue;
    }
    final decision = _parseDecision(decisionText);
    final rowProblems = <String>[];
    if (decision == null) rowProblems.add('décision « $decisionText » non reconnue (approuvé / rejeté)');
    if (id.isEmpty) rowProblems.add('identifiant absent');
    final version = int.tryParse(get('item_version'));
    if (!knownVersions.containsKey(id)) {
      rowProblems.add('identifiant inconnu');
    } else if (version == null) {
      rowProblems.add('version illisible');
    } else if (version != knownVersions[id]) {
      rowProblems.add('version $version ≠ version courante ${knownVersions[id]} (une fiche ne couvre que sa version)');
    }
    for (final f in ['validator', 'reviewer', 'approver', 'scope', 'sources_reviewed', 'sheet_ref']) {
      if (get(f).isEmpty) rowProblems.add('champ « $f » manquant');
    }
    final date = _parseDate(get('date'));
    if (date == null) rowProblems.add('date illisible (JJ/MM/AAAA ou AAAA-MM-JJ)');
    final cases = int.tryParse(get('independent_cases'));
    if (cases == null || cases < 2) rowProblems.add('au moins 2 cas indépendants requis (indiqué : ${get('independent_cases').isEmpty ? 'rien' : get('independent_cases')})');
    if (!seen.add(id)) rowProblems.add('élément déjà présent plus haut avec une décision');

    if (rowProblems.isNotEmpty) {
      problems.add('$where : ${rowProblems.join(' ; ')}.');
      continue;
    }
    records.add(ValidationRecord(
      itemId: id,
      itemVersion: version!,
      validatorName: get('validator'),
      validatorRole: 'Validateur scientifique',
      validatedOn: date!,
      scope: get('scope'),
      sourcesReviewed: get('sources_reviewed'),
      independentCases: cases!,
      sheetReference: get('sheet_ref'),
      technicalReviewerName: get('reviewer'),
      approverName: get('approver'),
      decision: decision!,
    ));
  }
  return ValidationImportResult(records: records, problems: problems, skippedBlank: blank);
}

String _dartString(String s) => "'${s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll('\n', ' ')}'";

/// Source Dart du fichier `validation_data.dart` pour [records].
String generateValidationDart(List<ValidationRecord> records) {
  final b = StringBuffer()
    ..writeln('// FICHIER GÉNÉRÉ par tool/import_validations.dart — ne pas modifier à la main.')
    ..writeln('// Source : registre de validation rempli et signé par le validateur scientifique.')
    ..writeln("import 'validation.dart';")
    ..writeln()
    ..writeln('final List<ValidationRecord> generatedValidationRecords = [');
  for (final r in records) {
    b
      ..writeln('  ValidationRecord(')
      ..writeln('    itemId: ${_dartString(r.itemId)},')
      ..writeln('    itemVersion: ${r.itemVersion},')
      ..writeln('    validatorName: ${_dartString(r.validatorName)},')
      ..writeln('    validatorRole: ${_dartString(r.validatorRole)},')
      ..writeln('    validatedOn: DateTime.utc(${r.validatedOn.year}, ${r.validatedOn.month}, ${r.validatedOn.day}),')
      ..writeln('    scope: ${_dartString(r.scope)},')
      ..writeln('    sourcesReviewed: ${_dartString(r.sourcesReviewed)},')
      ..writeln('    independentCases: ${r.independentCases},')
      ..writeln('    sheetReference: ${_dartString(r.sheetReference)},')
      ..writeln('    technicalReviewerName: ${_dartString(r.technicalReviewerName)},')
      ..writeln('    approverName: ${_dartString(r.approverName)},')
      ..writeln('    decision: ValidationDecision.${r.decision.name},')
      ..writeln('  ),');
  }
  b.writeln('];');
  return b.toString();
}
