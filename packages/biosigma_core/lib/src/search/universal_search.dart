import '../catalog.dart';
import '../lab/analyte_base.dart';
import '../lab/lab_units.dart';
import '../lab/smart_solver.dart';
import 'fold.dart';

/// Nature d'un résultat de recherche.
enum SearchKind {
  calculator('Calcul'),
  analyte('Analyte (Convert)'),
  unit('Unité (Convert)'),
  module('Module Lab');

  const SearchKind(this.label);
  final String label;
}

/// Un résultat : de quoi l'afficher et l'ouvrir.
class SearchHit {
  const SearchHit({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.score,
    this.module,
  });

  final SearchKind kind;

  /// Identifiant du calcul, de l'analyte, symbole de l'unité ou nom du module.
  final String id;
  final String title;
  final String subtitle;
  final int score;
  final LabModule? module;
}

/// Termes de recherche supplémentaires (abréviations, synonymes courants,
/// noms anglais) pour des calculs du catalogue. Ce sont de simples aides à
/// la recherche : ils ne contiennent aucune donnée scientifique.
const Map<String, List<String>> searchSynonyms = {
  'ckd_epi_creatinine_2021': ['dfg', 'gfr', 'egfr', 'debit de filtration glomerulaire', 'ckd epi', 'rein', 'creatinine'],
  'ckd_epi_cystatin_c_2012': ['dfg', 'gfr', 'egfr', 'cystatine', 'rein'],
  'ckd_epi_creatinine_cystatin_c_2021': ['dfg', 'gfr', 'egfr', 'cystatine', 'creatinine', 'rein'],
  'schwartz_bedside_pediatric': ['dfg', 'gfr', 'enfant', 'pediatrique', 'schwartz'],
  'bmi': ['imc', 'bmi', 'indice de masse corporelle', 'poids', 'taille', 'obesite'],
  'inr': ['inr', 'tp', 'taux de prothrombine', 'isi', 'avk', 'anticoagulant'],
  'aptt_ratio': ['tca', 'aptt', 'ratio tca', 'cephaline'],
  'rosner_index': ['rosner', 'melange', 'inhibiteur', 'tca'],
  'red_cell_indices': ['vgm', 'mcv', 'tcmh', 'mch', 'ccmh', 'mchc', 'constantes erythrocytaires', 'nfs', 'anemie', 'hematocrite'],
  'absolute_leukocyte_counts': ['anc', 'alc', 'neutrophiles', 'lymphocytes', 'polynucleaires', 'formule', 'nfs', 'neutropenie'],
  'reticulocyte_indices_panel': ['reticulocytes', 'crc', 'rpi', 'nfs'],
  'homa_ir': ['homa', 'insulinoresistance', 'insuline', 'diabete'],
  'quicki': ['insulinoresistance', 'insuline', 'diabete'],
  'tyg_index': ['triglycerides glucose', 'insulinoresistance'],
  'ldl_panel': ['ldl', 'friedewald', 'sampson', 'lipides', 'cholesterol', 'non hdl'],
  'fib4': ['fib 4', 'fibrose', 'foie', 'hepatique'],
  'apri': ['fibrose', 'foie', 'hepatique'],
  'meld_na': ['meld', 'foie', 'cirrhose', 'hepatique'],
  'albi_score': ['albi', 'foie', 'carcinome'],
  'cha2ds2_vasc_score': ['fibrillation', 'avc', 'afib', 'cha2ds2'],
  'has_bled_score': ['saignement', 'hemorragie', 'has bled'],
  'padua_prediction_score': ['thrombose', 'tev', 'vte', 'embolie'],
  'caprini_score': ['thrombose', 'tev', 'vte', 'chirurgie'],
  'improve_bleeding_score': ['saignement', 'hemorragie', 'improve'],
  'isth_dic_score': ['civd', 'dic', 'coagulation intravasculaire'],
  'four_ts_score': ['tih', 'heparine', 'thrombopenie', '4ts'],
  'sic_score': ['coagulopathie septique', 'sepsis', 'sic'],
  'anion_gap': ['trou anionique', 'anion gap', 'acidose'],
  'calculated_osmolarity_osmolar_gap': ['osmolarite', 'osmolalite', 'trou osmolaire'],
  'corrected_sodium_hyperglycemia': ['natremie', 'sodium corrige', 'hyperglycemie'],
  'corrected_calcium_albumin': ['calcemie', 'calcium corrige', 'albumine'],
  'expected_acid_base_compensation': ['acide base', 'compensation', 'gaz du sang', 'ph'],
  'estimated_average_glucose_adag': ['hba1c', 'eag', 'adag', 'glycemie moyenne'],
  'framingham_risk_score': ['framingham', 'risque cardiovasculaire'],
  'score2_risk': ['score2', 'score 2', 'risque cardiovasculaire', 'esc'],
  'proteinuria_24h': ['proteinurie', 'urines des 24 heures'],
  'urine_albumin_creatinine_ratio': ['acr', 'albuminurie', 'rac'],
  'urine_protein_creatinine_ratio': ['pcr', 'proteinurie', 'rpc'],
  'fractional_excretion_sodium': ['fena', 'excretion fractionnelle'],
  'fractional_excretion_urea': ['feurée', 'feu', 'excretion fractionnelle'],
  'creatinine_clearance_timed': ['clairance', 'cockcroft', 'urines'],
};

