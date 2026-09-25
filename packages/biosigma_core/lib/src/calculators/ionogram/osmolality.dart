import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// Osmolarité calculée (Smithline-Gardner 1976) et trou osmolaire optionnel
/// lorsqu'une osmolalité mesurée par osmométrie est disponible.
const FormulaMeta calculatedOsmolarityOsmolarGapMeta = FormulaMeta(
  id: 'calculated_osmolarity_osmolar_gap',
  name: 'Osmolarité calculée et trou osmolaire',
  shortName: 'Osmolarité calculée',
  category: CalculatorCategory.ionogram,
  version: 'Smithline-Gardner 1976',
  equation:
      'Osmolarité calculée = 2×Na + Glycémie(mmol/L) + Urée(mmol/L)  ;  '
      'Trou osmolaire = Osmolalité mesurée − Osmolarité calculée',
  sources: [
    Reference(
      citation:
          'Smithline N, Gardner KD Jr. Gaps—Anionic and Osmolal. JAMA. '
          '1976;236(14):1594-1597.',
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    "Le trou osmolaire ne doit être calculé que si une osmolalité mesurée "
        "par osmométrie (point de congélation) est disponible, jamais "
        "estimée.",
    "Osmolarité (par litre de solution) et osmolalité (par kg d'eau) ne "
        "sont pas rigoureusement identiques, bien qu'assimilées en pratique "
        "clinique courante.",
  ],
  helpText: 'Urée en mmol/L — et non azote uréique / BUN.',
);

/// Osmolarité calculée à partir du sodium, de la glycémie et de l'urée, et
/// trou osmolaire si une osmolalité mesurée est fournie séparément.
///
/// Convention : lorsque `measuredOsmolalityValue` est `null`, aucun
/// [ResultValue] de trou osmolaire n'est ajouté à `values` (il n'est ni
/// omis avec `value: null`, ni estimé) — le trou osmolaire n'apparaît que
/// s'il a été effectivement calculable à partir d'une osmolalité mesurée.
CalculationResult calculateCalculatedOsmolarity({
  required double sodiumValue,
  required double glucoseValue,
  required String glucoseUnit,
  required double ureaValue,
  double? measuredOsmolalityValue,
}) {
  final sodiumError = Validation.checkProvided(sodiumValue, 'sodiumValue', 'Sodium');
  final glucoseError = Validation.checkNonNegative(glucoseValue, 'glucoseValue', 'Glycémie');
  final ureaError = Validation.checkNonNegative(ureaValue, 'ureaValue', 'Urée');
  Validation.raiseIfAny([sodiumError, glucoseError, ureaError]);

  if (measuredOsmolalityValue != null) {
    Validation.raiseIfAny([
      Validation.checkNonNegative(
          measuredOsmolalityValue, 'measuredOsmolalityValue', 'Osmolalité mesurée'),
    ]);
  }

  final glucoseCanonicalMmolL =
      UnitRegistry.toCanonical(Analyte.glucose, glucoseValue, glucoseUnit);

  final osmCalculee = 2 * sodiumValue + glucoseCanonicalMmolL + ureaValue;

  final values = <ResultValue>[
    ResultValue(
      label: 'Osmolarité calculée',
      value: osmCalculee,
      unit: 'mOsm/L',
      precision: 1,
    ),
  ];

  final echoedInputs = <String, String>{
    'Sodium': '${sodiumValue.toStringAsFixed(1)} mmol/L',
    'Glycémie': glucoseUnit == 'mmol/L'
        ? '${glucoseValue.toStringAsFixed(2)} mmol/L'
        : '${glucoseValue.toStringAsFixed(2)} $glucoseUnit (${glucoseCanonicalMmolL.toStringAsFixed(2)} mmol/L)',
    'Urée': '${ureaValue.toStringAsFixed(1)} mmol/L',
  };

  if (measuredOsmolalityValue != null) {
    echoedInputs['Osmolalité mesurée'] = '${measuredOsmolalityValue.toStringAsFixed(1)} mOsm/kg';
    final trouOsmolaire = measuredOsmolalityValue - osmCalculee;
    values.add(ResultValue(
      label: 'Trou osmolaire (osmolalité mesurée − osmolarité calculée)',
      value: trouOsmolaire,
      unit: 'mOsm/kg',
      precision: 1,
    ));
  }

  return CalculationResult(
    formula: calculatedOsmolarityOsmolarGapMeta,
    echoedInputs: echoedInputs,
    values: values,
  );
}
