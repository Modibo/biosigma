// T-PIP-003 : stratégies minimales respectant les contraintes, rejets motivés.
// Les pipettes sont celles d'un jeu de test saisi ici (rien n'est embarqué).
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

final now = DateTime.utc(2026, 10, 4);

const p10 = Pipette(name: 'P10', minUl: 1, maxUl: 10, recommendedMinUl: 2);
const p100 = Pipette(name: 'P100', minUl: 10, maxUl: 100, recommendedMinUl: 20);
const p1000 = Pipette(
  name: 'P1000',
  minUl: 100,
  maxUl: 1000,
  recommendedMinUl: 200,
);

void expectFieldError(void Function() body, String fieldId) {
  try {
    body();
    fail('une CalculationInputException était attendue');
  } on CalculationInputException catch (e) {
    expect(
      e.errors.map((x) => x.fieldId),
      contains(fieldId),
      reason: e.toString(),
    );
  }
}

/// Vérifie, indépendamment du planificateur, l'arithmétique d'une stratégie.
void verifyPlan(
  DilutionPlan plan,
  double factor,
  double finalVolume, {
  double dead = 0,
  bool strict = true,
}) {
  // produit des facteurs = F
  final product = plan.steps.fold<double>(1, (a, s) => a * s.factor);
  expect(
    product,
    closeTo(factor, factor * 1e-9),
    reason: 'produit des facteurs',
  );
  // dernière étape : volume final demandé
  expect(plan.steps.last.tubeVolumeUl, closeTo(finalVolume, 1e-9));
  var concentration = 1.0;
  for (var j = 0; j < plan.steps.length; j++) {
    final s = plan.steps[j];
    expect(
      s.transfer.volumeUl,
      closeTo(s.tubeVolumeUl / s.factor, 1e-9),
      reason: 'prélèvement = V / f',
    );
    expect(
      s.diluent.volumeUl,
      closeTo(s.tubeVolumeUl - s.transfer.volumeUl, 1e-9),
      reason: 'diluant = V − t',
    );
    concentration *= s.transfer.volumeUl / s.tubeVolumeUl;
    if (j < plan.steps.length - 1) {
      // le tube intermédiaire doit permettre le prélèvement suivant (+ volume mort)
      expect(
        s.tubeVolumeUl,
        greaterThanOrEqualTo(plan.steps[j + 1].transfer.volumeUl + dead - 1e-9),
      );
    }
    for (final o in [s.transfer, s.diluent]) {
      expect(o.best, isNotNull, reason: 'volume ${o.volumeUl} sans pipette');
      if (strict) {
        expect(
          o.best!.fit.index,
          greaterThanOrEqualTo(PipetteFit.recommended.index),
          reason: '${o.label} ${o.volumeUl} µL',
        );
      }
    }
  }
  expect(
    concentration,
    closeTo(1 / factor, 1 / factor * 1e-9),
    reason: 'concentration finale = C0 / F',
  );
}

