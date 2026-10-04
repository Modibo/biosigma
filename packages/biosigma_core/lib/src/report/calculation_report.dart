import '../models/result.dart';
import '../registry/equation_registry.dart';
import '../rounding.dart';

/// Section libre ajoutée à un rapport (ex. étapes d'un plan de dilution).
class ReportSection {
  const ReportSection(this.title, this.lines);
  final String title;
  final List<String> lines;
}

/// Rapport imprimable / exportable d'un calcul (backlog P3-05, décision D-11 :
/// impression par le navigateur, aucune dépendance PDF).
///
/// Le rapport rassemble ce qui permet de **reproduire et de juger** le calcul :
/// équation et version, statut de validation, entrées, résultats (non
/// arrondis à l'excès : arrondi unique à l'affichage), avertissements séparés
/// en alertes et repères, sources, limites. Il **ne contient jamais
/// d'identité de patient** : seule une référence libre facultative, saisie
/// par l'utilisateur, peut y figurer.
class CalculationReport {
  const CalculationReport({
    required this.result,
    required this.generatedAt,
    required this.appVersion,
    this.decimalComma = true,
    this.reference,
    this.extraSections = const [],
  });

  final CalculationResult result;

  /// Date et heure d'édition (déjà formatées).
  final String generatedAt;
  final String appVersion;

  /// Virgule décimale (convention française) ou point.
  final bool decimalComma;

  /// Référence libre facultative (ex. numéro d'échantillon anonyme).
  final String? reference;
  final List<ReportSection> extraSections;

  static const String disclaimer =
      'Outil d\'aide au calcul : résultat à confronter aux données analytiques et cliniques, '
      'et à valider par un professionnel compétent. Ce document ne constitue pas un compte rendu '
      'd\'analyse et ne contient aucune identité de patient.';

  String _number(double v, int precision) {
    final text = RoundingPolicy.format(v, precision);
    return decimalComma ? text.replaceAll('.', ',') : text;
  }

  String _valueLine(ResultValue v) {
    final unit = v.unit.isEmpty ? '' : ' ${v.unit}';
    return '${v.label} : ${v.isComputed ? _number(v.value!, v.precision) : 'non calculé'}$unit';
  }

  EquationRecord? get _record => EquationRegistry.resolve(result.formula.id);

  List<CalculationWarning> get _alerts =>
      result.warnings.where((w) => w.severity != WarningSeverity.info).toList(growable: false);
  List<CalculationWarning> get _infos =>
      result.warnings.where((w) => w.severity == WarningSeverity.info).toList(growable: false);

  String get _statusLine {
    final r = _record;
    if (r == null) return 'Statut de validation : non enregistré au registre';
    return 'Identifiant : ${r.stableId} · version ${r.version} · statut de validation : ${r.status.label}';
  }

  /// Version texte brut.
  String toPlainText() {
    final f = result.formula;
    final b = StringBuffer()
      ..writeln('BioSigma — ${f.name}')
      ..writeln('Édité le $generatedAt · application $appVersion')
      ..writeln(_statusLine);
    if (reference != null && reference!.trim().isNotEmpty) {
      b.writeln('Référence : ${reference!.trim()}');
    }
    for (final note in _record?.changeNotes ?? const <String>[]) {
      b.writeln('Historique : $note');
    }
    b
      ..writeln()
      ..writeln('Version de l\'équation : ${f.version}')
      ..writeln('Formule : ${f.equation}')
      ..writeln()
      ..writeln('DONNÉES UTILISÉES');
    result.echoedInputs.forEach((k, v) => b.writeln('  $k : $v'));
    b
      ..writeln()
      ..writeln(result.isComplete ? 'RÉSULTATS' : 'RÉSULTATS (calcul incomplet)');
    for (final v in result.values) {
      b.writeln('  ${_valueLine(v)}');
    }
    if (_alerts.isNotEmpty) {
      b
        ..writeln()
        ..writeln('ALERTES');
      for (final w in _alerts) {
        b.writeln('  [${w.severity == WarningSeverity.blocking ? 'BLOQUANT' : 'ATTENTION'}] ${w.message}');
      }
    }
    if (_infos.isNotEmpty) {
      b
        ..writeln()
        ..writeln('INFORMATIONS ET REPÈRES D\'INTERPRÉTATION (généraux, non validés localement)');
      for (final w in _infos) {
        b.writeln('  - ${w.message}');
      }
    }
    for (final s in extraSections) {
      b
        ..writeln()
        ..writeln(s.title.toUpperCase());
      for (final l in s.lines) {
        b.writeln('  $l');
      }
    }
    b
      ..writeln()
      ..writeln('SOURCES');
    for (final s in f.sources) {
      b.writeln('  - $s');
    }
    final limits = [...f.forbiddenConditions.map((x) => 'Cas interdit : $x'), ...f.analyticalConditions.map((x) => 'Condition analytique : $x'), ...f.limitations];
    if (limits.isNotEmpty) {
      b
        ..writeln()
        ..writeln('LIMITES D\'EMPLOI');
      for (final l in limits) {
        b.writeln('  - $l');
      }
    }
    b
      ..writeln()
      ..writeln(disclaimer);
    return b.toString();
  }

