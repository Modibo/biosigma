import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../validation.dart';

/// Indices discriminants de la microcytose (VGM abaissé) : Mentzer,
/// Shine & Lal, England & Fraser, Green & King et RDWI.
///
/// Ces cinq indices ont été historiquement proposés pour orienter entre une
/// carence martiale et un trait thalassémique, mais aucun n'est
/// spécifique : ce module ne renvoie que la valeur numérique brute de
/// chaque indice, jamais une interprétation ou un verdict diagnostique
/// automatique — l'électrophorèse de l'hémoglobine et/ou le bilan martial
/// restent nécessaires pour trancher.

// ---------------------------------------------------------------------------
// a) Indice de Mentzer (VGM / GR).
// ---------------------------------------------------------------------------

const FormulaMeta mentzerIndexMeta = FormulaMeta(
  id: 'mentzer_index',
  name: 'Indice de Mentzer',
  shortName: 'Indice de Mentzer',
  category: CalculatorCategory.hematology,
  version: 'Mentzer 1973',
  equation: 'Indice de Mentzer = VGM (fL) / GR (×10¹²/L)',
  sources: [
    Reference(
      citation:
          'Mentzer WC Jr. Differentiation of Iron Deficiency From '
          'Thalassaemia Trait. Lancet. 1973;1(7808):882.',
    ),
  ],
  applicablePopulation:
      'Tout âge présentant une microcytose (VGM diminué) à explorer.',
  forbiddenConditions: [
    'Non interprétable si le patient a été récemment transfusé ou en cas '
        'de microcytose mixte (carence martiale associée à un trait '
        'thalassémique), non détectable à partir des seules valeurs '
        'saisies.',
  ],
  limitations: [
    'Sensibilité et spécificité modestes, très dépendantes de la '
        'population étudiée ; ne remplace ni le bilan martial (ferritine, '
        'coefficient de saturation de la transferrine) ni '
        "l'électrophorèse/HPLC de l'hémoglobine.",
    'Un seuil indicatif de 13 a été proposé par Mentzer (valeur < 13 '
        'évocatrice de trait thalassémique, > 13 évocatrice de carence '
        'martiale) ; ce seuil est purement informatif et n\'est appliqué '
        'par aucun calcul automatique de cette application.',
  ],
  helpText: 'VGM en fL, numération des globules rouges (GR) en ×10¹²/L.',
);

/// Indice de Mentzer : VGM / GR, pour orienter entre carence martiale et
/// trait thalassémique devant une microcytose (Mentzer 1973).
CalculationResult calculateMentzerIndex({
  required double mcvFl,
  required double rbcTeraL,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(mcvFl, 'mcvFl', 'VGM'),
    Validation.checkPositive(rbcTeraL, 'rbcTeraL', 'Numération des globules rouges (GR)'),
  ]);

  final index = mcvFl / rbcTeraL;

  return CalculationResult(
    formula: mentzerIndexMeta,
    echoedInputs: {
      'VGM': '${mcvFl.toStringAsFixed(1)} fL',
      'GR': '${rbcTeraL.toStringAsFixed(2)} ×10¹²/L',
    },
    values: [
      ResultValue(label: 'Indice de Mentzer', value: index, unit: '', precision: 2),
    ],
  );
}

// ---------------------------------------------------------------------------
// b) Indice de Shine & Lal (VGM² × TCMH / 100).
// ---------------------------------------------------------------------------

const FormulaMeta shineLalIndexMeta = FormulaMeta(
  id: 'shine_lal_index',
  name: 'Indice de Shine & Lal',
  shortName: 'Indice de Shine & Lal',
  category: CalculatorCategory.hematology,
  version: 'Shine-Lal 1977',
  equation: 'Indice de Shine & Lal = (VGM² × TCMH [pg]) / 100',
  sources: [
    Reference(
      citation:
          'Shine I, Lal S. A Strategy to Detect β-Thalassaemia Minor. '
          'Lancet. 1977;1(8013):692-694.',
    ),
  ],
  applicablePopulation:
      'Tout âge présentant une microcytose (VGM diminué) à explorer.',
  forbiddenConditions: [
    'Non interprétable en cas de microcytose mixte (carence martiale '
        'associée à un trait thalassémique), non détectable à partir des '
        'seules valeurs saisies.',
  ],
  limitations: [
    "Indice initialement décrit dans le cadre d'un dépistage en population "
        'féminine ; ne remplace ni le bilan martial ni '
        "l'électrophorèse/HPLC de l'hémoglobine.",
    'Un seuil indicatif de 1760 a été proposé par les auteurs (valeur '
        '< 1760 évocatrice de trait thalassémique) ; ce seuil est '
        "purement informatif et n'est appliqué par aucun calcul "
        'automatique de cette application.',
  ],
  helpText: 'VGM en fL, TCMH (teneur corpusculaire moyenne en hémoglobine) en pg.',
  displayPrecision: 1,
);

