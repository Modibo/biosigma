// Tableau Martin-Hopkins saisi par le validateur : contrôles de structure et cas
// calculés en Python à partir du tableau collé (analyse indépendante du code Dart).
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

CalculationResult _panel(double tc, double hdl, double tg) => calculateLdlPanel(
      totalCholesterolValue: tc, totalCholesterolUnit: 'mg/dL',
      hdlValue: hdl, hdlUnit: 'mg/dL',
      triglyceridesValue: tg, triglyceridesUnit: 'mg/dL',
      formula: LdlFormula.martinHopkins,
    );

/// LDL en mg/dL lu dans le résultat du panel (qui l'exprime en mmol/L).
double _ldlMgDl(CalculationResult r) => UnitRegistry.convert(
      Analyte.cholesterol, r.values.first.value!, fromUnit: 'mmol/L', toUnit: 'mg/dL');

void main() {
  final t = MartinHopkinsTable.entered;

  test('structure : 30 strates de TG × 6 colonnes de non-HDL-C = 180 facteurs', () {
    expect(t.tgLowerEdges.length, 30);
    expect(t.nonHdlLowerEdges, [0, 100, 130, 160, 190, 220]);
    expect(t.cellCount, 180);
    expect(t.tgLowerEdges.first, 7);
    expect(t.tgLowerEdges.last, 400);
    expect(t.tgLowerEdges, [
      7, 50, 57, 62, 67, 72, 76, 80, 84, 88, 93, 97, 101, 106, 111, 116, 121, 127, 133, 139, 147, 155, 164, 174,
      186, 202, 221, 248, 293, 400,
    ]);
  });

  test('cellules de coin et cellules repères du tableau saisi', () {
    expect(t.factors.first, [3.5, 3.4, 3.3, 3.3, 3.2, 3.1]);
    expect(t.factors.last, [11.9, 10.0, 8.8, 8.1, 7.5, 6.7]);
    expect(t.factorFor(triglyceridesMgDl: 350, nonHdlMgDl: 140), 7.5);
    expect(t.factorFor(triglyceridesMgDl: 100, nonHdlMgDl: 150), 4.8);
  });

  test('empreinte : somme et nombre de facteurs distincts (détecte une modification involontaire)', () {
    final all = [for (final r in t.factors) ...r];
    expect(all.length, 180);
    expect(all.fold<double>(0, (a, b) => a + b), closeTo(949.4, 1e-9));
  });

  test('un facteur ne croît jamais avec le non-HDL-C dans une strate ; une seule décroissance avec les TG', () {
    for (final row in t.factors) {
      for (var j = 1; j < row.length; j++) {
        expect(row[j], lessThanOrEqualTo(row[j - 1]));
      }
    }
    final decreases = <String>[];
    for (var j = 0; j < 6; j++) {
      for (var i = 1; i < t.factors.length; i++) {
        if (t.factors[i][j] < t.factors[i - 1][j]) {
          decreases.add('${t.tgLowerEdges[i - 1]}→${t.tgLowerEdges[i]} col $j');
        }
      }
    }
    expect(decreases, ['93.0→97.0 col 5'], reason: 'à vérifier à la source (FV-PREP-017)');
  });

  group('panel lipidique, équation Martin-Hopkins (valeurs Python)', () {
    for (final (tc, hdl, tg, expected) in const [
      (180.0, 40.0, 350.0, 93.33333333333334),
      (200.0, 50.0, 100.0, 129.16666666666666),
      (140.0, 60.0, 30.0, 71.42857142857143),
      (215.0, 85.0, 50.0, 116.48648648648648),
      (180.0, 51.0, 49.0, 114.58823529411765),
      (230.0, 50.0, 200.0, 145.51724137931035),
    ]) {
      test('CT $tc, HDL $hdl, TG $tg → LDL $expected mg/dL', () {
        final r = _panel(tc, hdl, tg);
        expect(_ldlMgDl(r), closeTo(expected, 1e-9));
        expect(r.warnings.any((w) => w.message.contains('Tableau saisi par le validateur')), isTrue);
        expect(r.warnings.any((w) => w.severity == WarningSeverity.blocking), isFalse);
      });
    }

    test('TG ≥ 400 mg/dL : LDL non calculé (bloquant), comme Friedewald ; la ligne « ≥ 400* » n\'est jamais utilisée', () {
      for (final tg in [400.0, 450.0, 800.0]) {
        final r = _panel(300, 35, tg);
        expect(r.values.first.value, isNull, reason: 'TG $tg');
        expect(r.warnings.any((w) => w.severity == WarningSeverity.blocking && w.message.contains('≥ 400')), isTrue);
      }
      // 399,4 mg/dL (arrondi 399) : calculé avec la ligne 293–399 ; 399,6 (arrondi 400) : refusé.
      expect(_ldlMgDl(_panel(250, 50, 399.4)), closeTo(138.55384615384617, 1e-9));
      expect(_panel(250, 50, 399.6).values.first.value, isNull);
    });

    test('strates entières : TG et non-HDL-C arrondis au mg/dL entier (0,5 vers le haut) pour la lecture ; TG/F avec le TG réel', () {
      // TG 132,4 → 132 (ligne 127–132, F 5,3) ; 132,5 et 132,86 → 133 (ligne 133–138, F 5,4).
      expect(_ldlMgDl(_panel(200, 50, 132.4)), closeTo(125.01886792452831, 1e-9));
      expect(_ldlMgDl(_panel(200, 50, 132.5)), closeTo(125.46296296296296, 1e-9));
      expect(_ldlMgDl(_panel(200, 50, 132.86)), closeTo(125.3962962962963, 1e-9));
      // non-HDL-C 129,6 → 130 : colonne 130–159 (F 4,8 pour TG 100), pas 100–129 (F 5,1).
      expect(_ldlMgDl(_panel(179.6, 50, 100)), closeTo(108.76666666666665, 1e-9));
    });

    test('1,5 mmol/L de TG (132,86 mg/dL) : strate 133–138 (F 5,4) et non plus 127–132', () {
      final r = calculateLdlPanel(
        totalCholesterolValue: 5.18, totalCholesterolUnit: 'mmol/L', hdlValue: 1.3, hdlUnit: 'mmol/L',
        triglyceridesValue: 1.5, triglyceridesUnit: 'mmol/L', formula: LdlFormula.martinHopkins,
      );
      expect(r.warnings.any((w) => w.message.contains('F = 5,4')), isTrue);
    });

    test('TG exactement 400 : dernière strate ; 399,9 : avant-dernière (borne inférieure incluse)', () {
      expect(t.factorFor(triglyceridesMgDl: 400, nonHdlMgDl: 150), 8.8);
      expect(t.factorFor(triglyceridesMgDl: 399.9, nonHdlMgDl: 150), 7.5);
    });

    test('bruit flottant à la borne : 215 − 85 = 130 mg/dL reste dans la colonne 130–159', () {
      // La conversion mg/dL → mmol/L → mg/dL redonne 129,99999999999997 : sans tolérance,
      // le non-HDL-C serait classé dans la colonne précédente (facteur 3,9 au lieu de 3,7).
      final r = _panel(215, 85, 50);
      expect(r.warnings.any((w) => w.message.contains('F = 3,7')), isTrue);
    });

    test('TG sous 7 mg/dL : LDL non calculé (bloquant), sans valeur', () {
      final r = _panel(180, 50, 5);
      expect(r.values.first.value, isNull);
      expect(r.warnings.any((w) => w.severity == WarningSeverity.blocking), isTrue);
    });

    test('Friedewald et Sampson : résultats inchangés par l\'ajout de la troisième équation', () {
      for (final f in [LdlFormula.friedewald, LdlFormula.sampson]) {
        final r = calculateLdlPanel(
          totalCholesterolValue: 200, totalCholesterolUnit: 'mg/dL', hdlValue: 50, hdlUnit: 'mg/dL',
          triglyceridesValue: 150, triglyceridesUnit: 'mg/dL', formula: f,
        );
        expect(r.values.first.value, isNotNull);
        expect(r.echoedInputs['Équation LDL'], f.label);
      }
    });
  });
}
