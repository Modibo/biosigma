import 'result.dart';

/// Niveau d'un message d'information (backlog P1-16). Les alertes
/// (`blocking`, `caution`) restent à part ; ce classement sépare, parmi les
/// messages d'information, ce qui relève de la méthode, de l'interprétation
/// biologique et des recommandations publiées.
///
/// Le niveau « calcul » est la valeur affichée au-dessus des messages. BioSigma
/// ne formule jamais de décision : le niveau [decisionSupport] ne fait que
/// reproduire, avec sa source, une recommandation publiée.
enum ResultLevel {
  /// Limites de la méthode, domaine de validité, correction peu pertinente,
  /// absence de seuil : ce qu'il faut savoir sur le calcul lui-même.
  analytical('Précisions analytiques et limites'),

  /// Catégories, seuils et repères d'interprétation biologique.
  interpretation('Informations et repères d\'interprétation'),

  /// Recommandations publiées (cible, indication de traitement, prophylaxie).
  decisionSupport('Recommandations publiées (aide à la décision)');

  const ResultLevel(this.title);
  final String title;

  /// Phrase affichée sous le titre du niveau.
  String get caption => switch (this) {
        analytical => 'Ce qui conditionne la validité ou la portée du résultat.',
        interpretation => 'Repères généraux, non validés localement : ils ne remplacent ni le contexte '
            'clinique ni le jugement du professionnel.',
        decisionSupport => 'Recommandations de sociétés savantes reproduites à titre d\'information, avec leur '
            'source. BioSigma ne formule aucune décision : elles ne s\'appliquent qu\'après une évaluation '
            'clinique individuelle.',
      };
}

/// Début de message (sans accent ni casse) → niveau « précisions analytiques ».
const List<String> _analyticalStarts = [
  'aucun intervalle',
  'aucun seuil n\'est applique',
  'correction peu pertinente',
  'approximation informative',
  'il n\'existe pas de seuil universel',
  'facteur ajustable',
  'modele derive et calibre',
];

/// Fragments qui signalent une recommandation publiée.
const List<String> _decisionSupportMarks = [
  'recommandation de classe',
  'thromboprophylaxie pharmacologique est',
  'prophylaxie pharmacologique associee',
  'objectif glycemique habituel',
  'la cible therapeutique de l\'inr',
  'doit inciter a corriger',
];

String _fold(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[éèêë]'), 'e')
    .replaceAll(RegExp('[àâä]'), 'a')
    .replaceAll(RegExp('[îï]'), 'i')
    .replaceAll(RegExp('[ôö]'), 'o')
    .replaceAll(RegExp('[ùûü]'), 'u')
    .replaceAll('ç', 'c')
    .replaceAll('’', '\'');

/// Niveau d'un message d'information. Par défaut, un message est une
/// interprétation : un message nouveau est donc affiché sous le niveau le plus
/// prudent à relire, jamais comme une recommandation sans l'avoir décidé
/// (un test impose le classement de chaque message existant).
ResultLevel levelOfInfo(CalculationWarning w) {
  final t = _fold(w.message);
  if (_decisionSupportMarks.any(t.contains)) return ResultLevel.decisionSupport;
  if (_analyticalStarts.any(t.startsWith)) return ResultLevel.analytical;
  return ResultLevel.interpretation;
}

/// Messages d'information regroupés par niveau, dans l'ordre des niveaux
/// (les niveaux vides sont omis).
Map<ResultLevel, List<CalculationWarning>> groupInfoByLevel(List<CalculationWarning> warnings) {
  final out = <ResultLevel, List<CalculationWarning>>{};
  for (final level in ResultLevel.values) {
    final items = [for (final w in warnings) if (w.severity == WarningSeverity.info && levelOfInfo(w) == level) w];
    if (items.isNotEmpty) out[level] = items;
  }
  return out;
}