/// Indice de Shine & Lal : (VGM² × TCMH) / 100 (Shine-Lal 1977).
CalculationResult calculateShineLalIndex({
  required double mcvFl,
  required double mchPg,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(mcvFl, 'mcvFl', 'VGM'),
    Validation.checkPositive(mchPg, 'mchPg', 'TCMH'),
  ]);

  final index = (mcvFl * mcvFl * mchPg) / 100;

  return CalculationResult(
    formula: shineLalIndexMeta,
    echoedInputs: {
      'VGM': '${mcvFl.toStringAsFixed(1)} fL',
      'TCMH': '${mchPg.toStringAsFixed(1)} pg',
    },
    values: [
      ResultValue(label: 'Indice de Shine & Lal', value: index, unit: '', precision: 1),
    ],
  );
}

// ---------------------------------------------------------------------------
// c) Indice (fonction discriminante) d'England & Fraser.
// ---------------------------------------------------------------------------

const FormulaMeta englandFraserIndexMeta = FormulaMeta(
  id: 'england_fraser_index',
  name: "Indice (fonction discriminante) d'England & Fraser",
  shortName: "Indice d'England & Fraser",
  category: CalculatorCategory.hematology,
  version: 'England-Fraser 1973',
  equation:
      "Indice d'England & Fraser = VGM − GR (×10¹²/L) − (5 × Hb [g/dL]) − 3,4",
  sources: [
    Reference(
      citation:
          'England JM, Fraser PM. Differentiation of Iron Deficiency From '
          'Thalassaemia Trait by Routine Blood-Count. Lancet. '
          '1973;1(7801):449-452.',
    ),
  ],
  applicablePopulation:
      'Adulte et enfant présentant une microcytose (VGM diminué) à '
      'explorer.',
  forbiddenConditions: [
    'Non interprétable en cas de microcytose mixte (carence martiale '
        'associée à un trait thalassémique), non détectable à partir des '
        'seules valeurs saisies.',
  ],
  limitations: [
    'Développé et validé sur un effectif limité (72 patients) ; ne '
        'remplace ni le bilan martial ni '
        "l'électrophorèse/HPLC de l'hémoglobine.",
    'Un résultat positif a été proposé par les auteurs comme évocateur de '
        "carence martiale et un résultat négatif comme évocateur de trait "
        "thalassémique ; cette lecture est purement informative et n'est "
        'appliquée par aucun calcul automatique de cette application.',
  ],
  helpText: 'VGM en fL, GR en ×10¹²/L, hémoglobine (Hb) en g/dL.',
);

