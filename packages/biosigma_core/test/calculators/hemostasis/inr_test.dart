import 'dart:io';

import 'package:biosigma_core/src/calculators/hemostasis/inr.dart';
import 'package:biosigma_core/src/models/errors.dart';
import 'package:biosigma_core/src/models/result.dart';
import 'package:test/test.dart';

void main() {
  group('calculateInr', () {
    test('PT patient=28 s, PT moyen normal=12 s, ISI=1.0', () {
      final result = calculateInr(
        patientPtSeconds: 28,
        meanNormalPtSeconds: 12,
        isi: 1.0,
      );
      expect(result.values.single.value, closeTo(2.3333333333333335, 1e-9));
      expect(
        result.warnings.any(
          (w) =>
              w.severity == WarningSeverity.info &&
              w.message.contains("dépend entièrement de l'indication"),
        ),
        isTrue,
      );
    });

    test('PT patient=28 s, PT moyen normal=12 s, ISI=1.2', () {
      final result = calculateInr(
        patientPtSeconds: 28,
        meanNormalPtSeconds: 12,
        isi: 1.2,
      );
      expect(result.values.single.value, closeTo(2.7642170559319026, 1e-9));
    });
  });

  // P3-02 : l'ISI est une entrée explicite, jamais une valeur par défaut.
  group('INR : ISI explicite (P3-02)', () {
    test(
      'l\'ISI change le résultat : 1,0 / 1,2 / 1,5 donnent trois INR distincts',
      () {
        double inr(double isi) => calculateInr(
          patientPtSeconds: 28,
          meanNormalPtSeconds: 12,
          isi: isi,
        ).values.single.value!;
        expect({inr(1.0), inr(1.2), inr(1.5)}.length, 3);
        expect(inr(1.5), greaterThan(inr(1.2)));
        expect(inr(1.2), greaterThan(inr(1.0)));
      },
    );

    test(
      'TP patient = TP moyen normal donne un INR de 1 quel que soit l\'ISI',
      () {
        for (final isi in [0.9, 1.0, 1.3, 2.0]) {
          final r = calculateInr(
            patientPtSeconds: 12,
            meanNormalPtSeconds: 12,
            isi: isi,
          );
          expect(
            r.values.single.value,
            closeTo(1.0, 1e-12),
            reason: 'ISI $isi',
          );
        }
      },
    );

    test('un ISI nul, négatif ou absent est refusé (champ « isi »)', () {
      for (final isi in [0.0, -1.0]) {
        expect(
          () => calculateInr(
            patientPtSeconds: 28,
            meanNormalPtSeconds: 12,
            isi: isi,
          ),
          throwsA(
            isA<CalculationInputException>().having(
              (e) => e.errors.map((x) => x.fieldId),
              'champs',
              contains('isi'),
            ),
          ),
          reason: 'ISI $isi',
        );
      }
      expect(
        () => calculateInr(
          patientPtSeconds: 28,
          meanNormalPtSeconds: double.nan,
          isi: 1.2,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('l\'ISI saisi est rappelé dans les entrées du résultat', () {
      final r = calculateInr(
        patientPtSeconds: 28,
        meanNormalPtSeconds: 12,
        isi: 1.23,
      );
      expect(r.echoedInputs['ISI'], '1.23');
    });

    test('la signature n\'a pas de valeur par défaut pour l\'ISI (paramètre requis)', () {
      // Garde de conception : si `isi` devenait optionnel, cette lecture du
      // code source le signalerait.
      final src = File('lib/src/calculators/hemostasis/inr.dart')
          .readAsStringSync();
      expect(src, contains('required double isi,'));
      expect(src, isNot(contains('double isi =')));
    });
  });

  group('calculateAptRatio', () {
    test('Patient=45 s, Témoin=30 s', () {
      final result = calculateAptRatio(
        patientAptSeconds: 45,
        controlAptSeconds: 30,
      );
      expect(result.values.single.value, closeTo(1.5, 1e-9));
      expect(
        result.warnings.any(
          (w) =>
              w.severity == WarningSeverity.info &&
              w.message.contains('pas de seuil universel'),
        ),
        isTrue,
      );
    });
  });

  group('calculateSerialTrend', () {
    test('previous=2.0, current=3.5, unit=INR', () {
      final result = calculateSerialTrend(
        analyteLabel: 'INR',
        previousValue: 2.0,
        currentValue: 3.5,
        unit: 'INR',
      );
      final absolute = result.values.firstWhere(
        (v) => v.label == 'Variation absolue',
      );
      final relative = result.values.firstWhere(
        (v) => v.label == 'Variation relative',
      );
      expect(absolute.value, closeTo(1.5, 1e-9));
      expect(relative.value, closeTo(75.0, 1e-9));
      expect(
        result.warnings.any(
          (w) =>
              w.severity == WarningSeverity.info &&
              w.message.contains('en hausse') &&
              w.message.contains('purement descriptive'),
        ),
        isTrue,
      );
    });

    test('cas limite : previous=0, current=1.0', () {
      final result = calculateSerialTrend(
        analyteLabel: 'Fibrinogène',
        previousValue: 0,
        currentValue: 1.0,
        unit: 'g/L',
      );
      final absolute = result.values.firstWhere(
        (v) => v.label == 'Variation absolue',
      );
      final relative = result.values.firstWhere(
        (v) => v.label == 'Variation relative',
      );
      expect(absolute.value, closeTo(1.0, 1e-9));
      expect(relative.value, isNull);
      expect(
        result.warnings.any(
          (w) =>
              w.severity == WarningSeverity.caution &&
              w.message.contains('non calculable'),
        ),
        isTrue,
      );
    });
  });
}
