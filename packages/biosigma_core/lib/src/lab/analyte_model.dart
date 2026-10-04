import '../units/analyte.dart';
import '../units/unit_registry.dart';
import 'lab_units.dart';

/// Catégories des analytes (libellés affichés dans Convert).
const String catElectrolytes = 'Électrolytes et minéraux';
const String catMetabolites = 'Métabolites';
const String catLipids = 'Lipides';
const String catHormones = 'Hormones';
const String catVitamins = 'Vitamines';
const String catDrugs = 'Médicaments et toxiques';
const String catProteins = 'Protéines et marqueurs (conversions massiques)';
const String catEnzymes = 'Enzymes (activité catalytique)';
const String catHematology = 'Hématologie';
const String catPhysiology = 'Gaz du sang, physiologie';

/// Précaution commune aux entrées sans masse molaire fiable.
const String massOnlyNote =
    'Masse molaire hétérogène ou non sourcée : seules les conversions massiques sont proposées '
    '(pour une conversion molaire, utilisez le mode Unités avec une masse molaire saisie).';

/// Poids atomiques standard **abrégés** (valeurs conventionnelles).
///
/// Source : Commission sur les abondances isotopiques et les poids atomiques
/// (CIAAW) de l'IUPAC, « Standard atomic weights » (valeurs abrégées). Les
/// masses molaires de la base d'analytes sont **calculées** à partir de ces
/// poids et de la formule brute : aucune masse molaire n'est saisie « de
/// mémoire ». Statut : non validé par un biologiste responsable (D-12).
const Map<String, double> atomicWeights = {
  'H': 1.008, 'Li': 6.94, 'C': 12.011, 'N': 14.007, 'O': 15.999, 'Na': 22.990, 'Mg': 24.305,
  'P': 30.974, 'S': 32.06, 'Cl': 35.45, 'K': 39.098, 'Ca': 40.078, 'Co': 58.933, 'Fe': 55.845,
  'Cu': 63.546, 'Zn': 65.38, 'Se': 78.971, 'I': 126.904, 'Hg': 200.59, 'Pb': 207.2,
  'Al': 26.982, 'Cr': 51.996, 'Mn': 54.938, 'Ni': 58.693, 'As': 74.922, 'Mo': 95.95, 'Cd': 112.41,
};

/// Nature d'un analyte du menu Convert : détermine les unités proposées.
enum AnalyteKind {
  /// Formule brute connue : masse molaire calculée, conversions masse ↔ mol.
  molecular,

  /// Masse molaire hétérogène ou non sourcée : conversions massiques seulement.
  massOnly,

  /// Facteurs du moteur existant (insuline, HbA1c) via `UnitRegistry`.
  legacy,

  /// Activité enzymatique (U/L ↔ katal), par définition.
  enzyme,

  /// Numération cellulaire (par litre, par µL, par mm³).
  cellCount,
  pressure,
  temperature,
  fraction,
  osmolality,
  clearance,
}

/// Un analyte (ou une grandeur) proposé par Convert.
class LabAnalyte {
  const LabAnalyte({
    required this.id,
    required this.name,
    required this.category,
    required this.kind,
    this.formula,
    this.formulaText,
    this.valence,
    this.note,
    this.urine24h = false,
    this.legacy,
  });

  final String id;
  final String name;
  final String category;
  final AnalyteKind kind;

  /// Formule brute : élément → nombre d'atomes (ex. glucose C6H12O6).
  final Map<String, int>? formula;
  final String? formulaText;

  /// Valence de l'ion ou de la forme dosée (éq), `null` si non définie.
  final int? valence;

  /// Forme chimique de référence et précautions (ex. « exprimé en P »).
  final String? note;

  /// Proposer aussi les unités d'excrétion (g/24 h, mmol/24 h…).
  final bool urine24h;

  /// Analyte correspondant du moteur existant, s'il y en a un.
  final Analyte? legacy;

  /// Masse molaire (g/mol) calculée par la formule brute, ou `null`.
  double? get molarMass {
    final f = formula;
    if (f == null) return null;
    var sum = 0.0;
    for (final e in f.entries) {
      sum += atomicWeights[e.key]! * e.value;
    }
    return sum;
  }

  /// Unités comparables à [fromUnit] pour cet analyte : une concentration ne
  /// se convertit qu'en concentration, une excrétion (par temps) qu'en
  /// excrétion, etc.
  List<String> compatibleUnits(String fromUnit) {
    if (kind == AnalyteKind.legacy) return units;
    final family = LabUnits.parse(fromUnit)?.family;
    return units.where((u) => LabUnits.parse(u)?.family == family).toList(growable: false);
  }

  /// Unités proposées pour cet analyte.
  List<String> get units {
    final rates = urine24h
        ? [
            ...LabUnits.massRates,
            if (kind == AnalyteKind.molecular) ...LabUnits.amountRates,
            if (kind == AnalyteKind.molecular && valence != null) ...LabUnits.equivalentRates,
          ]
        : const <String>[];
    switch (kind) {
      case AnalyteKind.molecular:
        return [
          ...LabUnits.massConcentrations,
          ...LabUnits.molarConcentrations,
          if (valence != null) ...LabUnits.equivalentConcentrations,
          ...rates,
        ];
      case AnalyteKind.massOnly:
        return [...LabUnits.massConcentrations, ...rates];
      case AnalyteKind.legacy:
        return UnitRegistry.unitsFor(legacy!);
      case AnalyteKind.enzyme:
        return LabUnits.catalyticConcentrations;
      case AnalyteKind.cellCount:
        return LabUnits.cellConcentrations;
      case AnalyteKind.pressure:
        return LabUnits.pressures;
      case AnalyteKind.temperature:
        return LabUnits.temperatures;
      case AnalyteKind.fraction:
        return LabUnits.fractions;
      case AnalyteKind.osmolality:
        return LabUnits.osmolalities;
      case AnalyteKind.clearance:
        return LabUnits.bsaClearances;
    }
  }
}

