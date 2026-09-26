import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../validation.dart';

/// Panel réticulocytaire : nombre absolu de réticulocytes, réticulocytes
/// corrigés (CRC) et indice de production réticulocytaire (RPI), à partir
/// du pourcentage de réticulocytes, de la numération érythrocytaire et de
/// l'hématocrite du patient.
///
/// Les trois valeurs sont composables (le RPI a besoin du CRC, qui a
/// besoin du pourcentage brut) : elles sont regroupées dans un seul
/// calculateur, à l'image du panel lipidique de `metabolic/lipids.dart`.

// ---------------------------------------------------------------------------
// Facteur de maturation médullaire de Hillman (1969), fonction en palier de
// l'hématocrite du patient.
// ---------------------------------------------------------------------------

/// Facteur de maturation réticulocytaire de Hillman, selon l'hématocrite du
/// patient : 1,0 si Hct ≥ 40 % ; 1,5 si 30–39,9 % ; 2,0 si 20–29,9 % ; 2,5
/// si < 20 % (Hillman 1969).
double _hillmanMaturationFactor(double hematocritPercent) {
  if (hematocritPercent >= 40) return 1.0;
  if (hematocritPercent >= 30) return 1.5;
  if (hematocritPercent >= 20) return 2.0;
  return 2.5;
}

const FormulaMeta reticulocyteIndicesPanelMeta = FormulaMeta(
  id: 'reticulocyte_indices_panel',
  name:
      'Panel réticulocytaire — nombre absolu, réticulocytes corrigés (CRC) '
      'et indice de production (RPI)',
  shortName: 'Panel réticulocytaire',
  category: CalculatorCategory.hematology,
  version: 'Convention standard (nombre absolu) + correction Hillman 1969',
  equation:
      'Nombre absolu (×10⁹/L) = [Réticulocytes (%) / 100] × GR (×10¹²/L) × '
      '1000  ;  CRC (%) = Réticulocytes (%) × (Hématocrite du patient (%) '
      '/ 45)  ;  RPI = CRC / facteur de maturation(Hct), où le facteur de '
      'maturation = 1,0 si Hct ≥ 40 % ; 1,5 si 30–39,9 % ; 2,0 si '
      '20–29,9 % ; 2,5 si < 20 %',
  sources: [
    Reference(
      citation:
          "Calcul standard d'hématologie clinique (dénombrement absolu à "
          'partir du pourcentage de réticulocytes et de la numération '
          'érythrocytaire).',
    ),
    Reference(
      citation:
          'Hillman RS. Characteristics of Marrow Production and '
          'Reticulocyte Maturation in Normal Man in Response to Anemia. J '
          'Clin Invest. 1969;48(3):443-453.',
      note:
          "Hématocrite de référence 45 % pour le calcul du CRC, et facteur "
          'de maturation en palier pour le RPI.',
    ),
  ],
  applicablePopulation: 'Adulte (hématocrite de référence 45 % non ajusté au sexe).',
  forbiddenConditions: [
    'Non valide en cas de transfusion récente (< 2-3 jours) : le compte '
        'réticulocytaire ne reflète alors plus la production médullaire du '
        'patient.',
  ],
  limitations: [
    "L'hématocrite de référence de 45 % utilisé pour le CRC est celui "
        "défini par Hillman ; certains protocoles utilisent une valeur "
        "différente selon le sexe (ex. 40 % chez la femme), non implémentée "
        'ici afin de rester fidèle à la définition originale.',
    'Le facteur de maturation est une fonction en palier (et non continue) '
        "de l'hématocrite, telle que décrite par Hillman ; elle ne tient "
        'pas compte du contexte clinique (ex. hémolyse, saignement aigu).',
  ],
  helpText:
      "Réticulocytes en %, numération des globules rouges (GR) en ×10¹²/L, "
      "hématocrite du patient en %.",
);

/// Panel réticulocytaire : nombre absolu de réticulocytes (×10⁹/L),
/// réticulocytes corrigés CRC (%, hématocrite de référence 45 %, Hillman
/// 1969) et indice de production réticulocytaire RPI (Hillman 1969).
CalculationResult calculateReticulocyteIndicesPanel({
  required double reticulocytePercent,
  required double rbcTeraL,
  required double hematocritPercent,
}) {
  Validation.raiseIfAny([
    Validation.checkNonNegative(reticulocytePercent, 'reticulocytePercent', 'Réticulocytes'),
    Validation.checkPositive(rbcTeraL, 'rbcTeraL', 'Numération des globules rouges (GR)'),
    Validation.checkPositive(hematocritPercent, 'hematocritPercent', 'Hématocrite'),
  ]);

  final absoluteCount = (reticulocytePercent / 100) * rbcTeraL * 1000;
  final correctedRetic = reticulocytePercent * (hematocritPercent / 45);
  final maturationFactor = _hillmanMaturationFactor(hematocritPercent);
  final rpi = correctedRetic / maturationFactor;

  return CalculationResult(
    formula: reticulocyteIndicesPanelMeta,
    echoedInputs: {
      'Réticulocytes': '${reticulocytePercent.toStringAsFixed(2)} %',
      'GR': '${rbcTeraL.toStringAsFixed(2)} ×10¹²/L',
      'Hématocrite': '${hematocritPercent.toStringAsFixed(1)} %',
      'Facteur de maturation (Hillman)': maturationFactor.toStringAsFixed(1),
    },
    values: [
      ResultValue(
        label: 'Nombre absolu de réticulocytes',
        value: absoluteCount,
        unit: '×10⁹/L',
        precision: 1,
      ),
      ResultValue(
        label: 'Réticulocytes corrigés (CRC)',
        value: correctedRetic,
        unit: '%',
        precision: 2,
      ),
      ResultValue(
        label: 'Indice de production réticulocytaire (RPI)',
        value: rpi,
        unit: '',
        precision: 2,
      ),
    ],
    warnings: [
      CalculationWarning(
        rpi < 2
            ? 'RPI < 2 : évocateur d\'une réponse médullaire inadaptée '
                '(hypoproliférative), compatible par exemple avec une '
                'insuffisance médullaire, une carence nutritionnelle ou '
                "une anémie par défaut de production. Interprétation "
                "d'enseignement classique en hématologie clinique, fondée "
                'sur la méthode de Hillman (1969) déjà citée pour ce '
                "panel, et non sur une recommandation formelle d'une "
                'société savante nommée.'
            : 'RPI ≥ 2 (typiquement 2 à 3 ou plus) : évocateur d\'une '
                'réponse médullaire compensatrice adaptée à l\'anémie, '
                'compatible par exemple avec une hémolyse active ou une '
                'hémorragie avec réponse médullaire appropriée. '
                "Interprétation d'enseignement classique en hématologie "
                'clinique, fondée sur la méthode de Hillman (1969) déjà '
                "citée pour ce panel, et non sur une recommandation "
                "formelle d'une société savante nommée.",
        severity: WarningSeverity.info,
      ),
    ],
  );
}
