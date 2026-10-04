import '../catalog.dart';
import '../lab/convert.dart';
import '../lab/count.dart';
import '../lab/dilution.dart';
import '../lab/microbiology.dart';
import '../lab/prepare.dart';
import '../lab/quality.dart';
import '../models/formula_meta.dart';

/// Statut de validation scientifique d'une équation (schéma E.3 du dossier).
///
/// Aucune équation n'est `validated` tant qu'une fiche de validation signée
/// n'existe pas (décision D-12 en attente) : toutes sont `notValidated`.
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
    dilutionMeta,
    serialDilutionMeta,
    outOfRangeDilutionMeta,
    solutionPreparationMeta,
    percentSolutionMeta,
    bufferMeta,
    cellCountMeta,
    totalCountMeta,
    differentialMeta,
    cfuMeta,
    qualityMeta,
  ];

  static EquationRecord _record(FormulaMeta meta, {required bool fromCatalog}) {
    final family = _family[meta.category]!;
    return EquationRecord(
      stableId: '${family}_${meta.id.toUpperCase()}_001',
      legacyId: meta.id,
      name: meta.name,
      family: family,
      version: 1,
      versionLabel: meta.version,
      status: EquationStatus.notValidated,
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
