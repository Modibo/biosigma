import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../validation.dart';

/// Indices d'inflammation systémique dérivés de la NFS : SII (Systemic
/// Immune-Inflammation Index) et SIRI (Systemic Inflammation Response
/// Index), tous deux calculés à partir des numérations absolues (×10⁹/L).

// ---------------------------------------------------------------------------
// a) SII — Systemic Immune-Inflammation Index.
// ---------------------------------------------------------------------------

const FormulaMeta siiIndexMeta = FormulaMeta(
  id: 'sii_index',
  name: "Index d'immuno-inflammation systémique (SII)",
  shortName: 'SII',
  category: CalculatorCategory.hematology,
  version: 'Hu et al. 2014',
  equation:
      'SII = (Plaquettes × Neutrophiles) / Lymphocytes (toutes en ×10⁹/L)',
  sources: [
    Reference(
      citation:
          'Hu B, Yang XR, Xu Y, et al. Systemic Immune-Inflammation Index '
          'Predicts Prognosis of Patients After Curative Resection for '
          'Hepatocellular Carcinoma. Clin Cancer Res. 2014;20(23):6212-6222.',
    ),
  ],
  applicablePopulation:
      'Adulte ; décrit initialement en oncologie (carcinome '
      'hépatocellulaire) et depuis étudié dans de nombreux autres '
      'contextes inflammatoires et néoplasiques.',
  forbiddenConditions: [
    'Non interprétable en cas de cytopénie ou hyperleucocytose liée à une '
        'cause aiguë non inflammatoire (ex. hémopathie, traitement '
        'cytotoxique récent), non détectable à partir des seules valeurs '
        'saisies.',
  ],
  limitations: [
    "Marqueur pronostique de recherche, non un test diagnostique : les "
        'seuils rapportés dans la littérature varient fortement selon la '
        "pathologie étudiée et ne sont pas reproduits ici — aucun seuil "
        "n'est appliqué automatiquement par cette application.",
    'Sensible à toute cause de variation des trois lignées (infection '
        'intercurrente, corticothérapie, splénectomie, grossesse).',
  ],
  helpText: 'Plaquettes, neutrophiles et lymphocytes en ×10⁹/L (numération absolue).',
  displayPrecision: 1,
);

/// SII (Systemic Immune-Inflammation Index) : (Plaquettes × Neutrophiles) /
/// Lymphocytes, toutes en ×10⁹/L (Hu et al. 2014).
CalculationResult calculateSiiIndex({
  required double plateletsGL,
  required double neutrophilsGL,
  required double lymphocytesGL,
}) {
  Validation.raiseIfAny([
    Validation.checkNonNegative(plateletsGL, 'plateletsGL', 'Plaquettes'),
    Validation.checkNonNegative(neutrophilsGL, 'neutrophilsGL', 'Neutrophiles'),
    Validation.checkPositive(lymphocytesGL, 'lymphocytesGL', 'Lymphocytes'),
  ]);

  final sii = (plateletsGL * neutrophilsGL) / lymphocytesGL;

  return CalculationResult(
    formula: siiIndexMeta,
    echoedInputs: {
      'Plaquettes': '${plateletsGL.toStringAsFixed(1)} ×10⁹/L',
      'Neutrophiles': '${neutrophilsGL.toStringAsFixed(2)} ×10⁹/L',
      'Lymphocytes': '${lymphocytesGL.toStringAsFixed(2)} ×10⁹/L',
    },
    values: [
      ResultValue(label: 'SII', value: sii, unit: '', precision: 1),
    ],
    warnings: const [
      CalculationWarning(
        "Aucun seuil clinique consensuel n'est actuellement recommandé "
        "par une société savante d'hématologie ou d'oncologie pour cet "
        'index ; les seuils rapportés dans la littérature (principalement '
        'en recherche pronostique oncologique) varient fortement selon la '
        'pathologie et la cohorte étudiées, et ne doivent pas être '
        'généralisés à la pratique clinique courante.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// b) SIRI — Systemic Inflammation Response Index.
// ---------------------------------------------------------------------------

const FormulaMeta siriIndexMeta = FormulaMeta(
  id: 'siri_index',
  name: "Index de réponse inflammatoire systémique (SIRI)",
  shortName: 'SIRI',
  category: CalculatorCategory.hematology,
  version: 'Qi et al. 2016',
  equation:
      'SIRI = (Neutrophiles × Monocytes) / Lymphocytes (toutes en ×10⁹/L)',
  sources: [
    Reference(
      citation:
          'Qi Q, Zhuang L, Shen Y, et al. A Novel Systemic Inflammation '
          'Response Index (SIRI) for Predicting the Survival of Patients '
          'With Pancreatic Cancer After Chemotherapy. Cancer. '
          '2016;122(14):2158-2167.',
    ),
  ],
  applicablePopulation:
      'Adulte ; décrit initialement en oncologie (cancer du pancréas sous '
      'chimiothérapie) et depuis étudié dans de nombreux autres contextes '
      'inflammatoires et néoplasiques.',
  forbiddenConditions: [
    'Non interprétable en cas de cytopénie ou hyperleucocytose liée à une '
        'cause aiguë non inflammatoire (ex. hémopathie, traitement '
        'cytotoxique récent), non détectable à partir des seules valeurs '
        'saisies.',
  ],
  limitations: [
    'Marqueur pronostique de recherche, non un test diagnostique : les '
        'seuils rapportés dans la littérature varient fortement selon la '
        "pathologie étudiée et ne sont pas reproduits ici — aucun seuil "
        "n'est appliqué automatiquement par cette application.",
    'Sensible à toute cause de variation des trois lignées (infection '
        'intercurrente, corticothérapie, splénectomie, grossesse).',
  ],
  helpText: 'Neutrophiles, monocytes et lymphocytes en ×10⁹/L (numération absolue).',
  displayPrecision: 2,
);

/// SIRI (Systemic Inflammation Response Index) : (Neutrophiles ×
/// Monocytes) / Lymphocytes, toutes en ×10⁹/L (Qi et al. 2016).
CalculationResult calculateSiriIndex({
  required double neutrophilsGL,
  required double monocytesGL,
  required double lymphocytesGL,
}) {
  Validation.raiseIfAny([
    Validation.checkNonNegative(neutrophilsGL, 'neutrophilsGL', 'Neutrophiles'),
    Validation.checkNonNegative(monocytesGL, 'monocytesGL', 'Monocytes'),
    Validation.checkPositive(lymphocytesGL, 'lymphocytesGL', 'Lymphocytes'),
  ]);

  final siri = (neutrophilsGL * monocytesGL) / lymphocytesGL;

  return CalculationResult(
    formula: siriIndexMeta,
    echoedInputs: {
      'Neutrophiles': '${neutrophilsGL.toStringAsFixed(2)} ×10⁹/L',
      'Monocytes': '${monocytesGL.toStringAsFixed(2)} ×10⁹/L',
      'Lymphocytes': '${lymphocytesGL.toStringAsFixed(2)} ×10⁹/L',
    },
    values: [
      ResultValue(label: 'SIRI', value: siri, unit: '', precision: 2),
    ],
    warnings: const [
      CalculationWarning(
        "Aucun seuil clinique consensuel n'est actuellement recommandé "
        "par une société savante d'hématologie ou d'oncologie pour cet "
        'index ; les seuils rapportés dans la littérature (principalement '
        'en recherche pronostique oncologique) varient fortement selon la '
        'pathologie et la cohorte étudiées, et ne doivent pas être '
        'généralisés à la pratique clinique courante.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}