/// Indice (fonction discriminante) d'England & Fraser : VGM − GR −
/// (5 × Hb) − 3,4 (England-Fraser 1973).
CalculationResult calculateEnglandFraserIndex({
  required double mcvFl,
  required double rbcTeraL,
  required double hbGDl,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(mcvFl, 'mcvFl', 'VGM'),
    Validation.checkPositive(rbcTeraL, 'rbcTeraL', 'Numération des globules rouges (GR)'),
    Validation.checkPositive(hbGDl, 'hbGDl', 'Hémoglobine'),
  ]);

  final index = mcvFl - rbcTeraL - (5 * hbGDl) - 3.4;

  return CalculationResult(
    formula: englandFraserIndexMeta,
    echoedInputs: {
      'VGM': '${mcvFl.toStringAsFixed(1)} fL',
      'GR': '${rbcTeraL.toStringAsFixed(2)} ×10¹²/L',
      'Hémoglobine': '${hbGDl.toStringAsFixed(1)} g/dL',
    },
    values: [
      ResultValue(
        label: "Indice d'England & Fraser",
        value: index,
        unit: '',
        precision: 1,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// d) Indice de Green & King.
// ---------------------------------------------------------------------------

const FormulaMeta greenKingIndexMeta = FormulaMeta(
  id: 'green_king_index',
  name: 'Indice de Green & King',
  shortName: 'Indice de Green & King',
  category: CalculatorCategory.hematology,
  version: 'Green-King 1989',
  equation:
      'Indice de Green & King = (VGM² × IDR [%]) / (Hb [g/dL] × 100)',
  sources: [
    Reference(
      citation:
          'Green R, King R. A New Red Cell Discriminant Incorporating '
          'Volume Dispersion for Differentiating Iron Deficiency Anemia '
          'From Thalassemia Minor. Blood Cells. 1989;15(3):481-495.',
    ),
  ],
  applicablePopulation:
      'Tout âge présentant une microcytose (VGM diminué) à explorer.',
  forbiddenConditions: [
    'Non interprétable en cas de microcytose mixte (carence martiale '
        'associée à un trait thalassémique), non détectable à partir des '
        'seules valeurs saisies.',
  ],
  limitations: [
    "Décrit comme l'un des indices les plus performants de sa génération "
        'sur la cohorte originale, mais reste imparfait ; ne remplace ni '
        "le bilan martial ni l'électrophorèse/HPLC de l'hémoglobine.",
    'Un seuil indicatif de 72 a été proposé par les auteurs (valeur ≤ 72 '
        "évocatrice de trait thalassémique) ; ce seuil est purement "
        "informatif et n'est appliqué par aucun calcul automatique de "
        'cette application.',
  ],
  helpText: "VGM en fL, IDR (indice de dispersion des GR, RDW) en %, Hb en g/dL.",
);

/// Indice de Green & King : (VGM² × IDR) / (Hb × 100) (Green-King 1989).
CalculationResult calculateGreenKingIndex({
  required double mcvFl,
  required double rdwPercent,
  required double hbGDl,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(mcvFl, 'mcvFl', 'VGM'),
    Validation.checkPositive(rdwPercent, 'rdwPercent', 'IDR (RDW)'),
    Validation.checkPositive(hbGDl, 'hbGDl', 'Hémoglobine'),
  ]);

  final index = (mcvFl * mcvFl * rdwPercent) / (hbGDl * 100);

  return CalculationResult(
    formula: greenKingIndexMeta,
    echoedInputs: {
      'VGM': '${mcvFl.toStringAsFixed(1)} fL',
      'IDR (RDW)': '${rdwPercent.toStringAsFixed(1)} %',
      'Hémoglobine': '${hbGDl.toStringAsFixed(1)} g/dL',
    },
    values: [
      ResultValue(label: 'Indice de Green & King', value: index, unit: '', precision: 1),
    ],
  );
}

// ---------------------------------------------------------------------------
// e) RDWI (RDW index).
// ---------------------------------------------------------------------------

const FormulaMeta rdwIndexMeta = FormulaMeta(
  id: 'rdw_index',
  name: 'RDWI (indice de dispersion des globules rouges)',
  shortName: 'RDWI',
  category: CalculatorCategory.hematology,
  version: 'Jayabose et al. 1999',
  equation: 'RDWI = VGM (fL) × IDR (%) / GR (×10¹²/L)',
  sources: [
    Reference(
      citation:
          'Jayabose S, Giavanelli J, Levendoglu-Tugal O, Sandoval C, '
          'Özkaynak F, Visintainer P. Differentiating Iron Deficiency '
          'Anemia From Thalassemia Minor by Using an RDW-Based Index. J '
          'Pediatr Hematol Oncol. 1999;21(4):314.',
      note:
          'Publié initialement sous forme de résumé de congrès (American '
          'Society of Pediatric Hematology/Oncology, 1999) ; formule '
          'largement reprise depuis dans la littérature comparant les '
          'indices discriminants (ex. Sirdah et al. 2008, ci-dessous).',
    ),
    Reference(
      citation:
          'Sirdah M, Tarazi I, Al Najjar E, Al Haddad R. Evaluation of '
          'the Diagnostic Reliability of Different RBC Indices and '
          'Formulas in the Differentiation of the β-Thalassaemia Minor '
          'From Iron Deficiency Anaemia in Palestinians. Int J Lab '
          'Hematol. 2008;30(4):324-330.',
      note: 'Étude de validation comparative incluant le RDWI',
    ),
  ],
  applicablePopulation:
      'Décrit initialement en population pédiatrique ; utilisé plus '
      'largement à tout âge devant une microcytose (VGM diminué) à '
      'explorer.',
  forbiddenConditions: [
    'Non interprétable en cas de microcytose mixte (carence martiale '
        'associée à un trait thalassémique), non détectable à partir des '
        'seules valeurs saisies.',
  ],
  limitations: [
    'Source primaire publiée uniquement sous forme de résumé de congrès '
        "(pas d'article original détaillé) ; les performances rapportées "
        "varient selon les études de validation ultérieures.",
    'Un seuil indicatif de 220 a été proposé (valeur > 220 évocatrice de '
        'carence martiale, < 220 évocatrice de trait thalassémique) ; ce '
        "seuil est purement informatif et n'est appliqué par aucun calcul "
        'automatique de cette application.',
  ],
  helpText: 'VGM en fL, IDR (RDW) en %, GR en ×10¹²/L.',
  displayPrecision: 1,
);

/// RDWI (RDW index) : VGM × IDR / GR (Jayabose et al. 1999).
CalculationResult calculateRdwIndex({
  required double mcvFl,
  required double rdwPercent,
  required double rbcTeraL,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(mcvFl, 'mcvFl', 'VGM'),
    Validation.checkPositive(rdwPercent, 'rdwPercent', 'IDR (RDW)'),
    Validation.checkPositive(rbcTeraL, 'rbcTeraL', 'Numération des globules rouges (GR)'),
  ]);

  final index = (mcvFl * rdwPercent) / rbcTeraL;

  return CalculationResult(
    formula: rdwIndexMeta,
    echoedInputs: {
      'VGM': '${mcvFl.toStringAsFixed(1)} fL',
      'IDR (RDW)': '${rdwPercent.toStringAsFixed(1)} %',
      'GR': '${rbcTeraL.toStringAsFixed(2)} ×10¹²/L',
    },
    values: [
      ResultValue(label: 'RDWI', value: index, unit: '', precision: 1),
    ],
  );
}
