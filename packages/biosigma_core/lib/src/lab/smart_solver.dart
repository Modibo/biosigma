import 'lab_units.dart';

/// Modules proposés par le Smart Solver.
enum LabModule {
  convert('Convert'),
  dilute('Dilute'),
  prepare('Prepare'),
  count('Count'),
  microbiology('Microbiology'),
  quality('Quality');

  const LabModule(this.label);
  final String label;
}

/// Une quantité repérée dans la phrase, telle qu'écrite (jamais interprétée).
class DetectedQuantity {
  const DetectedQuantity(this.raw, this.unit);
  final String raw;
  final String unit;
}

/// Proposition du Smart Solver : un module **à confirmer**, jamais un calcul.
class SolverSuggestion {
  const SolverSuggestion({
    required this.candidates,
    required this.quantities,
    required this.matchedKeywords,
  });

  /// Modules compatibles, du plus probable au moins probable. Vide = aucun.
  final List<LabModule> candidates;
  final List<DetectedQuantity> quantities;
  final Map<LabModule, List<String>> matchedKeywords;

  bool get recognized => candidates.isNotEmpty;

  /// `true` si plusieurs modules sont aussi probables : l'utilisateur choisit.
  bool get ambiguous => candidates.length > 1 && _tie;
  bool get _tie =>
      candidates.length > 1 &&
      matchedKeywords[candidates[0]]!.length == matchedKeywords[candidates[1]]!.length;
}

const Map<LabModule, List<String>> _keywords = {
  LabModule.convert: ['convert', 'conversion', 'exprimer en', 'passer de', ' en mmol', ' en mg/dl', ' en µmol'],
  LabModule.dilute: ['dilu', 'facteur de dilution', 'c1v1', 'c1·v1', 'volume final', 'prelever', 'serie', 'lineari', 'au 1/'],
  LabModule.prepare: ['prepar', 'peser', 'masse a', 'tampon', 'buffer', 'ph ', 'pka', 'solution de', 'molaire', 'pourcent'],
  LabModule.count: ['numeration', 'cellule', 'chambre', 'formule leuco', 'differentiel', 'spermato', 'compter', 'comptage', 'neubauer'],
  LabModule.microbiology: ['ufc', 'cfu', 'colonie', 'boite', 'gelose', 'inoculum', 'mcfarland', 'denombrement', 'germes'],
  LabModule.quality: [' cv', 'coefficient de variation', 'biais', 'sigma', 'justesse', 'fidelite', 'recuperation', 'ecart-type', 'ecart type', 'erreur totale'],
};

const Map<String, String> _accents = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'ç': 'c', 'é': 'e', 'è': 'e', 'ê': 'e',
  'ë': 'e', 'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', 'ñ': 'n', 'ó': 'o', 'ò': 'o', 'ô': 'o',
  'ö': 'o', 'õ': 'o', 'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ý': 'y', 'ÿ': 'y', 'œ': 'oe',
  'æ': 'ae', 'µ': 'u', 'μ': 'u',
};

/// Minuscules sans accents, entourées d'espaces (pour les mots-clés « mot entier »).
String _fold(String s) {
  final b = StringBuffer(' ');
  for (final ch in s.toLowerCase().split('')) {
    b.write(_accents[ch] ?? ch);
  }
  b.write(' ');
  return b.toString();
}

/// Analyse déterministe par mots-clés, hors connexion : propose un module,
/// liste les quantités repérées, et laisse l'utilisateur confirmer.
/// Ne calcule rien et ne remplit aucun champ à sa place.
SolverSuggestion analyzeLabQuestion(String text) {
  final folded = _fold(text);
  final matched = <LabModule, List<String>>{};
  _keywords.forEach((module, words) {
    final hits = [for (final w in words) if (folded.contains(w)) w.trim()];
    if (hits.isNotEmpty) matched[module] = hits;
  });
  final ranked = matched.keys.toList()
    ..sort((a, b) => matched[b]!.length.compareTo(matched[a]!.length));

  final quantities = <DetectedQuantity>[];
  final pattern = RegExp(r'(\d+(?:[.,]\d+)?)\s*([a-zA-Zµμ%]+(?:/[a-zA-Zµμ]+)?)');
  for (final m in pattern.allMatches(text)) {
    final unit = m.group(2)!;
    if (unit == '%' || LabUnits.parse(unit) != null) {
      quantities.add(DetectedQuantity(m.group(0)!.trim(), unit));
    }
  }
  return SolverSuggestion(candidates: ranked, quantities: quantities, matchedKeywords: matched);
}
