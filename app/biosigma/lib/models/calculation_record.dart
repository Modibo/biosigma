import 'package:biosigma_core/biosigma_core.dart';

import '../app_version.dart';
import 'calculator_definition.dart';
import 'calculator_field.dart';
import 'history_entry.dart';

/// Une valeur de résultat telle qu'enregistrée (valeur brute, non arrondie).
class RecordedResult {
  const RecordedResult({
    required this.label,
    required this.value,
    required this.unit,
    required this.precision,
  });

  final String label;
  final double? value;
  final String unit;
  final int precision;

  Map<String, dynamic> toJson() =>
      {'label': label, 'value': value, 'unit': unit, 'precision': precision};

  factory RecordedResult.fromJson(Map<String, dynamic> json) => RecordedResult(
        label: json['label'] as String,
        value: (json['value'] as num?)?.toDouble(),
        unit: json['unit'] as String,
        precision: json['precision'] as int,
      );
}

/// Enregistrement de calcul v2 (backlog P1-14) : entièrement local et
/// anonyme (aucune identité de patient n'existe dans le moteur), immuable,
/// et **reproductible** — il garde l'équation et sa version, la version de
/// l'application, la règle d'arrondi, les entrées brutes (valeur et unité
/// saisies) et les résultats non arrondis. Un enregistrement n'est jamais
/// recalculé silencieusement : le rejouer est une opération explicite.
class CalculationRecord {
  const CalculationRecord({
    required this.id,
    required this.timestamp,
    required this.equationId,
    required this.equationName,
    this.equationStableId,
    this.equationVersion,
    this.equationVersionLabel,
    this.appVersion,
    this.roundingRule,
    this.rawInputs = const {},
    this.echoedInputs = const {},
    this.results = const [],
    this.warnings = const [],
    this.complete = true,
    this.resultSummary = const [],
    this.legacy = false,
  });

  static const schema = 2;

  final String id;
  final DateTime timestamp;

  /// Identifiant historique de l'équation (valide indéfiniment).
  final String equationId;
  final String equationName;
  final String? equationStableId;
  final int? equationVersion;
  final String? equationVersionLabel;
  final String? appVersion;
  final String? roundingRule;

  /// Entrées brutes rejouables : `{champ: {value, unit}}`, booléen, texte,
  /// ou `{option: libellé}` pour une liste de choix.
  final Map<String, Object?> rawInputs;
  final Map<String, String> echoedInputs;
  final List<RecordedResult> results;
  final List<Map<String, String>> warnings; // {severity, message}
  final bool complete;

  /// Lignes « libellé : valeur unité » prêtes à l'affichage.
  final List<String> resultSummary;

  /// `true` pour un enregistrement converti depuis l'ancien historique v1
  /// (pas de version d'équation ni d'entrées brutes : non rejouable).
  final bool legacy;

  bool get replayable => !legacy && rawInputs.isNotEmpty;

  /// Construit l'enregistrement d'un calcul du catalogue générique.
  factory CalculationRecord.fromCalculation({
    required CalculatorDefinition definition,
    required Map<String, dynamic> values,
    required CalculationResult result,
    required DateTime now,
  }) {
    final meta = definition.meta;
    final registry = EquationRegistry.resolve(meta.id);
    final raw = <String, Object?>{};
    for (final field in definition.fields) {
      final v = values[field.id];
      switch (field.kind) {
        case FieldKind.numberWithUnit:
        case FieldKind.numberFixedUnit:
          final entry = v as NumericEntry;
          raw[field.id] = {'value': entry.value, 'unit': entry.unit};
        case FieldKind.boolean:
          raw[field.id] = v as bool;
        case FieldKind.enumSelect:
          raw[field.id] = {
            'option': v == null
                ? null
                : field.enumOptions!.firstWhere((o) => o.value == v).label,
          };
        case FieldKind.text:
          raw[field.id] = v as String;
      }
    }
    return CalculationRecord(
      id: now.microsecondsSinceEpoch.toString(),
      timestamp: now,
      equationId: meta.id,
      equationName: meta.name,
      equationStableId: registry?.stableId,
      equationVersion: registry?.version,
      equationVersionLabel: meta.version,
      appVersion: kAppVersion,
      roundingRule: RoundingPolicy.ruleId,
      rawInputs: raw,
      echoedInputs: result.echoedInputs,
      results: [
        for (final r in result.values)
          RecordedResult(label: r.label, value: r.value, unit: r.unit, precision: r.precision),
      ],
      warnings: [
        for (final w in result.warnings) {'severity': w.severity.name, 'message': w.message},
      ],
      complete: result.isComplete,
      resultSummary: [
        for (final r in result.values)
          '${r.label} : ${r.isComputed ? RoundingPolicy.format(r.value!, r.precision) : "non calculé"} ${r.unit}',
      ],
    );
  }

  /// Conversion d'une entrée de l'ancien historique v1 : rien n'est inventé
  /// (ni version d'équation, ni entrées brutes), l'enregistrement est marqué `legacy`.
  factory CalculationRecord.fromLegacy(HistoryEntry entry) => CalculationRecord(
        id: entry.id,
        timestamp: entry.timestamp,
        equationId: entry.calculatorId,
        equationName: entry.calculatorName,
        equationStableId: EquationRegistry.stableIdFor(entry.calculatorId),
        echoedInputs: entry.echoedInputs,
        resultSummary: entry.resultSummary,
        legacy: true,
      );

  Map<String, dynamic> toJson() => {
        'schema': schema,
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'equationId': equationId,
        'equationName': equationName,
        'equationStableId': equationStableId,
        'equationVersion': equationVersion,
        'equationVersionLabel': equationVersionLabel,
        'appVersion': appVersion,
        'roundingRule': roundingRule,
        'rawInputs': rawInputs,
        'echoedInputs': echoedInputs,
        'results': results.map((r) => r.toJson()).toList(),
        'warnings': warnings,
        'complete': complete,
        'resultSummary': resultSummary,
        'legacy': legacy,
      };

  factory CalculationRecord.fromJson(Map<String, dynamic> json) {
    if (json['schema'] != schema) {
      throw FormatException('Schéma d\'enregistrement inattendu : ${json['schema']}');
    }
    return CalculationRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      equationId: json['equationId'] as String,
      equationName: json['equationName'] as String,
      equationStableId: json['equationStableId'] as String?,
      equationVersion: json['equationVersion'] as int?,
      equationVersionLabel: json['equationVersionLabel'] as String?,
      appVersion: json['appVersion'] as String?,
      roundingRule: json['roundingRule'] as String?,
      rawInputs: Map<String, Object?>.from(json['rawInputs'] as Map),
      echoedInputs: Map<String, String>.from(json['echoedInputs'] as Map),
      results: [
        for (final r in json['results'] as List) RecordedResult.fromJson(Map<String, dynamic>.from(r as Map)),
      ],
      warnings: [
        for (final w in json['warnings'] as List) Map<String, String>.from(w as Map),
      ],
      complete: json['complete'] as bool,
      resultSummary: List<String>.from(json['resultSummary'] as List),
      legacy: json['legacy'] as bool,
    );
  }
}
