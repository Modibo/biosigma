import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';
import '../units/analyte.dart';
import '../units/unit_registry.dart';
import '../validation.dart';
import 'lab_units.dart';

const Reference _siReference = Reference(
  citation:
      'Bureau international des poids et mesures (BIPM). Le Système '
      'international d\'unités (SI), brochure, 9e édition, 2019.',
  note: 'définition des préfixes SI (puissances de dix)',
);

/// Conversion de grandeurs de laboratoire par préfixes SI, avec masse
/// molaire ou valence fournie par l'utilisateur si la nature de la grandeur
/// change.
const FormulaMeta convertMeta = FormulaMeta(
  id: 'lab_convert',
  name: 'Conversion de grandeurs et d\'unités',
  shortName: 'Convert',
  category: CalculatorCategory.laboratory,
  version: 'Convert 1 — préfixes SI ; masse molaire et valence saisies',
  equation:
      'Même grandeur : valeur × (facteur de l\'unité de départ / facteur de l\'unité d\'arrivée)\n'
      'Masse → quantité de matière : n = m / M   (M en g/mol, saisie)\n'
      'Quantité de matière → équivalents : éq = n × z   (z : valence, saisie)',
  sources: [_siReference],
  applicablePopulation: 'Sans objet (conversion de grandeurs, indépendante du patient).',
  analyticalConditions: [
    'La masse molaire doit correspondre à la forme chimique réellement dosée '
        '(sel, hydrate, forme libre) : BioSigma ne la fournit pas et ne la vérifie pas.',
  ],
  limitations: [
    'Aucune masse molaire n\'est embarquée dans cette conversion : elle est '
        'toujours saisie par l\'utilisateur, qui en est responsable.',
    'Les conversions propres à un analyte (ex. créatinine mg/dL ↔ µmol/L) utilisent les '
        'facteurs arrondis du moteur existant, non validés par un biologiste responsable.',
  ],
  displayPrecision: 4,
  helpText: 'Choisissez une valeur, son unité de départ et l\'unité d\'arrivée.',
);

double _toMol(double base, LabDimension kind, double? molarMass, double? valence) =>
    switch (kind) {
      LabDimension.mass => base / molarMass!,
      LabDimension.equivalent => base / valence!,
      _ => base,
    };

double _fromMol(double mol, LabDimension kind, double? molarMass, double? valence) =>
    switch (kind) {
      LabDimension.mass => mol * molarMass!,
      LabDimension.equivalent => mol * valence!,
      _ => mol,
    };

String _num(double v) => v.toString();

/// Convertit [value] de [fromUnit] vers [toUnit].
///
/// Même grandeur : simple mise à l'échelle SI. Nature de grandeur
/// différente (masse, quantité de matière, équivalents) : [molarMassGPerMol]
/// et/ou [valence] sont **obligatoires** ; ils ne sont jamais déduits.
CalculationResult calculateConversion({
  required double? value,
  required String fromUnit,
  required String toUnit,
  double? molarMassGPerMol,
  double? valence,
}) {
  final valueError = Validation.checkProvided(value, 'value', 'La valeur');
  Validation.raiseIfAny([valueError]);

  final from = LabUnits.require(fromUnit, 'fromUnit', 'l\'unité de départ');
  final to = LabUnits.require(toUnit, 'toUnit', 'l\'unité d\'arrivée');

  final fromIsConc = from.isConcentration;
  final toIsConc = to.isConcentration;
  final fromVolume = from.dimension == LabDimension.volume;
  final toVolume = to.dimension == LabDimension.volume;
  if (fromIsConc != toIsConc || fromVolume != toVolume) {
    throw CalculationInputException([
      FieldError(
        fieldId: 'toUnit',
        message: 'Conversion impossible : « $fromUnit » (${from.dimension.label}) et '
            '« $toUnit » (${to.dimension.label}) ne sont pas comparables '
            '(une concentration ne se convertit pas en quantité ni en volume).',
      ),
    ]);
  }

  final fromKind = from.quantityKind;
  final toKind = to.quantityKind;
  final needsMolarMass = !fromVolume &&
      fromKind != toKind &&
      (fromKind == LabDimension.mass || toKind == LabDimension.mass);
  final needsValence = !fromVolume &&
      fromKind != toKind &&
      (fromKind == LabDimension.equivalent || toKind == LabDimension.equivalent);

  final errors = <FieldError?>[];
  if (needsMolarMass) {
    errors.add(molarMassGPerMol == null
        ? const FieldError(
            fieldId: 'molarMass',
            message: 'La masse molaire (g/mol) est requise pour passer d\'une masse à une '
                'quantité de matière ; BioSigma ne la déduit jamais.')
        : Validation.checkPositive(molarMassGPerMol, 'molarMass', 'La masse molaire'));
  }
  if (needsValence) {
    errors.add(valence == null
        ? const FieldError(
            fieldId: 'valence',
            message: 'La valence est requise pour passer de moles à des équivalents ; '
                'BioSigma ne la déduit jamais.')
        : Validation.checkPositive(valence, 'valence', 'La valence'));
  }
  Validation.raiseIfAny(errors);

  final base = value! * from.factorToBase;
  final double converted;
  if (fromKind == toKind) {
    converted = base / to.factorToBase;
  } else {
    final mol = _toMol(base, fromKind, molarMassGPerMol, valence);
    converted = _fromMol(mol, toKind, molarMassGPerMol, valence) / to.factorToBase;
  }

  final method = fromKind == toKind
      ? 'mise à l\'échelle par préfixes SI'
      : 'passage par la quantité de matière'
          '${needsMolarMass ? ' avec la masse molaire saisie' : ''}'
          '${needsMolarMass && needsValence ? ' et' : ''}'
          '${needsValence ? ' avec la valence saisie' : ''}';

  return CalculationResult(
    formula: convertMeta,
    echoedInputs: {
      'Valeur saisie': '${_num(value)} $fromUnit',
      'Conversion vers': toUnit,
      'Méthode': method,
      if (needsMolarMass) 'Masse molaire saisie': '${_num(molarMassGPerMol!)} g/mol',
      if (needsValence) 'Valence saisie': _num(valence!),
    },
    values: [
      ResultValue(
        label: 'Valeur convertie',
        value: converted,
        unit: to.symbol,
        precision: LabUnits.decimalsForSignificant(converted),
      ),
    ],
    warnings: [
      if (needsMolarMass)
        const CalculationWarning(
          'La masse molaire est celle que vous avez saisie ; BioSigma ne la vérifie pas. '
          'Elle doit correspondre à la forme chimique dosée (sel, hydrate, forme libre).',
          severity: WarningSeverity.caution,
        ),
      if (needsValence)
        const CalculationWarning(
          'La valence est celle que vous avez saisie ; BioSigma ne la vérifie pas.',
          severity: WarningSeverity.caution,
        ),
    ],
  );
}

