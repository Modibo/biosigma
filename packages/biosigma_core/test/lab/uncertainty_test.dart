// T-INC-001 et suivants : valeurs de référence calculées en Python (hors du code
// testé) à partir des formules du GUM (JCGM 100:2008, éq. 10 et 12).
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

double v(CalculationResult r, String start) =>
    r.values.firstWhere((x) => x.label.startsWith(start)).value!;

void main() {
  test('modèle linéaire : y = x1 + x2 − x3 ; u_c = √(0,1² + 0,2² + 0,05²)', () {
    final r = calculateUncertainty(
      model: UncertaintyModel.linear,
      coverageFactor: 2,
      inputs: const [
        UncertaintyInput(name: 'x1', value: 10, standardUncertainty: 0.1),
        UncertaintyInput(name: 'x2', value: 5, standardUncertainty: 0.2),
        UncertaintyInput(name: 'x3', value: 3, standardUncertainty: 0.05, weight: -1),
      ],
    );
    expect(v(r, 'Résultat'), 12);
    expect(v(r, 'Incertitude-type composée'), closeTo(0.22912878474779202, 1e-12));
    expect(v(r, 'Incertitude élargie'), closeTo(2 * 0.22912878474779202, 1e-12));
  });

  test('T-INC-001 : dilution C2 = C1·V1/V2 (C1 100 ± 1, V1 10 ± 0,05, V2 100 ± 0,1)', () {
    final r = calculateDilutionUncertainty(
      c1: 100, uC1: 1, v1: 10, uV1: 0.05, v2: 100, uV2: 0.1, coverageFactor: 2,
    );
    expect(v(r, 'Résultat'), closeTo(10.0, 1e-12));
    expect(v(r, 'Incertitude-type composée'), closeTo(0.11224972160321825, 1e-12));
    expect(v(r, 'Incertitude-type relative'), closeTo(1.1224972160321825, 1e-10));
    expect(v(r, 'Incertitude élargie'), closeTo(0.2244994432064365, 1e-12));
    expect(v(r, 'Part de la variance : C1'), closeTo(79.36507936507937, 1e-9));
    expect(v(r, 'Part de la variance : V1'), closeTo(19.841269841269842, 1e-9));
    expect(v(r, 'Part de la variance : V2'), closeTo(0.7936507936507936, 1e-9));
  });

  test('modèle produit avec exposants non unitaires et constante : 3·x²·z^−0,5', () {
    final r = calculateUncertainty(
      model: UncertaintyModel.product,
      coverageFactor: 2,
      constant: 3,
      inputs: const [
        UncertaintyInput(name: 'x', value: 4, standardUncertainty: 0.2, weight: 2),
        UncertaintyInput(name: 'z', value: 9, standardUncertainty: 0.3, weight: -0.5),
      ],
    );
    expect(v(r, 'Résultat'), closeTo(16.0, 1e-12));
    expect(v(r, 'Incertitude-type composée'), closeTo(1.6220700080795254, 1e-12));
  });

  test('les parts de variance totalisent 100 %', () {
    final r = calculateDilutionUncertainty(
      c1: 50, uC1: 0.7, v1: 2, uV1: 0.02, v2: 25, uV2: 0.2, coverageFactor: 2,
    );
    final total = r.values
        .where((x) => x.label.startsWith('Part de la variance'))
        .fold<double>(0, (a, b) => a + b.value!);
    expect(total, closeTo(100, 1e-9));
  });

  test('contre-vérification : la propagation numérique générale égale les modèles analytiques', () {
    final num = propagateNumeric((x) => x[0] * x[1] / x[2], [100, 10, 100], [1, 0.05, 0.1]);
    expect(num.y, closeTo(10, 1e-12));
    expect(num.combined, closeTo(0.11224972160321825, 1e-7));
    final lin = propagateNumeric((x) => x[0] + x[1] - x[2], [10, 5, 3], [0.1, 0.2, 0.05]);
    expect(lin.combined, closeTo(0.22912878474779202, 1e-7));
  });

  test('type A : s/√n ; type B rectangulaire : a/√3 ; U/k', () {
    expect(standardUncertaintyOfMean([10.1, 10.2, 9.9, 10.0]), closeTo(0.06454972243679005, 1e-12));
    expect(standardUncertaintyRectangular(0.5), closeTo(0.2886751345948129, 1e-12));
    expect(standardUncertaintyFromExpanded(0.6, 2), closeTo(0.3, 1e-12));
  });

  test('toutes incertitudes nulles : u_c = 0, aucune part de variance', () {
    final r = calculateUncertainty(
      model: UncertaintyModel.linear, coverageFactor: 2,
      inputs: const [UncertaintyInput(name: 'a', value: 1, standardUncertainty: 0)],
    );
    expect(v(r, 'Incertitude-type composée'), 0);
    expect(r.values.any((x) => x.label.startsWith('Part de la variance')), isFalse);
  });

  group('refus et avertissements', () {
    test('k ≤ 0, incertitude négative, valeur nulle en modèle produit, liste vide', () {
      expect(() => calculateUncertainty(model: UncertaintyModel.linear, coverageFactor: 0,
          inputs: const [UncertaintyInput(name: 'a', value: 1, standardUncertainty: 0.1)]),
          throwsA(isA<CalculationInputException>()));
      expect(() => calculateUncertainty(model: UncertaintyModel.linear, coverageFactor: 2,
          inputs: const [UncertaintyInput(name: 'a', value: 1, standardUncertainty: -0.1)]),
          throwsA(isA<CalculationInputException>()));
      expect(() => calculateUncertainty(model: UncertaintyModel.product, coverageFactor: 2,
          inputs: const [UncertaintyInput(name: 'a', value: 0, standardUncertainty: 0.1)]),
          throwsA(isA<CalculationInputException>()));
      expect(() => calculateUncertainty(model: UncertaintyModel.linear, coverageFactor: 2, inputs: const []),
          throwsA(isA<CalculationInputException>()));
      expect(() => standardUncertaintyOfMean([1]), throwsA(isA<CalculationInputException>()));
      expect(() => standardUncertaintyRectangular(0), throwsA(isA<CalculationInputException>()));
    });

    test('k hors de 2–3 : avertissement ; k = 2 et 3 : aucun', () {
      bool warns(double k) => calculateDilutionUncertainty(
            c1: 1, uC1: 0.01, v1: 1, uV1: 0.01, v2: 1, uV2: 0.01, coverageFactor: k,
          ).warnings.any((w) => w.message.contains('hors de l\'intervalle usuel'));
      expect(warns(1), isTrue);
      expect(warns(3.5), isTrue);
      expect(warns(2), isFalse);
      expect(warns(3), isFalse);
    });

    test('l\'hypothèse (premier ordre, non corrélées) est toujours rappelée', () {
      final r = calculateDilutionUncertainty(
        c1: 1, uC1: 0.01, v1: 1, uV1: 0.01, v2: 1, uV2: 0.01, coverageFactor: 2,
      );
      expect(r.warnings.first.message, contains('non corrélées'));
    });
  });
}
