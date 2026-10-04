// Valeurs attendues calculées à la main (puissances de dix, g/mol saisies
// dans le test) — jamais recopiées depuis la fonction testée.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

double _value(CalculationResult r) => r.values.first.value!;

void expectFieldError(void Function() body, String fieldId) {
  try {
    body();
    fail('une CalculationInputException était attendue');
  } on CalculationInputException catch (e) {
    expect(e.errors.map((x) => x.fieldId), contains(fieldId), reason: e.toString());
  }
}

void main() {
  group('LabUnits.parse', () {
    test('reconnaît les unités simples et composées', () {
      expect(LabUnits.parse('mg')!.dimension, LabDimension.mass);
      expect(LabUnits.parse('µL')!.dimension, LabDimension.volume);
      expect(LabUnits.parse('mmol')!.dimension, LabDimension.amount);
      expect(LabUnits.parse('mEq')!.dimension, LabDimension.equivalent);
      expect(LabUnits.parse('mg/dL')!.dimension, LabDimension.massConcentration);
      expect(LabUnits.parse('mmol/L')!.dimension, LabDimension.molarConcentration);
      expect(LabUnits.parse('mEq/L')!.dimension, LabDimension.equivalentConcentration);
    });

    test('facteurs vers la base : 1 mg/dL = 0,01 g/L ; 1 µL = 1e-6 L', () {
      expect(LabUnits.parse('mg/dL')!.factorToBase, closeTo(0.01, 1e-15));
      expect(LabUnits.parse('µL')!.factorToBase, closeTo(1e-6, 1e-20));
      expect(LabUnits.parse('kg')!.factorToBase, 1000);
    });

    test('« u » et « μ » (grec) sont des écritures de « µ »', () {
      expect(LabUnits.parse('uL')!.symbol, 'µL');
      expect(LabUnits.parse('ug/mL')!.factorToBase, closeTo(1e-6 / 1e-3, 1e-15));
      expect(LabUnits.parse('μmol/L')!.dimension, LabDimension.molarConcentration);
    });

    test('refuse tout ce qui est ambigu ou inconnu', () {
      for (final s in ['', 'xyz', 'mg/g', 'mL/L', 'mg/mg', 'g/', 'dmol', 'kL', 'mg/dL/s']) {
        expect(LabUnits.parse(s), isNull, reason: s);
      }
    });
  });

  group('décimales affichées', () {
    test('4 chiffres significatifs', () {
      expect(LabUnits.decimalsForSignificant(5.55), 3);
      expect(LabUnits.decimalsForSignificant(0.00123), 6);
      expect(LabUnits.decimalsForSignificant(1234.5), 0);
      expect(LabUnits.decimalsForSignificant(1e-15), 12);
      // puissances de dix exactes (log10 flottant donnerait 2,9999…)
      expect(LabUnits.decimalsForSignificant(1000), 0);
      expect(LabUnits.decimalsForSignificant(100), 1);
      expect(LabUnits.decimalsForSignificant(1), 3);
      expect(LabUnits.decimalsForSignificant(0.001), 6);
    });
  });

  group('Convert — même grandeur (préfixes SI)', () {
    test('1 mg/dL = 10 mg/L ; 1 g/L = 100 mg/dL', () {
      expect(_value(calculateConversion(value: 1, fromUnit: 'mg/dL', toUnit: 'mg/L')), closeTo(10, 1e-12));
      expect(_value(calculateConversion(value: 1, fromUnit: 'g/L', toUnit: 'mg/dL')), closeTo(100, 1e-12));
    });

    test('volumes et masses', () {
      expect(_value(calculateConversion(value: 5, fromUnit: 'µL', toUnit: 'mL')), closeTo(0.005, 1e-15));
      expect(_value(calculateConversion(value: 2, fromUnit: 'L', toUnit: 'µL')), closeTo(2e6, 1e-6));
      expect(_value(calculateConversion(value: 3, fromUnit: 'mg', toUnit: 'ng')), closeTo(3e6, 1e-6));
    });

    test('aller-retour', () {
      final there = _value(calculateConversion(value: 7.3, fromUnit: 'ng/mL', toUnit: 'pg/mL'));
      final back = _value(calculateConversion(value: there, fromUnit: 'pg/mL', toUnit: 'ng/mL'));
      expect(back, closeTo(7.3, 1e-12));
    });

    test('mêmes unités : valeur inchangée, sans demande de masse molaire', () {
      expect(_value(calculateConversion(value: 12.5, fromUnit: 'mg/dL', toUnit: 'mg/dL')), 12.5);
    });

    test('aucun avertissement de masse molaire quand elle est inutile', () {
      expect(calculateConversion(value: 1, fromUnit: 'mg', toUnit: 'g').warnings, isEmpty);
    });
  });

  group('Convert — avec masse molaire / valence saisies', () {
    test('100 mg/dL avec M = 180,16 g/mol → 5,5506 mmol/L (1 g/L ÷ 180,16)', () {
      final r = calculateConversion(
          value: 100, fromUnit: 'mg/dL', toUnit: 'mmol/L', molarMassGPerMol: 180.16);
      expect(_value(r), closeTo(1000 / 180.16, 1e-9));
      expect(r.warnings.any((w) => w.message.contains('masse molaire')), isTrue);
      expect(r.echoedInputs['Masse molaire saisie'], '180.16 g/mol');
    });

    test('aller-retour mg/dL → mmol/L → mg/dL', () {
      final mmol = _value(calculateConversion(
          value: 88.4, fromUnit: 'mg/dL', toUnit: 'mmol/L', molarMassGPerMol: 113.12));
      final back = _value(calculateConversion(
          value: mmol, fromUnit: 'mmol/L', toUnit: 'mg/dL', molarMassGPerMol: 113.12));
      expect(back, closeTo(88.4, 1e-9));
    });

    test('masse ↔ quantité : 18,016 g → 0,1 mol', () {
      expect(
          _value(calculateConversion(
              value: 18.016, fromUnit: 'g', toUnit: 'mol', molarMassGPerMol: 180.16)),
          closeTo(0.1, 1e-12));
    });

    test('valence : 2,5 mmol/L × 2 = 5 mEq/L et retour', () {
      expect(
          _value(calculateConversion(value: 2.5, fromUnit: 'mmol/L', toUnit: 'mEq/L', valence: 2)),
          closeTo(5, 1e-12));
      expect(
          _value(calculateConversion(value: 5, fromUnit: 'mEq/L', toUnit: 'mmol/L', valence: 2)),
          closeTo(2.5, 1e-12));
    });

    test('mg/dL → mEq/L exige les deux : 100 mg/L ÷ 40,08 × 2 = 4,99 mEq/L', () {
      final r = calculateConversion(
          value: 10, fromUnit: 'mg/dL', toUnit: 'mEq/L', molarMassGPerMol: 40.08, valence: 2);
      expect(_value(r), closeTo(100 / 40.08 * 2, 1e-9));
    });
  });

  group('Convert — refus', () {
    test('masse → quantité sans masse molaire', () {
      expectFieldError(
          () => calculateConversion(value: 1, fromUnit: 'mg/dL', toUnit: 'mmol/L'), 'molarMass');
    });

    test('mmol → mEq sans valence', () {
      expectFieldError(
          () => calculateConversion(value: 1, fromUnit: 'mmol/L', toUnit: 'mEq/L'), 'valence');
    });

    test('masse molaire ou valence nulles ou négatives', () {
      expectFieldError(
          () => calculateConversion(
              value: 1, fromUnit: 'mg/dL', toUnit: 'mmol/L', molarMassGPerMol: 0),
          'molarMass');
      expectFieldError(
          () => calculateConversion(value: 1, fromUnit: 'mmol/L', toUnit: 'mEq/L', valence: -1),
          'valence');
    });

    test('grandeurs non comparables', () {
      expectFieldError(() => calculateConversion(value: 1, fromUnit: 'mg/dL', toUnit: 'mg'), 'toUnit');
      expectFieldError(() => calculateConversion(value: 1, fromUnit: 'mL', toUnit: 'mg'), 'toUnit');
    });

    test('unité inconnue, valeur absente ou non finie', () {
      expectFieldError(() => calculateConversion(value: 1, fromUnit: 'zz', toUnit: 'mg'), 'fromUnit');
      expectFieldError(() => calculateConversion(value: 1, fromUnit: 'mg', toUnit: 'zz'), 'toUnit');
      expectFieldError(() => calculateConversion(value: null, fromUnit: 'mg', toUnit: 'g'), 'value');
      expectFieldError(
          () => calculateConversion(value: double.infinity, fromUnit: 'mg', toUnit: 'g'), 'value');
    });
  });

  group('Convert — analytes du moteur existant', () {
    test('glucose 90 mg/dL → 4,995 mmol/L (facteur 0,0555 existant)', () {
      final r = calculateAnalyteConversion(
          analyte: Analyte.glucose, value: 90, fromUnit: 'mg/dL', toUnit: 'mmol/L');
      expect(_value(r), closeTo(4.995, 1e-9));
      expect(r.warnings.first.message, contains('arrondis'));
    });

    test('insuline : avertissement sur l\'étalon', () {
      final r = calculateAnalyteConversion(
          analyte: Analyte.insulin, value: 10, fromUnit: 'µU/mL', toUnit: 'pmol/L');
      expect(r.warnings.any((w) => w.message.contains('étalon')), isTrue);
    });

    test('unité hors liste de l\'analyte refusée', () {
      expectFieldError(
          () => calculateAnalyteConversion(
              analyte: Analyte.glucose, value: 1, fromUnit: 'g/L', toUnit: 'mmol/L'),
          'fromUnit');
    });
  });

  test('les outils laboratoire ne sont pas dans le catalogue des 59 calculs', () {
    expect(CalculatorCatalog.all.length, 59);
    expect(CalculatorCatalog.byCategory(CalculatorCategory.laboratory), isEmpty);
  });
}
