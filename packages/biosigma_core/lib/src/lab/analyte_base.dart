import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';
import '../registry/equation_registry.dart' show EquationStatus;
import '../registry/validation.dart';
import '../units/analyte.dart';
import '../units/unit_registry.dart';
import '../validation.dart';
import 'analyte_additions.dart';
import 'analyte_model.dart';
import 'convert.dart';

export 'analyte_model.dart';

const String _massOnlyNote = massOnlyNote;

/// Base d'analytes de Convert (backlog P1-11) : formules brutes, valences et
/// natures. **Statut de toutes les entrées : NON VALIDÉ.**
class AnalyteBase {
  AnalyteBase._();

  static const _el = catElectrolytes;
  static const _met = catMetabolites;
  static const _lip = catLipids;
  static const _hor = catHormones;
  static const _vit = catVitamins;
  static const _tdm = catDrugs;
  static const _pro = catProteins;
  static const _enz = catEnzymes;
  static const _hem = catHematology;
  static const _gaz = catPhysiology;

  static const List<LabAnalyte> _core = [
    // --- Électrolytes et minéraux ---
    LabAnalyte(id: 'sodium', name: 'Sodium (Na⁺)', category: _el, kind: AnalyteKind.molecular,
        formula: {'Na': 1}, formulaText: 'Na', valence: 1, urine24h: true),
    LabAnalyte(id: 'potassium', name: 'Potassium (K⁺)', category: _el, kind: AnalyteKind.molecular,
        formula: {'K': 1}, formulaText: 'K', valence: 1, urine24h: true),
    LabAnalyte(id: 'chloride', name: 'Chlorure (Cl⁻)', category: _el, kind: AnalyteKind.molecular,
        formula: {'Cl': 1}, formulaText: 'Cl', valence: 1, urine24h: true),
    LabAnalyte(id: 'bicarbonate', name: 'Bicarbonate (HCO₃⁻, CO₂ total)', category: _el,
        kind: AnalyteKind.molecular, formula: {'H': 1, 'C': 1, 'O': 3}, formulaText: 'HCO3', valence: 1),
    LabAnalyte(id: 'calcium', name: 'Calcium (Ca²⁺, total ou ionisé)', category: _el,
        kind: AnalyteKind.molecular, formula: {'Ca': 1}, formulaText: 'Ca', valence: 2,
        urine24h: true, legacy: Analyte.calcium),
    LabAnalyte(id: 'magnesium', name: 'Magnésium (Mg²⁺)', category: _el, kind: AnalyteKind.molecular,
        formula: {'Mg': 1}, formulaText: 'Mg', valence: 2, urine24h: true),
    LabAnalyte(id: 'phosphate', name: 'Phosphate (phosphore inorganique, exprimé en P)', category: _el,
        kind: AnalyteKind.molecular, formula: {'P': 1}, formulaText: 'P',
        note: 'Exprimé en phosphore (P). Équivalents non proposés : la valence du phosphate dépend du pH.',
        urine24h: true),
    LabAnalyte(id: 'lithium', name: 'Lithium (Li⁺)', category: _el, kind: AnalyteKind.molecular,
        formula: {'Li': 1}, formulaText: 'Li', valence: 1),
    LabAnalyte(id: 'iron', name: 'Fer (Fe)', category: _el, kind: AnalyteKind.molecular,
        formula: {'Fe': 1}, formulaText: 'Fe', note: 'Équivalents non proposés : valence (Fe²⁺/Fe³⁺) ambiguë.'),
    LabAnalyte(id: 'copper', name: 'Cuivre (Cu)', category: _el, kind: AnalyteKind.molecular,
        formula: {'Cu': 1}, formulaText: 'Cu'),
    LabAnalyte(id: 'zinc', name: 'Zinc (Zn²⁺)', category: _el, kind: AnalyteKind.molecular,
        formula: {'Zn': 1}, formulaText: 'Zn', valence: 2),
    LabAnalyte(id: 'selenium', name: 'Sélénium (Se)', category: _el, kind: AnalyteKind.molecular,
        formula: {'Se': 1}, formulaText: 'Se'),
    LabAnalyte(id: 'lead', name: 'Plomb (Pb)', category: _el, kind: AnalyteKind.molecular,
        formula: {'Pb': 1}, formulaText: 'Pb'),
    LabAnalyte(id: 'mercury', name: 'Mercure (Hg)', category: _el, kind: AnalyteKind.molecular,
        formula: {'Hg': 1}, formulaText: 'Hg'),

    // --- Métabolites ---
    LabAnalyte(id: 'glucose', name: 'Glucose', category: _met, kind: AnalyteKind.molecular,
        formula: {'C': 6, 'H': 12, 'O': 6}, formulaText: 'C6H12O6', urine24h: true, legacy: Analyte.glucose),
    LabAnalyte(id: 'urea', name: 'Urée', category: _met, kind: AnalyteKind.molecular,
        formula: {'C': 1, 'H': 4, 'N': 2, 'O': 1}, formulaText: 'CH4N2O', urine24h: true),
    LabAnalyte(id: 'urea_nitrogen', name: 'Azote uréique (BUN)', category: _met, kind: AnalyteKind.molecular,
        formula: {'N': 2}, formulaText: 'N2',
        note: 'Masse exprimée en azote (28,014 g par mole d\'urée) : 1 mol d\'urée = 2 atomes d\'azote. '
            'Les unités molaires désignent des moles d\'urée.',
        urine24h: true),
    LabAnalyte(id: 'creatinine', name: 'Créatinine', category: _met, kind: AnalyteKind.molecular,
        formula: {'C': 4, 'H': 7, 'N': 3, 'O': 1}, formulaText: 'C4H7N3O', urine24h: true,
        legacy: Analyte.creatinine),
    LabAnalyte(id: 'uric_acid', name: 'Acide urique', category: _met, kind: AnalyteKind.molecular,
        formula: {'C': 5, 'H': 4, 'N': 4, 'O': 3}, formulaText: 'C5H4N4O3', urine24h: true),
    LabAnalyte(id: 'bilirubin', name: 'Bilirubine (totale, directe, indirecte)', category: _met,
        kind: AnalyteKind.molecular, formula: {'C': 33, 'H': 36, 'N': 4, 'O': 6}, formulaText: 'C33H36N4O6'),
    LabAnalyte(id: 'ammonia', name: 'Ammoniac (NH₃)', category: _met, kind: AnalyteKind.molecular,
        formula: {'N': 1, 'H': 3}, formulaText: 'NH3'),
    LabAnalyte(id: 'lactate', name: 'Lactate (exprimé en acide lactique)', category: _met,
        kind: AnalyteKind.molecular, formula: {'C': 3, 'H': 6, 'O': 3}, formulaText: 'C3H6O3', valence: 1),
    LabAnalyte(id: 'pyruvate', name: 'Pyruvate (exprimé en acide pyruvique)', category: _met,
        kind: AnalyteKind.molecular, formula: {'C': 3, 'H': 4, 'O': 3}, formulaText: 'C3H4O3'),
    LabAnalyte(id: 'bhb', name: 'β-hydroxybutyrate (exprimé en acide)', category: _met,
        kind: AnalyteKind.molecular, formula: {'C': 4, 'H': 8, 'O': 3}, formulaText: 'C4H8O3'),
    LabAnalyte(id: 'homocysteine', name: 'Homocystéine', category: _met, kind: AnalyteKind.molecular,
        formula: {'C': 4, 'H': 9, 'N': 1, 'O': 2, 'S': 1}, formulaText: 'C4H9NO2S'),
    LabAnalyte(id: 'phenylalanine', name: 'Phénylalanine', category: _met, kind: AnalyteKind.molecular,
        formula: {'C': 9, 'H': 11, 'N': 1, 'O': 2}, formulaText: 'C9H11NO2'),
    LabAnalyte(id: 'ethanol', name: 'Éthanol', category: _met, kind: AnalyteKind.molecular,
        formula: {'C': 2, 'H': 6, 'O': 1}, formulaText: 'C2H6O'),

    // --- Lipides ---
    LabAnalyte(id: 'cholesterol', name: 'Cholestérol (total, HDL, LDL, non-HDL)', category: _lip,
        kind: AnalyteKind.molecular, formula: {'C': 27, 'H': 46, 'O': 1}, formulaText: 'C27H46O',
        legacy: Analyte.cholesterol),
    LabAnalyte(id: 'triglycerides', name: 'Triglycérides', category: _lip, kind: AnalyteKind.molecular,
        formula: {'C': 57, 'H': 104, 'O': 6}, formulaText: 'C57H104O6',
        note: 'Mélange de triglycérides : convention de la trioléine (C57H104O6) ; la masse molaire '
            'moyenne réelle varie avec la composition en acides gras.',
        legacy: Analyte.triglycerides),

    // --- Hormones ---
    LabAnalyte(id: 'cortisol', name: 'Cortisol', category: _hor, kind: AnalyteKind.molecular,
        formula: {'C': 21, 'H': 30, 'O': 5}, formulaText: 'C21H30O5', urine24h: true),
    LabAnalyte(id: 'testosterone', name: 'Testostérone', category: _hor, kind: AnalyteKind.molecular,
        formula: {'C': 19, 'H': 28, 'O': 2}, formulaText: 'C19H28O2'),
    LabAnalyte(id: 'estradiol', name: 'Estradiol', category: _hor, kind: AnalyteKind.molecular,
        formula: {'C': 18, 'H': 24, 'O': 2}, formulaText: 'C18H24O2'),
    LabAnalyte(id: 'progesterone', name: 'Progestérone', category: _hor, kind: AnalyteKind.molecular,
        formula: {'C': 21, 'H': 30, 'O': 2}, formulaText: 'C21H30O2'),
    LabAnalyte(id: 't4', name: 'Thyroxine (T4, totale ou libre)', category: _hor, kind: AnalyteKind.molecular,
        formula: {'C': 15, 'H': 11, 'I': 4, 'N': 1, 'O': 4}, formulaText: 'C15H11I4NO4'),
    LabAnalyte(id: 't3', name: 'Triiodothyronine (T3, totale ou libre)', category: _hor,
        kind: AnalyteKind.molecular, formula: {'C': 15, 'H': 12, 'I': 3, 'N': 1, 'O': 4}, formulaText: 'C15H12I3NO4'),
    LabAnalyte(id: 'insulin', name: 'Insuline', category: _hor, kind: AnalyteKind.legacy,
        legacy: Analyte.insulin,
        note: 'Facteur µU/mL ↔ pmol/L du moteur existant : dépend de l\'étalon du dosage.'),

    // --- Vitamines ---
    LabAnalyte(id: 'b12', name: 'Vitamine B12 (cyanocobalamine)', category: _vit, kind: AnalyteKind.molecular,
        formula: {'C': 63, 'H': 88, 'Co': 1, 'N': 14, 'O': 14, 'P': 1}, formulaText: 'C63H88CoN14O14P'),
    LabAnalyte(id: 'folate', name: 'Folates (exprimés en acide folique)', category: _vit,
        kind: AnalyteKind.molecular, formula: {'C': 19, 'H': 19, 'N': 7, 'O': 6}, formulaText: 'C19H19N7O6'),
    LabAnalyte(id: 'vitd', name: 'Vitamine D (25-OH, exprimée en 25-OH-D3)', category: _vit,
        kind: AnalyteKind.molecular, formula: {'C': 27, 'H': 44, 'O': 2}, formulaText: 'C27H44O2'),
    LabAnalyte(id: 'vitc', name: 'Vitamine C (acide ascorbique)', category: _vit, kind: AnalyteKind.molecular,
        formula: {'C': 6, 'H': 8, 'O': 6}, formulaText: 'C6H8O6'),

    // --- Médicaments et toxiques ---
    LabAnalyte(id: 'paracetamol', name: 'Paracétamol', category: _tdm, kind: AnalyteKind.molecular,
        formula: {'C': 8, 'H': 9, 'N': 1, 'O': 2}, formulaText: 'C8H9NO2'),
    LabAnalyte(id: 'salicylate', name: 'Salicylate (acide salicylique)', category: _tdm,
        kind: AnalyteKind.molecular, formula: {'C': 7, 'H': 6, 'O': 3}, formulaText: 'C7H6O3'),
    LabAnalyte(id: 'theophylline', name: 'Théophylline', category: _tdm, kind: AnalyteKind.molecular,
        formula: {'C': 7, 'H': 8, 'N': 4, 'O': 2}, formulaText: 'C7H8N4O2'),
    LabAnalyte(id: 'phenytoin', name: 'Phénytoïne', category: _tdm, kind: AnalyteKind.molecular,
        formula: {'C': 15, 'H': 12, 'N': 2, 'O': 2}, formulaText: 'C15H12N2O2'),
    LabAnalyte(id: 'carbamazepine', name: 'Carbamazépine', category: _tdm, kind: AnalyteKind.molecular,
        formula: {'C': 15, 'H': 12, 'N': 2, 'O': 1}, formulaText: 'C15H12N2O'),
    LabAnalyte(id: 'valproate', name: 'Acide valproïque', category: _tdm, kind: AnalyteKind.molecular,
        formula: {'C': 8, 'H': 16, 'O': 2}, formulaText: 'C8H16O2'),
    LabAnalyte(id: 'phenobarbital', name: 'Phénobarbital', category: _tdm, kind: AnalyteKind.molecular,
        formula: {'C': 12, 'H': 12, 'N': 2, 'O': 3}, formulaText: 'C12H12N2O3'),
    LabAnalyte(id: 'digoxin', name: 'Digoxine', category: _tdm, kind: AnalyteKind.molecular,
        formula: {'C': 41, 'H': 64, 'O': 14}, formulaText: 'C41H64O14'),

    // --- Protéines et marqueurs : conversions massiques seulement ---
    LabAnalyte(id: 'albumin', name: 'Albumine', category: _pro, kind: AnalyteKind.massOnly,
        note: _massOnlyNote, urine24h: true, legacy: Analyte.albumin),
    LabAnalyte(id: 'total_protein', name: 'Protéines totales', category: _pro, kind: AnalyteKind.massOnly,
        note: _massOnlyNote, urine24h: true),
    LabAnalyte(id: 'hemoglobin', name: 'Hémoglobine', category: _pro, kind: AnalyteKind.massOnly,
        note: _massOnlyNote),
    LabAnalyte(id: 'transferrin', name: 'Transferrine', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'ferritin', name: 'Ferritine', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'crp', name: 'Protéine C-réactive (CRP)', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'igg', name: 'Immunoglobulines (IgG, IgA, IgM)', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'fibrinogen', name: 'Fibrinogène', category: _pro, kind: AnalyteKind.massOnly,
        note: _massOnlyNote, legacy: Analyte.fibrinogen),
    LabAnalyte(id: 'apoa1', name: 'Apolipoprotéine A1', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'apob', name: 'Apolipoprotéine B', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'cystatin_c', name: 'Cystatine C', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'b2m', name: 'β2-microglobuline', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'psa', name: 'PSA', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'troponin', name: 'Troponine', category: _pro, kind: AnalyteKind.massOnly,
        note: '$_massOnlyNote Les unités dépendent de la méthode (hs-cTnT, hs-cTnI) : ne pas comparer deux méthodes.'),
    LabAnalyte(id: 'bnp', name: 'BNP / NT-proBNP', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'procalcitonin', name: 'Procalcitonine', category: _pro, kind: AnalyteKind.massOnly, note: _massOnlyNote),
    LabAnalyte(id: 'ddimer', name: 'D-dimères', category: _pro, kind: AnalyteKind.massOnly,
        note: '$_massOnlyNote Attention : unités FEU et DDU non équivalentes (facteur ≈ 2 selon le réactif, non fourni).'),
    LabAnalyte(id: 'hba1c', name: 'HbA1c', category: _pro, kind: AnalyteKind.legacy, legacy: Analyte.hba1c,
        note: 'Équation d\'étalonnage IFCC–NGSP du moteur existant.'),

    // --- Enzymes ---
    LabAnalyte(id: 'alt', name: 'ALAT (ALT)', category: _enz, kind: AnalyteKind.enzyme),
    LabAnalyte(id: 'ast', name: 'ASAT (AST)', category: _enz, kind: AnalyteKind.enzyme),
    LabAnalyte(id: 'alp', name: 'Phosphatases alcalines (PAL)', category: _enz, kind: AnalyteKind.enzyme),
    LabAnalyte(id: 'ggt', name: 'Gamma-GT', category: _enz, kind: AnalyteKind.enzyme),
    LabAnalyte(id: 'ldh', name: 'LDH', category: _enz, kind: AnalyteKind.enzyme),
    LabAnalyte(id: 'ck', name: 'Créatine kinase (CK, CK-MB)', category: _enz, kind: AnalyteKind.enzyme),
    LabAnalyte(id: 'amylase', name: 'Amylase', category: _enz, kind: AnalyteKind.enzyme),
    LabAnalyte(id: 'lipase', name: 'Lipase', category: _enz, kind: AnalyteKind.enzyme),
    LabAnalyte(id: 'cholinesterase', name: 'Cholinestérase', category: _enz, kind: AnalyteKind.enzyme),

    // --- Hématologie ---
    LabAnalyte(id: 'wbc', name: 'Leucocytes', category: _hem, kind: AnalyteKind.cellCount),
    LabAnalyte(id: 'rbc', name: 'Hématies', category: _hem, kind: AnalyteKind.cellCount),
    LabAnalyte(id: 'platelets', name: 'Plaquettes', category: _hem, kind: AnalyteKind.cellCount),
    LabAnalyte(id: 'reticulocytes', name: 'Réticulocytes (numération absolue)', category: _hem, kind: AnalyteKind.cellCount),
    LabAnalyte(id: 'differential_cells', name: 'Neutrophiles, lymphocytes, monocytes, éosinophiles, basophiles', category: _hem, kind: AnalyteKind.cellCount),
    LabAnalyte(id: 'cd4', name: 'Lymphocytes CD4', category: _hem, kind: AnalyteKind.cellCount),
    LabAnalyte(id: 'hematocrit', name: 'Hématocrite', category: _hem, kind: AnalyteKind.fraction),

    // --- Gaz du sang, physiologie ---
    LabAnalyte(id: 'po2', name: 'PO₂ (pression partielle en oxygène)', category: _gaz, kind: AnalyteKind.pressure),
    LabAnalyte(id: 'pco2', name: 'PCO₂ (pression partielle en dioxyde de carbone)', category: _gaz, kind: AnalyteKind.pressure),
    LabAnalyte(id: 'sao2', name: 'Saturation en oxygène (SaO₂)', category: _gaz, kind: AnalyteKind.fraction),
    LabAnalyte(id: 'osmolality', name: 'Osmolalité', category: _gaz, kind: AnalyteKind.osmolality),
    LabAnalyte(id: 'temperature', name: 'Température', category: _gaz, kind: AnalyteKind.temperature),
    LabAnalyte(id: 'gfr', name: 'DFG (clairance rapportée à 1,73 m²)', category: _gaz, kind: AnalyteKind.clearance),
  ];

