
import '../../models/errors.dart';
import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';
import 'shared_formulas.dart';

/// Indice de masse corporelle (IMC / BMI).
///
/// La classification OMS 2000 est une classification universellement
/// reconnue (à la différence des autres indices composites de ce fichier) :
/// elle est donc affichée systématiquement, sous forme d'avertissement
/// informatif (`WarningSeverity.info`) accompagnant le résultat, sans jamais
/// constituer un verdict diagnostique automatique — voir [limitations] pour
/// les réserves (populations, masse grasse/maigre, seuils ethniques).
const FormulaMeta bmiMeta = FormulaMeta(
  id: 'bmi',
  name: 'Indice de masse corporelle (IMC)',
  shortName: 'IMC',
  category: CalculatorCategory.metabolic,
  version: 'Quetelet 1832 — cadre clinique OMS 2000',
  equation: 'IMC = Poids (kg) / [Taille (m)]²',
  sources: [
    Reference(
      citation:
          "Quetelet LAJ. Recherches sur le poids de l'homme aux différents "
          'âges. Mémoires de l\'Académie Royale des Sciences et '
          'Belles-Lettres de Bruxelles. 1832;7.',
      note: 'origine historique de l\'indice (indice de Quetelet)',
    ),
    Reference(
      citation:
          'World Health Organization. Obesity: Preventing and Managing the '
          'Global Epidemic. Report of a WHO Consultation. WHO Technical '
          'Report Series 894. Geneva: World Health Organization; 2000.',
      note: 'cadre clinique et bandes de classification OMS',
    ),
  ],
  applicablePopulation:
      "Adulte ≥ 18 ans (formule non adaptée à l'enfant et à l'adolescent, "
      'qui nécessitent des courbes de croissance IMC-pour-âge spécifiques).',
  limitations: [
    "Les bandes de l'OMS (maigreur < 18,5 ; poids normal 18,5–24,9 ; "
        'surpoids 25,0–29,9 ; obésité ≥ 30,0 kg/m²) sont affichées à titre '
        "informatif (avertissement de sévérité « info ») ; elles ne "
        "constituent jamais un verdict diagnostique automatique — "
        "l'interprétation clinique individuelle relève du biologiste ou du "
        'clinicien.',
    'Ne distingue pas la masse grasse de la masse maigre : peu fiable chez '
        'le sportif très musclé, la personne âgée sarcopénique, la femme '
        "enceinte ou en cas d'œdèmes/ascite.",
    'Les seuils de surpoids/obésité diffèrent selon certaines '
        "recommandations ethniques (ex. seuils abaissés proposés pour les "
        "populations asiatiques) — non pris en charge automatiquement ici.",
  ],
  displayPrecision: 1,
);

/// Indice TyG-IMC (Triglyceride Glucose-BMI index).
const FormulaMeta tygBmiMeta = FormulaMeta(
  id: 'tyg_bmi',
  name: 'Indice TyG-IMC (Triglyceride Glucose-BMI)',
  shortName: 'TyG-IMC',
  category: CalculatorCategory.metabolic,
  version:
      "Er 2016 — TyG-IMC = indice TyG (convention Simental-Mendía) × IMC",
  equation:
      'TyG = ln[(Triglycérides à jeun, mg/dL × Glycémie à jeun, mg/dL) / 2] '
      ' ;  TyG-IMC = TyG × IMC (kg/m²)',
  sources: [
    Reference(
      citation:
          'Er LK, Wu S, Chou HH, Hsu LA, Teng MS, Sun YC, Ko YL. Prediction '
          'of Insulin Resistance by Fasting Serum Glucose × '
          'Triglyceride/Body Mass Index in a Population without Diabetes. '
          'PLoS One. 2016;11(3):e0149731.',
      note: 'définition du TyG-IMC',
    ),
    Reference(
      citation:
          'Simental-Mendía LE, Rodríguez-Morán M, Guerrero-Romero F. The '
          'Product of Fasting Glucose and Triglycerides As Surrogate for '
          'Identifying Insulin Resistance in Apparently Healthy Subjects. '
          'Metab Syndr Relat Disord. 2008;6(4):299-304.',
      note: "composante indice TyG",
    ),
  ],
  applicablePopulation:
      'Adulte, prélèvement à jeun (triglycérides et glycémie doivent être '
      'toutes deux à jeun).',
  limitations: [
    "Indice composite : hérite des limites de l'indice TyG (référence "
        'indirecte, non un substitut au clamp euglycémique) et de celles de '
        "l'IMC (ne distingue pas masse grasse et masse maigre).",
    'Décrit initialement dans une cohorte taïwanaise sans diabète connu ; '
        'les seuils publiés dans cette population ne sont pas '
        'nécessairement transposables ailleurs sans validation locale.',
    "Comme pour l'indice TyG seul, il existe dans la littérature d'autres "
        'conventions de notation : ne jamais comparer ce résultat à un '
        'seuil publié pour une autre convention.',
  ],
  displayPrecision: 2,
);

