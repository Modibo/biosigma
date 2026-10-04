import '../lab/analyte_base.dart';
import 'equation_registry.dart';
import 'validation.dart';

/// Éléments validables et leur version courante : équations (identifiant
/// stable) et analytes (`analyte:<id>`).
Map<String, int> validationKnownVersions() => {
      for (final r in EquationRegistry.all) r.stableId: r.version,
      for (final a in AnalyteBase.all) 'analyte:${a.id}': 1,
    };

/// Dossiers de validation déjà préparés (brouillons non signés).
const Map<String, String> preparedDossiers = {
  'RENAL_CKD_EPI_CREATININE_2021_001': 'fiches-de-validation/FV-PREP-001-ckd-epi-creatinine-2021.md',
  'analyte:glucose': 'fiches-de-validation/FV-PREP-002-conversion-glucose.md',
};

const Map<String, String> _equationFlags = {
  'apri': 'Référence à reconfirmer (R-08 : citée sans lecture du texte source)',
  'padua_prediction_score': 'Référence à reconfirmer (R-08)',
  'has_bled_score': 'Référence à reconfirmer (R-08)',
  'cha2ds2_vasc_score': 'Référence à reconfirmer (R-08)',
  'red_cell_indices': 'Citation primaire des définitions à compléter',
  'absolute_leukocyte_counts': 'Citation primaire des définitions à compléter',
  'lab_quality': 'Citations Sigma / erreur totale à compléter ; ETa et k saisis par l\'utilisateur',
  'lab_prepare_buffer': 'Citation Henderson-Hasselbalch à vérifier',
};

String _csv(String s) => '"${s.replaceAll('"', '""').replaceAll('\n', ' ')}"';

/// Registre de validation vierge, à remplir par le validateur : une ligne par
/// élément. Les colonnes `validator`, `reviewer`, `approver` sont préremplies
/// avec les rôles désignés ; **tant que `decision` est vide, la ligne ne
/// valide rien**. Séparateur « ; » (ouverture directe dans un tableur
/// français).
String exportValidationRegisterCsv({
  String validator = 'Dr Modibo Mouctar Coulibaly',
  List<ValidationRecord>? existing,
}) {
  const header = [
    'item_id', 'type', 'name', 'item_version', 'current_status', 'source_cited', 'points_to_review',
    'prepared_dossier', 'validator', 'reviewer', 'approver', 'date', 'scope', 'sources_reviewed',
    'independent_cases', 'sheet_ref', 'decision', 'comments',
  ];
  final b = StringBuffer()..writeln(header.join(';'));

  void row(List<String> f) => b.writeln(f.map(_csv).join(';'));

  for (final r in EquationRegistry.all) {
    final flags = <String>[
      if (_equationFlags[r.legacyId] != null) _equationFlags[r.legacyId]!,
      if (!r.fromCatalog && !_equationFlags.containsKey(r.legacyId))
        'Relation de définition : aucune norme citée, à relire',
      if (r.meta.limitations.isNotEmpty) 'Limites d\'emploi affichées à relire',
    ];
    row([
      r.stableId,
      r.fromCatalog ? 'équation' : 'outil Lab',
      r.name,
      '${r.version}',
      validationStatusFor(r.stableId, r.version, records: existing ?? validationRecords).label,
      r.meta.sources.isEmpty ? '' : r.meta.sources.first.citation,
      flags.join(' ; '),
      preparedDossiers[r.stableId] ?? '',
      validator, validator, validator, '', '', '', '', '', '', '',
    ]);
  }
  for (final a in AnalyteBase.all) {
    final id = 'analyte:${a.id}';
    final flags = <String>[
      switch (a.kind) {
        AnalyteKind.molecular => 'Forme chimique${a.valence != null ? ' et valence' : ''} à relire',
        AnalyteKind.massOnly => 'Conversions massiques seulement : unités à relire',
        AnalyteKind.legacy => 'Facteur du moteur existant (arrondi) : à relire',
        _ => 'Unités et définitions à relire',
      },
      if (a.note != null) a.note!,
    ];
    row([
      id,
      'analyte (${a.category})',
      a.name,
      '1',
      validationStatusFor(id, 1, records: existing ?? validationRecords).label,
      a.kind == AnalyteKind.molecular
          ? 'Poids atomiques IUPAC/CIAAW abrégés ; formule ${a.formulaText} contrôlée contre PubChem/NCI'
          : 'Définitions des unités (BIPM)',
      flags.join(' ; '),
      preparedDossiers[id] ?? '',
      validator, validator, validator, '', '', '', '', '', '', '',
    ]);
  }
  return b.toString();
}
