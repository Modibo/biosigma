// Chambres de numération (Malassez, Neubauer améliorée) : géométrie recoupée et calculs à la main.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

CountingChamber _c(String id) => countingChamberById(id)!;

double? _v(CalculationResult r, String label, String unit) =>
    r.values.firstWhere((v) => v.label == label && v.unit.startsWith(unit)).value;

void main() {
  test('quatorze chambres proposées, chacune avec sa source, ses unités et un nom unique', () {
    expect(countingChambers.map((c) => c.id), [
      'neubauer_improved', 'neubauer', 'burker', 'burker_turk', 'thoma', 'thoma_new', 'fuchs_rosenthal', 'nageotte',
      'malassez', 'makler', 'petroff_hausser', 'neubauer_improved_depth_001', 'neubauer_improved_depth_002',
      'thoma_helber',
    ]);
    expect({for (final c in countingChambers) c.name}.length, 14);
    for (final c in countingChambers) {
      expect(c.source, isNotEmpty, reason: c.id);
      expect(c.units, isNotEmpty, reason: c.id);
      expect(c.depthMm, greaterThan(0));
      for (final u in c.units) {
        expect(u.areaMm2, greaterThan(0), reason: '${c.id} ${u.label}');
        expect(u.maxPerChamber, greaterThan(0));
      }
    }
    expect(countingChamberById('inconnue'), isNull);
  });

  group('géométrie recoupée avec les tableaux des fabricants (surface mm² et volume µL par unité)', () {
    // Valeurs imprimées dans la fiche technique de Paul Marienfeld (colonnes « sqmm » et « cmm = µl »).
    const printed = <String, List<(String, double, double)>>{
      'neubauer_improved': [('grille', 1, 0.1), ('grand carré', 0.04, 0.004), ('petit carré', 0.0025, 0.00025)],
      'neubauer': [('grand carré', 1, 0.1), ('carré de groupe', 0.04, 0.004), ('petit carré', 0.0025, 0.00025)],
      'burker': [('grand carré', 1, 0.1), ('petit carré', 0.04, 0.004)],
      'burker_turk': [('grand carré', 1, 0.1), ('petit carré (0,2', 0.04, 0.004), ('plus petit', 0.0025, 0.00025)],
      'fuchs_rosenthal': [('grand carré', 1, 0.2), ('petit carré', 0.0625, 0.0125)],
    };
    test('surface et volume de chaque unité = valeurs imprimées par le fabricant', () {
      for (final e in printed.entries) {
        final c = countingChamberById(e.key)!;
        for (final (start, area, ul) in e.value) {
          final u = c.units.firstWhere((u) => u.label.startsWith(start), orElse: () => fail('${e.key} : $start'));
          expect(u.areaMm2, closeTo(area, 1e-12), reason: '${e.key} $start');
          expect(u.areaMm2 * c.depthMm, closeTo(ul, 1e-12), reason: '${e.key} $start (µL)');
        }
      }
    });

    test('totaux imprimés : famille Neubauer/Bürker 9 mm² = 0,9 µL ; Fuchs-Rosenthal 16 mm² = 3,2 µL', () {
      for (final id in ['neubauer_improved', 'neubauer', 'burker', 'burker_turk']) {
        final c = countingChamberById(id)!;
        expect(c.units.first.areaMm2 * c.units.first.maxPerChamber, closeTo(9, 1e-12), reason: id);
        expect(c.units.first.areaMm2 * c.units.first.maxPerChamber * c.depthMm, closeTo(0.9, 1e-12), reason: id);
      }
      final f = countingChamberById('fuchs_rosenthal')!;
      expect(f.units.first.areaMm2 * f.units.first.maxPerChamber, closeTo(16, 1e-12));
      expect(f.units.first.areaMm2 * f.units.first.maxPerChamber * f.depthMm, closeTo(3.2, 1e-12));
    });

    test('Nageotte : 40 bandes de 0,25 × 10 mm = 100 mm² ; 1,25 µL par bande, 50 µL au total', () {
      final n = countingChamberById('nageotte')!;
      expect(n.depthMm, 0.5);
      expect(n.units.single.areaMm2, closeTo(2.5, 1e-12));
      expect(n.units.single.maxPerChamber, 40);
      expect(n.units.single.areaMm2 * 40, closeTo(100, 1e-12));
      expect(n.units.single.areaMm2 * n.depthMm, closeTo(1.25, 1e-12));
      expect(n.units.single.areaMm2 * 40 * n.depthMm, closeTo(50, 1e-12));
    });

    test('Malassez : 100 rectangles de 0,20 × 0,25 mm × 0,2 mm = 1 µL (0,01 µL par rectangle) ; 20 petits carrés par rectangle', () {
      final m = countingChamberById('malassez')!;
      expect(m.depthMm, 0.2);
      final rect = m.units.first, grid = m.units[1], small = m.units[2];
      expect(rect.areaMm2, closeTo(0.20 * 0.25, 1e-15));
      expect(rect.maxPerChamber * rect.areaMm2 * m.depthMm, closeTo(1.0, 1e-12));
      expect(rect.areaMm2 * m.depthMm, closeTo(0.01, 1e-15));
      expect(grid.areaMm2 * m.depthMm, closeTo(1.0, 1e-12));
      expect(small.maxPerChamber, 100 * 20);
      expect(small.maxPerChamber * small.areaMm2, closeTo(5.0, 1e-12));
    });

    test('Neubauer améliorée : 25 groupes de 0,04 mm² = 1 grille ; 16 petits carrés par groupe ; 100 nL par grille', () {
      final n = countingChamberById('neubauer_improved')!;
      expect(n.units[1].areaMm2 * n.units[1].maxPerChamber, closeTo(1.0, 1e-12));
      expect(n.units[2].areaMm2 * 16, closeTo(0.04, 1e-12));
      expect(n.units[2].maxPerChamber, 25 * 16);
      expect(n.units.first.areaMm2 * n.depthMm, closeTo(0.1, 1e-15), reason: '0,1 µL = 100 nL');
    });

    test('Thoma : 25 groupes × 16 petits carrés = 400 petits carrés de 0,0025 mm² = 1 mm²', () {
      final t = countingChamberById('thoma')!;
      expect(t.units.last.maxPerChamber, 400);
      expect(t.units.last.maxPerChamber * t.units.last.areaMm2, closeTo(1.0, 1e-12));
    });

    test('Petroff-Hausser : 0,02 mm de profondeur → 0,02 mm³ (0,02 µL) au-dessus de 1 mm²', () {
      final p = countingChamberById('petroff_hausser')!;
      expect(p.depthMm, 0.02);
      expect(p.units.first.areaMm2 * p.depthMm, closeTo(0.02, 1e-15));
      expect(p.units.first.maxPerChamber, 9, reason: 'rulings couvrant 9 mm²');
    });

    test('profondeurs spéciales de Marienfeld : 0,01 et 0,02 mm (Neubauer améliorée), 0,02 mm (Thoma Helber)', () {
      expect(countingChamberById('neubauer_improved_depth_001')!.depthMm, 0.01);
      expect(countingChamberById('neubauer_improved_depth_002')!.depthMm, 0.02);
      expect(countingChamberById('thoma_helber')!.depthMm, 0.02);
    });

    test('Makler : profondeur 10 µm ; 150 spermatozoïdes dans une bande de 10 carrés → 150 × 10⁶/mL, sans dilution', () {
      final m = countingChamberById('makler')!;
      expect(m.depthMm, 0.01);
      final r = calculateChamberCount(
        chamber: m, unit: m.units.first, unitsCounted: 1, counted: 150, dilutionFactor: 1,
      );
      // 150 / (0,1 mm² × 0,01 mm = 0,001 µL) = 150 000 /µL = 150 × 10⁶/mL.
      expect(_v(r, 'Concentration', 'cellules/µL'), closeTo(150000, 1e-6));
      expect(_v(r, 'Concentration', '×10⁹/L'), closeTo(150, 1e-9));
      expect(m.units[1].maxPerChamber * m.units[1].areaMm2, closeTo(1.0, 1e-12), reason: '100 carrés = 1 mm²');
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
        chamber: m, unit: m.units[1], unitsCounted: 1, counted: 250, dilutionFactor: 20,
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
        chamber: n, unit: n.units[1], unitsCounted: 5, counted: 50, dilutionFactor: 1,
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