/// HOMA-β (fonction des cellules β), Matthews 1985.
const FormulaMeta homaBetaMeta = FormulaMeta(
  id: 'homa_beta',
  name: 'HOMA-β (fonction des cellules β)',
  shortName: 'HOMA-β',
  category: CalculatorCategory.metabolic,
  version: 'Matthews 1985 — HOMA-β (%), forme classique',
  equation:
      'HOMA-β (%) = (20 × Insulinémie à jeun, µU/mL) / (Glycémie à jeun, '
      'mmol/L − 3,5)',
  sources: [
    Reference(
      citation:
          'Matthews DR, Hosker JP, Rudenski AS, Naylor BA, Treacher DF, '
          'Turner RC. Homeostasis Model Assessment: Insulin Resistance and '
          'Beta-Cell Function From Fasting Plasma Glucose and Insulin '
          'Concentrations in Man. Diabetologia. 1985;28(7):412-419.',
      note: 'équation HOMA-β',
    ),
  ],
  applicablePopulation:
      'Adulte, prélèvement à jeun (même contexte de validité que le '
      'HOMA-IR).',
  forbiddenConditions: [
    'Glycémie à jeun ≤ 3,5 mmol/L (0,63 g/L) : dénominateur nul ou '
        'négatif, calcul impossible.',
  ],
  limitations: [
    "Indice indirect de la fonction des cellules β, non une mesure directe "
        '(référence : clamp hyperglycémique ou test de tolérance au '
        "glucose avec dosage de l'insuline).",
    "Perd sa validité en cas d'insulinothérapie exogène récente ou de "
        'diabète évolué avec insulinopénie sévère.',
    'Les seuils publiés varient selon la population et la méthode de '
        "dosage de l'insuline — à valider localement.",
  ],
  displayPrecision: 1,
);

/// Rapport cholestérol total / HDL-C (indice de Castelli I).
const FormulaMeta ctHdlRatioMeta = FormulaMeta(
  id: 'ct_hdl_ratio',
  name: 'Rapport cholestérol total/HDL-C (indice de Castelli I)',
  shortName: 'CT/HDL (Castelli I)',
  category: CalculatorCategory.metabolic,
  version: 'Castelli 1983 — indice de Castelli I',
  equation: 'Indice de Castelli I = Cholestérol total / HDL-cholestérol',
  sources: [
    Reference(
      citation:
          'Castelli WP, Abbott RD, McNamara PM. Summary Estimates of '
          'Cholesterol Used to Predict Coronary and Cardiovascular '
          'Disease. Circulation. 1983;67(4):730-734.',
    ),
  ],
  applicablePopulation: 'Adulte',
  limitations: [
    'Ratio simple qui ne distingue pas les sous-fractions de LDL ni la '
        'taille des particules ; à interpréter avec le bilan lipidique '
        'complet (LDL, non-HDL, triglycérides).',
    'Les seuils de risque cardiovasculaire publiés varient selon les '
        "recommandations (ex. ESC/EAS) et ne sont ni calculés ni affichés "
        'automatiquement par cette application.',
  ],
  displayPrecision: 2,
);

/// Rapport ApoB/ApoA1 (Walldius-Jungner 2006).
const FormulaMeta apoBApoA1RatioMeta = FormulaMeta(
  id: 'apob_apoa1_ratio',
  name: 'Rapport ApoB/ApoA1',
  shortName: 'ApoB/ApoA1',
  category: CalculatorCategory.metabolic,
  version: 'Walldius-Jungner 2006',
  equation:
      'Rapport ApoB/ApoA1 = Apolipoprotéine B (g/L) / Apolipoprotéine A1 '
      '(g/L)',
  sources: [
    Reference(
      citation:
          'Walldius G, Jungner I. The apoB/apoA-I Ratio: A Strong, New '
          'Risk Factor for Cardiovascular Disease and a Target for '
          'Lipid-Lowering Therapy--a Review of the Evidence. J Intern Med. '
          '2006;259(5):493-519.',
    ),
    Reference(
      citation:
          'Mach F, Baigent C, Catapano AL, et al.; ESC Scientific Document '
          'Group. 2019 ESC/EAS Guidelines for the management of '
          'dyslipidaemias: lipid modification to reduce cardiovascular '
          'risk. Eur Heart J. 2020;41(1):111-188.',
      note:
          "mention du rapport ApoB/ApoA1 comme outil d'affinement du risque "
          'dans des situations spécifiques, sans seuil unique consensuel',
    ),
  ],
  applicablePopulation: 'Adulte',
  limitations: [
    "Nécessite des dosages d'ApoB et d'ApoA1 standardisés "
        '(immunonéphélémétrie/immunoturbidimétrie calibrées sur les '
        'standards internationaux OMS-IFCC SP1-01 et SP1-02).',
    'Les seuils de risque publiés varient selon le sexe et les '
        'recommandations — non calculés ni affichés automatiquement par '
        'cette application.',
  ],
  displayPrecision: 2,
);

