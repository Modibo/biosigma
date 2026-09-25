import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('UnitRegistry — conversions aller-retour', () {
    void roundTrip(Analyte analyte, double value, String unit, {double tol = 1e-9}) {
      final canonical = UnitRegistry.toCanonical(analyte, value, unit);
      final back = UnitRegistry.fromCanonical(analyte, canonical, unit);
      expect(back, closeTo(value, tol),
          reason: '$analyte $value $unit : aller-retour doit redonner la valeur initiale');
    }

    test('créatinine mg/dL <-> µmol/L', () {
      roundTrip(Analyte.creatinine, 1.0, 'mg/dL');
      expect(UnitRegistry.toCanonical(Analyte.creatinine, 1.0, 'mg/dL'), closeTo(88.42, 1e-9));
      expect(UnitRegistry.fromCanonical(Analyte.creatinine, 88.42, 'mg/dL'), closeTo(1.0, 1e-9));
    });

    test('cystatine C mg/L (unité unique)', () {
      roundTrip(Analyte.cystatinC, 1.2, 'mg/L');
      expect(UnitRegistry.unitsFor(Analyte.cystatinC), equals(['mg/L']));
    });

    test('glycémie mg/dL <-> mmol/L', () {
      roundTrip(Analyte.glucose, 90.0, 'mg/dL');
      expect(UnitRegistry.convert(Analyte.glucose, 90.0, fromUnit: 'mg/dL', toUnit: 'mmol/L'),
          closeTo(4.995, 1e-9));
    });

    test('triglycérides mg/dL <-> mmol/L', () {
      roundTrip(Analyte.triglycerides, 150.0, 'mg/dL');
      expect(
          UnitRegistry.convert(Analyte.triglycerides, 150.0, fromUnit: 'mg/dL', toUnit: 'mmol/L'),
          closeTo(1.695, 1e-9));
    });

    test('protéinurie mg/L <-> g/L <-> mg/dL', () {
      roundTrip(Analyte.proteinuria, 150.0, 'mg/L');
      expect(UnitRegistry.convert(Analyte.proteinuria, 1.0, fromUnit: 'g/L', toUnit: 'mg/L'),
          closeTo(1000.0, 1e-9));
      expect(UnitRegistry.convert(Analyte.proteinuria, 100.0, fromUnit: 'mg/dL', toUnit: 'mg/L'),
          closeTo(1000.0, 1e-9));
      expect(
          UnitRegistry.convert(Analyte.proteinuria, 1000.0, fromUnit: 'mg/L', toUnit: 'g/L'),
          closeTo(1.0, 1e-9));
    });

    test('volume mL <-> L', () {
      roundTrip(Analyte.volume, 1800.0, 'mL');
      expect(UnitRegistry.convert(Analyte.volume, 1.8, fromUnit: 'L', toUnit: 'mL'),
          closeTo(1800.0, 1e-9));
    });

    test('durée h <-> min', () {
      roundTrip(Analyte.duration, 24.0, 'h');
      expect(UnitRegistry.convert(Analyte.duration, 24.0, fromUnit: 'h', toUnit: 'min'),
          closeTo(1440.0, 1e-9));
    });

    test('albumine g/dL <-> g/L', () {
      roundTrip(Analyte.albumin, 4.0, 'g/dL');
      expect(UnitRegistry.convert(Analyte.albumin, 4.0, fromUnit: 'g/dL', toUnit: 'g/L'),
          closeTo(40.0, 1e-9));
    });

    test('calcium mg/dL <-> mmol/L', () {
      roundTrip(Analyte.calcium, 9.5, 'mg/dL');
      expect(UnitRegistry.convert(Analyte.calcium, 10.0, fromUnit: 'mg/dL', toUnit: 'mmol/L'),
          closeTo(2.495, 1e-9));
    });

    test('fibrinogène g/L <-> mg/dL', () {
      roundTrip(Analyte.fibrinogen, 3.0, 'g/L');
      expect(UnitRegistry.convert(Analyte.fibrinogen, 300.0, fromUnit: 'mg/dL', toUnit: 'g/L'),
          closeTo(3.0, 1e-9));
    });

    test('insulinémie µU/mL <-> pmol/L (facteur documenté, dépendant de l\'étalon)', () {
      roundTrip(Analyte.insulin, 15.0, 'µU/mL');
      expect(UnitRegistry.convert(Analyte.insulin, 15.0, fromUnit: 'µU/mL', toUnit: 'pmol/L'),
          closeTo(15.0 * 6.945, 1e-6));
    });

    test('HbA1c % (NGSP) <-> mmol/mol (IFCC)', () {
      roundTrip(Analyte.hba1c, 7.0, '%');
      // Exemple canonique : 7,0 % NGSP correspond à 53 mmol/mol IFCC.
      expect(UnitRegistry.convert(Analyte.hba1c, 7.0, fromUnit: '%', toUnit: 'mmol/mol'),
          closeTo(53.0, 0.2));
      expect(UnitRegistry.convert(Analyte.hba1c, 53.0, fromUnit: 'mmol/mol', toUnit: '%'),
          closeTo(7.0, 0.05));
    });

    test('cholestérol mmol/L <-> g/L <-> mg/dL', () {
      roundTrip(Analyte.cholesterol, 5.0, 'mmol/L');
      expect(UnitRegistry.convert(Analyte.cholesterol, 200.0, fromUnit: 'mg/dL', toUnit: 'mmol/L'),
          closeTo(5.172, 1e-3));
    });

    test('unité inconnue lève une erreur explicite', () {
      expect(() => UnitRegistry.toCanonical(Analyte.creatinine, 1.0, 'g/L'), throwsArgumentError);
    });

    test('même unité : convert est une identité sans dépendre du registre', () {
      expect(UnitRegistry.convert(Analyte.glucose, 5.5, fromUnit: 'mmol/L', toUnit: 'mmol/L'),
          equals(5.5));
    });
  });
}
