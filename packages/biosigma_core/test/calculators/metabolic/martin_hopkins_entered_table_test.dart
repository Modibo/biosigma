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
        expect(r.warnings.any((w) => w.message.contains('tableau de Martin-Hopkins saisi')), isTrue);
        expect(r.warnings.any((w) => w.severity == WarningSeverity.blocking), isFalse);
      });
    }

    test('TG ≥ 400 : calcul avec la dernière ligne, mais mise en garde sur l\'astérisque', () {
      final r = _panel(300, 35, 450);
      expect(_ldlMgDl(r), closeTo(197.83582089552237, 1e-9));
      expect(r.warnings.any((w) => w.severity == WarningSeverity.caution && w.message.contains('astérisque')), isTrue);
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
