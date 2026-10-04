import 'dart:math' as math;

import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';
import '../validation.dart';
import 'lab_units.dart';

const Reference _toVerify = Reference(
  citation:
      'Relations de définition (concentration = quantité / volume ; m = C × V × M ; '
      '% m/v = g pour 100 mL) : aucune norme citée — à relire par le laboratoire.',
);

/// Masse à peser pour une solution de concentration cible.
const FormulaMeta solutionPreparationMeta = FormulaMeta(
  id: 'lab_prepare_solution',
  name: 'Préparation d\'une solution : masse à peser',
  shortName: 'Prepare — masse',
  category: CalculatorCategory.laboratory,
  version: 'Prepare 1 — m = C × V (× M) / pureté',
  equation:
      'Concentration massique : m = C × V\n'
      'Concentration molaire : m = C × V × M   (M en g/mol, saisie)\n'
      'Masse à peser = m / (pureté % / 100)',
  sources: [_toVerify],
  applicablePopulation: 'Sans objet (préparation de réactif).',
  analyticalConditions: [
    'La masse molaire M doit être celle de la forme réellement pesée (sel, hydrate, forme libre).',
    'La pureté est celle indiquée sur le certificat du fabricant du lot utilisé.',
  ],
  limitations: [
    'Aucune masse molaire ni pureté n\'est embarquée : elles sont saisies par l\'utilisateur.',
    'Le volume saisi est le volume FINAL : dissoudre dans moins de solvant puis compléter au trait (qsp).',
  ],
  displayPrecision: 4,
);

/// Solution exprimée en pourcentage.
const FormulaMeta percentSolutionMeta = FormulaMeta(
  id: 'lab_prepare_percent',
  name: 'Préparation d\'une solution en pourcentage (m/v ou v/v)',
  shortName: 'Prepare — pourcentage',
  category: CalculatorCategory.laboratory,
  version: 'Prepare 1 — % m/v = g / 100 mL ; % v/v = mL / 100 mL',
  equation: 'Soluté = pourcentage × volume final / 100',
  sources: [_toVerify],
  applicablePopulation: 'Sans objet (préparation de réactif).',
  limitations: [
    '« % m/v » = grammes de soluté pour 100 mL de solution FINALE ; « % v/v » = mL de soluté pour '
        '100 mL de solution finale (les volumes ne sont pas strictement additifs).',
    'Le pourcentage massique (m/m) n\'est pas géré.',
  ],
  displayPrecision: 4,
);

/// Tampon : rapport base/acide par l'équation de Henderson-Hasselbalch.
const FormulaMeta bufferMeta = FormulaMeta(
  id: 'lab_prepare_buffer',
  name: 'Tampon (Henderson-Hasselbalch)',
  shortName: 'Prepare — tampon',
  category: CalculatorCategory.laboratory,
  version: 'Prepare 1 — pH = pKa + log10([A⁻]/[HA])',
  equation:
      'pH = pKa + log10([A⁻] / [HA])  ;  [A⁻]/[HA] = 10^(pH − pKa)\n'
      'n(A⁻) = C × V × r / (1 + r)  ;  n(HA) = C × V / (1 + r)   (r = [A⁻]/[HA])',
  sources: [
    Reference(
      citation:
          'Po HN, Senozan NM. The Henderson-Hasselbalch equation: its history and limitations. '
          'J Chem Educ. 2001;78(11):1499-1503.',
      note: 'citation à vérifier par le laboratoire',
    ),
  ],
  applicablePopulation: 'Sans objet (préparation de réactif).',
  analyticalConditions: [
    'Le pKa dépend de la température et de la force ionique : valeur saisie par l\'utilisateur, '
        'issue de sa source (fiche du réactif, littérature).',
  ],
  limitations: [
    'Approximation : activités assimilées aux concentrations. Ajuster et contrôler le pH final '
        'avec un pH-mètre étalonné.',
    'Aucun pKa n\'est embarqué.',
  ],
  displayPrecision: 4,
);

String _autoMass(double grams, List<ResultValue> out, String label) {
  final (value, unit) = grams >= 1
      ? (grams, 'g')
      : grams >= 1e-3
          ? (grams * 1e3, 'mg')
          : (grams * 1e6, 'µg');
  out.add(ResultValue(
      label: label, value: value, unit: unit, precision: LabUnits.decimalsForSignificant(value)));
  return '$value $unit';
}

