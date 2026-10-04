import 'dart:math' as math;

import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';

/// Propagation d'incertitude (mode Expert), loi de propagation du premier ordre
/// du GUM pour des grandeurs d'entrée **non corrélées**.
const FormulaMeta uncertaintyMeta = FormulaMeta(
  id: 'lab_uncertainty',
  name: 'Propagation d\'incertitude (GUM) : incertitude-type composée et élargie',
  shortName: 'Incertitude',
  category: CalculatorCategory.laboratory,
  version: 'GUM 1 — JCGM 100:2008, premier ordre, grandeurs non corrélées',
  equation:
      'Modèle linéaire Y = Σ cᵢ·xᵢ :  u_c²(y) = Σ cᵢ²·u²(xᵢ)\n'
      'Modèle produit Y = c·Πxᵢ^pᵢ :  [u_c(y)/y]² = Σ [pᵢ·u(xᵢ)/xᵢ]²\n'
      'Incertitude élargie U = k·u_c(y)   (k saisi)\n'
      'Type A : u = s/√n ;  type B rectangulaire : u = a/√3',
  sources: [
    Reference(
      citation:
          'JCGM 100:2008. Evaluation of measurement data — Guide to the expression of uncertainty in '
          'measurement (GUM).',
      note: 'éq. (10) § 5.1.2, éq. (12) § 5.1.6, éq. (5) § 4.2.3, éq. (7) § 4.3.7, §§ 6.2-6.3 — '
          'lus le 2026-10-04 (texte du guide) ; à relire par le validateur',
    ),
  ],
  applicablePopulation: 'Sans objet (métrologie du résultat).',
  analyticalConditions: [
    'Les incertitudes-types des grandeurs d\'entrée sont saisies par l\'utilisateur (type A ou B) ; '
        'BioSigma n\'en propose aucune.',
    'Les grandeurs d\'entrée sont supposées non corrélées.',
  ],
  limitations: [
    'Approximation du premier ordre : insuffisante si le modèle est fortement non linéaire (GUM § 5.1.2, note).',
    'Le facteur d\'élargissement k est choisi par l\'utilisateur ; l\'association de k à un niveau de confiance '
        'suppose une distribution approximativement normale (GUM § 6.3, annexe G).',
    'Les composantes de covariance, les degrés de liberté et la formule de Welch-Satterthwaite ne sont pas pris en compte.',
  ],
  displayPrecision: 4,
);

enum UncertaintyModel {
  linear('Somme pondérée Y = Σ cᵢ·xᵢ'),
  product('Produit Y = c·Π xᵢ^pᵢ');

  const UncertaintyModel(this.label);
  final String label;
}

/// Une grandeur d'entrée : valeur, incertitude-type, et son coefficient
/// (modèle linéaire : cᵢ) ou son exposant (modèle produit : pᵢ).
class UncertaintyInput {
  const UncertaintyInput({
    required this.name,
    required this.value,
    required this.standardUncertainty,
    this.weight = 1,
  });
  final String name;
  final double value;
  final double standardUncertainty;

  /// Coefficient cᵢ (linéaire) ou exposant pᵢ (produit).
  final double weight;
}

/// Incertitude-type d'une moyenne de répétitions (GUM § 4.2.3) : s / √n.
double standardUncertaintyOfMean(List<double> repeats) {
  if (repeats.length < 2) {
    throw CalculationInputException([
      const FieldError(fieldId: 'repeats', message: 'Au moins 2 répétitions sont nécessaires.'),
    ]);
  }
  final n = repeats.length;
  final mean = repeats.reduce((a, b) => a + b) / n;
  final s2 = repeats.fold<double>(0, (a, x) => a + (x - mean) * (x - mean)) / (n - 1);
  return math.sqrt(s2 / n);
}

/// Incertitude-type d'une grandeur bornée par ± [halfWidth], loi rectangulaire
/// (GUM § 4.3.7) : a / √3.
double standardUncertaintyRectangular(double halfWidth) {
  if (!(halfWidth > 0) || !halfWidth.isFinite) {
    throw CalculationInputException([
      const FieldError(fieldId: 'halfWidth', message: 'La demi-largeur doit être strictement positive.'),
    ]);
  }
  return halfWidth / math.sqrt(3);
}

/// Incertitude-type déduite d'une incertitude élargie donnée avec son facteur k : U / k.
double standardUncertaintyFromExpanded(double expanded, double k) {
  if (!(expanded > 0) || !(k > 0) || !expanded.isFinite || !k.isFinite) {
    throw CalculationInputException([
      const FieldError(fieldId: 'expanded', message: 'U et k doivent être strictement positifs.'),
    ]);
  }
  return expanded / k;
}

/// Propagation numérique générale (premier ordre, non corrélée), par
/// différences centrales : sert de contre-vérification aux deux modèles
/// analytiques et à tout modèle dérivable fourni par l'appelant.
({double y, double combined, List<double> sensitivities}) propagateNumeric(
  double Function(List<double>) f,
  List<double> values,
  List<double> standardUncertainties,
) {
  assert(values.length == standardUncertainties.length);
  final y = f(values);
  final c = <double>[];
  var variance = 0.0;
  for (var i = 0; i < values.length; i++) {
    final h = math.max(values[i].abs(), 1e-3) * 1e-6;
    final up = [...values]..[i] = values[i] + h;
    final down = [...values]..[i] = values[i] - h;
    final ci = (f(up) - f(down)) / (2 * h);
    c.add(ci);
    variance += ci * ci * standardUncertainties[i] * standardUncertainties[i];
  }
  return (y: y, combined: math.sqrt(variance), sensitivities: c);
}

