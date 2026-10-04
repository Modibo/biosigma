// P1-10 : modèle dimensionnel des unités. Valeurs de référence calculées à la main
// ou en Python (hors du code testé) ; cohérence vérifiée contre LabUnits.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

DimUnit _u(String s) {
  final p = UnitAnalyzer.parse(s);
  expect(p.error, isNull, reason: s);
  return p.unit!;
}

void close(double a, double b, [String? reason]) =>
    expect(a, closeTo(b, b.abs() * 1e-12 + 1e-300), reason: reason);

void main() {
  group('algèbre des dimensions', () {
    test('formule et noms', () {
      expect((Dim.mass / Dim.volume).formula, 'M·L⁻³');
      expect((Dim.mass / Dim.volume).name, 'concentration massique');
      expect(Dim.dimensionless.formula, '1');
      expect((Dim.amount / Dim.volume / Dim.time).formula, 'L⁻³·T⁻¹·N');
      expect((Dim.length.pow(2) * Dim.time.pow(-1)).formula, 'L²·T⁻¹');
      expect(Dim.mass / Dim.mass, Dim.dimensionless);
      expect((Dim.mass * Dim.length) == (Dim.length * Dim.mass), isTrue);
    });
  });

  group('lecture des unités composées : dimension et facteur (SI : kg, m, s, mol)', () {
    for (final (text, dim, factor) in <(String, Dim, double)>[
      ('mg/dL', Dim.mass / Dim.volume, 1e-2),
      ('g/L', Dim.mass / Dim.volume, 1),
      ('mmol/L', Dim.amount / Dim.volume, 1),
      ('µmol/L', Dim.amount / Dim.volume, 1e-3),
      ('umol/L', Dim.amount / Dim.volume, 1e-3),
      ('mM', Dim.amount / Dim.volume, 1),
      ('M', Dim.amount / Dim.volume, 1e3),
      ('mg/100 mL', Dim.mass / Dim.volume, 1e-2),
      ('mg%', Dim.mass / Dim.volume, 1e-2),
      ('g%', Dim.mass / Dim.volume, 10),
      ('U/L', Dim.amount / Dim.time / Dim.volume, 1.6666666666666667e-05),
      ('µkat/L', Dim.amount / Dim.time / Dim.volume, 1e-3),
      ('mL/min/1.73 m²', Dim.length / Dim.time, 9.633911368015414e-09),
      ('mL/min/1.73m2', Dim.length / Dim.time, 9.633911368015414e-09),
      ('kg/m²', Dim.mass / Dim.length.pow(2), 1),
      ('kg/m^2', Dim.mass / Dim.length.pow(2), 1),
      ('/µL', Dim.dimensionless / Dim.volume, 1e9),
      ('G/L', Dim.dimensionless / Dim.volume, 1e12),
      ('×10⁹/L', Dim.dimensionless / Dim.volume, 1e12),
      ('10^9/L', Dim.dimensionless / Dim.volume, 1e12),
      ('x10^12/L', Dim.dimensionless / Dim.volume, 1e15),
      ('K/µL', Dim.dimensionless / Dim.volume, 1e12),
      ('/mm3', Dim.dimensionless / Dim.volume, 1e9),
      ('mmHg', Dim.mass / (Dim.length * Dim.time.pow(2)), 133.322387415),
      ('kPa', Dim.mass / (Dim.length * Dim.time.pow(2)), 1000),
      ('mOsm/kg', Dim.amount / Dim.mass, 1e-3),
      ('mg/24h', Dim.mass / Dim.time, 1.1574074074074074e-11),
      ('%', Dim.dimensionless, 0.01),
      ('mEq/L', Dim.equivalent / Dim.volume, 1),
      ('lb', Dim.mass, 0.45359237),
      ('K', Dim.temperature, 1),
    ]) {
      test('« $text » → ${dim.formula}, facteur $factor', () {
        final u = _u(text);
        expect(u.dim, dim, reason: '${u.dim.formula} ≠ ${dim.formula}');
        close(u.factor, factor, text);
      });
    }

    test('« G/L » (cellules) et « g/L » (grammes) sont deux dimensions distinctes', () {
      expect(_u('G/L').dim, isNot(_u('g/L').dim));
    });
  });

  group('unités refusées, avec raison', () {
    for (final (text, fragment) in [
      ('', 'vide'),
      ('mg/(dL·h)', 'parenthèses'),
      ('°C', 'décalées'),
      ('degF', 'décalées'),
      ('foo/L', 'n\'est pas une unité reconnue'),
      ('mg/', 'dénominateur'),
      ('mg/zzz', 'zzz'),
    ]) {
      test('« $text »', () {
        final p = UnitAnalyzer.parse(text);
        expect(p.unit, isNull);
        expect(p.error, contains(fragment));
      });
    }
  });

  group('plan de conversion', () {
    ConversionPlan plan(String a, String b) => planConversion(_u(a), _u(b));
    test('même dimension : directe', () {
      expect(plan('mg/dL', 'g/L').isDirect, isTrue);
      expect(plan('U/L', 'µkat/L').isDirect, isTrue);
      expect(plan('mL/min/1.73m²', 'mL/s/1.73m²').isDirect, isTrue);
      expect(plan('mmHg', 'kPa').isDirect, isTrue);
    });
    test('masse ↔ mole : masse molaire ; mole ↔ équivalents : valence ; masse ↔ équivalents : les deux', () {
      expect((plan('mg/dL', 'mmol/L').needsMolarMass, plan('mg/dL', 'mmol/L').needsValence), (true, false));
      expect((plan('mmol/L', 'mEq/L').needsMolarMass, plan('mmol/L', 'mEq/L').needsValence), (false, true));
      expect((plan('mg/dL', 'mEq/L').needsMolarMass, plan('mg/dL', 'mEq/L').needsValence), (true, true));
      expect((plan('mg/24h', 'µmol/min').needsMolarMass), isTrue);
    });
    test('dimensions incompatibles : impossible, avec les deux grandeurs nommées', () {
      final p = plan('mg/dL', 'mmHg');
      expect(p.possible, isFalse);
      expect(p.reason, contains('concentration massique'));
      expect(p.reason, contains('pression'));
      expect(plan('mL/min', 'mg/dL').possible, isFalse);
      expect(plan('G/L', 'g/L').possible, isFalse);
      expect(plan('mg/dL', 'mmol/min').possible, isFalse, reason: 'le volume et le temps ne s\'annulent pas');
    });
  });

  group('conversions (valeurs hors du code)', () {
    double conv(double v, String a, String b, {double? m, double? z}) => calculateDimensionalConversion(
          value: v, fromUnit: a, toUnit: b, molarMassGPerMol: m, valence: z,
        ).values.single.value!;

    test('créatinine : 1 mg/dL → µmol/L avec M = 113,12 (valeur du convertisseur existant)', () {
      close(conv(1, 'mg/dL', 'µmol/L', m: 113.12), 88.4016973125884);
    });
    test('clairance : 100 mL/min/1,73 m² → mL/s/1,73 m² = 1,6667', () {
      close(conv(100, 'mL/min/1.73m²', 'mL/s/1.73m²'), 1.6666666666666667);
    });
    test('enzymes : 5 U/L → µkat/L = 0,08333', () {
      close(conv(5, 'U/L', 'µkat/L'), 5 / 60);
    });
    test('dose : 12 mg/kg/d → µg/kg/min = 8,3333 (unité composée hors des listes)', () {
      close(conv(12, 'mg/kg/d', 'µg/kg/min'), 8.333333333333334);
    });
    test('masse : 70 kg → lb', () {
      close(conv(70, 'kg', 'lb'), 154.3235835294143);
    });
    test('calcium : 10 mg/dL → mEq/L avec M = 40,078 et z = 2 : 4,99027', () {
      close(conv(10, 'mg/dL', 'mEq/L', m: 40.078, z: 2), 4.990268975497779);
      close(conv(2, 'mmol/L', 'mEq/L', z: 2), 4);
    });
    test('numération : 5 G/L → /µL = 5000 ; 5000 /µL → ×10⁹/L = 5', () {
      close(conv(5, 'G/L', '/µL'), 5000);
      close(conv(5000, '/µL', '×10⁹/L'), 5);
    });
    test('pression : 760 mmHg → atm (définitions conventionnelles : 1,00000014)', () {
      close(conv(760, 'mmHg', 'atm'), 1.0000001424663214);
    });
    test('débit : 1 L/min → mL/s ; surface : 70 kg/m² → g/cm²', () {
      close(conv(1, 'L/min', 'mL/s'), 16.666666666666668);
      close(conv(70, 'kg/m²', 'g/cm²'), 7);
    });
  });

  group('refus à la conversion', () {
    test('masse molaire manquante, valence manquante, valeur absente', () {
      expect(() => calculateDimensionalConversion(value: 1, fromUnit: 'mg/dL', toUnit: 'mmol/L'),
          throwsA(isA<CalculationInputException>().having((e) => e.errors.first.fieldId, 'champ', 'molarMass')));
      expect(() => calculateDimensionalConversion(value: 1, fromUnit: 'mmol/L', toUnit: 'mEq/L'),
          throwsA(isA<CalculationInputException>().having((e) => e.errors.first.fieldId, 'champ', 'valence')));
      expect(() => calculateDimensionalConversion(value: null, fromUnit: 'mg/dL', toUnit: 'g/L'),
          throwsA(isA<CalculationInputException>()));
    });
    test('unité illisible ou dimensions incompatibles : erreur de champ', () {
      expect(() => calculateDimensionalConversion(value: 1, fromUnit: 'zzz', toUnit: 'g/L'),
          throwsA(isA<CalculationInputException>().having((e) => e.errors.first.fieldId, 'champ', 'fromUnit')));
      expect(() => calculateDimensionalConversion(value: 1, fromUnit: 'mg/dL', toUnit: 'mmHg'),
          throwsA(isA<CalculationInputException>().having((e) => e.errors.first.message, 'message', contains('Conversion impossible'))));
    });
    test('masse molaire négative ou nulle refusée', () {
      expect(() => calculateDimensionalConversion(value: 1, fromUnit: 'mg/dL', toUnit: 'mmol/L', molarMassGPerMol: 0),
          throwsA(isA<CalculationInputException>()));
    });
    test('rapports sans dimension : mise en garde (HbA1c % ↔ mmol/mol ne se convertit pas par facteur)', () {
      final r = calculateDimensionalConversion(value: 53, fromUnit: 'mmol/mol', toUnit: '%');
      expect(r.warnings.any((w) => w.message.contains('HbA1c') && w.severity == WarningSeverity.caution), isTrue);
    });
    test('le résultat rappelle les dimensions et la méthode', () {
      final r = calculateDimensionalConversion(value: 1, fromUnit: 'mg/dL', toUnit: 'g/L');
      expect(r.echoedInputs['Dimension de départ'], contains('concentration massique'));
      expect(r.echoedInputs['Méthode'], contains('même dimension'));
    });
  });

  group('cohérence avec le modèle existant (LabUnits)', () {
    Dim dimOf(LabDimension d) => switch (d) {
          LabDimension.mass => Dim.mass,
          LabDimension.volume => Dim.volume,
          LabDimension.amount => Dim.amount,
          LabDimension.equivalent => Dim.equivalent,
          LabDimension.massConcentration => Dim.mass / Dim.volume,
          LabDimension.molarConcentration => Dim.amount / Dim.volume,
          LabDimension.equivalentConcentration => Dim.equivalent / Dim.volume,
          LabDimension.catalytic => Dim.amount / Dim.time,
          LabDimension.catalyticConcentration => Dim.amount / Dim.time / Dim.volume,
          LabDimension.massRate => Dim.mass / Dim.time,
          LabDimension.amountRate => Dim.amount / Dim.time,
          LabDimension.equivalentRate => Dim.equivalent / Dim.time,
          LabDimension.flow => Dim.volume / Dim.time,
          LabDimension.bsaClearance => Dim.length / Dim.time,
          LabDimension.pressure => Dim.mass / (Dim.length * Dim.time.pow(2)),
          LabDimension.temperature => Dim.temperature,
          LabDimension.cellConcentration => Dim.dimensionless / Dim.volume,
          LabDimension.fraction => Dim.dimensionless,
          LabDimension.osmolality => Dim.amount / Dim.mass,
          LabDimension.length => Dim.length,
          LabDimension.time => Dim.time,
        };

    test('toute unité proposée (hors températures) a la dimension attendue et le même rapport de facteurs', () {
      var checked = 0;
      for (final entry in LabUnits.offered.entries) {
        if (entry.key == LabDimension.temperature) continue;
        final units = entry.value;
        final base = LabUnits.parse(units.first)!;
        final baseDim = _u(units.first);
        for (final text in units) {
          final old = LabUnits.parse(text)!;
          final nu = _u(text);
          expect(nu.dim, dimOf(entry.key), reason: '$text : ${nu.dim.formula}');
          // Même rapport de facteurs que LabUnits (indépendant de la base choisie).
          close(nu.factor / baseDim.factor, old.factorToBase / base.factorToBase, text);
          checked++;
        }
      }
      final total = [
        for (final e in LabUnits.offered.entries)
          if (e.key != LabDimension.temperature) e.value.length,
      ].fold<int>(0, (a, b) => a + b);
      expect(checked, total, reason: 'toutes les unités proposées sont couvertes');
      expect(total, 140);
    });

    test('conversions identiques à calculateConversion pour toutes les paires d\'une même grandeur (sans changement de nature)', () {
      var pairs = 0;
      for (final entry in LabUnits.offered.entries) {
        if (entry.key == LabDimension.temperature) continue;
        for (final a in entry.value) {
          for (final b in entry.value) {
            final oldValue = calculateConversion(value: 3.7, fromUnit: a, toUnit: b).values.single.value!;
            final newValue = calculateDimensionalConversion(value: 3.7, fromUnit: a, toUnit: b).values.single.value!;
            close(newValue, oldValue, '$a → $b');
            pairs++;
          }
        }
      }
      final total = [
        for (final e in LabUnits.offered.entries)
          if (e.key != LabDimension.temperature) e.value.length * e.value.length,
      ].fold<int>(0, (a, b) => a + b);
      expect(pairs, total);
      expect(total, 1236);
    });

    test('masse molaire et valence : mêmes résultats que calculateConversion', () {
      for (final (a, b, m, z) in const [
        ('mg/dL', 'mmol/L', 113.12, null),
        ('mmol/L', 'mg/dL', 40.078, null),
        ('mg/dL', 'mEq/L', 40.078, 2.0),
        ('mEq/L', 'mg/dL', 22.99, 1.0),
        ('g/24h', 'mmol/24h', 58.44, null),
      ]) {
        final o = calculateConversion(value: 2.3, fromUnit: a, toUnit: b, molarMassGPerMol: m, valence: z);
        final n = calculateDimensionalConversion(value: 2.3, fromUnit: a, toUnit: b, molarMassGPerMol: m, valence: z);
        close(n.values.single.value!, o.values.single.value!, '$a → $b');
      }
    });

    test('aller-retour : a → b → a rend la valeur de départ (toutes paires)', () {
      for (final entry in LabUnits.offered.entries) {
        if (entry.key == LabDimension.temperature) continue;
        for (final a in entry.value) {
          for (final b in entry.value) {
            final there = calculateDimensionalConversion(value: 12.5, fromUnit: a, toUnit: b).values.single.value!;
            final back = calculateDimensionalConversion(value: there, fromUnit: b, toUnit: a).values.single.value!;
            close(back, 12.5, '$a ↔ $b');
          }
        }
      }
    });
  });
}
