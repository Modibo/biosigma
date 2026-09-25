import 'analyte.dart';
import 'unit_spec.dart';

/// Bibliothèque centrale de conversion d'unités.
///
/// Une unité canonique unique est choisie par analyte ; toute valeur
/// saisie est convertie vers cette unité avant calcul, et reconvertie pour
/// l'affichage. Les facteurs sont documentés avec leur source ; le facteur
/// insuline µU/mL ↔ pmol/L dépend de l'étalon international utilisé par le
/// dosage (1ère préparation de référence internationale OMS 66/304) et
/// doit être confirmé localement — voir `docs/tracabilite-scientifique.md`.
class UnitRegistry {
  UnitRegistry._();

  static const Map<Analyte, String> canonicalUnit = {
    Analyte.creatinine: 'µmol/L',
    Analyte.cystatinC: 'mg/L',
    Analyte.glucose: 'mmol/L',
    Analyte.triglycerides: 'mmol/L',
    Analyte.proteinuria: 'mg/L',
    Analyte.volume: 'mL',
    Analyte.duration: 'min',
    Analyte.albumin: 'g/L',
    Analyte.calcium: 'mmol/L',
    Analyte.fibrinogen: 'g/L',
    Analyte.insulin: 'µU/mL',
    Analyte.hba1c: '%',
    Analyte.cholesterol: 'mmol/L',
  };

  static const Map<Analyte, Map<String, UnitSpec>> _units = {
    Analyte.creatinine: {
      'µmol/L': UnitSpec('µmol/L', 1.0),
      // 1 mg/dL = 88,42 µmol/L (masse molaire créatinine 113,12 g/mol).
      'mg/dL': UnitSpec('mg/dL', 88.42),
    },
    Analyte.cystatinC: {
      'mg/L': UnitSpec('mg/L', 1.0),
    },
    Analyte.glucose: {
      'mmol/L': UnitSpec('mmol/L', 1.0),
      // 1 mg/dL = 0,0555 mmol/L (masse molaire glucose 180,16 g/mol).
      'mg/dL': UnitSpec('mg/dL', 0.0555),
    },
    Analyte.triglycerides: {
      'mmol/L': UnitSpec('mmol/L', 1.0),
      // Facteur usuel de conversion clinique (masse molaire moyenne ~885 g/mol).
      'mg/dL': UnitSpec('mg/dL', 0.0113),
    },
    Analyte.proteinuria: {
      'mg/L': UnitSpec('mg/L', 1.0),
      'g/L': UnitSpec('g/L', 1000.0),
      'mg/dL': UnitSpec('mg/dL', 10.0),
    },
    Analyte.volume: {
      'mL': UnitSpec('mL', 1.0),
      'L': UnitSpec('L', 1000.0),
    },
    Analyte.duration: {
      'min': UnitSpec('min', 1.0),
      'h': UnitSpec('h', 60.0),
    },
    Analyte.albumin: {
      'g/L': UnitSpec('g/L', 1.0),
      'g/dL': UnitSpec('g/dL', 10.0),
    },
    Analyte.calcium: {
      'mmol/L': UnitSpec('mmol/L', 1.0),
      // 1 mg/dL = 0,2495 mmol/L (masse molaire calcium 40,08 g/mol).
      'mg/dL': UnitSpec('mg/dL', 0.2495),
    },
    Analyte.fibrinogen: {
      'g/L': UnitSpec('g/L', 1.0),
      'mg/dL': UnitSpec('mg/dL', 0.01),
    },
    Analyte.insulin: {
      'µU/mL': UnitSpec('µU/mL', 1.0),
      // Facteur dépendant de l'étalon du dosage — à valider localement.
      'pmol/L': UnitSpec('pmol/L', 1 / 6.945),
    },
    Analyte.hba1c: {
      // NGSP/DCCT (%), unité canonique.
      '%': UnitSpec('%', 1.0),
      // IFCC (mmol/mol) → NGSP(%) : %  = (mmol/mol)/10,929 + 2,15
      // (équation-maître de standardisation IFCC-NGSP, Hoelzel et al. 2004).
      'mmol/mol': UnitSpec('mmol/mol', 1 / 10.929, offset: 2.15),
    },
    Analyte.cholesterol: {
      'mmol/L': UnitSpec('mmol/L', 1.0),
      // 1 g/L cholestérol = 2,586 mmol/L (masse molaire ~386,65 g/mol).
      // Conversions additionnelles (hors liste minimale du cahier des
      // charges) fournies par commodité pour les panels lipidiques, dont
      // les équations LDL historiques (Friedewald, Sampson) sont définies
      // en mg/dL.
      'g/L': UnitSpec('g/L', 2.586),
      'mg/dL': UnitSpec('mg/dL', 0.02586),
    },
  };

  /// Unités disponibles pour un analyte, dans un ordre stable pour l'UI.
  static List<String> unitsFor(Analyte analyte) =>
      List.unmodifiable(_units[analyte]!.keys);

  static double toCanonical(Analyte analyte, double value, String unit) {
    final spec = _units[analyte]?[unit];
    if (spec == null) {
      throw ArgumentError('Unité inconnue pour $analyte : "$unit"');
    }
    return spec.toCanonical(value);
  }

  static double fromCanonical(Analyte analyte, double canonicalValue, String unit) {
    final spec = _units[analyte]?[unit];
    if (spec == null) {
      throw ArgumentError('Unité inconnue pour $analyte : "$unit"');
    }
    return spec.fromCanonical(canonicalValue);
  }

  /// Convertit directement d'une unité vers une autre unité du même
  /// analyte, en passant par l'unité canonique.
  static double convert(
    Analyte analyte,
    double value, {
    required String fromUnit,
    required String toUnit,
  }) {
    if (fromUnit == toUnit) return value;
    return fromCanonical(analyte, toCanonical(analyte, value, fromUnit), toUnit);
  }
}
