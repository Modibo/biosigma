// Unités étendues (SI et traditionnelles) et base d'analytes de Convert.
// Valeurs attendues calculées à la main à partir des formules brutes et des
// définitions des unités — jamais recopiées depuis le code testé.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

double conv(double v, String from, String to, {double? m, double? z}) =>
    calculateConversion(
      value: v,
      fromUnit: from,
      toUnit: to,
      molarMassGPerMol: m,
      valence: z,
    ).values.first.value!;

double aconv(String id, double v, String from, String to) =>
    calculateAnalyteUnitConversion(
      analyteId: id,
      value: v,
      fromUnit: from,
      toUnit: to,
    ).values.first.value!;

void expectFieldError(void Function() body, String fieldId) {
  try {
    body();
    fail('une CalculationInputException était attendue');
  } on CalculationInputException catch (e) {
    expect(
      e.errors.map((x) => x.fieldId),
      contains(fieldId),
      reason: e.toString(),
    );
  }
}

void main() {
  group('Unités — reconnaissance', () {
    test(
      'toutes les unités proposées sont reconnues, dans la bonne grandeur',
      () {
        LabUnits.offered.forEach((dimension, symbols) {
          for (final s in symbols) {
            final u = LabUnits.parse(s);
            expect(u, isNotNull, reason: s);
            expect(u!.dimension, dimension, reason: s);
          }
        });
      },
    );

    test('toutes les familles du menu ne contiennent que des unités de la même famille', () {
      for (final f in LabUnits.families) {
        for (final s in f.units) {
          expect(LabUnits.parse(s)!.family, f.key, reason: '${f.key} : $s');
        }
      }
    });

    test('écritures alternatives', () {
      expect(LabUnits.parse('IU/L')!.symbol, 'U/L');
      expect(LabUnits.parse('UI/L')!.symbol, 'U/L');
      expect(LabUnits.parse('mIU/mL')!.symbol, 'mU/mL');
      expect(LabUnits.parse('x10^9/L')!.symbol, '×10⁹/L');
      expect(LabUnits.parse('/mm3')!.symbol, '/mm³');
      expect(LabUnits.parse('ukat/L')!.symbol, 'µkat/L');
      expect(LabUnits.parse('degC')!.symbol, '°C');
    });

    test(
      'refuse ce qui est ambigu : µU (unité d\'insuline), g/g, kL, mL/min/s',
      () {
        for (final s in [
          'µU/mL',
          'g/g',
          'kL',
          'mL/min/s',
          'mmol/mol/L',
          'U/min',
        ]) {
          expect(LabUnits.parse(s), isNull, reason: s);
        }
      },
    );
  });

  group('Conversions par définition', () {
    test('activité enzymatique : 100 U/L = 1,66667 µkat/L = 1666,67 nkat/L ; 1 µkat/L = 60 U/L', () {
      expect(conv(100, 'U/L', 'µkat/L'), closeTo(100 / 60, 1e-9));
      expect(conv(100, 'U/L', 'nkat/L'), closeTo(100000 / 60, 1e-6));
      expect(conv(1, 'µkat/L', 'U/L'), closeTo(60, 1e-9));
      expect(conv(1, 'kU/L', 'U/L'), closeTo(1000, 1e-9));
      expect(conv(1, 'U/mL', 'U/L'), closeTo(1000, 1e-9));
      expect(conv(40, 'IU/L', 'U/L'), closeTo(40, 1e-12));
    });

    test('température : 37 °C = 98,6 °F = 310,15 K ; 0 °C = 273,15 K ; 98,6 °F = 37 °C', () {
      expect(conv(37, '°C', '°F'), closeTo(98.6, 1e-9));
      expect(conv(37, '°C', 'K'), closeTo(310.15, 1e-9));
      expect(conv(0, '°C', 'K'), closeTo(273.15, 1e-9));
      expect(conv(98.6, '°F', '°C'), closeTo(37, 1e-9));
      expect(conv(-40, '°C', '°F'), closeTo(-40, 1e-9));
    });

    test('température sous le zéro absolu refusée', () {
      expectFieldError(() => conv(-300, '°C', 'K'), 'value');
      expectFieldError(() => conv(-500, '°F', '°C'), 'value');
    });

    test('pression : 100 mmHg = 13,3322 kPa ; 760 Torr = 1 atm ; 1 bar = 750,06 mmHg', () {
      expect(conv(100, 'mmHg', 'kPa'), closeTo(13.3322387415, 1e-9));
      expect(conv(760, 'Torr', 'atm'), closeTo(1, 1e-12));
      expect(conv(1, 'atm', 'kPa'), closeTo(101.325, 1e-9));
      expect(conv(1, 'bar', 'kPa'), closeTo(100, 1e-12));
      expect(conv(10, 'cmH2O', 'Pa'), closeTo(980.665, 1e-9));
    });

    test('numération cellulaire : 7,5 ×10⁹/L = 7500 /µL = 7500 /mm³ ; 5 ×10¹²/L = 5 ×10⁶/µL', () {
      expect(conv(7.5, '×10⁹/L', '/µL'), closeTo(7500, 1e-9));
      expect(conv(7.5, 'G/L', '/mm³'), closeTo(7500, 1e-9));
      expect(conv(5, '×10¹²/L', '×10⁶/µL'), closeTo(5, 1e-12));
      expect(conv(250, '×10⁹/L', 'K/µL'), closeTo(250, 1e-12));
      expect(conv(1, '×10⁶/mL', '×10⁹/L'), closeTo(1, 1e-12));
      expect(conv(4.5, 'T/L', '/L'), closeTo(4.5e12, 1));
    });

    test('fraction et osmolalité', () {
      expect(conv(45, '%', 'L/L'), closeTo(0.45, 1e-12));
      expect(conv(290, 'mOsm/kg', 'mmol/kg'), closeTo(290, 1e-12));
      expect(conv(290, 'mOsm/kg', 'Osm/kg'), closeTo(0.29, 1e-12));
    });

    test('longueur et masses non métriques : 70 in = 177,8 cm ; 6 ft = 182,88 cm ; 154 lb = 69,853 kg', () {
      expect(conv(70, 'in', 'cm'), closeTo(177.8, 1e-9));
      expect(conv(6, 'ft', 'cm'), closeTo(182.88, 1e-9));
      expect(conv(154, 'lb', 'kg'), closeTo(154 * 0.45359237, 1e-9));
      expect(conv(16, 'oz', 'g'), closeTo(16 * 28.349523125, 1e-9));
    });

    test('excrétion et débits : 1,5 g/24h = 1500 mg/d ; 2 L/24h = 1,38889 mL/min ; DFG 90 mL/min = 1,5 mL/s', () {
      expect(conv(1.5, 'g/24h', 'mg/d'), closeTo(1500, 1e-9));
      expect(conv(100, 'mmol/24h', 'µmol/min'), closeTo(100000 / 1440, 1e-9));
      expect(conv(2, 'L/24h', 'mL/min'), closeTo(2000 / 1440, 1e-9));
      expect(conv(90, 'mL/min/1.73m²', 'mL/s/1.73m²'), closeTo(1.5, 1e-12));
      expect(conv(60, 'min', 'h'), closeTo(1, 1e-12));
    });

    test(
      'écritures traditionnelles : 100 mg% = 1 g/L = 100 mg/dL ; 1 g% = 10 g/L',
      () {
        expect(conv(100, 'mg%', 'g/L'), closeTo(1, 1e-12));
        expect(conv(100, 'mg%', 'mg/dL'), closeTo(100, 1e-9));
        expect(conv(1, 'g%', 'g/L'), closeTo(10, 1e-12));
      },
    );

    test('nouveaux préfixes : 1 fg = 1e-15 g ; 1 fmol = 1e-15 mol ; 1 cL = 10 mL ; 1 pL = 1e-12 L', () {
      expect(conv(1, 'fg', 'pg'), closeTo(1e-3, 1e-15));
      expect(conv(1, 'cL', 'mL'), closeTo(10, 1e-12));
      expect(conv(1, 'mL', 'pL'), closeTo(1e9, 1e-3));
      expect(conv(1, 'pmol', 'fmol'), closeTo(1000, 1e-9));
    });

    test('familles non comparables refusées', () {
      expectFieldError(() => conv(1, 'mmHg', '°C'), 'toUnit');
      expectFieldError(() => conv(1, 'U/L', 'mg/L'), 'toUnit');
      expectFieldError(() => conv(1, 'U/L', 'mmol/L', m: 100), 'toUnit');
      expectFieldError(() => conv(1, 'g/24h', 'g/L'), 'toUnit');
      expectFieldError(() => conv(1, '%', 'mm'), 'toUnit');
    });

    test('excrétion avec masse molaire : 100 mmol/24h de sodium (M 22,990) = 2299 mg/24h', () {
      expect(conv(100, 'mmol/24h', 'mg/24h', m: 22.990), closeTo(2299, 1e-9));
      expect(conv(100, 'mmol/24h', 'mEq/24h', z: 1), closeTo(100, 1e-12));
    });

    test('aller-retour sur toutes les unités de chaque famille (masse molaire et valence fournies)', () {
      for (final f in LabUnits.families) {
        for (final other in f.units) {
          const probe = 12.5;
          final first = f.units.first;
          final there = conv(probe, first, other, m: 100, z: 2);
          final back = conv(there, other, first, m: 100, z: 2);
          expect(
            back,
            closeTo(probe, 1e-9 * (probe.abs() + 1)),
            reason: '${f.key} : $first ↔ $other',
          );
        }
      }
    });
  });

  group('Base d\'analytes — masses molaires calculées', () {
    double m(String id) => AnalyteBase.byId(id)!.molarMass!;

    test('formules brutes → masses molaires (sommes calculées à la main)', () {
      expect(
        m('glucose'),
        closeTo(6 * 12.011 + 12 * 1.008 + 6 * 15.999, 1e-9),
      ); // 180,156
      expect(m('glucose'), closeTo(180.156, 1e-9));
      expect(m('creatinine'), closeTo(113.120, 1e-9));
      expect(m('urea'), closeTo(60.056, 1e-9));
      expect(m('urea_nitrogen'), closeTo(28.014, 1e-9));
      expect(m('uric_acid'), closeTo(168.112, 1e-9));
      expect(m('bilirubin'), closeTo(584.673, 1e-9));
      expect(m('cholesterol'), closeTo(386.664, 1e-9));
      expect(m('triglycerides'), closeTo(885.453, 1e-9));
      expect(m('calcium'), closeTo(40.078, 1e-12));
      expect(m('bicarbonate'), closeTo(61.016, 1e-9));
      expect(m('b12'), closeTo(1355.388, 1e-9));
      expect(m('vitd'), closeTo(400.647, 1e-9));
    });

    test('toutes les formules n\'utilisent que des éléments du tableau des poids atomiques', () {
      for (final a in AnalyteBase.all.where((a) => a.formula != null)) {
        for (final el in a.formula!.keys) {
          expect(
            atomicWeights.containsKey(el),
            isTrue,
            reason: '${a.id} : $el',
          );
        }
        expect(a.molarMass, greaterThan(0));
        expect(a.kind, AnalyteKind.molecular, reason: a.id);
      }
    });

    test(
      'structure : identifiants uniques, catégories non vides, kinds cohérents',
      () {
        final ids = AnalyteBase.all.map((a) => a.id).toList();
        expect(ids.toSet().length, ids.length);
        expect(AnalyteBase.all.length, greaterThanOrEqualTo(80));
        for (final a in AnalyteBase.all) {
          expect(a.name, isNotEmpty);
          expect(a.category, isNotEmpty);
          if (a.kind == AnalyteKind.massOnly) {
            expect(
              a.formula,
              isNull,
              reason: 'masse molaire non sourcée : ${a.id}',
            );
            expect(a.note, contains('masse molaire'));
          }
          if (a.kind == AnalyteKind.molecular) {
            expect(a.formula, isNotNull, reason: a.id);
          }
        }
        expect(AnalyteBase.categories.length, 10);
      },
    );

    test('recherche', () {
      expect(AnalyteBase.search('gluc').map((a) => a.id), ['glucose']);
      expect(AnalyteBase.search('CALC').map((a) => a.id), contains('calcium'));
      expect(AnalyteBase.search('zzz'), isEmpty);
      expect(AnalyteBase.search('').length, AnalyteBase.all.length);
    });
  });

  group('Conversions d\'analytes', () {
    test('glucose 100 mg/dL = 1000/180,156 = 5,5507 mmol/L', () {
      expect(
        aconv('glucose', 100, 'mg/dL', 'mmol/L'),
        closeTo(1000 / 180.156, 1e-9),
      );
      expect(aconv('glucose', 100, 'mg/dL', 'mmol/L'), closeTo(5.5507, 1e-3));
    });

    test('créatinine 1 mg/dL = 88,40 µmol/L ; calcium 10 mg/dL = 2,495 mmol/L = 4,990 mEq/L', () {
      expect(
        aconv('creatinine', 1, 'mg/dL', 'µmol/L'),
        closeTo(10000 / 113.12, 1e-9),
      );
      expect(aconv('creatinine', 1, 'mg/dL', 'µmol/L'), closeTo(88.4017, 1e-3));
      expect(
        aconv('calcium', 10, 'mg/dL', 'mmol/L'),
        closeTo(100 / 40.078, 1e-9),
      );
      expect(
        aconv('calcium', 10, 'mg/dL', 'mEq/L'),
        closeTo(200 / 40.078, 1e-9),
      );
    });

    test('azote uréique : 20 mg/dL de BUN = 7,139 mmol/L d\'urée', () {
      expect(
        aconv('urea_nitrogen', 20, 'mg/dL', 'mmol/L'),
        closeTo(200 / 28.014, 1e-9),
      );
      expect(aconv('urea', 40, 'mg/dL', 'mmol/L'), closeTo(400 / 60.056, 1e-9));
    });

    test('sodium : 140 mmol/L = 140 mEq/L = 321,86 mg/dL ; 100 mmol/24h = 2299 mg/24h', () {
      expect(aconv('sodium', 140, 'mmol/L', 'mEq/L'), closeTo(140, 1e-12));
      expect(
        aconv('sodium', 140, 'mmol/L', 'mg/dL'),
        closeTo(140 * 22.990 / 10, 1e-9),
      );
      expect(aconv('sodium', 100, 'mmol/24h', 'mg/24h'), closeTo(2299, 1e-9));
    });

    test(
      'vitamine D 30 ng/mL = 74,88 nmol/L ; B12 500 pg/mL = 368,9 pmol/L',
      () {
        expect(
          aconv('vitd', 30, 'ng/mL', 'nmol/L'),
          closeTo(30000 / 400.647, 1e-6),
        );
        expect(aconv('vitd', 30, 'ng/mL', 'nmol/L'), closeTo(74.88, 1e-2));
        expect(
          aconv('b12', 500, 'pg/mL', 'pmol/L'),
          closeTo(500000 / 1355.388, 1e-6),
        );
      },
    );

    test(
      'bilirubine 1 mg/dL = 17,1 µmol/L ; cholestérol 200 mg/dL = 5,172 mmol/L',
      () {
        expect(
          aconv('bilirubin', 1, 'mg/dL', 'µmol/L'),
          closeTo(10000 / 584.673, 1e-9),
        );
        expect(aconv('bilirubin', 1, 'mg/dL', 'µmol/L'), closeTo(17.1, 5e-2));
        expect(
          aconv('cholesterol', 200, 'mg/dL', 'mmol/L'),
          closeTo(2000 / 386.664, 1e-9),
        );
      },
    );

    test('enzyme, cellules, pression, température, fraction, DFG', () {
      expect(aconv('alt', 40, 'U/L', 'µkat/L'), closeTo(40 / 60, 1e-9));
      expect(aconv('wbc', 7.5, '×10⁹/L', '/µL'), closeTo(7500, 1e-9));
      expect(aconv('po2', 100, 'mmHg', 'kPa'), closeTo(13.3322, 1e-3));
      expect(aconv('temperature', 38.5, '°C', '°F'), closeTo(101.3, 1e-9));
      expect(aconv('hematocrit', 45, '%', 'L/L'), closeTo(0.45, 1e-12));
      expect(
        aconv('gfr', 60, 'mL/min/1.73m²', 'mL/s/1.73m²'),
        closeTo(1, 1e-12),
      );
    });

    test('masse seulement : albumine 4 g/dL = 40 g/L ; troponine 14 ng/L = 0,014 ng/mL', () {
      expect(aconv('albumin', 4, 'g/dL', 'g/L'), closeTo(40, 1e-12));
      expect(aconv('troponin', 14, 'ng/L', 'ng/mL'), closeTo(0.014, 1e-12));
    });

    test('anciens analytes : insuline et HbA1c via les facteurs du moteur existant', () {
      expect(
        aconv('insulin', 10, 'µU/mL', 'pmol/L'),
        closeTo(10 / (1 / 6.945), 1e-6),
      );
      final r = calculateAnalyteUnitConversion(
        analyteId: 'hba1c',
        value: 7,
        fromUnit: '%',
        toUnit: 'mmol/mol',
      );
      expect(r.values.first.value, closeTo((7 - 2.15) * 10.929, 1e-6));
    });

    test('écart avec le facteur arrondi des calculateurs, signalé sans rien modifier', () {
      final r = calculateAnalyteUnitConversion(
        analyteId: 'glucose',
        value: 90,
        fromUnit: 'mg/dL',
        toUnit: 'mmol/L',
      );
      final note = r.warnings.firstWhere(
        (w) => w.message.contains('facteur arrondi'),
      );
      expect(note.message, contains('4.995'));
      expect(r.values.first.value, closeTo(900 / 180.156, 1e-9));
      // le moteur des calculateurs est inchangé
      expect(
        UnitRegistry.convert(
          Analyte.glucose,
          90,
          fromUnit: 'mg/dL',
          toUnit: 'mmol/L',
        ),
        closeTo(4.995, 1e-12),
      );
    });

    test('le résultat rappelle formule, masse molaire utilisée et statut NON VALIDÉ', () {
      final r = calculateAnalyteUnitConversion(
        analyteId: 'glucose',
        value: 90,
        fromUnit: 'mg/dL',
        toUnit: 'mmol/L',
      );
      expect(r.echoedInputs['Formule brute'], 'C6H12O6');
      expect(r.echoedInputs['Statut de la base'], 'NON VALIDÉ');
      expect(
        r.echoedInputs['Masse molaire utilisée (base d\'analytes)'],
        '180.156 g/mol',
      );
      expect(
        r.warnings.any((w) => w.message.contains('poids atomiques IUPAC')),
        isTrue,
      );
    });

    test(
      'unités comparables : concentration et excrétion ne se mélangent pas',
      () {
        final sodium = AnalyteBase.byId('sodium')!;
        final conc = sodium.compatibleUnits('mmol/L');
        expect(conc, contains('mg/dL'));
        expect(conc, contains('mEq/L'));
        expect(conc, isNot(contains('mmol/24h')));
        expect(
          sodium.compatibleUnits('mmol/24h'),
          containsAll(['mg/24h', 'mEq/24h']),
        );
        expect(AnalyteBase.byId('iron')!.units, isNot(contains('mEq/L')));
        expect(AnalyteBase.byId('hba1c')!.compatibleUnits('%'), [
          '%',
          'mmol/mol',
        ]);
        expectFieldError(
          () => aconv('sodium', 1, 'mmol/L', 'mmol/24h'),
          'toUnit',
        );
      },
    );

    test(
      'refus : unité non proposée, équivalents sans valence, analyte inconnu',
      () {
        expectFieldError(
          () => aconv('albumin', 1, 'mmol/L', 'g/L'),
          'fromUnit',
        );
        expectFieldError(() => aconv('iron', 1, 'µg/dL', 'mEq/L'), 'toUnit');
        expectFieldError(
          () => aconv('phosphate', 1, 'mg/dL', 'mEq/L'),
          'toUnit',
        );
        expectFieldError(() => aconv('alt', 1, 'U/L', 'mg/L'), 'toUnit');
        expectFieldError(
          () => calculateAnalyteUnitConversion(
            analyteId: 'inconnu',
            value: 1,
            fromUnit: 'a',
            toUnit: 'b',
          ),
          'analyte',
        );
        expectFieldError(
          () => calculateAnalyteUnitConversion(
            analyteId: 'sodium',
            value: null,
            fromUnit: 'mmol/L',
            toUnit: 'mg/dL',
          ),
          'value',
        );
      },
    );

    test(
      'aller-retour sur tous les analytes et toutes leurs unités proposées',
      () {
        var checked = 0;
        for (final a in AnalyteBase.all) {
          final units = a.units;
          expect(units, isNotEmpty, reason: a.id);
          for (final first in units) {
            for (final u in a.compatibleUnits(first)) {
              const probe = 7.5;
              final there = aconv(a.id, probe, first, u);
              final back = aconv(a.id, there, u, first);
              expect(
                back,
                closeTo(probe, 1e-8 * (probe.abs() + 1)),
                reason: '${a.id} : $first ↔ $u',
              );
              checked++;
            }
          }
        }
        expect(checked, greaterThan(5000));
      },
    );
  });
}