  /// Toutes les entrées : base initiale puis ajouts (formules vérifiées
  /// contre une source externe indépendante).
  static const List<LabAnalyte> all = [..._core, ...additionalAnalytes];

  /// Statut de validation d'un analyte (fiches de validation) : `NON VALIDÉ`
  /// tant qu'aucune fiche complète n'existe pour sa version.
  static EquationStatus statusOf(String id, {List<ValidationRecord>? records}) =>
      validationStatusFor('analyte:$id', 1, records: records);

  static LabAnalyte? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Catégories dans l'ordre d'apparition.
  static List<String> get categories => [for (final c in {for (final a in all) a.category}) c];

  static List<LabAnalyte> inCategory(String category) =>
      all.where((a) => a.category == category).toList(growable: false);

  /// Recherche insensible à la casse sur le nom et l'identifiant.
  static List<LabAnalyte> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((a) => a.name.toLowerCase().contains(q) || a.id.contains(q))
        .toList(growable: false);
  }
}

/// Conversion pour un analyte de la base.
const FormulaMeta analyteConvertMeta = FormulaMeta(
  id: 'lab_convert_analyte',
  name: 'Conversion d\'un analyte',
  shortName: 'Convert — analyte',
  category: CalculatorCategory.laboratory,
  version: 'Convert 2 — base d\'analytes (formules brutes, poids atomiques IUPAC abrégés)',
  equation:
      'Masse molaire M = Σ (poids atomique × nombre d\'atomes de la formule brute)\n'
      'Concentration molaire = concentration massique / M ;  éq = mol × valence\n'
      'Même grandeur : facteurs de définition des unités',
  sources: [
    Reference(
      citation:
          'IUPAC / Commission on Isotopic Abundances and Atomic Weights (CIAAW). Standard atomic '
          'weights (valeurs conventionnelles abrégées).',
      note: 'masses molaires calculées à partir des formules brutes ; non validées localement',
    ),
    Reference(
      citation:
          'Bureau international des poids et mesures (BIPM). Le Système international d\'unités '
          '(SI), brochure, 9e édition, 2019 (préfixes SI, katal).',
    ),
  ],
  applicablePopulation: 'Sans objet (conversion de grandeurs, indépendante du patient).',
  analyticalConditions: [
    'La masse molaire correspond à la forme chimique indiquée pour l\'analyte (ex. phosphate exprimé '
        'en P, lactate en acide lactique, vitamine D en 25-OH-D3) : elle doit être celle de la forme '
        'dosée par votre méthode.',
  ],
  limitations: [
    'Statut de toutes les entrées de la base : NON VALIDÉ (aucune revue par un biologiste responsable).',
    'Les masses molaires sont calculées, jamais saisies de mémoire ; les analytes à masse molaire '
        'hétérogène (protéines, hormones peptidiques) ne proposent que des conversions massiques.',
    'Pour les analytes déjà gérés par les calculateurs, ceux-ci utilisent des facteurs arrondis : '
        'l\'écart éventuel est indiqué sous le résultat.',
  ],
  displayPrecision: 4,
);