/// Recherche universelle hors connexion : calculs, analytes, unités et
/// modules Lab. Insensible à la casse et aux accents ; tous les mots saisis
/// doivent se retrouver (ET). Les résultats sont triés par pertinence.
List<SearchHit> universalSearch(String query, {int limit = 40}) {
  final q = foldText(query).trim();
  if (q.isEmpty) return const [];
  final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  final hits = <SearchHit>[];

  int score(List<String> fields) {
    // un champ strictement égal à la requête entière obtient le meilleur score
    var best = 0;
    final folded = [for (final f in fields) foldText(f)];
    if (folded.any((f) => f == q)) best = 100;
    var total = 0;
    for (final t in tokens) {
      var tokenBest = 0;
      for (final f in folded) {
        if (f == t) {
          tokenBest = tokenBest < 40 ? 40 : tokenBest;
        } else if (f.startsWith(t)) {
          tokenBest = tokenBest < 30 ? 30 : tokenBest;
        } else if (f.split(RegExp(r'[\s\-/()·,]+')).any((w) => w.startsWith(t))) {
          tokenBest = tokenBest < 22 ? 22 : tokenBest;
        } else if (f.contains(t)) {
          tokenBest = tokenBest < 10 ? 10 : tokenBest;
        }
      }
      if (tokenBest == 0) return 0; // ET : un mot sans correspondance exclut le résultat
      total += tokenBest;
    }
    return best + total;
  }

  for (final m in CalculatorCatalog.all) {
    final s = score([m.name, m.shortName, m.id.replaceAll('_', ' '), ...?searchSynonyms[m.id]]);
    if (s > 0) {
      hits.add(SearchHit(
        kind: SearchKind.calculator,
        id: m.id,
        title: m.shortName,
        subtitle: m.category.label,
        score: s + 5,
      ));
    }
  }

  for (final a in AnalyteBase.all) {
    final s = score([a.name, a.id.replaceAll('_', ' '), if (a.formulaText != null) a.formulaText!]);
    if (s > 0) {
      hits.add(SearchHit(
        kind: SearchKind.analyte,
        id: a.id,
        title: a.name,
        subtitle: a.category,
        score: s,
      ));
    }
  }

  // Unités : seulement si la requête ressemble à un symbole (un seul mot).
  if (tokens.length == 1) {
    final seen = <String>{};
    for (final entry in LabUnits.offered.entries) {
      for (final symbol in entry.value) {
        if (!seen.add(symbol)) continue;
        final f = foldText(symbol);
        if (f == q || f.startsWith(q)) {
          hits.add(SearchHit(
            kind: SearchKind.unit,
            id: symbol,
            title: symbol,
            subtitle: entry.key.label,
            score: f == q ? 60 : 12,
          ));
        }
      }
    }
  }

  for (final module in LabModule.values) {
    final words = [module.label, ...?_moduleTerms[module]];
    final s = score(words);
    if (s > 0) {
      hits.add(SearchHit(
        kind: SearchKind.module,
        id: module.name,
        title: module.label,
        subtitle: _moduleSummary[module]!,
        score: s + 8,
        module: module,
      ));
    }
  }

  // Une phrase libre : le Smart Solver propose un module (sans calculer).
  if (tokens.length >= 3) {
    final suggestion = analyzeLabQuestion(query);
    for (final m in suggestion.candidates) {
      if (hits.any((h) => h.module == m)) continue;
      hits.add(SearchHit(
        kind: SearchKind.module,
        id: m.name,
        title: m.label,
        subtitle: 'Proposé d\'après votre phrase — à confirmer',
        score: 15,
        module: m,
      ));
    }
  }

  hits.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.title.compareTo(b.title);
  });
  return hits.length > limit ? hits.sublist(0, limit) : hits;
}

const Map<LabModule, List<String>> _moduleTerms = {
  LabModule.convert: ['conversion', 'convertir', 'unites', 'unite'],
  LabModule.dilute: ['dilution', 'diluer', 'c1v1', 'serie', 'linearite'],
  LabModule.prepare: ['preparation', 'preparer', 'solution', 'tampon', 'masse a peser', 'pourcentage'],
  LabModule.count: ['numeration', 'chambre', 'neubauer', 'formule leucocytaire', 'compteur', 'spermatozoides'],
  LabModule.microbiology: ['microbiologie', 'ufc', 'cfu', 'colonies', 'denombrement'],
  LabModule.quality: ['qualite', 'cv', 'biais', 'sigma', 'recuperation', 'erreur totale'],
};

const Map<LabModule, String> _moduleSummary = {
  LabModule.convert: 'Conversion d\'unités et d\'analytes',
  LabModule.dilute: 'Dilution simple, en série, hors linéarité',
  LabModule.prepare: 'Masse à peser, pourcentages, tampons',
  LabModule.count: 'Numération en chambre, formule leucocytaire',
  LabModule.microbiology: 'UFC/mL à partir de boîtes dénombrées',
  LabModule.quality: 'CV, biais, récupération, Sigma',
};
