/// Politique d'arrondi et de chiffres significatifs (règle `FMT_ARRONDI_001`,
/// backlog P1-15, décision D-09).
///
/// - **Calculs** : arithmétique `double` (IEEE 754) ; **aucun arrondi
///   intermédiaire** ; la précision interne n'est jamais tronquée.
/// - **Affichage** : un seul arrondi, à la toute fin, avec un nombre de
///   décimales fixé par le résultat (`ResultValue.precision`). C'est le
///   comportement de `double.toStringAsFixed` : arrondi au plus proche de la
///   valeur binaire exacte du `double` ; en cas d'égalité exacte, l'arrondi
///   s'éloigne de zéro (2,5 → « 3 », −2,5 → « −3 »).
/// - **Conséquence connue** : un décimal non représentable exactement peut
///   s'arrondir « vers le bas » (1,005 est stocké 1,00499… et s'affiche
///   « 1,00 »). Ce n'est pas une erreur de calcul.
/// - **Modules Lab** : nombre de décimales choisi pour afficher 4 chiffres
///   significatifs ([decimalsForSignificant]) ; la valeur n'est jamais arrondie.
///
/// Cette règle décrit ce que le code fait déjà ; elle ne change aucun
/// résultat existant. Elle reste à faire valider (D-12).
class RoundingPolicy {
  RoundingPolicy._();

  static const String ruleId = 'FMT_ARRONDI_001';

  /// Texte de la règle, affichable et enregistrable avec un calcul.
  static const String description =
      'Calcul en double précision sans arrondi intermédiaire ; arrondi unique à l\'affichage '
      '(au plus proche, égalité exacte vers l\'extérieur).';

  /// Texte de [value] arrondi à [decimals] décimales (point décimal).
  static String format(double value, int decimals) => value.toStringAsFixed(decimals);

  /// Nombre de décimales à afficher pour garder [significant] chiffres
  /// significatifs (affichage uniquement). Lit l'exposant dans la notation
  /// scientifique : exact aussi pour les puissances de dix (1000).
  static int decimalsForSignificant(double value, {int significant = 4}) {
    if (value == 0 || !value.isFinite) return 2;
    final magnitude = int.parse(value.abs().toStringAsExponential().split('e').last);
    return (significant - 1 - magnitude).clamp(0, 12);
  }
}
