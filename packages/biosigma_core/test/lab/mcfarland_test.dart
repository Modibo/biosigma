// P2-08 : équivalence McFarland saisie par le validateur (0,5 ≈ 1,5 × 10⁸ UFC/mL).
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

double? _v(CalculationResult r, String start) {
  final m = r.values.where((x) => x.label.startsWith(start));
  return m.isEmpty ? null : m.first.value;
}

void main() {
  test('0,5 McFarland → 1,5 × 10⁸ UFC/mL (valeur saisie), log10 = 8,176', () {
    final r = calculateMcFarland(standard: 0.5);
    expect(_v(r, 'UFC/mL approximatif'), 1.5e8);
    expect(_v(r, 'log10'), closeTo(8.1760912590556813, 1e-12)); // log10(1,5) + 8
    expect(r.warnings.first.severity, WarningSeverity.caution);
    expect(r.warnings.first.message, contains('pas un dénombrement'));
    expect(r.isComplete, isTrue);
  });

  test('dilution vers une cible : 1,5 × 10⁸ → 5 × 10⁵ UFC/mL = facteur 300', () {
    final r = calculateMcFarland(standard: 0.5, targetCfuPerMl: 5e5);
    expect(_v(r, 'Facteur de dilution'), closeTo(300, 1e-9));
    expect(r.warnings.any((w) => w.message.contains('1 volume de suspension + 299,0 volumes de diluant')), isTrue);
  });

  test('cible égale à la suspension : facteur 1 ; cible supérieure : refus', () {
    expect(_v(calculateMcFarland(standard: 0.5, targetCfuPerMl: 1.5e8), 'Facteur de dilution'), 1.0);
    expect(() => calculateMcFarland(standard: 0.5, targetCfuPerMl: 2e8), throwsA(isA<CalculationInputException>()));
  });

  test('tout autre standard est refusé : aucune équivalence n\'est extrapolée', () {
    for (final s in [0.25, 1.0, 2.0, 3.0, 4.0, 0.0]) {
      expect(
        () => calculateMcFarland(standard: s),
        throwsA(isA<CalculationInputException>().having((e) => e.errors.first.message, 'message', contains('Seul le standard 0,5'))),
        reason: '$s',
      );
    }
    expect(() => calculateMcFarland(standard: null), throwsA(isA<CalculationInputException>()));
    expect(() => calculateMcFarland(standard: 0.5, targetCfuPerMl: 0), throwsA(isA<CalculationInputException>()));
  });

  test('une seule équivalence est embarquée, avec sa mention de provenance', () {
    expect(mcFarlandEnteredCfuPerMl, {0.5: 1.5e8});
    expect(mcFarlandMeta.sources.single.citation, contains('saisie par le validateur'));
  });
}
