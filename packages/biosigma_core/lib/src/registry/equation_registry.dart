import '../catalog.dart';
import '../lab/analyte_base.dart' show analyteConvertMeta;
import '../lab/convert.dart';
import '../lab/count.dart';
import '../lab/dilution.dart';
import '../lab/dilution_planner.dart' show dilutionPlannerMeta;
import '../lab/microbiology.dart';
import '../lab/prepare.dart';
import '../lab/quality.dart';
import '../lab/uncertainty.dart';
import '../models/formula_meta.dart';
import 'validation.dart';

/// Statut de validation scientifique d'une équation (schéma E.3 du dossier).
///
/// Il est dérivé des fiches de validation (`validationRecords`) : une
/// équation n'est `validated` que si une fiche complète existe pour sa
/// version courante. Aucune fiche n'existe à ce jour : toutes sont `notValidated`.
enum EquationStatus {
  notValidated('NON VALIDÉ'),
  validated('VALIDÉ'),
  withdrawn('RETIRÉ');

  const EquationStatus(this.label);
  final String label;
}

/// Entrée du registre : identité stable, alias hérité, version, statut.
class EquationRecord {
  const EquationRecord({
    required this.stableId,
    required this.legacyId,
    required this.name,
    required this.family,
    required this.version,
    required this.versionLabel,
    required this.status,
    required this.fromCatalog,
    required this.meta,
    this.changeNotes = const [],
  });

  /// Identifiant stable `FAMILLE_NOM_NNN` : jamais réutilisé, jamais renommé.
  final String stableId;

  /// Identifiant historique (favoris, historique, navigation) : valide indéfiniment.
  final String legacyId;
  final String name;
  final String family;

  /// Numéro de version entier de l'équation : toute modification de formule,
  /// de constante, d'unité ou de domaine l'incrémente.
  final int version;

  /// Notes des changements de version (le plus ancien en premier) ; vide pour
  /// une équation jamais modifiée depuis son entrée au registre.
  final List<String> changeNotes;

  /// Version déclarée dans `FormulaMeta` (texte libre, conservé tel quel).
  final String versionLabel;
  final EquationStatus status;

  /// `true` pour les 59 calculs cliniques du catalogue ; `false` pour les outils Lab.
  final bool fromCatalog;
  final FormulaMeta meta;
}

/// Registre versionné des équations (backlog P1-13).
///
/// Il enveloppe le catalogue et les outils Lab sans les modifier : les 59
/// identifiants historiques restent valides et résolvent vers leur entrée.
class EquationRegistry {
  EquationRegistry._();

  static const Map<CalculatorCategory, String> _family = {
    CalculatorCategory.renal: 'RENAL',
    CalculatorCategory.metabolic: 'METAB',
    CalculatorCategory.ionogram: 'IONO',
    CalculatorCategory.hemostasis: 'HEMO',
    CalculatorCategory.hematology: 'HEMATO',
    CalculatorCategory.laboratory: 'LAB',
  };

  static final List<FormulaMeta> _labMetas = [
    convertMeta,
    analyteConvertMeta,
    dilutionMeta,
    serialDilutionMeta,
    outOfRangeDilutionMeta,
    dilutionPlannerMeta,
    solutionPreparationMeta,
    percentSolutionMeta,
    bufferMeta,
    cellCountMeta,
    totalCountMeta,
    differentialMeta,
    cfuMeta,
    qualityMeta,
    uncertaintyMeta,
  ];

  /// Versions des équations modifiées depuis leur entrée au registre (toute
  /// modification de formule, constante, unité ou domaine crée une version) ;
  /// les autres sont en version 1. Une fiche de validation ne couvre que sa version.
  static const Map<String, (int, List<String>)> _versions = {
    'ldl_panel': (
      2,
      [
        '2026-10-04 — version 2 : ajout de l\'équation LDL de Martin-Hopkins (tableau de 180 facteurs saisi par '
            'le validateur, dossier FV-PREP-017). Friedewald et Sampson sont inchangées (résultats identiques).',
      ],
    ),
    'ckd_epi_creatinine_cystatin_c_2021': (
      2,
      [
        '2026-10-04 — version 2 : correction des coefficients α (−0,219 femme / −0,144 homme au lieu de '
            '−0,241 / −0,302, valeurs de l\'équation à la créatinine seule). La version 1 surestimait le DFG '
            'lorsque la créatininémie était inférieure à κ (jusqu\'à ≈ 10 % pour une créatininémie très basse).',
      ],
    ),
  };

  static EquationRecord _record(FormulaMeta meta, {required bool fromCatalog}) {
    final family = _family[meta.category]!;
    final versionInfo = _versions[meta.id];
    final version = versionInfo?.$1 ?? 1;
    return EquationRecord(
      stableId: '${family}_${meta.id.toUpperCase()}_001',
      legacyId: meta.id,
      name: meta.name,
      family: family,
      version: version,
      changeNotes: versionInfo?.$2 ?? const [],
      versionLabel: meta.version,
      status: validationStatusFor('${family}_${meta.id.toUpperCase()}_001', version),
      fromCatalog: fromCatalog,
      meta: meta,
    );
  }

  /// Toutes les entrées : 59 calculs cliniques puis les outils Lab.
  static final List<EquationRecord> all = List.unmodifiable([
    for (final m in CalculatorCatalog.all) _record(m, fromCatalog: true),
    for (final m in _labMetas) _record(m, fromCatalog: false),
  ]);

  static final Map<String, EquationRecord> _index = {
    for (final r in all) ...{r.stableId: r, r.legacyId: r},
  };

  /// Résout un identifiant stable **ou** historique ; `null` si inconnu.
  static EquationRecord? resolve(String id) => _index[id];

  /// Identifiant stable correspondant à un identifiant historique.
  static String? stableIdFor(String legacyId) => _index[legacyId]?.stableId;
}