  /// Échappe le texte pour l'insérer dans du HTML (aucun contenu saisi n'est interprété).
  static String escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  /// Document HTML autonome, mis en page pour l'impression (A4).
  String toHtml() {
    final f = result.formula;
    String e(String s) => escapeHtml(s);
    final b = StringBuffer()
      ..writeln('<!doctype html>')
      ..writeln('<html lang="fr"><head><meta charset="utf-8">')
      ..writeln('<title>${e('BioSigma — ${f.name}')}</title>')
      ..writeln('<style>')
      ..writeln('@page{size:A4;margin:16mm}')
      ..writeln('body{font-family:Arial,Helvetica,sans-serif;font-size:11pt;color:#111;line-height:1.35}')
      ..writeln('h1{font-size:16pt;margin:0 0 4px}h2{font-size:12pt;margin:16px 0 4px;border-bottom:1px solid #999}')
      ..writeln('.meta{color:#444;font-size:9.5pt}table{border-collapse:collapse;width:100%}')
      ..writeln('td{padding:2px 6px;vertical-align:top;border-bottom:1px solid #ddd}td.k{width:38%;color:#333}')
      ..writeln('.v{font-weight:bold}.alert{border-left:4px solid #b00020;padding:2px 8px;margin:4px 0}')
      ..writeln('.caution{border-left-color:#b26a00}.info{color:#333;margin:3px 0}.small{font-size:9pt;color:#444}')
      ..writeln('.disclaimer{margin-top:18px;padding:8px;border:1px solid #999;font-size:9.5pt}')
      ..writeln('</style></head><body>')
      ..writeln('<h1>${e(f.name)}</h1>')
      ..writeln('<div class="meta">Édité le ${e(generatedAt)} · BioSigma ${e(appVersion)}<br>${e(_statusLine)}');
    for (final note in _record?.changeNotes ?? const <String>[]) {
      b.writeln('<br>${e('Historique : $note')}');
    }
    if (reference != null && reference!.trim().isNotEmpty) {
      b.writeln('<br>Référence : ${e(reference!.trim())}');
    }
    b
      ..writeln('</div>')
      ..writeln('<h2>Équation</h2><div>${e(f.version)}</div><div class="small">${e(f.equation).replaceAll('\n', '<br>')}</div>')
      ..writeln('<h2>Données utilisées</h2><table>');
    result.echoedInputs.forEach((k, v) => b.writeln('<tr><td class="k">${e(k)}</td><td>${e(v)}</td></tr>'));
    b
      ..writeln('</table>')
      ..writeln('<h2>${result.isComplete ? 'Résultats' : 'Résultats (calcul incomplet)'}</h2><table>');
    for (final v in result.values) {
      final unit = v.unit.isEmpty ? '' : ' ${v.unit}';
      b.writeln('<tr><td class="k">${e(v.label)}</td><td class="v">'
          '${v.isComputed ? e('${_number(v.value!, v.precision)}$unit') : 'non calculé'}</td></tr>');
    }
    b.writeln('</table>');
    if (_alerts.isNotEmpty) {
      b.writeln('<h2>Alertes</h2>');
      for (final w in _alerts) {
        b.writeln('<div class="alert ${w.severity == WarningSeverity.caution ? 'caution' : ''}">'
            '<b>${w.severity == WarningSeverity.blocking ? 'Bloquant' : 'Attention'}</b> — ${e(w.message)}</div>');
      }
    }
    if (_infos.isNotEmpty) {
      b.writeln('<h2>Informations et repères d\'interprétation</h2>'
          '<div class="small">Repères généraux, non validés localement : ils ne remplacent ni le contexte clinique ni le jugement du professionnel.</div>');
      for (final w in _infos) {
        b.writeln('<div class="info">• ${e(w.message)}</div>');
      }
    }
    for (final s in extraSections) {
      b.writeln('<h2>${e(s.title)}</h2>');
      for (final l in s.lines) {
        b.writeln('<div>${e(l)}</div>');
      }
    }
    b.writeln('<h2>Sources</h2>');
    for (final s in f.sources) {
      b.writeln('<div class="small">• ${e(s.toString())}</div>');
    }
    final limits = [...f.forbiddenConditions.map((x) => 'Cas interdit : $x'), ...f.analyticalConditions.map((x) => 'Condition analytique : $x'), ...f.limitations];
    if (limits.isNotEmpty) {
      b.writeln('<h2>Limites d\'emploi</h2>');
      for (final l in limits) {
        b.writeln('<div class="small">• ${e(l)}</div>');
      }
    }
    b
      ..writeln('<div class="disclaimer">${e(disclaimer)}</div>')
      ..writeln('</body></html>');
    return b.toString();
  }
}
