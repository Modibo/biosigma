// Chambres de numération (Malassez, Neubauer améliorée) : géométrie recoupée et calculs à la main.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

CountingChamber _c(String id) => countingChamberById(id)!;

double? _v(CalculationResult r, String label, String unit) =>
    r.values.firstWhere((v) => v.label == label && v.unit.startsWith(unit)).value;

void main() {
  test('deux chambres proposées, avec leur source', () {
    expect(countingChambers.map((c) => c.id), ['neubauer_improved', 'malassez']);
    for (final c in countingChambers) {
      expect(c.source, isNotEmpty);
      expect(c.units, isNotEmpty);
    }
    expect(countingChamberById('inconnue'), isNull);
  });

  group('géométrie recoupée', () {
    test('Malassez : 100 rectangles de 0,20 × 0,25 mm × 0,2 mm de profondeur = 1 µL (0,01 µL par rectangle)', () {
      final m = _c('malassez');
      expect(m.depthMm, 0.2);
      final rect = m.units.first, grid = m.units.last;
      expect(rect.areaMm2, closeTo(0.20 * 0.25, 1e-15));
      expect(rect.maxPerChamber * rect.areaMm2, closeTo(5.0, 1e-12), reason: '2,5 mm × 2 mm');
      expect(rect.maxPerChamber * rect.areaMm2 * m.depthMm, closeTo(1.0, 1e-12), reason: '1 mm³ = 1 µL');
      expect(rect.areaMm2 * m.depthMm, closeTo(0.01, 1e-15), reason: '0,01 µL par rectangle');
      expect(grid.areaMm2 * grid.maxPerChamber, closeTo(5.0, 1e-12));
    });

    test('Neubauer améliorée (OMS) : une grille = 1 mm² × 0,1 mm = 100 nL ; 25 grands carrés par grille ; 9 grilles', () {
      final n = _c('neubauer_improved');
      expect(n.depthMm, 0.1);
      final grid = n.units.first, square = n.units.last;
      expect(grid.areaMm2 * n.depthMm, closeTo(0.1, 1e-15), reason: '0,1 µL = 100 nL');
      expect(grid.maxPerChamber, 9);
      expect(square.areaMm2 * square.maxPerChamber, closeTo(1.0, 1e-12), reason: '25 grands carrés = 1 grille');
    });
  });

  group('calculs (à la main)', () {
    test('Malassez : 120 cellules dans 10 rectangles (0,1 µL), sans dilution → 1200 /µL = 1,2 × 10⁶/mL', () {
      final r = calculateChamberCount(
        chamber: _c('malassez'), unit: _c('malassez').units.first, unitsCounted: 10, counted: 120, dilutionFactor: 1,
      );
      expect(_v(r, 'Concentration', 'cellules/µL'), closeTo(1200, 1e-9));
      // Wikipédia : 10 rectangles = 0,1 µL → multiplier par 10 000 pour obtenir par mL.
      expect(_v(r, 'Concentration', 'cellules/µL')! * 1000, closeTo(120 * 10000, 1e-6));
      expect(r.echoedInputs['Chambre'], 'Malassez');
      expect(r.echoedInputs['Volume compté'], contains('0.1'));
    });

    test('Malassez : quadrillage entier (1 µL), 250 cellules, dilution 20 → 5000 /µL', () {
      final m = _c('malassez');
      final r = calculateChamberCount(
        chamber: m, unit: m.units.last, unitsCounted: 1, counted: 250, dilutionFactor: 20,
      );
      expect(_v(r, 'Concentration', 'cellules/µL'), closeTo(5000, 1e-9));
    });

    test('Neubauer améliorée : 200 cellules sur 1 grille (0,1 µL), dilution 20 → 40 000 /µL', () {
      final n = _c('neubauer_improved');
      final r = calculateChamberCount(
        chamber: n, unit: n.units.first, unitsCounted: 1, counted: 200, dilutionFactor: 20,
      );
      expect(_v(r, 'Concentration', 'cellules/µL'), closeTo(40000, 1e-9));
    });

    test('Neubauer : 5 grands carrés (0,2 mm²) soit 20 nL ; 50 cellules → 2500 /µL', () {
      final n = _c('neubauer_improved');
      final r = calculateChamberCount(
        chamber: n, unit: n.units.last, unitsCounted: 5, counted: 50, dilutionFactor: 1,
      );
      expect(_v(r, 'Concentration', 'cellules/µL'), closeTo(2500, 1e-9));
    });

    test('même résultat que le mode « Personnalisée » pour la même surface et la même profondeur', () {
      final m = _c('malassez');
      final a = calculateChamberCount(
        chamber: m, unit: m.units.first, unitsCounted: 30, counted: 345, dilutionFactor: 2,
      );
      final b = calculateCellCount(counted: 345, countedAreaMm2: 1.5, depthMm: 0.2, dilutionFactor: 2);
      expect(a.values.first.value, b.values.first.value);
    });

    test('la source de la géométrie est rappelée dans le résultat', () {
      final r = calculateChamberCount(
        chamber: _c('malassez'), unit: _c('malassez').units.first, unitsCounted: 10, counted: 5, dilutionFactor: 1,
      );
      expect(r.warnings.any((w) => w.message.contains('Wikipédia') && w.message.contains('fiche de votre chambre')), isTrue);
    });
  });

  group('refus', () {
    test('plus d\'unités que la chambre n\'en contient ; zéro unité ; non saisi', () {
      final m = _c('malassez');
      expect(
        () => calculateChamberCount(chamber: m, unit: m.units.first, unitsCounted: 101, counted: 5, dilutionFactor: 1),
        throwsA(isA<CalculationInputException>().having((e) => e.errors.first.message, 'message', contains('au plus 100'))),
      );
      expect(
        () => calculateChamberCount(chamber: m, unit: m.units.first, unitsCounted: 0, counted: 5, dilutionFactor: 1),
        throwsA(isA<CalculationInputException>()),
      );
      expect(
        () => calculateChamberCount(chamber: m, unit: m.units.first, unitsCounted: null, counted: 5, dilutionFactor: 1),
        throwsA(isA<CalculationInputException>()),
      );
      final n = _c('neubauer_improved');
      expect(
        () => calculateChamberCount(chamber: n, unit: n.units.first, unitsCounted: 10, counted: 5, dilutionFactor: 1),
        throwsA(isA<CalculationInputException>()),
        reason: 'une chambre de Neubauer n\'a que 9 grilles',
      );
    });
  });
}