double _bmiFromWeightHeight(double weightKg, double heightCm) {
  final heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

/// Classification OMS 2000 (WHO Technical Report Series 894) de l'IMC —
/// classification universellement reconnue, à la différence des autres
/// indices composites de ce fichier.
String _whoBmiCategory(double bmi) {
  if (bmi < 18.5) return 'maigreur (< 18,5 kg/m²)';
  if (bmi < 25.0) return 'poids normal (18,5-24,9 kg/m²)';
  if (bmi < 30.0) return 'surpoids (25,0-29,9 kg/m²)';
  if (bmi < 35.0) return 'obésité classe I (30,0-34,9 kg/m²)';
  if (bmi < 40.0) return 'obésité classe II (35,0-39,9 kg/m²)';
  return 'obésité classe III (≥ 40,0 kg/m²)';
}

const CalculationWarning _noConsensusThresholdTygBmi = CalculationWarning(
  "Aucun seuil diagnostique consensuel n'est actuellement recommandé par "
  "une société savante (ADA/EASD/IDF) pour l'indice TyG-IMC ; les seuils "
  "publiés dans la littérature proviennent d'une cohorte d'étude "
  "spécifique et ne doivent pas être généralisés ni utilisés comme seuil "
  'diagnostique universel.',
  severity: WarningSeverity.info,
);

const CalculationWarning _noConsensusThresholdHomaBeta = CalculationWarning(
  "Aucun seuil consensuel de société savante (ADA/EASD/IDF) n'existe pour "
  'interpréter le HOMA-β en pratique clinique courante ; les valeurs de '
  'référence publiées varient selon la population et la méthode de '
  "dosage de l'insuline utilisée, à ne pas généraliser.",
  severity: WarningSeverity.info,
);

const CalculationWarning _legacyCtHdlRatioInterpretation = CalculationWarning(
  "Seuils descriptifs souvent cités dans l'enseignement (héritage de "
  "l'ère NCEP) : < 4 souhaitable, ≥ 5 risque élevé. Ce ratio n'est "
  "toutefois pas retenu comme critère de première ligne par les "
  'recommandations actuelles (ESC/EAS, ADA), qui privilégient les valeurs '
  'absolues de LDL-C, de cholestérol non-HDL ou d\'ApoB comme cibles '
  'thérapeutiques ; à considérer comme un repère informel et non comme '
  'une cible de traitement actuelle.',
  severity: WarningSeverity.info,
);

const CalculationWarning _apoBApoA1RiskRefinementInterpretation =
    CalculationWarning(
  "Aucun seuil diagnostique unique consensuel n'est actuellement "
  'recommandé par une société savante (ESC/AHA) pour ce rapport. Il est '
  'mentionné dans les recommandations ESC/EAS 2019 comme outil '
  "d'affinement du risque cardiovasculaire dans certaines situations "
  "spécifiques (ex. hypertriglycéridémie, diabète, obésité), sans seuil "
  'unique universel de décision thérapeutique.',
  severity: WarningSeverity.info,
);

void _checkFastingConfirmed(bool fastingConfirmed) {
  if (!fastingConfirmed) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'fastingConfirmed',
        message: 'Confirmez que le prélèvement est réalisé à jeun.',
      ),
    ]);
  }
}

