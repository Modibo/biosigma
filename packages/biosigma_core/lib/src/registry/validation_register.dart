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
final Map<String, String> preparedDossiers = {
  'RENAL_CKD_EPI_CREATININE_2021_001':
      'fiches-de-validation/FV-PREP-001-ckd-epi-creatinine-2021.md',
  'analyte:glucose': 'fiches-de-validation/FV-PREP-002-conversion-glucose.md',
  'IONO_FIB4_001': 'fiches-de-validation/FV-PREP-003-fib-4.md',
  'HEMO_INR_001': 'fiches-de-validation/FV-PREP-004-inr.md',
  'METAB_TYG_INDEX_001': 'fiches-de-validation/FV-PREP-005-tyg.md',
  'METAB_BMI_001': 'fiches-de-validation/FV-PREP-006-imc.md',
  'METAB_HOMA_IR_001': 'fiches-de-validation/FV-PREP-007-homa-ir.md',
  'RENAL_CKD_EPI_CYSTATIN_C_2012_001':
      'fiches-de-validation/FV-PREP-008-ckd-epi-cystatine-2012.md',
  'RENAL_CKD_EPI_CREATININE_CYSTATIN_C_2021_001':
      'fiches-de-validation/FV-PREP-009-ckd-epi-creatinine-cystatine-2021.md',
  'RENAL_SCHWARTZ_BEDSIDE_PEDIATRIC_001':
      'fiches-de-validation/FV-PREP-010-schwartz-bedside.md',
  'IONO_MELD_NA_001': 'fiches-de-validation/FV-PREP-011-meld-na.md',
  'HEMO_CHA2DS2_VASC_SCORE_001':
      'fiches-de-validation/FV-PREP-012-cha2ds2-vasc.md',
  'HEMO_HAS_BLED_SCORE_001': 'fiches-de-validation/FV-PREP-013-has-bled.md',
  'METAB_QUICKI_001': 'fiches-de-validation/FV-PREP-014-quicki.md',
  'METAB_LDL_PANEL_001': 'fiches-de-validation/FV-PREP-017-martin-hopkins.md',
  'LAB_LAB_UNCERTAINTY_001': 'fiches-de-validation/FV-PREP-016-incertitude-gum.md',
  for (final a in const [
    'creatinine',
    'urea',
    'urea_nitrogen',
    'calcium',
    'cholesterol',
    'triglycerides',
    'bilirubin',
    'sodium',
  ])
    'analyte:$a': 'fiches-de-validation/FV-PREP-015-conversions-frequentes.md',
};

const Map<String, String> _equationFlags = {
  'fib4': 'Texte d\'attribution des seuils corrigé le 2026-10-04 (1,30/2,67 « largement repris » ; Sterling 2006 : 1,45/3,25), à relire (voir FV-PREP-003)',
  'tyg_index': 'Exemple de seuil « TyG > 4,5 » retiré le 2026-10-04 (incohérent avec la convention mg/dL), texte à relire (voir FV-PREP-005)',
  'albi_score': 'Coefficient albumine −0,0852 dans le code ; l\'article original donne −0,085 selon ma mémoire (non vérifié) : à confronter à la source primaire',
  'ckd_epi_creatinine_cystatin_c_2021': 'Version 2 (2026-10-04) : coefficients α corrigés ; relire le dossier FV-PREP-009',
  'ldl_panel': 'Version 2 : Martin-Hopkins ajoutée (tableau saisi, non confronté à la source) : relire FV-PREP-017, notamment la cellule 93–96 / ≥ 220 et l\'astérisque de « ≥ 400 »',
  'apri': 'Référence à reconfirmer (R-08 : citée sans lecture du texte source)',
  'padua_prediction_score': 'Référence à reconfirmer (R-08)',
  'has_bled_score': 'Référence à reconfirmer (R-08)',
  'cha2ds2_vasc_score': 'Référence à reconfirmer (R-08)',
  'red_cell_indices': 'Citation primaire des définitions à compléter',
  'absolute_leukocyte_counts': 'Citation primaire des définitions à compléter',
  'lab_uncertainty': 'GUM (JCGM 100:2008) lu le 2026-10-04 (éq. 10, 12, 5, 7 ; §§ 6.2-6.3) : relire le périmètre (premier ordre, grandeurs non corrélées)',
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
    'item_id',
    'type',
    'name',
    'item_version',
    'current_status',
    'source_cited',
    'points_to_review',
    'prepared_dossier',
    'validator',
    'reviewer',
    'approver',
    'date',
    'scope',
    'sources_reviewed',
    'independent_cases',
    'sheet_ref',
    'decision',
    'comments',
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
      validationStatusFor(
        r.stableId,
        r.version,
        records: existing ?? validationRecords,
      ).label,
      r.meta.sources.isEmpty ? '' : r.meta.sources.first.citation,
      flags.join(' ; '),
      preparedDossiers[r.stableId] ?? '',
      validator,
      validator,
      validator,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
  }
  for (final a in AnalyteBase.all) {
    final id = 'analyte:${a.id}';
    final flags = <String>[
      switch (a.kind) {
        AnalyteKind.molecular =>
          'Forme chimique${a.valence != null ? ' et valence' : ''} à relire',
        AnalyteKind.massOnly =>
          'Conversions massiques seulement : unités à relire',
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
      validator,
      validator,
      validator,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);
  }
  return b.toString();
}
