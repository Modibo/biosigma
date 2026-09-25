import 'dart:math' as math;

import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// Équation utilisée pour estimer le LDL-cholestérol calculé.
enum LdlFormula {
  friedewald('Friedewald 1972'),
  sampson('Sampson 2020 (équation NIH 2)');

  const LdlFormula(this.label);

  /// Libellé affiché en français.
  final String label;
}

/// Panel lipidique — LDL calculé (Friedewald ou Sampson), non-HDL, ratios
/// athérogènes et cholestérol résiduel.
const FormulaMeta ldlPanelMeta = FormulaMeta(
  id: 'ldl_panel',
  name: 'Panel lipidique — LDL calculé, non-HDL, ratios, cholestérol résiduel',
  shortName: 'Panel lipidique (LDL calculé)',
  category: CalculatorCategory.metabolic,
  version:
      "Friedewald 1972 ou Sampson 2020 (équation NIH 2), selon le choix de "
      "l'utilisateur — voir « Équation LDL » dans les entrées échoïsées",
  equation:
      'LDL (Friedewald) = CT − HDL − TG/5 (mg/dL ; domaine valide TG < 400 '
      'mg/dL, soit 4,52 mmol/L)  |  '
      'LDL (Sampson, NIH éq. 2) = CT/0,948 − HDL/0,971 − '
      '[TG/8,56 + TG×non-HDL/2140 − TG²/16100] − 9,44 (mg/dL ; domaine '
      'valide TG < 800 mg/dL)  |  non-HDL = CT − HDL  |  CT/HDL = CT/HDL  |  '
      'TG/HDL (mg/dL) = TG/HDL  |  Cholestérol résiduel = non-HDL − LDL',
  sources: [
    Reference(
      citation:
          'Friedewald WT, Levy RI, Fredrickson DS. Estimation of the '
          'Concentration of Low-Density Lipoprotein Cholesterol in Plasma, '
          'Without Use of the Preparative Ultracentrifuge. Clin Chem. '
          '1972;18(6):499-502.',
      note: 'équation Friedewald',
    ),
    Reference(
      citation:
          'Sampson M, Ling C, Sun Q, et al. A New Equation for Calculation '
          'of Low-Density Lipoprotein Cholesterol in Patients With '
          'Normolipidemia and/or Hypertriglyceridemia. JAMA Cardiol. '
          '2020;5(5):540-548.',
      note: 'équation Sampson / NIH équation 2',
    ),
    Reference(
      citation:
          'Dobiásová M, Frohlich J. The Plasma Parameter log (TG/HDL-C) as '
          'an Atherogenic Index. Clin Biochem. 2001;34(7):583-588.',
      note: 'pour le contexte des ratios lipidiques',
    ),
  ],
  applicablePopulation: 'Adulte',
  forbiddenConditions: [
    'Non valide en cas de chylomicronémie ou de dysbêtalipoprotéinémie de '
        'type III (non détectable à partir des seules valeurs saisies).',
  ],
  limitations: [
    "L'équation Martin-Hopkins (table de facteurs ajustés) n'est pas "
        "implémentée dans cette version : risque de transcription d'une "
        "table à 180 cellules jugé trop élevé sans validation externe "
        "formelle ; Friedewald et Sampson couvrent la majorité des cas "
        "d'usage.",
  ],
);

/// Indice athérogène du plasma (AIP, Dobiásová-Frohlich 2001).
const FormulaMeta atherogenicIndexOfPlasmaMeta = FormulaMeta(
  id: 'atherogenic_index_of_plasma',
  name: 'Indice athérogène du plasma (AIP)',
  shortName: 'AIP',
  category: CalculatorCategory.metabolic,
  version: 'Dobiásová-Frohlich 2001',
  equation: 'AIP = log10(Triglycérides mmol/L / HDL-C mmol/L)',
  sources: [
    Reference(
      citation:
          'Dobiásová M, Frohlich J. The Plasma Parameter log (TG/HDL-C) as '
          'an Atherogenic Index: Correlation With Lipoprotein Particle Size '
          'and Esterification Rate in apoB-Lipoprotein-Depleted Plasma '
          '(FER_HDL). Clin Biochem. 2001;34(7):583-588.',
    ),
  ],
  applicablePopulation: 'Adulte',
  limitations: [
    'Ne pas confondre avec le simple ratio TG/HDL en mg/dL (convention '
        "McLaughlin), numériquement différent car les deux analytes n'ont "
        'pas le même facteur de conversion mg/dL→mmol/L.',
  ],
  displayPrecision: 3,
);

double _log10(double x) => math.log(x) / math.ln10;