/// IMC = Poids (kg) / [Taille (m)]².
CalculationResult calculateBmi({
  required double weightKgValue,
  required double heightCmValue,
}) {
  final weightError =
      Validation.checkPositive(weightKgValue, 'weightKgValue', 'Poids');
  final heightError =
      Validation.checkPositive(heightCmValue, 'heightCmValue', 'Taille');
  Validation.raiseIfAny([weightError, heightError]);

  final heightM = heightCmValue / 100;
  final bmi = _bmiFromWeightHeight(weightKgValue, heightCmValue);

  return CalculationResult(
    formula: bmiMeta,
    echoedInputs: {
      'Poids': '${weightKgValue.toStringAsFixed(1)} kg',
      'Taille':
          '${heightCmValue.toStringAsFixed(1)} cm (${heightM.toStringAsFixed(3)} m)',
    },
    values: [
      ResultValue(label: 'IMC', value: bmi, unit: 'kg/m²', precision: 1),
    ],
    warnings: [
      CalculationWarning(
        'Classification OMS 2000 (WHO Technical Report Series 894) : '
        '${_whoBmiCategory(bmi)}. Catégorie de population générale, '
        'informative : les seuils de surpoids/obésité diffèrent selon '
        "certaines recommandations ethniques (ex. seuils abaissés proposés "
        "pour les populations asiatiques), et l'IMC ne distingue pas la "
        "masse grasse de la masse maigre — l'interprétation clinique "
        'individuelle relève du biologiste ou du clinicien.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

/// TyG-IMC = TyG × IMC, à partir des triglycérides et de la glycémie à jeun
/// (converties en mg/dL en interne, convention Simental-Mendía) et du poids
/// et de la taille.
CalculationResult calculateTygBmi({
  required double triglyceridesValue,
  required String triglyceridesUnit,
  required double fastingGlucoseValue,
  required String fastingGlucoseUnit,
  required double weightKgValue,
  required double heightCmValue,
  required bool fastingConfirmed,
}) {
  final tgError = Validation.checkPositive(
      triglyceridesValue, 'triglyceridesValue', 'Triglycérides à jeun');
  final glucoseError = Validation.checkPositive(
      fastingGlucoseValue, 'fastingGlucoseValue', 'Glycémie à jeun');
  final weightError =
      Validation.checkPositive(weightKgValue, 'weightKgValue', 'Poids');
  final heightError =
      Validation.checkPositive(heightCmValue, 'heightCmValue', 'Taille');
  Validation.raiseIfAny([tgError, glucoseError, weightError, heightError]);
  _checkFastingConfirmed(fastingConfirmed);

  final tgCanonicalMmolL = UnitRegistry.toCanonical(
      Analyte.triglycerides, triglyceridesValue, triglyceridesUnit);
  final tgMgDl =
      UnitRegistry.fromCanonical(Analyte.triglycerides, tgCanonicalMmolL, 'mg/dL');
  final glucoseCanonicalMmolL = UnitRegistry.toCanonical(
      Analyte.glucose, fastingGlucoseValue, fastingGlucoseUnit);
  final glucoseMgDl =
      UnitRegistry.fromCanonical(Analyte.glucose, glucoseCanonicalMmolL, 'mg/dL');

  final tyg = tygIndexFromMgDl(tgMgDl, glucoseMgDl);
  final bmi = _bmiFromWeightHeight(weightKgValue, heightCmValue);
  final tygBmi = tyg * bmi;

  final heightM = heightCmValue / 100;

  return CalculationResult(
    formula: tygBmiMeta,
    echoedInputs: {
      'Triglycérides à jeun':
          '${triglyceridesValue.toStringAsFixed(2)} $triglyceridesUnit (${tgMgDl.toStringAsFixed(1)} mg/dL)',
      'Glycémie à jeun':
          '${fastingGlucoseValue.toStringAsFixed(2)} $fastingGlucoseUnit (${glucoseMgDl.toStringAsFixed(1)} mg/dL)',
      'Poids': '${weightKgValue.toStringAsFixed(1)} kg',
      'Taille':
          '${heightCmValue.toStringAsFixed(1)} cm (${heightM.toStringAsFixed(3)} m)',
      'Prélèvement à jeun': 'confirmé',
    },
    values: [
      ResultValue(label: 'TyG-IMC', value: tygBmi, unit: '', precision: 2),
      ResultValue(label: 'Indice TyG (composante)', value: tyg, unit: '', precision: 3),
      ResultValue(label: 'IMC (composante)', value: bmi, unit: 'kg/m²', precision: 1),
    ],
    warnings: const [_noConsensusThresholdTygBmi],
  );
}

/// HOMA-β (%) = (20 × Insulinémie à jeun, µU/mL) / (Glycémie à jeun,
/// mmol/L − 3,5).
CalculationResult calculateHomaBeta({
  required double fastingInsulinValue,
  required String fastingInsulinUnit,
  required double fastingGlucoseValue,
  required String fastingGlucoseUnit,
  required bool fastingConfirmed,
}) {
  final insulinError = Validation.checkPositive(
      fastingInsulinValue, 'fastingInsulinValue', 'Insulinémie à jeun');
  final glucoseError = Validation.checkPositive(
      fastingGlucoseValue, 'fastingGlucoseValue', 'Glycémie à jeun');
  Validation.raiseIfAny([insulinError, glucoseError]);
  _checkFastingConfirmed(fastingConfirmed);

  final insulinUUmL = UnitRegistry.toCanonical(
      Analyte.insulin, fastingInsulinValue, fastingInsulinUnit);
  final glucoseMmolL = UnitRegistry.toCanonical(
      Analyte.glucose, fastingGlucoseValue, fastingGlucoseUnit);

  if (glucoseMmolL <= 3.5) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'fastingGlucoseValue',
        message:
            'La glycémie doit être strictement supérieure à 3,5 mmol/L '
            "(0,63 g/L) pour calculer le HOMA-β.",
      ),
    ]);
  }

  final homaBeta = (20 * insulinUUmL) / (glucoseMmolL - 3.5);

  return CalculationResult(
    formula: homaBetaMeta,
    echoedInputs: {
      'Insulinémie à jeun':
          '${fastingInsulinValue.toStringAsFixed(2)} $fastingInsulinUnit (${insulinUUmL.toStringAsFixed(2)} µU/mL)',
      'Glycémie à jeun':
          '${fastingGlucoseValue.toStringAsFixed(2)} $fastingGlucoseUnit (${glucoseMmolL.toStringAsFixed(3)} mmol/L)',
      'Prélèvement à jeun': 'confirmé',
    },
    values: [
      ResultValue(label: 'HOMA-β', value: homaBeta, unit: '%', precision: 1),
    ],
    warnings: const [_noConsensusThresholdHomaBeta],
  );
}