/// Calcule l'incertitude composée et élargie d'un résultat. [constant] est le
/// facteur c du modèle produit (1 par défaut).
CalculationResult calculateUncertainty({
  required UncertaintyModel model,
  required List<UncertaintyInput> inputs,
  required double coverageFactor,
  double constant = 1,
}) {
  final errors = <FieldError>[];
  if (inputs.isEmpty) {
    errors.add(const FieldError(fieldId: 'inputs', message: 'Au moins une grandeur d\'entrée est requise.'));
  }
  if (!(coverageFactor > 0) || !coverageFactor.isFinite) {
    errors.add(const FieldError(fieldId: 'coverageFactor', message: 'Le facteur d\'élargissement k doit être strictement positif.'));
  }
  for (final x in inputs) {
    if (!x.value.isFinite) {
      errors.add(FieldError(fieldId: 'value:${x.name}', message: 'Valeur de « ${x.name} » invalide.'));
    }
    if (!(x.standardUncertainty >= 0) || !x.standardUncertainty.isFinite) {
      errors.add(FieldError(
        fieldId: 'uncertainty:${x.name}',
        message: 'L\'incertitude-type de « ${x.name} » doit être positive ou nulle.',
      ));
    }
    if (model == UncertaintyModel.product) {
      if (x.value == 0) {
        errors.add(FieldError(
          fieldId: 'value:${x.name}',
          message: 'Modèle produit : « ${x.name} » ne peut pas être nul (incertitude relative indéfinie).',
        ));
      } else if (x.value < 0 && x.weight != x.weight.roundToDouble()) {
        errors.add(FieldError(
          fieldId: 'value:${x.name}',
          message: 'Modèle produit : « ${x.name} » négatif avec un exposant non entier n\'a pas de sens.',
        ));
      }
    }
  }
  if (errors.isNotEmpty) throw CalculationInputException(errors);

  double y;
  final contributions = <double>[]; // cᵢ²·u²(xᵢ) en unités de y²
  if (model == UncertaintyModel.linear) {
    y = inputs.fold<double>(0, (a, x) => a + x.weight * x.value);
    for (final x in inputs) {
      contributions.add(math.pow(x.weight * x.standardUncertainty, 2).toDouble());
    }
  } else {
    y = constant * inputs.fold<double>(1, (a, x) => a * math.pow(x.value, x.weight));
    for (final x in inputs) {
      // (∂y/∂xᵢ · u)² = (y·pᵢ·u/xᵢ)²  — équivalent à l'éq. (12) rapportée à y².
      contributions.add(math.pow(y * x.weight * x.standardUncertainty / x.value, 2).toDouble());
    }
  }
  final variance = contributions.fold<double>(0, (a, b) => a + b);
  final uc = math.sqrt(variance);
  final expanded = coverageFactor * uc;

  final values = <ResultValue>[
    ResultValue(label: 'Résultat y', value: y, unit: '', precision: 4),
    ResultValue(label: 'Incertitude-type composée u_c(y)', value: uc, unit: '', precision: 4),
    if (y != 0)
      ResultValue(label: 'Incertitude-type relative u_c(y)/|y|', value: uc / y.abs() * 100, unit: '%', precision: 3),
    ResultValue(label: 'Incertitude élargie U = k·u_c', value: expanded, unit: '', precision: 4),
    if (variance > 0)
      for (var i = 0; i < inputs.length; i++)
        ResultValue(
          label: 'Part de la variance : ${inputs[i].name}',
          value: contributions[i] / variance * 100,
          unit: '%',
          precision: 1,
        ),
  ];

  final warnings = <CalculationWarning>[
    const CalculationWarning(
      'Propagation du premier ordre, grandeurs d\'entrée supposées non corrélées (GUM § 5.1.2). '
      'Les incertitudes-types saisies sont de votre responsabilité.',
      severity: WarningSeverity.info,
    ),
    if (coverageFactor < 2 || coverageFactor > 3)
      CalculationWarning(
        'k = ${coverageFactor.toStringAsFixed(2)} est hors de l\'intervalle usuel 2 à 3 (GUM § 6.3.1) : '
        'à justifier selon le niveau de confiance recherché.',
        severity: WarningSeverity.caution,
      ),
  ];

  return CalculationResult(
    formula: uncertaintyMeta,
    echoedInputs: {
      'Modèle': model.label,
      if (model == UncertaintyModel.product && constant != 1) 'Constante c': constant.toString(),
      for (final x in inputs)
        x.name: '${x.value} ± ${x.standardUncertainty} (u)'
            '${model == UncertaintyModel.linear ? ', c=' : ', p='}${x.weight}',
      'Facteur d\'élargissement k': coverageFactor.toString(),
    },
    values: values,
    warnings: warnings,
  );
}

/// Préréglage de la dilution C2 = C1·V1/V2 (modèle produit, exposants +1, +1, −1).
CalculationResult calculateDilutionUncertainty({
  required double c1,
  required double uC1,
  required double v1,
  required double uV1,
  required double v2,
  required double uV2,
  required double coverageFactor,
}) =>
    calculateUncertainty(
      model: UncertaintyModel.product,
      coverageFactor: coverageFactor,
      inputs: [
        UncertaintyInput(name: 'C1', value: c1, standardUncertainty: uC1, weight: 1),
        UncertaintyInput(name: 'V1', value: v1, standardUncertainty: uV1, weight: 1),
        UncertaintyInput(name: 'V2', value: v2, standardUncertainty: uV2, weight: -1),
      ],
    );
