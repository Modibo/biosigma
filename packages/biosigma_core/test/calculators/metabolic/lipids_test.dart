import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

double? _ldlMmolL(CalculationResult result) =>
    result.values.firstWhere((v) => v.label.startsWith('LDL calculé')).value;

double? _byLabel(CalculationResult result, String label) =>
    result.values.firstWhere((v) => v.label == label).value;

void main() {
  group('LDL calculé — Friedewald', () {
    test('TC=200 mg/dL, HDL=50 mg/dL, TG=100 mg/dL -> LDL 130.0 mg/dL', () {
      final result = calculateLdlPanel(
        totalCholesterolValue: 200,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 50,
        hdlUnit: 'mg/dL',
        triglyceridesValue: 100,
        triglyceridesUnit: 'mg/dL',
        formula: LdlFormula.friedewald,
      );
      final ldlMgDl = UnitRegistry.convert(
        Analyte.cholesterol,
        _ldlMmolL(result)!,
        fromUnit: 'mmol/L',
        toUnit: 'mg/dL',
      );
      expect(ldlMgDl, closeTo(130.0, 1e-6));
      expect(result.hasBlockingWarning, isFalse);
    });

    test('TC=180 mg/dL, HDL=45 mg/dL, TG=150 mg/dL -> LDL 105.0 mg/dL', () {
      final result = calculateLdlPanel(
        totalCholesterolValue: 180,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 45,
        hdlUnit: 'mg/dL',
        triglyceridesValue: 150,
        triglyceridesUnit: 'mg/dL',
        formula: LdlFormula.friedewald,
      );
      final ldlMgDl = UnitRegistry.convert(
        Analyte.cholesterol,
        _ldlMmolL(result)!,
        fromUnit: 'mmol/L',
        toUnit: 'mg/dL',
      );
      expect(ldlMgDl, closeTo(105.0, 1e-6));
    });

    test('TG=450 mg/dL -> LDL non calculé + warning bloquant', () {
      final result = calculateLdlPanel(
        totalCholesterolValue: 200,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 50,
        hdlUnit: 'mg/dL',
        triglyceridesValue: 450,
        triglyceridesUnit: 'mg/dL',
        formula: LdlFormula.friedewald,
      );
      expect(_ldlMmolL(result), isNull);
      expect(result.hasBlockingWarning, isTrue);
      expect(
        result.warnings.single.severity,
        WarningSeverity.blocking,
      );
      // Le cholestérol résiduel dépend du LDL : non calculable non plus.
      expect(_byLabel(result, 'Cholestérol résiduel (non-HDL − LDL)'), isNull);
    });
  });

  group('LDL calculé — Sampson', () {
    test('TC=200 mg/dL, HDL=50 mg/dL, TG=100 mg/dL -> LDL 131.96668749215988 mg/dL', () {
      final result = calculateLdlPanel(
        totalCholesterolValue: 200,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 50,
        hdlUnit: 'mg/dL',
        triglyceridesValue: 100,
        triglyceridesUnit: 'mg/dL',
        formula: LdlFormula.sampson,
      );
      final ldlMgDl = UnitRegistry.convert(
        Analyte.cholesterol,
        _ldlMmolL(result)!,
        fromUnit: 'mmol/L',
        toUnit: 'mg/dL',
      );
      expect(ldlMgDl, closeTo(131.96668749215988, 1e-6));
    });

    test('TC=180 mg/dL, HDL=45 mg/dL, TG=300 mg/dL -> LDL 85.70754193328463 mg/dL', () {
      final result = calculateLdlPanel(
        totalCholesterolValue: 180,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 45,
        hdlUnit: 'mg/dL',
        triglyceridesValue: 300,
        triglyceridesUnit: 'mg/dL',
        formula: LdlFormula.sampson,
      );
      final ldlMgDl = UnitRegistry.convert(
        Analyte.cholesterol,
        _ldlMmolL(result)!,
        fromUnit: 'mmol/L',
        toUnit: 'mg/dL',
      );
      expect(ldlMgDl, closeTo(85.70754193328463, 1e-6));
    });

    test('TG >= 800 mg/dL -> LDL non calculé + warning bloquant', () {
      final result = calculateLdlPanel(
        totalCholesterolValue: 200,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 50,
        hdlUnit: 'mg/dL',
        triglyceridesValue: 850,
        triglyceridesUnit: 'mg/dL',
        formula: LdlFormula.sampson,
      );
      expect(_ldlMmolL(result), isNull);
      expect(result.hasBlockingWarning, isTrue);
    });
  });

  group('non-HDL et ratio CT/HDL', () {
    test('TC=200 mg/dL, HDL=50 mg/dL -> CT/HDL = 4.0', () {
      final result = calculateLdlPanel(
        totalCholesterolValue: 200,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 50,
        hdlUnit: 'mg/dL',
        triglyceridesValue: 100,
        triglyceridesUnit: 'mg/dL',
        formula: LdlFormula.friedewald,
      );
      expect(_byLabel(result, 'Ratio CT/HDL'), closeTo(4.0, 1e-6));
    });

    test('TC=5.172 mmol/L, HDL=1.293 mmol/L -> CT/HDL = 4.0 (unit-invariant)', () {
      final result = calculateLdlPanel(
        totalCholesterolValue: 5.172,
        totalCholesterolUnit: 'mmol/L',
        hdlValue: 1.293,
        hdlUnit: 'mmol/L',
        triglyceridesValue: 100,
        triglyceridesUnit: 'mg/dL',
        formula: LdlFormula.friedewald,
      );
      expect(_byLabel(result, 'Ratio CT/HDL'), closeTo(4.0, 1e-3));
    });
  });

  group('Ratio TG/HDL (mg/dL)', () {
    test('TG=100 mg/dL, HDL=50 mg/dL -> 2.0', () {
      final result = calculateLdlPanel(
        totalCholesterolValue: 200,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 50,
        hdlUnit: 'mg/dL',
        triglyceridesValue: 100,
        triglyceridesUnit: 'mg/dL',
        formula: LdlFormula.friedewald,
      );
      expect(_byLabel(result, 'Ratio TG/HDL (mg/dL)'), closeTo(2.0, 1e-9));
    });
  });

  group('Indice athérogène du plasma (AIP)', () {
    test('TG=1.7 mmol/L, HDL=1.2 mmol/L -> 0.15126767533064914', () {
      final result = calculateAtherogenicIndexOfPlasma(
        triglyceridesValue: 1.7,
        triglyceridesUnit: 'mmol/L',
        hdlValue: 1.2,
        hdlUnit: 'mmol/L',
      );
      expect(result.values.single.value, closeTo(0.15126767533064914, 1e-9));
      expect(result.formula.id, 'atherogenic_index_of_plasma');
    });
  });
}