/// Libellé d'une valeur numérique sans exposant parasite.
String _g(double v) => v.toString();

/// Convertit [value] de [fromUnit] vers [toUnit] pour l'analyte [analyteId]
/// de la base ; la masse molaire et la valence viennent de la base.
CalculationResult calculateAnalyteUnitConversion({
  required String analyteId,
  required double? value,
  required String fromUnit,
  required String toUnit,
}) {
  final analyte = AnalyteBase.byId(analyteId);
  if (analyte == null) {
    throw CalculationInputException([
      FieldError(fieldId: 'analyte', message: 'Analyte « $analyteId » inconnu de la base.'),
    ]);
  }
  final units = analyte.units;
  Validation.raiseIfAny([
    units.contains(fromUnit)
        ? null
        : FieldError(fieldId: 'fromUnit', message: 'Unité « $fromUnit » non proposée pour ${analyte.name}.'),
    units.contains(toUnit)
        ? null
        : FieldError(fieldId: 'toUnit', message: 'Unité « $toUnit » non proposée pour ${analyte.name}.'),
  ]);

  late final CalculationResult inner;
  if (analyte.kind == AnalyteKind.legacy) {
    inner = calculateAnalyteConversion(
        analyte: analyte.legacy!, value: value, fromUnit: fromUnit, toUnit: toUnit);
  } else {
    final m = analyte.kind == AnalyteKind.molecular ? analyte.molarMass : null;
    inner = calculateConversion(
      value: value,
      fromUnit: fromUnit,
      toUnit: toUnit,
      molarMassGPerMol: m,
      valence: analyte.valence?.toDouble(),
    );
  }

  final out = inner.values.first;
  final echoed = <String, String>{
    'Analyte': analyte.name,
    ...inner.echoedInputs.map((k, v) => MapEntry(
        k == 'Masse molaire saisie'
            ? 'Masse molaire utilisée (base d\'analytes)'
            : k == 'Valence saisie'
                ? 'Valence utilisée (base d\'analytes)'
                : k,
        v)),
    if (analyte.formulaText != null) 'Formule brute': analyte.formulaText!,
    'Statut de la base': AnalyteBase.statusOf(analyte.id).label,
  };

  final warnings = <CalculationWarning>[
    if (analyte.kind == AnalyteKind.molecular)
      CalculationWarning(
        'Masse molaire calculée à partir de la formule ${analyte.formulaText} et des poids '
        'atomiques IUPAC abrégés ; elle doit correspondre à la forme dosée par votre méthode. '
        'Base non validée par un biologiste responsable.',
        severity: WarningSeverity.caution,
      ),
    if (analyte.note != null) CalculationWarning(analyte.note!, severity: WarningSeverity.info),
    ...inner.warnings.where((w) =>
        !w.message.startsWith('La masse molaire est celle que vous avez saisie') &&
        !w.message.startsWith('La valence est celle que vous avez saisie')),
  ];

  // Écart avec le facteur arrondi des calculateurs, s'il existe pour cette paire d'unités.
  final legacy = analyte.legacy;
  if (analyte.kind == AnalyteKind.molecular && legacy != null) {
    final legacyUnits = UnitRegistry.unitsFor(legacy);
    if (legacyUnits.contains(fromUnit) && legacyUnits.contains(toUnit) && fromUnit != toUnit) {
      final old = UnitRegistry.convert(legacy, value!, fromUnit: fromUnit, toUnit: toUnit);
      final diff = out.value == 0 ? 0 : (old - out.value!) / out.value! * 100;
      warnings.add(CalculationWarning(
        'Les calculateurs de BioSigma utilisent un facteur arrondi pour ${analyte.name} : '
        '${_g(old)} $toUnit (écart de ${diff.abs().toStringAsFixed(3)} % avec ce résultat). '
        'Les calculs existants ne sont pas modifiés.',
        severity: WarningSeverity.info,
      ));
    }
  }

  return CalculationResult(
    formula: analyteConvertMeta,
    echoedInputs: echoed,
    values: [
      ResultValue(
        label: '${analyte.name} — valeur convertie',
        value: out.value,
        unit: out.unit,
        precision: out.precision,
      ),
    ],
    warnings: warnings,
  );
}
