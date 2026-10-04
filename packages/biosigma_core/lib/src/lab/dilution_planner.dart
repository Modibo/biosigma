import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';
import '../validation.dart';
import 'pipette.dart';

/// Planificateur de dilutions (backlog P5-04, tests T-PIP-003).
const FormulaMeta dilutionPlannerMeta = FormulaMeta(
  id: 'lab_dilution_planner',
  name: 'Planificateur de dilutions avec vos pipettes',
  shortName: 'Planificateur de dilutions',
  category: CalculatorCategory.laboratory,
  version: 'Planner 1 — recherche exhaustive bornée, règle PIP_CHECK_001',
  equation:
      'Étape j : prélèvement t_j = V_j / f_j ; diluant d_j = V_j − t_j ;  F = f_1 × f_2 × … × f_k\n'
      'Chaque volume pipeté doit être réalisable avec une pipette de l\'utilisateur (classes : possible / recommandé / validé)',
  sources: [
    Reference(
      citation:
          'Conservation du soluté lors d\'une dilution (C1·V1 = C2·V2) et règle de pipetabilité '
          'PIP_CHECK_001 fondée sur les seuils saisis par l\'utilisateur : aucune norme citée — '
          'à relire par le laboratoire.',
    ),
  ],
  applicablePopulation: 'Sans objet (préparation).',
  analyticalConditions: [
    'Les pipettes, leurs plages, leur seuil « recommandé » et leur vérification sont ceux saisis par l\'utilisateur.',
  ],
  limitations: [
    'Calcul théorique : exactitude et justesse des pipettes, volume mort réel, évaporation, '
        'adsorption et mélange ne sont pas modélisés (seul un volume mort saisi est pris en compte).',
    'Un volume supérieur à votre plus grande pipette est considéré non réalisable (pas de pipetages multiples).',
    'Recherche bornée : étapes entières jusqu\'à une certaine taille ; la meilleure stratégie parmi '
        'celles explorées est proposée, pas une optimalité prouvée au sens absolu.',
  ],
  displayPrecision: 3,
);

/// Un volume à pipeter, avec les pipettes utilisables.
class PlanOperation {
  const PlanOperation({required this.label, required this.volumeUl, required this.checks});

  /// « Prélèvement » ou « Diluant ».
  final String label;
  final double volumeUl;

  /// Pipettes utilisables, de la meilleure à la moins bonne (voir [suggestPipettes]).
  final List<PipetteCheck> checks;

  PipetteCheck? get best => checks.isEmpty ? null : checks.first;
}

class PlanStep {
  const PlanStep({
    required this.index,
    required this.factor,
    required this.cumulativeFactor,
    required this.tubeVolumeUl,
    required this.transfer,
    required this.diluent,
  });

  final int index;

  /// Facteur de dilution de cette étape (volume du tube / volume prélevé).
  final double factor;
  final double cumulativeFactor;

  /// Volume final du tube après cette étape (µL).
  final double tubeVolumeUl;
  final PlanOperation transfer;
  final PlanOperation diluent;
}

class DilutionPlan {
  const DilutionPlan({required this.steps, required this.score, required this.usesDiscouraged});

  final List<PlanStep> steps;

  /// Somme des classes des pipettes retenues (plus haut = mieux).
  final int score;
  final bool usesDiscouraged;

  double get totalDiluentUl => steps.fold(0.0, (a, s) => a + s.diluent.volumeUl);
  int get stepCount => steps.length;
  bool get hasNonIntegerFactor => steps.any((s) => (s.factor - s.factor.roundToDouble()).abs() > 1e-9);
}

/// Stratégie écartée, avec les raisons.
class RejectedPlan {
  const RejectedPlan({required this.description, required this.reasons});
  final String description;
  final List<String> reasons;
}

class DilutionPlanResult {
  const DilutionPlanResult({
    required this.result,
    required this.plans,
    required this.rejected,
    required this.factor,
    required this.finalVolumeUl,
  });