void main() {
  group('une étape suffit', () {
    test(
      'F = 10, 1000 µL avec P100 + P1000 : 100 µL (P100) + 900 µL (P1000)',
      () {
        final r = planDilution(
          factor: 10,
          finalVolumeUl: 1000,
          pipettes: [p100, p1000],
          now: now,
        );
        final best = r.best!;
        expect(best.stepCount, 1);
        expect(best.steps.single.transfer.volumeUl, closeTo(100, 1e-9));
        expect(best.steps.single.transfer.best!.pipette.name, 'P100');
        expect(best.steps.single.diluent.volumeUl, closeTo(900, 1e-9));
        expect(best.steps.single.diluent.best!.pipette.name, 'P1000');
        expect(r.rejected, isEmpty);
        verifyPlan(best, 10, 1000);
        expect(r.result.isComplete, isTrue);
      },
    );

    test('facteur non entier 2,5 : une étape, prélèvement 400 µL', () {
      final r = planDilution(
        factor: 2.5,
        finalVolumeUl: 1000,
        pipettes: [p100, p1000],
        now: now,
      );
      expect(r.best!.stepCount, 1);
      expect(r.best!.steps.single.transfer.volumeUl, closeTo(400, 1e-9));
      verifyPlan(r.best!, 2.5, 1000);
    });
  });

  group('plusieurs étapes quand une seule est impossible', () {
    test('F = 1000, 1000 µL, P100 + P1000 : 1 µL est inférieur au minimum → 2 étapes (rejet motivé)', () {
      final r = planDilution(
        factor: 1000,
        finalVolumeUl: 1000,
        pipettes: [p100, p1000],
        now: now,
      );
      final best = r.best!;
      expect(best.stepCount, 2);
      verifyPlan(best, 1000, 1000);
      expect(r.rejected.length, 1);
      expect(r.rejected.single.description, contains('1 étape'));
      expect(
        r.rejected.single.reasons.single,
        contains('inférieur au minimum'),
      );
      expect(r.rejected.single.reasons.single, contains('10 µL'));
    });

    test('toutes les stratégies proposées sont arithmétiquement correctes', () {
      final r = planDilution(
        factor: 1000,
        finalVolumeUl: 1000,
        pipettes: [p100, p1000],
        now: now,
      );
      expect(r.plans, isNotEmpty);
      for (final p in r.plans) {
        verifyPlan(p, 1000, 1000);
      }
    });

    test('classement : moins d\'étapes d\'abord', () {
      final r = planDilution(
        factor: 1000,
        finalVolumeUl: 1000,
        pipettes: [p100, p1000],
        now: now,
      );
      for (var i = 1; i < r.plans.length; i++) {
        expect(
          r.plans[i].stepCount,
          greaterThanOrEqualTo(r.plans[i - 1].stepCount),
        );
      }
    });

    test('volume mort saisi : le tube intermédiaire contient le prélèvement suivant + 50 µL', () {
      final r = planDilution(
        factor: 100,
        finalVolumeUl: 1000,
        pipettes: [p100, p1000],
        now: now,
        deadVolumeUl: 50,
      );
      verifyPlan(r.best!, 100, 1000, dead: 50);
      expect(r.best!.stepCount, 2);
    });
  });

  group('volumes déconseillés', () {
    test('F = 1000, 1000 µL avec P10 : 1 µL n\'est que « possible » → refusé par défaut', () {
      final r = planDilution(
        factor: 1000,
        finalVolumeUl: 1000,
        pipettes: [p10, p100, p1000],
        now: now,
      );
      expect(r.best!.stepCount, greaterThan(1));
      expect(
        r.rejected.first.reasons.first,
        contains('possible (déconseillé)'),
      );
      expect(r.best!.usesDiscouraged, isFalse);
    });

    test('autorisés : 1 étape avec avertissement « déconseillé »', () {
      final r = planDilution(
        factor: 1000,
        finalVolumeUl: 1000,
        pipettes: [p10, p100, p1000],
        now: now,
        allowDiscouraged: true,
      );
      expect(r.best!.stepCount, 1);
      expect(r.best!.usesDiscouraged, isTrue);
      expect(
        r.result.warnings.any((w) => w.message.contains('déconseillé')),
        isTrue,
      );
      verifyPlan(r.best!, 1000, 1000, strict: false);
    });
  });

  group('aucune stratégie réalisable', () {
    test('une seule pipette P1000 et F = 100000 : rien de réalisable, avertissement bloquant et aide', () {
      final r = planDilution(
        factor: 100000,
        finalVolumeUl: 1000,
        pipettes: [p1000],
        now: now,
      );
      expect(r.plans, isEmpty);
      expect(r.best, isNull);
      expect(r.result.isComplete, isFalse);
      expect(r.result.hasBlockingWarning, isTrue);
      expect(r.rejected, isNotEmpty);
      expect(
        r.result.warnings.any(
          (w) => w.message.contains('dépasserait votre plus grande pipette'),
        ),
        isTrue,
      );
    });

    test(
      'le diluant dépasse la plus grande pipette : le dit explicitement',
      () {
        final r = planDilution(
          factor: 10,
          finalVolumeUl: 5000,
          pipettes: [p100, p1000],
          now: now,
          maxSteps: 1,
        );
        expect(r.plans, isEmpty);
        expect(
          r.rejected.single.reasons.join(' '),
          contains('dépasse votre plus grande pipette'),
        );
      },
    );
  });

  group('pipettes de l\'utilisateur', () {
    test('une pipette vérifiée (validée) est préférée à une non vérifiée', () {
      final verified = Pipette(
        name: 'P100 vérifiée',
        minUl: 10,
        maxUl: 100,
        recommendedMinUl: 20,
        verifiedOn: DateTime.utc(2026, 9, 1),
        verificationValidDays: 365,
      );
      const unverified = Pipette(
        name: 'P100 sans vérification',
        minUl: 10,
        maxUl: 100,
        recommendedMinUl: 20,
      );
      final r = planDilution(
        factor: 10,
        finalVolumeUl: 1000,
        pipettes: [unverified, verified, p1000],
        now: now,
      );
      expect(r.best!.steps.single.transfer.best!.pipette.name, 'P100 vérifiée');
      expect(r.best!.steps.single.transfer.best!.fit, PipetteFit.validated);
    });

    test('vérification périmée : avertissement dans le résultat', () {
      final expired = Pipette(
        name: 'P100 périmée',
        minUl: 10,
        maxUl: 100,
        recommendedMinUl: 20,
        verifiedOn: DateTime.utc(2024, 1, 1),
        verificationValidDays: 365,
      );
      final r = planDilution(
        factor: 10,
        finalVolumeUl: 1000,
        pipettes: [expired, p1000],
        now: now,
      );
      expect(
        r.result.warnings.any((w) => w.message.contains('périmée')),
        isTrue,
      );
    });
  });

  group('refus de saisie', () {
    test('facteur ≤ 1 ou trop grand, volume nul, étapes hors 1-4, volume mort négatif, aucune pipette', () {
      expectFieldError(
        () => planDilution(
          factor: 1,
          finalVolumeUl: 1000,
          pipettes: [p100],
          now: now,
        ),
        'factor',
      );
      expectFieldError(
        () => planDilution(
          factor: null,
          finalVolumeUl: 1000,
          pipettes: [p100],
          now: now,
        ),
        'factor',
      );
      expectFieldError(
        () => planDilution(
          factor: 1e8,
          finalVolumeUl: 1000,
          pipettes: [p100],
          now: now,
        ),
        'factor',
      );
      expectFieldError(
        () => planDilution(
          factor: 10,
          finalVolumeUl: 0,
          pipettes: [p100],
          now: now,
        ),
        'finalVolume',
      );
      expectFieldError(
        () => planDilution(
          factor: 10,
          finalVolumeUl: 1000,
          pipettes: [p100],
          now: now,
          maxSteps: 5,
        ),
        'maxSteps',
      );
      expectFieldError(
        () => planDilution(
          factor: 10,
          finalVolumeUl: 1000,
          pipettes: [p100],
          now: now,
          deadVolumeUl: -1,
        ),
        'deadVolume',
      );
      expectFieldError(
        () => planDilution(
          factor: 10,
          finalVolumeUl: 1000,
          pipettes: const [],
          now: now,
        ),
        'pipettes',
      );
    });
  });

  test('performance : 4 étapes autorisées, F = 10⁶, reste rapide', () {
    final sw = Stopwatch()..start();
    final r = planDilution(
      factor: 1e6,
      finalVolumeUl: 1000,
      pipettes: [p10, p100, p1000],
      now: now,
      maxSteps: 4,
    );
    sw.stop();
    expect(sw.elapsedMilliseconds, lessThan(8000));
    for (final p in r.plans) {
      verifyPlan(p, 1e6, 1000);
    }
  });

  test('le planificateur est enregistré parmi les outils Lab', () {
    expect(EquationRegistry.resolve('lab_dilution_planner'), isNotNull);
  });
}