/// Libellés français des analytes dont le moteur connaît la conversion
/// (facteurs existants de [UnitRegistry]).
const Map<Analyte, String> analyteConversionLabels = {
  Analyte.creatinine: 'Créatinine',
  Analyte.cystatinC: 'Cystatine C',
  Analyte.glucose: 'Glucose',
  Analyte.triglycerides: 'Triglycérides',
  Analyte.proteinuria: 'Protéinurie',
  Analyte.albumin: 'Albumine',
  Analyte.calcium: 'Calcium',
  Analyte.fibrinogen: 'Fibrinogène',
  Analyte.insulin: 'Insuline',
  Analyte.hba1c: 'HbA1c',
  Analyte.cholesterol: 'Cholestérol',
};

/// Conversion d'un analyte clinique avec les facteurs **déjà utilisés par
/// les calculateurs de BioSigma** (`UnitRegistry`), repris à l'identique.
///
/// Ces facteurs sont arrondis et non validés par un biologiste responsable
/// (statut : non validé) ; aucun nouveau facteur n'est introduit ici.
CalculationResult calculateAnalyteConversion({
  required Analyte analyte,
  required double? value,
  required String fromUnit,
  required String toUnit,
}) {
  final valueError = Validation.checkProvided(value, 'value', 'La valeur');
  Validation.raiseIfAny([valueError]);
  final units = UnitRegistry.unitsFor(analyte);
  Validation.raiseIfAny([
    units.contains(fromUnit)
        ? null
        : FieldError(fieldId: 'fromUnit', message: 'Unité « $fromUnit » inconnue pour cet analyte.'),
    units.contains(toUnit)
        ? null
        : FieldError(fieldId: 'toUnit', message: 'Unité « $toUnit » inconnue pour cet analyte.'),
  ]);

  final converted = UnitRegistry.convert(analyte, value!, fromUnit: fromUnit, toUnit: toUnit);
  final label = analyteConversionLabels[analyte] ?? analyte.name;
  return CalculationResult(
    formula: convertMeta,
    echoedInputs: {
      'Analyte': label,
      'Valeur saisie': '${_num(value)} $fromUnit',
      'Conversion vers': toUnit,
      'Méthode': 'facteur du moteur BioSigma pour cet analyte',
    },
    values: [
      ResultValue(
        label: '$label — valeur convertie',
        value: converted,
        unit: toUnit,
        precision: LabUnits.decimalsForSignificant(converted),
      ),
    ],
    warnings: [
      const CalculationWarning(
        'Facteurs de conversion arrondis, identiques à ceux utilisés par les calculateurs '
        'de BioSigma ; ils n\'ont pas été validés par un biologiste responsable.',
        severity: WarningSeverity.info,
      ),
      if (analyte == Analyte.insulin)
        const CalculationWarning(
          'Le facteur µU/mL ↔ pmol/L dépend de l\'étalon du dosage : à confirmer localement.',
          severity: WarningSeverity.caution,
        ),
    ],
  );
}
