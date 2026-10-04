import 'equation_registry.dart' show EquationStatus;

/// Décision d'une fiche de validation.
enum ValidationDecision { approved, rejected }

/// Fiche de validation scientifique d'un élément (équation, analyte…) à une
/// **version précise** (décision D-12, section 2.3 du cahier des charges).
///
/// Un élément n'est « VALIDÉ » que si une fiche **complète** existe pour sa
/// version courante : source consultée, au moins deux cas de vérification
/// indépendants, validateur identifié, date, périmètre et référence de la
/// fiche signée. Ce n'est pas une preuve de justesse : c'est la trace d'un
/// acte humain de validation, que le code refuse de supposer.
class ValidationRecord {
  const ValidationRecord({
    required this.itemId,
    required this.itemVersion,
    required this.validatorName,
    required this.validatorRole,
    required this.validatedOn,
    required this.scope,
    required this.sourcesReviewed,
    required this.independentCases,
    required this.sheetReference,
    this.decision = ValidationDecision.approved,
  });

  /// Identifiant stable de l'équation (`METAB_BMI_001`) ou `analyte:<id>`.
  final String itemId;
  final int itemVersion;
  final String validatorName;
  final String validatorRole;
  final DateTime validatedOn;

  /// Ce qui a été validé (ex. « formule, unités et domaine de validité »).
  final String scope;

  /// Sources effectivement consultées par le validateur.
  final String sourcesReviewed;

  /// Nombre de cas de vérification indépendants (calculés hors du code testé).
  final int independentCases;

  /// Référence de la fiche signée (numéro, emplacement).
  final String sheetReference;
  final ValidationDecision decision;

  /// Fiche exploitable : tous les champs renseignés, au moins 2 cas indépendants.
  bool get isComplete =>
      itemId.trim().isNotEmpty &&
      itemVersion > 0 &&
      validatorName.trim().isNotEmpty &&
      validatorRole.trim().isNotEmpty &&
      scope.trim().isNotEmpty &&
      sourcesReviewed.trim().isNotEmpty &&
      sheetReference.trim().isNotEmpty &&
      independentCases >= 2;
}

/// Fiches de validation signées. **Vide à ce jour** : aucune équation ni
/// aucun analyte n'a été validé par un biologiste responsable. Une fiche
/// s'ajoute ici, avec sa référence, après la procédure décrite dans
/// `docs/biosigma-lab/gouvernance-validation.md`.
const List<ValidationRecord> validationRecords = [];

/// Statut d'un élément à une version donnée, d'après [records].
///
/// - `validated` : une fiche complète et approuvée existe pour cette version ;
/// - `withdrawn` : une fiche rejetée existe pour cette version ;
/// - `notValidated` sinon (y compris si seule une version antérieure a été validée).
EquationStatus validationStatusFor(
  String itemId,
  int version, {
  List<ValidationRecord> records = validationRecords,
}) {
  final matching = records.where((r) => r.itemId == itemId && r.itemVersion == version && r.isComplete);
  if (matching.any((r) => r.decision == ValidationDecision.rejected)) {
    return EquationStatus.withdrawn;
  }
  if (matching.any((r) => r.decision == ValidationDecision.approved)) {
    return EquationStatus.validated;
  }
  return EquationStatus.notValidated;
}