  final CalculationResult result;

  /// Stratégies réalisables, la meilleure en premier (au plus 5).
  final List<DilutionPlan> plans;
  final List<RejectedPlan> rejected;
  final double factor;
  final double finalVolumeUl;

  DilutionPlan? get best => plans.isEmpty ? null : plans.first;
}

String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(v < 10 ? 2 : 1);
}

class _Evaluated {
  _Evaluated(this.factors, this.steps, this.problems);

  final List<double> factors;

  /// Étapes réussies, de la dernière à la première (arrêt à la première étape impossible).
  final List<PlanStep> steps;
  final List<String> problems;
  bool get feasible => problems.isEmpty && steps.length == factors.length;
}

/// Cherche comment réaliser une dilution de facteur [factor] jusqu'à
/// [finalVolumeUl] µL avec les [pipettes] de l'utilisateur.
///
/// - Exploration de 1 à [maxSteps] étapes (facteurs entiers pour les premières
///   étapes, dernier facteur déduit) ;
/// - chaque volume (prélèvement, diluant) doit être pipetable : classes
///   « recommandé » ou « validé » (et « possible » si [allowDiscouraged]) ;
/// - un tube intermédiaire doit contenir au moins le prélèvement de l'étape
///   suivante plus [deadVolumeUl] ;
/// - les stratégies sont classées : moins d'étapes, facteurs entiers, meilleure
///   classe de pipettes, moins de diluant ; les écartées sont expliquées.
DilutionPlanResult planDilution({
  required double? factor,
  required double? finalVolumeUl,
  required List<Pipette> pipettes,
  required DateTime now,
  int maxSteps = 3,
  double deadVolumeUl = 0,
  bool allowDiscouraged = false,
}) {
  Validation.raiseIfAny([
    Validation.checkProvided(factor, 'factor', 'Le facteur de dilution'),
    if (factor != null && factor <= 1)
      const FieldError(fieldId: 'factor', message: 'Le facteur de dilution doit être supérieur à 1.'),
    if (factor != null && factor > 1e7)
      const FieldError(fieldId: 'factor', message: 'Facteur de dilution trop grand pour être planifié (≤ 10⁷).'),
    Validation.checkPositive(finalVolumeUl, 'finalVolume', 'Le volume final'),
    maxSteps < 1 || maxSteps > 4
        ? const FieldError(fieldId: 'maxSteps', message: 'Le nombre d\'étapes maximal doit être compris entre 1 et 4.')
        : null,
    Validation.checkNonNegative(deadVolumeUl, 'deadVolume', 'Le volume mort'),
    pipettes.isEmpty
        ? const FieldError(
            fieldId: 'pipettes',
            message: 'Aucune pipette enregistrée : ajoutez vos pipettes dans Réglages pour planifier.')
        : null,
  ]);

  final f = factor!;
  final vFinal = finalVolumeUl!;
  final minFit = allowDiscouraged ? PipetteFit.possible.index : PipetteFit.recommended.index;

  PlanOperation op(String label, double volume) =>
      PlanOperation(label: label, volumeUl: volume, checks: suggestPipettes(volume, pipettes, now: now));

  bool acceptable(PlanOperation o) => o.best != null && o.best!.fit.index >= minFit;

  String whyNot(PlanOperation o, String where) {
    final all = [for (final p in pipettes) checkPipetability(o.volumeUl, p, now: now)];
    final usable = all.where((c) => c.usable).toList();
    final v = '${_fmt(o.volumeUl)} µL';
    if (usable.isEmpty) {
      final maxUl = pipettes.map((p) => p.maxUl).reduce((a, b) => a > b ? a : b);
      final minUl = pipettes.map((p) => p.minUl).reduce((a, b) => a < b ? a : b);
      if (o.volumeUl > maxUl) {
        return '$where : $v dépasse votre plus grande pipette (${_fmt(maxUl)} µL).';
      }
      if (o.volumeUl < minUl) {
        return '$where : $v est inférieur au minimum de votre pipette la plus fine (${_fmt(minUl)} µL).';
      }
      return '$where : $v n\'entre dans la plage d\'aucune de vos pipettes.';
    }
    return '$where : $v n\'est que « possible (déconseillé) » avec ${usable.first.pipette.name} '
        '(sous votre seuil recommandé).';
  }

  /// Construit les étapes (de la dernière à la première) ; s'arrête à la première
  /// étape impossible et en donne les raisons.
  _Evaluated evaluate(List<double> factors) {
    final k = factors.length;
    final built = <PlanStep>[]; // de la dernière étape à la première
    var nextTransferNeed = 0.0;
    var cum = 1.0;
    final cumulative = <double>[];
    for (final x in factors) {
      cum *= x;
      cumulative.add(cum);
    }

    for (var j = k - 1; j >= 0; j--) {
      final fj = factors[j];
      final List<double> candidates;
      if (j == k - 1) {
        candidates = [vFinal];
      } else {
        final required = nextTransferNeed + deadVolumeUl;
        const grid = [1, 1.1, 1.25, 1.5, 2, 2.5, 3, 4, 5, 7.5, 10, 15, 20, 50];
        final set = <double>{for (final g in grid) _round(required * g)};
        for (final p in pipettes) {
          for (final t in [p.recommendedMinUl ?? p.minUl, p.maxUl, (p.minUl + p.maxUl) / 2]) {
            final v = _round(t * fj);
            if (v >= required) set.add(v);
          }
        }
        candidates = set.where((v) => v >= required - 1e-9).toList()..sort();
      }

      PlanStep? chosen;
      var bestScore = -1;
      List<String>? bestProblems;
      for (final v in candidates) {
        final t = op('Prélèvement', v / fj);
        final d = op('Diluant', v - v / fj);
        final ok = acceptable(t) && acceptable(d);
        final sc = (t.best?.fit.index ?? 0) + (d.best?.fit.index ?? 0);
        if (ok && sc > bestScore) {
          bestScore = sc;
          chosen = PlanStep(
            index: j + 1,
            factor: fj,
            cumulativeFactor: cumulative[j],
            tubeVolumeUl: v,
            transfer: t,
            diluent: d,
          );
        } else if (!ok && chosen == null) {
          final where = k == 1 ? '' : 'Étape ${j + 1} (1/${_fmt(fj)})';
          final probs = <String>[
            if (!acceptable(t)) whyNot(t, where.isEmpty ? 'Prélèvement' : '$where, prélèvement'),
            if (!acceptable(d)) whyNot(d, where.isEmpty ? 'Diluant' : '$where, diluant'),
          ];
          if (bestProblems == null || probs.length < bestProblems.length) bestProblems = probs;
        }
      }
      if (chosen == null) {
        return _Evaluated(factors, built, bestProblems ?? ['Étape ${j + 1} : aucun volume réalisable.']);
      }
      built.add(chosen);
      nextTransferNeed = chosen.transfer.volumeUl;
    }
    return _Evaluated(factors, built.reversed.toList(), const []);
  }

  final plans = <DilutionPlan>[];
  final nearMisses = <int, _Evaluated>{}; // meilleure tentative infructueuse par nombre d'étapes
  final integerF = (f - f.roundToDouble()).abs() < 1e-9;

  bool better(_Evaluated a, _Evaluated b) {
    if (a.steps.length != b.steps.length) return a.steps.length > b.steps.length;
    return a.problems.length < b.problems.length;
  }

  void consider(List<double> factors) {
    final e = evaluate(factors);
    if (e.feasible) {
      final score = e.steps.fold<int>(0, (a, s) => a + (s.transfer.best?.fit.index ?? 0) + (s.diluent.best?.fit.index ?? 0));
      final discouraged = e.steps.any((s) =>
          (s.transfer.best?.fit == PipetteFit.possible) || (s.diluent.best?.fit == PipetteFit.possible));
      plans.add(DilutionPlan(steps: e.steps, score: score, usesDiscouraged: discouraged));
    } else {
      final cur = nearMisses[factors.length];
      if (cur == null || better(e, cur)) nearMisses[factors.length] = e;
    }
  }

  // 1 étape
  consider([f]);

  // 2 étapes : f1 entier, f2 = F / f1 (≥ 1,5)
  if (maxSteps >= 2 && plans.length < 5) {
    final limit = f.floor().clamp(2, 2000);
    for (var f1 = 2; f1 <= limit; f1++) {
      final f2 = f / f1;
      if (f2 < 1.5) break;
      consider([f1.toDouble(), f2]);
    }
  }
  // 3 étapes (la recherche s'arrête dès que 5 stratégies plus courtes existent)
  if (maxSteps >= 3 && plans.length < 5) {
    for (var f1 = 2; f1 <= 200; f1++) {
      for (var f2 = 2; f2 <= 200; f2++) {
        final f3 = f / (f1 * f2);
        if (f3 < 1.5) break;
        consider([f1.toDouble(), f2.toDouble(), f3]);
      }
    }
  }
  // 4 étapes (facteurs 2..30 pour borner la recherche)
  if (maxSteps >= 4 && plans.length < 5) {
    for (var f1 = 2; f1 <= 30; f1++) {
      for (var f2 = 2; f2 <= 30; f2++) {
        for (var f3 = 2; f3 <= 30; f3++) {
          final f4 = f / (f1 * f2 * f3);
          if (f4 < 1.5) break;
          consider([f1.toDouble(), f2.toDouble(), f3.toDouble(), f4]);
        }
      }
    }
  }

  // Facteurs non entiers : seulement quand F l'est ou pour la dernière étape.
  plans.removeWhere((p) {
    if (integerF) return false;
    return p.steps.length > 1 && p.steps.take(p.steps.length - 1).any((s) => (s.factor - s.factor.roundToDouble()).abs() > 1e-9);
  });

  plans.sort((a, b) {
    final bySteps = a.stepCount.compareTo(b.stepCount);
    if (bySteps != 0) return bySteps;
    final byInt = (a.hasNonIntegerFactor ? 1 : 0).compareTo(b.hasNonIntegerFactor ? 1 : 0);
    if (byInt != 0) return byInt;
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    return a.totalDiluentUl.compareTo(b.totalDiluentUl);
  });
  final top = plans.length > 5 ? plans.sublist(0, 5) : plans;

  // Rejets motivés : la tentative à 1 étape, et la meilleure tentative infructueuse des autres nombres d'étapes.
  final rejected = <RejectedPlan>[];
  String describe(_Evaluated e) => e.factors.length == 1
      ? '1 étape (1/${_fmt(f)})'
      : '${e.factors.length} étapes (${e.factors.map((x) => '1/${_fmt(x)}').join(' puis ')})';
  for (final entry in (nearMisses.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))) {
    // On n'explique un nombre d'étapes que s'il est plus petit que celui de la meilleure stratégie trouvée,
    // ou s'il n'y en a aucune.
    if (top.isNotEmpty && entry.key >= top.first.stepCount) continue;
    rejected.add(RejectedPlan(description: describe(entry.value), reasons: entry.value.problems));
  }

  final warnings = <CalculationWarning>[];
  final values = <ResultValue>[
    ResultValue(label: 'Facteur de dilution visé', value: f, unit: '', precision: 4),
  ];
  if (top.isEmpty) {
    warnings.add(CalculationWarning(
      'Aucune stratégie réalisable avec vos pipettes (jusqu\'à $maxSteps étape(s)). '
      'Ajoutez une pipette adaptée, autorisez les volumes « possibles (déconseillés) », augmentez le volume final '
      'ou le nombre d\'étapes.',
      severity: WarningSeverity.blocking,
    ));
    // Aide : volume final minimal pour une étape unique
    final minRec = pipettes.map((p) => p.recommendedMinUl ?? p.minUl).reduce((a, b) => a < b ? a : b);
    final maxUl = pipettes.map((p) => p.maxUl).reduce((a, b) => a > b ? a : b);
    final vNeeded = minRec * f;
    if (vNeeded - minRec <= maxUl) {
      warnings.add(CalculationWarning(
        'Pour une seule étape, le volume final devrait être d\'au moins ${_fmt(vNeeded)} µL '
        '(prélèvement de ${_fmt(minRec)} µL = seuil recommandé de votre pipette la plus fine ; '
        'diluant ${_fmt(vNeeded - minRec)} µL, dans la plage de votre plus grande pipette).',
        severity: WarningSeverity.info,
      ));
    } else {
      warnings.add(CalculationWarning(
        'Même en une seule étape, le diluant dépasserait votre plus grande pipette (${_fmt(maxUl)} µL) : '
        'ajoutez une pipette de plus grande plage ou répartissez la dilution en plusieurs étapes.',
        severity: WarningSeverity.info,
      ));
    }
  } else {
    final b = top.first;
    values.add(ResultValue(label: 'Nombre d\'étapes de la stratégie proposée', value: b.stepCount.toDouble(), unit: '', precision: 0));
    values.add(ResultValue(label: 'Diluant total', value: b.totalDiluentUl, unit: 'µL', precision: 1));
    values.add(ResultValue(label: 'Prélèvement sur la solution mère', value: b.steps.first.transfer.volumeUl, unit: 'µL', precision: 2));
    if (b.usesDiscouraged) {
      warnings.add(const CalculationWarning(
        'Cette stratégie emploie au moins un volume « possible (déconseillé) » (sous votre seuil recommandé).',
        severity: WarningSeverity.caution,
      ));
    }
    if (b.hasNonIntegerFactor) {
      warnings.add(const CalculationWarning(
        'Un facteur d\'étape n\'est pas entier : prélèvement et diluant sont calculés exactement, '
        'mais cette étape est moins pratique à préparer.',
        severity: WarningSeverity.info,
      ));
    }
    final notes = <String>{
      for (final s in b.steps) ...[...?s.transfer.best?.notes, ...?s.diluent.best?.notes],
    };
    for (final n in notes) {
      warnings.add(CalculationWarning(n, severity: WarningSeverity.caution));
    }
  }
  warnings.add(const CalculationWarning(
    'Calcul théorique : exactitude des pipettes, volume mort réel, évaporation et mélange ne sont pas modélisés. '
    'Notation : « 1/F » = 1 volume dans F volumes au total.',
    severity: WarningSeverity.info,
  ));

  final result = CalculationResult(
    formula: dilutionPlannerMeta,
    isComplete: top.isNotEmpty,
    echoedInputs: {
      'Facteur de dilution visé': _fmt(f),
      'Volume final': '${_fmt(vFinal)} µL',
      'Pipettes': pipettes.map((p) => p.name).join(', '),
      'Volume mort saisi': '${_fmt(deadVolumeUl)} µL',
      'Étapes maximales': '$maxSteps',
      'Volumes déconseillés': allowDiscouraged ? 'autorisés' : 'refusés',
    },
    values: values,
    warnings: warnings,
  );

  return DilutionPlanResult(
    result: result,
    plans: top,
    rejected: rejected,
    factor: f,
    finalVolumeUl: vFinal,
  );
}

double _round(double v) {
  // 4 chiffres significatifs : des volumes lisibles, sans changer l'ordre de grandeur.
  final s = v.toStringAsPrecision(4);
  return double.parse(s);
}