/// Indice de Castelli I = Cholestérol total / HDL-cholestérol.
CalculationResult calculateCtHdlRatio({
  required double totalCholesterolValue,
  required String totalCholesterolUnit,
  required double hdlValue,
  required String hdlUnit,
}) {
  final tcError = Validation.checkPositive(
      totalCholesterolValue, 'totalCholesterolValue', 'Cholestérol total');
  final hdlError =
      Validation.checkPositive(hdlValue, 'hdlValue', 'HDL-cholestérol');
  Validation.raiseIfAny([tcError, hdlError]);

  final tcMmolL = UnitRegistry.toCanonical(
      Analyte.cholesterol, totalCholesterolValue, totalCholesterolUnit);
  final hdlMmolL =
      UnitRegistry.toCanonical(Analyte.cholesterol, hdlValue, hdlUnit);

  final ratio = totalToHdlCholesterolRatio(tcMmolL, hdlMmolL);

  return CalculationResult(
    formula: ctHdlRatioMeta,
    echoedInputs: {
      'Cholestérol total':
          '${totalCholesterolValue.toStringAsFixed(2)} $totalCholesterolUnit (${tcMmolL.toStringAsFixed(3)} mmol/L)',
      'HDL-cholestérol':
          '${hdlValue.toStringAsFixed(2)} $hdlUnit (${hdlMmolL.toStringAsFixed(3)} mmol/L)',
    },
    values: [
      ResultValue(
        label: 'Indice de Castelli I (CT/HDL)',
        value: ratio,
        unit: '',
        precision: 2,
      ),
    ],
    warnings: const [_legacyCtHdlRatioInterpretation],
  );
}

/// Rapport ApoB/ApoA1 = ApoB (g/L) / ApoA1 (g/L).
CalculationResult calculateApoBApoA1Ratio({
  required double apoBValue,
  required double apoA1Value,
}) {
  final apoBError =
      Validation.checkPositive(apoBValue, 'apoBValue', 'Apolipoprotéine B');
  final apoA1Error =
      Validation.checkPositive(apoA1Value, 'apoA1Value', 'Apolipoprotéine A1');
  Validation.raiseIfAny([apoBError, apoA1Error]);

  final ratio = apoBValue / apoA1Value;

  return CalculationResult(
    formula: apoBApoA1RatioMeta,
    echoedInputs: {
      'Apolipoprotéine B': '${apoBValue.toStringAsFixed(2)} g/L',
      'Apolipoprotéine A1': '${apoA1Value.toStringAsFixed(2)} g/L',
    },
    values: [
      ResultValue(
        label: 'Rapport ApoB/ApoA1',
        value: ratio,
        unit: '',
        precision: 2,
      ),
    ],
    warnings: const [_apoBApoA1RiskRefinementInterpretation],
  );
}
