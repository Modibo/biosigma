import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// Trou anionique — Emmett-Narins 1977 (avec variante potassium), avec
/// correction optionnelle pour l'albuminémie (Figge 1998).
const FormulaMeta anionGapMeta = FormulaMeta(
  id: 'anion_gap',
  name: 'Trou anionique',
  shortName: 'Trou anionique',
  category: CalculatorCategory.ionogram,
  version: 'Emmett-Narins 1977 (± K), correction albumine Figge 1998',
  equation:
      'Trou anionique = Na − (Cl + HCO3)  ;  avec K : (Na+K) − (Cl+HCO3)  ;  '
      'corrigé albumine : Trou anionique + 2,5 × (4,0 − Albumine g/dL)',
  sources: [
    Reference(
      citation:
          'Emmett M, Narins RG. Clinical Use of the Anion Gap. Medicine '
          '(Baltimore). 1977;56(1):38-54.',
    ),
    Reference(
      citation:
          'Figge J, Jabor A, Kazda A, Fencl V. Anion Gap and Hypoalbuminemia. '
          'Crit Care Med. 1998;26(11):1807-1810.',
      note: 'correction albumine',
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    'Les valeurs de référence dépendent de la méthode de dosage du chlore et '
        'des bicarbonates du laboratoire (photométrie, potentiométrie '
        'indirecte/directe) ; ne pas appliquer un seuil universel.',
  ],
  helpText: 'Sodium, chlore, bicarbonates et potassium en mmol/L.',
);

/// Trou anionique, avec variante incluant le potassium et correction
/// optionnelle pour l'albuminémie (convention Figge 1998, appliquée à la
/// variante sans potassium).
CalculationResult calculateAnionGap({
  required double sodiumValue,
  required double chlorideValue,
  required double bicarbonateValue,
  double? potassiumValue,
  double? albuminValue,
  String? albuminUnit,
}) {
  final sodiumError = Validation.checkProvided(sodiumValue, 'sodiumValue', 'Sodium');
  final chlorideError = Validation.checkProvided(chlorideValue, 'chlorideValue', 'Chlore');
  final bicarbonateError =
      Validation.checkNonNegative(bicarbonateValue, 'bicarbonateValue', 'Bicarbonates');
  Validation.raiseIfAny([sodiumError, chlorideError, bicarbonateError]);

  if (potassiumValue != null) {
    Validation.raiseIfAny([
      Validation.checkNonNegative(potassiumValue, 'potassiumValue', 'Potassium'),
    ]);
  }
  if (albuminValue != null) {
    Validation.raiseIfAny([
      Validation.checkPositive(albuminValue, 'albuminValue', 'Albuminémie'),
    ]);
  }

  final agSansK = sodiumValue - (chlorideValue + bicarbonateValue);

  final String agCategory;
  if (agSansK < 8) {
    agCategory = 'bas';
  } else if (agSansK <= 12) {
    agCategory = 'normal';
  } else {
    agCategory = 'élevé';
  }
  final warnings = <CalculationWarning>[
    CalculationWarning(
      'Trou anionique (sans potassium) : $agCategory (repère habituel '
      '≈ 8-12 mmol/L, enseignement classique de biochimie clinique — '
      'Emmett & Narins 1977). Un trou anionique élevé oriente vers une '
      'acidose métabolique à trou anionique augmenté et impose une '
      'recherche étiologique (ex. lactates, cétones, toxiques '
      '[méthanol, éthylène glycol, salicylés], insuffisance rénale — '
      "catégories classiquement résumées par l'acronyme MUDPILES) ; un "
      'trou anionique bas a peu de valeur diagnostique isolée (à '
      "évoquer notamment en cas d'hypoalbuminémie).",
      severity: WarningSeverity.info,
    ),
  ];

  final echoedInputs = <String, String>{
    'Sodium': '${sodiumValue.toStringAsFixed(1)} mmol/L',
    'Chlore': '${chlorideValue.toStringAsFixed(1)} mmol/L',
    'Bicarbonates': '${bicarbonateValue.toStringAsFixed(1)} mmol/L',
  };

  final values = <ResultValue>[
    ResultValue(
      label: 'Trou anionique (sans potassium)',
      value: agSansK,
      unit: 'mmol/L',
    ),
  ];

  if (potassiumValue != null) {
    echoedInputs['Potassium'] = '${potassiumValue.toStringAsFixed(1)} mmol/L';
    final agAvecK = (sodiumValue + potassiumValue) - (chlorideValue + bicarbonateValue);
    values.add(ResultValue(
      label: 'Trou anionique (avec potassium)',
      value: agAvecK,
      unit: 'mmol/L',
    ));
  }

  if (albuminValue != null) {
    final albuminUnitResolved = albuminUnit ?? 'g/L';
    final albuminCanonicalGL =
        UnitRegistry.toCanonical(Analyte.albumin, albuminValue, albuminUnitResolved);
    final albuminGDl = UnitRegistry.fromCanonical(Analyte.albumin, albuminCanonicalGL, 'g/dL');
    echoedInputs['Albuminémie'] = albuminUnitResolved == 'g/L'
        ? '${albuminValue.toStringAsFixed(1)} g/L'
        : '${albuminValue.toStringAsFixed(2)} $albuminUnitResolved (${albuminCanonicalGL.toStringAsFixed(1)} g/L)';
    final agCorrige = agSansK + 2.5 * (4.0 - albuminGDl);
    values.add(ResultValue(
      label: "Trou anionique corrigé pour l'albuminémie",
      value: agCorrige,
      unit: 'mmol/L',
    ));
    warnings.add(const CalculationWarning(
      "La correction pour l'albuminémie vise à démasquer un trou "
      'anionique élevé faussement normalisé par une hypoalbuminémie ; le '
      'même repère habituel (≈ 8-12 mmol/L) est usuellement appliqué à '
      'la valeur corrigée.',
      severity: WarningSeverity.info,
    ));
  }

  return CalculationResult(
    formula: anionGapMeta,
    echoedInputs: echoedInputs,
    values: values,
    warnings: warnings,
  );
}
