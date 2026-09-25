import 'reference.dart';

/// Catégorie clinique d'un calcul, utilisée pour le classement et la
/// recherche dans l'application.
enum CalculatorCategory {
  renal('Fonction rénale et urines'),
  metabolic('Glucides, insulinorésistance et cardiométabolisme'),
  ionogram('Ionogramme, gaz du sang et biochimie générale'),
  hemostasis('Hémostase');

  const CalculatorCategory(this.label);

  /// Libellé affiché en français.
  final String label;
}

/// Métadonnées scientifiques et d'usage d'une formule : tout ce que
/// l'écran de résultat doit pouvoir afficher (formule, unités, version,
/// source, population, limites), conformément à l'exigence de traçabilité
/// complète du cahier des charges.
class FormulaMeta {
  const FormulaMeta({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.version,
    required this.equation,
    required this.sources,
    required this.applicablePopulation,
    this.forbiddenConditions = const [],
    this.analyticalConditions = const [],
    this.limitations = const [],
    this.displayPrecision = 2,
    this.helpText,
  });

  /// Identifiant stable, unique, utilisé pour la navigation, l'historique
  /// et les favoris (ex. "ckd_epi_creatinine_2021").
  final String id;

  /// Nom complet affiché en tête d'écran.
  final String name;

  /// Nom court utilisé dans les listes et la recherche.
  final String shortName;

  final CalculatorCategory category;

  /// Version explicite de l'équation (ex. "CKD-EPI 2021, sans coefficient
  /// racial") — ne jamais laisser une version implicite.
  final String version;

  /// Formule mathématique lisible, avec toutes les parenthèses explicites,
  /// telle qu'affichée à l'écran (ex. "TyG = ln[(TG mg/dL × Glyc mg/dL)/2]").
  final String equation;

  /// Sources primaires ou organismes officiels, consultables hors connexion.
  final List<Reference> sources;

  /// Population à laquelle la formule s'applique (ex. "Adulte ≥ 18 ans").
  final String applicablePopulation;

  /// Conditions qui interdisent le calcul (ex. "âge < 18 ans",
  /// "triglycérides ≥ 4,52 mmol/L pour Friedewald").
  final List<String> forbiddenConditions;

  /// Conditions analytiques requises (ex. "créatinine standardisée IDMS").
  final List<String> analyticalConditions;

  /// Limites d'emploi affichées sous le résultat.
  final List<String> limitations;

  /// Nombre de décimales par défaut à l'affichage (l'utilisateur peut
  /// ajuster la précision d'affichage globale dans les réglages ; la
  /// précision interne des calculs n'est jamais tronquée).
  final int displayPrecision;

  /// Aide contextuelle courte pour la saisie.
  final String? helpText;
}
