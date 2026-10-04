import 'dart:math' as math;

import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';
import '../validation.dart';
import 'lab_units.dart';

/// Indicateurs de qualité analytique : CV, biais, récupération, erreur totale, Sigma.
const FormulaMeta qualityMeta = FormulaMeta(
  id: 'lab_quality',
  name: 'Qualité analytique : CV, biais, récupération, erreur totale, Sigma',
  shortName: 'Quality',
  category: CalculatorCategory.laboratory,
  version: 'Quality 1 — définitions usuelles ; ETa et k saisis par l\'utilisateur',
  equation:
      'Moyenne x̄ = Σxᵢ / n ;  écart-type s = √[Σ(xᵢ − x̄)² / (n − 1)] ;  CV % = s / x̄ × 100\n'
      'Biais % = (x̄ − cible) / cible × 100 ;  Récupération % = x̄ / cible × 100\n'
      'Erreur totale % = |biais %| + k × CV %   (k saisi)\n'
      'Sigma = (ETa % − |biais %|) / CV %   (ETa saisie)',
  sources: [
    Reference(
      citation:
          'Définitions statistiques usuelles (moyenne, écart-type, coefficient de variation) et '
          'formules de biais, d\'erreur totale et de métrique Sigma : références à compléter par '
          'le laboratoire. Aucune valeur d\'erreur totale admissible (ETa), de coefficient k ni '
          'seuil d\'interprétation n\'est embarquée.',
      note: 'à relire par le laboratoire',
    ),
  ],
  applicablePopulation: 'Sans objet (qualité analytique d\'une méthode).',
  analyticalConditions: [
    'L\'ETa provient d\'une source choisie par le laboratoire (réglementaire, biologique, '
        'fournisseur…) : BioSigma n\'en propose aucune.',
    'Le CV et le biais doivent venir de mesures réalisées dans des conditions comparables '
        '(même niveau de concentration, même période).',
  ],
  limitations: [
    'Aucune interprétation (« acceptable », « excellent »…) n\'est donnée : la valeur Sigma '
        'est restituée sans verdict.',
    'Un échantillon de petite taille donne un CV peu fiable.',
  ],
  displayPrecision: 2,
);

/// Calcule les indicateurs possibles avec les données fournies.
///
/// Source des statistiques : soit [values] (n ≥ 2), soit [mean] et [sd].
/// [target] ajoute biais et récupération ; [tea] (ETa, en %) ajoute Sigma ;
/// [k] ajoute l'erreur totale.
CalculationResult calculateQuality({
  List<double>? values,
  double? mean,
  double? sd,
  double? target,
  double? tea,
  double? k,
}) {
  double m;
  double s;
  int? n;
  if (values != null && values.isNotEmpty) {
    if (values.any((v) => !v.isFinite)) {
      throw CalculationInputException(const [
        FieldError(fieldId: 'values', message: 'Toutes les valeurs doivent être des nombres valides.'),
      ]);
    }
    if (values.length < 2) {
      throw CalculationInputException(const [
        FieldError(fieldId: 'values', message: 'Au moins deux valeurs sont nécessaires pour un écart-type.'),
      ]);
    }
    n = values.length;
    m = values.reduce((a, b) => a + b) / n;
    s = math.sqrt(values.fold<double>(0, (acc, v) => acc + (v - m) * (v - m)) / (n - 1));
  } else {
    Validation.raiseIfAny([
      Validation.checkProvided(mean, 'mean', 'La moyenne'),
      Validation.checkNonNegative(sd, 'sd', 'L\'écart-type'),
    ]);
    m = mean!;
    s = sd!;
  }
  Validation.raiseIfAny([
    if (m == 0)
      const FieldError(fieldId: 'mean', message: 'La moyenne est nulle : le CV n\'est pas défini.'),
    if (target != null) Validation.checkPositive(target, 'target', 'La valeur cible'),
    if (tea != null) Validation.checkPositive(tea, 'tea', 'L\'ETa'),
    if (k != null) Validation.checkPositive(k, 'k', 'Le coefficient k'),
  ]);

  final cv = s / m.abs() * 100;
  final out = <ResultValue>[
    ResultValue(label: 'Moyenne', value: m, unit: '', precision: LabUnits.decimalsForSignificant(m)),
    ResultValue(label: 'Écart-type', value: s, unit: '', precision: LabUnits.decimalsForSignificant(s)),
    ResultValue(label: 'CV', value: cv, unit: '%', precision: 2),
  ];

  double? bias;
  if (target != null) {
    bias = (m - target) / target * 100;
    out.add(ResultValue(label: 'Biais', value: bias, unit: '%', precision: 2));
    out.add(ResultValue(label: 'Récupération', value: m / target * 100, unit: '%', precision: 2));
  }
  if (k != null) {
    out.add(bias == null
        ? const ResultValue(label: 'Erreur totale (cible requise pour le biais)', value: null, unit: '%')
        : ResultValue(label: 'Erreur totale', value: bias.abs() + k * cv, unit: '%', precision: 2));
  }
  var sigmaNote = false;
  if (tea != null) {
    if (bias == null || cv == 0) {
      out.add(const ResultValue(label: 'Sigma (cible requise et CV > 0)', value: null, unit: 'σ'));
      sigmaNote = true;
    } else {
      out.add(ResultValue(label: 'Sigma', value: (tea - bias.abs()) / cv, unit: 'σ', precision: 2));
    }
  }

  return CalculationResult(
    formula: qualityMeta,
    isComplete: !(k != null && bias == null) && !sigmaNote,
    echoedInputs: {
      if (n != null) 'Nombre de valeurs': '$n',
      if (target != null) 'Valeur cible': '$target',
      if (tea != null) 'ETa saisie': '$tea %',
      if (k != null) 'Coefficient k saisi': '$k',
    },
    values: out,
    warnings: [
      if (tea != null || k != null)
        const CalculationWarning(
          'L\'ETa et le coefficient k sont ceux que vous avez saisis ; BioSigma n\'en fournit '
          'aucun et ne donne aucune interprétation du résultat.',
          severity: WarningSeverity.caution,
        ),
      if (n != null && n < 20)
        CalculationWarning(
          'Seulement $n valeurs : le CV est peu fiable avec un petit échantillon.',
          severity: WarningSeverity.info,
        ),
    ],
  );
}