/// Masse à peser pour obtenir [finalVolume] de solution à [targetConcentration].
///
/// Concentration massique : la masse molaire n'est pas utilisée. Concentration
/// molaire : [molarMassGPerMol] est obligatoire (jamais déduite).
CalculationResult calculateSolutionPreparation({
  required double? targetConcentration,
  required String concentrationUnit,
  required double? finalVolume,
  required String volumeUnit,
  double? molarMassGPerMol,
  double? purityPercent,
}) {
  final conc = LabUnits.require(concentrationUnit, 'targetConcentration', 'la concentration');
  final vol = LabUnits.require(volumeUnit, 'finalVolume', 'le volume');
  Validation.raiseIfAny([
    if (conc.dimension != LabDimension.massConcentration &&
        conc.dimension != LabDimension.molarConcentration)
      const FieldError(
          fieldId: 'targetConcentration',
          message: 'Une concentration massique (g/L, mg/mL…) ou molaire (mol/L, mmol/L…) est attendue.'),
    if (vol.dimension != LabDimension.volume)
      const FieldError(fieldId: 'finalVolume', message: 'Un volume est attendu (L, mL…).'),
  ]);
  final molar = conc.dimension == LabDimension.molarConcentration;
  Validation.raiseIfAny([
    Validation.checkPositive(targetConcentration, 'targetConcentration', 'La concentration cible'),
    Validation.checkPositive(finalVolume, 'finalVolume', 'Le volume final'),
    if (molar)
      molarMassGPerMol == null
          ? const FieldError(
              fieldId: 'molarMass',
              message: 'La masse molaire (g/mol) est requise pour une concentration molaire ; '
                  'BioSigma ne la déduit jamais.')
          : Validation.checkPositive(molarMassGPerMol, 'molarMass', 'La masse molaire'),
    if (purityPercent != null)
      Validation.checkInRange(purityPercent, 'purity', 'La pureté', min: 0.0000001, max: 100),
  ]);

  final volumeL = finalVolume! * vol.factorToBase;
  final base = targetConcentration! * conc.factorToBase; // g/L ou mol/L
  final pureGrams = molar ? base * volumeL * molarMassGPerMol! : base * volumeL;
  final purity = purityPercent ?? 100;
  final weighed = pureGrams / (purity / 100);

  final values = <ResultValue>[];
  _autoMass(weighed, values, purity == 100 ? 'Masse à peser' : 'Masse à peser (corrigée de la pureté)');
  if (purity != 100) _autoMass(pureGrams, values, 'Masse de soluté pur correspondante');

  return CalculationResult(
    formula: solutionPreparationMeta,
    echoedInputs: {
      'Concentration cible': '$targetConcentration ${conc.symbol}',
      'Volume final': '$finalVolume ${vol.symbol}',
      if (molar) 'Masse molaire saisie': '$molarMassGPerMol g/mol',
      'Pureté saisie': '$purity %',
    },
    values: values,
    warnings: [
      if (molar)
        const CalculationWarning(
          'La masse molaire est celle que vous avez saisie ; BioSigma ne la vérifie pas '
          '(forme réellement pesée : sel, hydrate, forme libre).',
          severity: WarningSeverity.caution,
        ),
      if (purityPercent == null)
        const CalculationWarning(
          'Pureté non précisée : 100 % supposé. Corrigez si le certificat indique moins.',
          severity: WarningSeverity.caution,
        ),
      const CalculationWarning(
        'Dissoudre dans un peu moins de solvant, puis compléter au volume final (qsp).',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

/// Solution en pourcentage : [kind] = `mv` (g pour 100 mL) ou `vv` (mL pour 100 mL).
CalculationResult calculatePercentSolution({
  required double? percent,
  required String kind,
  required double? finalVolume,
  required String volumeUnit,
}) {
  final vol = LabUnits.require(volumeUnit, 'finalVolume', 'le volume');
  Validation.raiseIfAny([
    kind == 'mv' || kind == 'vv'
        ? null
        : const FieldError(fieldId: 'kind', message: 'Type de pourcentage inconnu (m/v ou v/v).'),
    vol.dimension == LabDimension.volume
        ? null
        : const FieldError(fieldId: 'finalVolume', message: 'Un volume est attendu (L, mL…).'),
    Validation.checkInRange(percent, 'percent', 'Le pourcentage', min: 0.0000001, max: 100),
    Validation.checkPositive(finalVolume, 'finalVolume', 'Le volume final'),
  ]);

  final volumeMl = finalVolume! * vol.factorToBase * 1000;
  final amount = percent! * volumeMl / 100; // g (m/v) ou mL (v/v)
  final values = <ResultValue>[];
  if (kind == 'mv') {
    _autoMass(amount, values, 'Masse de soluté à peser');
  } else {
    final (v, u) = amount >= 1 ? (amount, 'mL') : (amount * 1000, 'µL');
    values.add(ResultValue(
        label: 'Volume de soluté à prélever',
        value: v,
        unit: u,
        precision: LabUnits.decimalsForSignificant(v)));
  }
  return CalculationResult(
    formula: percentSolutionMeta,
    echoedInputs: {
      'Pourcentage': '$percent % ${kind == 'mv' ? 'm/v' : 'v/v'}',
      'Volume final': '$finalVolume ${vol.symbol}',
    },
    values: values,
    warnings: const [
      CalculationWarning(
        'Compléter ensuite avec le solvant jusqu\'au volume final (qsp).',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

/// Composition d'un tampon à un pH donné pour un pKa **saisi**.
CalculationResult calculateBuffer({
  required double? targetPh,
  required double? pKa,
  required double? totalConcentration,
  required String concentrationUnit,
  required double? finalVolume,
  required String volumeUnit,
}) {
  final conc = LabUnits.require(concentrationUnit, 'totalConcentration', 'la concentration');
  final vol = LabUnits.require(volumeUnit, 'finalVolume', 'le volume');
  Validation.raiseIfAny([
    conc.dimension == LabDimension.molarConcentration
        ? null
        : const FieldError(
            fieldId: 'totalConcentration', message: 'Une concentration molaire (mol/L, mmol/L…) est attendue.'),
    vol.dimension == LabDimension.volume
        ? null
        : const FieldError(fieldId: 'finalVolume', message: 'Un volume est attendu.'),
    Validation.checkInRange(targetPh, 'targetPh', 'Le pH cible', min: 0, max: 14),
    Validation.checkInRange(pKa, 'pKa', 'Le pKa', min: -5, max: 20),
    Validation.checkPositive(totalConcentration, 'totalConcentration', 'La concentration totale du tampon'),
    Validation.checkPositive(finalVolume, 'finalVolume', 'Le volume final'),
  ]);

  final ratio = math.pow(10, targetPh! - pKa!).toDouble(); // [A-]/[HA]
  final totalMol = totalConcentration! * conc.factorToBase * finalVolume! * vol.factorToBase;
  final molBase = totalMol * ratio / (1 + ratio);
  final molAcid = totalMol / (1 + ratio);

  ResultValue amount(String label, double mol) {
    final (v, u) = mol >= 1
        ? (mol, 'mol')
        : mol >= 1e-3
            ? (mol * 1e3, 'mmol')
            : (mol * 1e6, 'µmol');
    return ResultValue(label: label, value: v, unit: u, precision: LabUnits.decimalsForSignificant(v));
  }

  return CalculationResult(
    formula: bufferMeta,
    echoedInputs: {
      'pH cible': '$targetPh',
      'pKa saisi': '$pKa',
      'Concentration totale du tampon': '$totalConcentration ${conc.symbol}',
      'Volume final': '$finalVolume ${vol.symbol}',
    },
    values: [
      ResultValue(label: 'Rapport [A⁻]/[HA]', value: ratio, unit: '', precision: 4),
      ResultValue(
          label: 'Fraction de forme basique (A⁻)',
          value: ratio / (1 + ratio) * 100,
          unit: '%',
          precision: 2),
      amount('Quantité de forme basique (A⁻)', molBase),
      amount('Quantité de forme acide (HA)', molAcid),
    ],
    warnings: [
      const CalculationWarning(
        'Le pKa est celui que vous avez saisi ; il dépend de la température et de la force '
        'ionique. Contrôlez le pH final avec un pH-mètre étalonné.',
        severity: WarningSeverity.caution,
      ),
      if ((targetPh - pKa).abs() > 1)
        const CalculationWarning(
          'pH cible éloigné du pKa de plus d\'une unité : le pouvoir tampon est faible '
          '(constat qualitatif, sans seuil normatif).',
          severity: WarningSeverity.caution,
        ),
    ],
  );
}
