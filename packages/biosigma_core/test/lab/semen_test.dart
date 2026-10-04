// P2-06 : spermatozoïdes selon le manuel OMS 6e éd. Les tableaux 2.1, 2.3, 2.4 et 8.3
// sont recopiés du texte du PDF dans ce test (indépendamment du code testé) et
// recoupés par des relations statistiques (Poisson) et géométriques (100 nL / grille).
import 'dart:math' as math;

import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void close(double? a, double b, [String? why]) => expect(a, closeTo(b, b.abs() * 1e-12 + 1e-12), reason: why);

CalculationResult _calc(
  List<(int, int)> pairs, {
  SpermDilution d = SpermDilution.d20,
  SpermArea a = SpermArea.grids1,
  double? vol,
}) =>
    calculateSpermConcentration(replicatePairs: pairs, dilution: d, area: a, ejaculateVolumeMl: vol);

double? _v(CalculationResult r, String start) {
  final m = r.values.where((x) => x.label.startsWith(start));
  return m.isEmpty ? null : m.first.value;
}

void main() {
  group('tableau 2.4 de l\'OMS (facteurs de correction), recopié du PDF', () {
    // Colonnes : 5, 10, 25 grands carrés ; puis 2 à 9 grilles.
    const printed = <SpermDilution, List<double>>{
      SpermDilution.d2: [20, 40, 100, 200, 300, 400, 500, 600, 700, 800, 900],
      SpermDilution.d5: [8, 16, 40, 80, 120, 160, 200, 240, 280, 320, 360],
      SpermDilution.d10: [4, 8, 20, 40, 60, 80, 100, 120, 140, 160, 180],
      SpermDilution.d20: [2, 4, 10, 20, 30, 40, 50, 60, 70, 80, 90],
      SpermDilution.d50: [0.8, 1.6, 4, 8, 12, 16, 20, 24, 28, 32, 36],
    };
    const areas = [
      SpermArea.squares5, SpermArea.squares10, SpermArea.grids1, SpermArea.grids2, SpermArea.grids3,
      SpermArea.grids4, SpermArea.grids5, SpermArea.grids6, SpermArea.grids7, SpermArea.grids8, SpermArea.grids9,
    ];
    test('les 55 facteurs calculés (2 chambres × 100 nL par grille ÷ dilution) égalent ceux du tableau', () {
      var n = 0;
      for (final e in printed.entries) {
        for (var i = 0; i < areas.length; i++) {
          close(spermCorrectionFactor(e.key, areas[i]), e.value[i], '${e.key.label} / ${areas[i].label}');
          n++;
        }
      }
      expect(n, 55);
    });
  });

  test('tableau 2.1 : facteur de dilution = (sperme + fixateur) / sperme, volumes imprimés', () {
    const printed = {
      SpermDilution.d50: (50, 2450), SpermDilution.d20: (50, 950), SpermDilution.d10: (50, 450),
      SpermDilution.d5: (50, 200), SpermDilution.d2: (100, 100),
    };
    for (final e in printed.entries) {
      expect((e.key.semenMicrolitres, e.key.fixativeMicrolitres), e.value, reason: e.key.label);
      expect((e.value.$1 + e.value.$2) / e.value.$1, e.key.factor.toDouble(), reason: e.key.label);
    }
  });

  group('tableau 2.3 : transcription vérifiée', () {
    test('61 lignes contiguës de 1 à 1000 (la coquille « 22–36 » corrigée en « 22–26 »)', () {
      final rows = [...replicateLimitTable]..sort((a, b) => a.sumFrom.compareTo(b.sumFrom));
      expect(rows.length, 61);
      expect(rows.first.sumFrom, 1);
      expect(rows.last.sumTo, 1000);
      for (var i = 1; i < rows.length; i++) {
        expect(rows[i].sumFrom, rows[i - 1].sumTo + 1, reason: '${rows[i - 1].sumTo}→${rows[i].sumFrom}');
      }
    });

    test('chaque ligne suit la loi de Poisson : limite = ⌊1,96·√S_min⌋ et erreur = 100/√S_min (0,1 près)', () {
      for (final r in replicateLimitTable) {
        expect(r.maxDifference, (1.96 * math.sqrt(r.sumFrom) + 1e-9).floor(), reason: '${r.sumFrom}–${r.sumTo}');
        expect(r.errorPercent, closeTo((100 / math.sqrt(r.sumFrom) * 10).round() / 10, 1e-9), reason: '${r.sumFrom}');
      }
    });

    test('lignes repères imprimées', () {
      expect(replicateLimitFor(1000)!.maxDifference, 61);
      expect(replicateLimitFor(969)!.errorPercent, 3.2);
      expect(replicateLimitFor(408)!.maxDifference, 39);
      expect(replicateLimitFor(408)!.errorPercent, 5.0);
      expect(replicateLimitFor(180)!.maxDifference, 26);
      expect(replicateLimitFor(24)!.maxDifference, 9);
      expect(replicateLimitFor(24)!.errorPercent, 21.3);
      expect(replicateLimitFor(1)!.errorPercent, 100.0);
      expect(replicateLimitFor(0), isNull);
      expect(replicateLimitFor(1001), isNull);
    });
  });

  group('calcul (valeurs calculées à la main)', () {
    test('1 : 20, 1 grille : 210 et 198 → somme 408, accepté (écart 12 ≤ 39), 40,8 ×10⁶/mL (affiché 41), erreur 5,0 %', () {
      final r = _calc([(210, 198)], vol: 3.0);
      close(_v(r, 'Concentration en spermatozoïdes'), 40.8);
      close(_v(r, 'Concentration en spermatozoïdes (par mL)'), 41e6, '2 chiffres significatifs');
      expect(r.values.first.precision, 0, reason: '40,8 → 41 (2 chiffres significatifs)');
      close(_v(r, 'Erreur'), 5.0);
      close(_v(r, 'Nombre total'), 122.4);
      expect(r.values.last.precision, 0, reason: 'entier de millions (OMS § 2.4.8.7)');
      expect(r.isComplete, isTrue);
    });

    test('deux chiffres significatifs : décimales de l\'affichage selon l\'ordre de grandeur', () {
      int prec(List<(int, int)> p, SpermDilution d, SpermArea a) =>
          _calc(p, d: d, a: a).values.first.precision;
      expect(prec([(210, 198)], SpermDilution.d20, SpermArea.grids1), 0); // 40,8
      expect(prec([(60, 58)], SpermDilution.d2, SpermArea.grids9), 2); // 0,131 → 0,13
      expect(prec([(900, 905)], SpermDilution.d50, SpermArea.squares5), 0); // 1805/0,8 = 2256 (> 100)
      expect(prec([(24, 20)], SpermDilution.d2, SpermArea.grids9), 3); // 44/900 = 0,0489 → 0,049
      final r = _calc([(210, 198)]);
      close(r.values.first.value, 40.8, 'la valeur n\'est jamais arrondie');
    });

    test('nombre total < 10 millions : une décimale', () {
      final r = _calc([(60, 58)], d: SpermDilution.d2, a: SpermArea.grids9, vol: 2.0);
      // somme 118, F = 900 → 0,13111 ×10⁶/mL ; total 0,2622 → une décimale
      close(_v(r, 'Concentration en spermatozoïdes'), 118 / 900);
      expect(r.values.last.precision, 1);
    });

    test('1 : 2 et 9 grilles, comptages 25 et 25 : moins de 25 par chambre ? non (25) ; 24 et 20 : oui, borne 50/F', () {
      final ok = _calc([(25, 25)], d: SpermDilution.d2, a: SpermArea.grids9);
      expect(ok.warnings.any((w) => w.message.contains('Moins de 25')), isFalse);
      final low = _calc([(24, 20)], d: SpermDilution.d2, a: SpermArea.grids9);
      final w = low.warnings.firstWhere((w) => w.message.contains('Moins de 25'));
      expect(w.severity, WarningSeverity.caution);
      expect(w.message, contains('0,056'), reason: '50/900 = 0,0556 ×10⁶/mL (OMS : < 55 555/mL)');
      expect(w.message, contains('14 %'));
    });

    test('moins de 200 par chambre : information (étendre le comptage)', () {
      final r = _calc([(150, 140)]);
      expect(r.warnings.any((w) => w.message.contains('au moins 200')), isTrue);
      expect(_calc([(210, 205)]).warnings.any((w) => w.message.contains('au moins 200')), isFalse);
    });

    test('écart trop grand (120 et 60 : somme 180, limite 26) : pas de concentration, nouveau comptage demandé', () {
      final r = _calc([(120, 60)]);
      expect(r.isComplete, isFalse);
      expect(_v(r, 'Concentration en spermatozoïdes'), isNull);
      expect(r.warnings.any((w) => w.message.contains('nouvelle chambre')), isTrue);
      expect(r.echoedInputs['Couple 1'], contains('écart trop grand'));
    });

    test('deuxième couple accepté : c\'est lui qui donne la concentration', () {
      final r = _calc([(120, 60), (100, 95)]);
      close(_v(r, 'Concentration en spermatozoïdes'), 195 / 10);
      expect(r.echoedInputs['Couple 1'], contains('trop grand'));
      expect(r.echoedInputs['Couple 2'], contains('accepté'));
    });

    test('trois couples trop éloignés : moyenne des trois sommes et mise en garde', () {
      final r = _calc([(120, 60), (130, 70), (110, 40)]);
      // sommes 180, 200, 150 → moyenne 176,667 ; F = 10
      close(_v(r, 'Concentration en spermatozoïdes'), (180 + 200 + 150) / 3 / 10);
      expect(r.warnings.any((w) => w.message.contains('moyenne des trois sommes')), isTrue);
      expect(r.echoedInputs.containsKey('Moyenne des trois sommes'), isTrue);
    });

    test('aucun spermatozoïde : pas de concentration, azoospermie non affirmée', () {
      final r = _calc([(0, 0)], d: SpermDilution.d2, a: SpermArea.grids9);
      expect(r.isComplete, isFalse);
      expect(r.warnings.single.message, contains('culot de centrifugation'));
    });

    test('somme > 1000 : calcul avec mise en garde (le tableau s\'arrête à 1000)', () {
      final r = _calc([(520, 500)]);
      close(_v(r, 'Concentration en spermatozoïdes'), 1020 / 10);
      expect(r.warnings.any((w) => w.message.contains('1000')), isTrue);
    });

    test('3 chambres sans couple valable, ordre : le premier couple acceptable est retenu même s\'il y en a un autre', () {
      final r = _calc([(100, 98), (300, 10)]);
      close(_v(r, 'Concentration en spermatozoïdes'), 198 / 10);
      expect(r.echoedInputs.containsKey('Couple 2'), isFalse);
    });
  });

  group('repères de la population de référence (tableau 8.3)', () {
    test('5es centiles imprimés', () {
      const p5 = {
        'Volume': 1.4, 'Concentration': 16, 'Nombre total': 39, 'Mobilité totale': 42, 'Mobilité progressive': 30,
        'Mobilité non progressive': 1, 'Spermatozoïdes immobiles': 20, 'Vitalité': 54, 'Formes normales': 4,
      };
      for (final e in p5.entries) {
        final r = semenReferences.firstWhere((x) => x.parameter.startsWith(e.key));
        expect(r.p5, e.value, reason: e.key);
      }
      expect(semenReferences.length, 9);
    });

    test('les 9 centiles sont croissants (cohérence de la transcription) ; effectifs imprimés', () {
      for (final r in semenReferences) {
        expect(r.centiles.length, 9, reason: r.parameter);
        for (var i = 1; i < 9; i++) {
          expect(r.centiles[i], greaterThanOrEqualTo(r.centiles[i - 1]), reason: '${r.parameter} $i');
        }
      }
      expect(semenReferences.map((r) => r.n), [3586, 3587, 3584, 3488, 3389, 3387, 2800, 1337, 3335]);
      expect(semenReferences[1].centiles, [11, 16, 22, 36, 66, 110, 166, 208, 254]);
    });

    test('le résultat se situe par rapport au 5e centile, avec la mise en garde de l\'OMS', () {
      final low = _calc([(80, 75)], d: SpermDilution.d10, a: SpermArea.grids1, vol: 2.0); // 155/20 = 7,75
      final msg = low.warnings.firstWhere((w) => w.message.startsWith('Concentration')).message;
      expect(msg, contains('inférieure au 5e centile'));
      expect(msg, contains('16'));
      expect(msg, contains('pas une limite entre hommes fertiles et infertiles'));
      final high = _calc([(210, 198)], vol: 3.0); // 40,8 ; total 122,4
      expect(high.warnings.firstWhere((w) => w.message.startsWith('Concentration')).message,
          contains('supérieure ou égale'));
      expect(high.warnings.firstWhere((w) => w.message.startsWith('Nombre total')).message,
          contains('supérieur ou égal'));
    });
  });

  group('entrées refusées', () {
    test('aucun couple, plus de trois, comptage négatif, volume nul', () {
      expect(() => _calc([]), throwsA(isA<CalculationInputException>()));
      expect(() => _calc([(1, 1), (1, 1), (1, 1), (1, 1)]), throwsA(isA<CalculationInputException>()));
      expect(() => _calc([(-1, 5)]), throwsA(isA<CalculationInputException>()));
      expect(() => _calc([(100, 100)], vol: 0), throwsA(isA<CalculationInputException>()));
    });
  });

  test('chaque dilution porte l\'orientation du tableau 2.1 (observation à l\'état frais)', () {
    for (final d in SpermDilution.values) {
      expect(d.guidance, isNotEmpty);
    }
    expect(SpermDilution.d2.guidance, contains('< 2'));
  });
}