/// Panel lipidique complet : LDL calculé (Friedewald ou Sampson au choix),
/// non-HDL, ratio CT/HDL, ratio TG/HDL (mg/dL) et cholestérol résiduel.
CalculationResult calculateLdlPanel({
  required double totalCholesterolValue,
  required String totalCholesterolUnit,
  required double hdlValue,
  required String hdlUnit,
  required double triglyceridesValue,
  required String triglyceridesUnit,
  required LdlFormula formula,
}) {
  final tcError = Validation.checkPositive(
      totalCholesterolValue, 'totalCholesterolValue', 'Cholestérol total');
  final hdlError = Validation.checkPositive(hdlValue, 'hdlValue', 'HDL-cholestérol');
  final tgError =
      Validation.checkPositive(triglyceridesValue, 'triglyceridesValue', 'Triglycérides');
  Validation.raiseIfAny([tcError, hdlError, tgError]);

  final tcMmolL =
      UnitRegistry.toCanonical(Analyte.cholesterol, totalCholesterolValue, totalCholesterolUnit);
  final tcMgDl = UnitRegistry.fromCanonical(Analyte.cholesterol, tcMmolL, 'mg/dL');
  final hdlMmolL = UnitRegistry.toCanonical(Analyte.cholesterol, hdlValue, hdlUnit);
  final hdlMgDl = UnitRegistry.fromCanonical(Analyte.cholesterol, hdlMmolL, 'mg/dL');
  final tgMmolL =
      UnitRegistry.toCanonical(Analyte.triglycerides, triglyceridesValue, triglyceridesUnit);
  final tgMgDl = UnitRegistry.fromCanonical(Analyte.triglycerides, tgMmolL, 'mg/dL');

  double? ldlMgDl;
  final warnings = <CalculationWarning>[];

  switch (formula) {
    case LdlFormula.friedewald:
      if (tgMgDl >= 400) {
        warnings.add(const CalculationWarning(
          "LDL non calculé : triglycérides ≥ 4,52 mmol/L (400 mg/dL), hors "
              "domaine de validité de l'équation de Friedewald. Choisir "
              "l'équation de Sampson ou recourir à une mesure directe.",
          severity: WarningSeverity.blocking,
        ));
      } else {
        ldlMgDl = tcMgDl - hdlMgDl - tgMgDl / 5;
      }
    case LdlFormula.sampson:
      if (tgMgDl >= 800) {
        warnings.add(const CalculationWarning(
          "LDL non calculé : triglycérides ≥ 800 mg/dL, hors domaine de "
              "validité de l'équation de Sampson. Recourir à une mesure "
              "directe.",
          severity: WarningSeverity.blocking,
        ));
      } else {
        final nonHdlMgDl = tcMgDl - hdlMgDl;
        ldlMgDl = tcMgDl / 0.948 -
            hdlMgDl / 0.971 -
            (tgMgDl / 8.56 + tgMgDl * nonHdlMgDl / 2140 - tgMgDl * tgMgDl / 16100) -
            9.44;
      }
  }

  final ldlMmolL = ldlMgDl != null
      ? UnitRegistry.convert(Analyte.cholesterol, ldlMgDl, fromUnit: 'mg/dL', toUnit: 'mmol/L')
      : null;

  final nonHdl = tcMmolL - hdlMmolL;
  final ctHdlRatio = tcMmolL / hdlMmolL;
  final tgHdlRatioMgDl = tgMgDl / hdlMgDl;
  final remnantCholesterol = ldlMmolL != null ? nonHdl - ldlMmolL : null;

  return CalculationResult(
    formula: ldlPanelMeta,
    echoedInputs: {
      'Cholestérol total':
          '${totalCholesterolValue.toStringAsFixed(2)} $totalCholesterolUnit '
              '(${tcMmolL.toStringAsFixed(3)} mmol/L, ${tcMgDl.toStringAsFixed(1)} mg/dL)',
      'HDL-cholestérol':
          '${hdlValue.toStringAsFixed(2)} $hdlUnit '
              '(${hdlMmolL.toStringAsFixed(3)} mmol/L, ${hdlMgDl.toStringAsFixed(1)} mg/dL)',
      'Triglycérides':
          '${triglyceridesValue.toStringAsFixed(2)} $triglyceridesUnit '
              '(${tgMmolL.toStringAsFixed(3)} mmol/L, ${tgMgDl.toStringAsFixed(1)} mg/dL)',
      'Équation LDL': formula.label,
    },
    values: [
      ResultValue(
        label: 'LDL calculé (${formula.label})',
        value: ldlMmolL,
        unit: 'mmol/L',
        precision: 2,
      ),
      ResultValue(
        label: 'Cholestérol non-HDL',
        value: nonHdl,
        unit: 'mmol/L',
        precision: 2,
      ),
      ResultValue(
        label: 'Ratio CT/HDL',
        value: ctHdlRatio,
        unit: '',
        precision: 2,
      ),
      ResultValue(
        label: 'Ratio TG/HDL (mg/dL)',
        value: tgHdlRatioMgDl,
        unit: '',
        precision: 2,
      ),
      ResultValue(
        label: 'Cholestérol résiduel (non-HDL − LDL)',
        value: remnantCholesterol,
        unit: 'mmol/L',
        precision: 2,
      ),
    ],
    warnings: warnings,
  );
}

/// Indice athérogène du plasma (AIP) : log10(TG/HDL-C), les deux exprimés
/// en mmol/L (Dobiásová-Frohlich 2001).
CalculationResult calculateAtherogenicIndexOfPlasma({
  required double triglyceridesValue,
  required String triglyceridesUnit,
  required double hdlValue,
  required String hdlUnit,
}) {
  final tgError =
      Validation.checkPositive(triglyceridesValue, 'triglyceridesValue', 'Triglycérides');
  final hdlError = Validation.checkPositive(hdlValue, 'hdlValue', 'HDL-cholestérol');
  Validation.raiseIfAny([tgError, hdlError]);

  final tgMmolL =
      UnitRegistry.toCanonical(Analyte.triglycerides, triglyceridesValue, triglyceridesUnit);
  final hdlMmolL = UnitRegistry.toCanonical(Analyte.cholesterol, hdlValue, hdlUnit);

  final aip = _log10(tgMmolL / hdlMmolL);

  return CalculationResult(
    formula: atherogenicIndexOfPlasmaMeta,
    echoedInputs: {
      'Triglycérides':
          '${triglyceridesValue.toStringAsFixed(2)} $triglyceridesUnit (${tgMmolL.toStringAsFixed(3)} mmol/L)',
      'HDL-cholestérol':
          '${hdlValue.toStringAsFixed(2)} $hdlUnit (${hdlMmolL.toStringAsFixed(3)} mmol/L)',
    },
    values: [
      ResultValue(label: 'AIP', value: aip, unit: '', precision: 3),
    ],
  );
}
