import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateExpectedAcidBaseCompensation', () {
    test('acidose métabolique : PaCO2 attendue = 1,5×HCO3 + 8', () {
      // HCO3 = 10 mmol/L → PaCO2 attendue = 1,5×10 + 8 = 23 mmHg, ± 2 mmHg.
      final result = calculateExpectedAcidBaseCompensation(
        disorder: PrimaryAcidBaseDisorder.acidoseMetabolique,
        measuredValue: 10,
      );
      final central =
          result.values.firstWhere((v) => v.label == 'PaCO2 attendue (valeur centrale)');
      final range = result.values
          .firstWhere((v) => v.label == 'Demi-amplitude de la fourchette attendue (±)');
      expect(central.value, closeTo(23.0, 1e-9));
      expect(central.unit, 'mmHg');
      expect(range.value, closeTo(2.0, 1e-9));
    });

    test('alcalose métabolique : PaCO2 attendue = 40 + 0,7×(HCO3 − 24)', () {
      // HCO3 = 30 mmol/L → PaCO2 attendue = 40 + 0,7×6 = 44,2 mmHg, ± 5 mmHg.
      final result = calculateExpectedAcidBaseCompensation(
        disorder: PrimaryAcidBaseDisorder.alcaloseMetabolique,
        measuredValue: 30,
      );
      final central =
          result.values.firstWhere((v) => v.label == 'PaCO2 attendue (valeur centrale)');
      final range = result.values
          .firstWhere((v) => v.label == 'Demi-amplitude de la fourchette attendue (±)');
      expect(central.value, closeTo(44.2, 1e-9));
      expect(range.value, closeTo(5.0, 1e-9));
    });

    test('acidose respiratoire aiguë : HCO3 attendu = 24 + 0,1×(PaCO2 − 40)', () {
      // PaCO2 = 60 mmHg → HCO3 attendu = 24 + 0,1×20 = 26 mmol/L, ± 3 mmol/L.
      final result = calculateExpectedAcidBaseCompensation(
        disorder: PrimaryAcidBaseDisorder.acidoseRespiratoireAigue,
        measuredValue: 60,
      );
      final central =
          result.values.firstWhere((v) => v.label == 'HCO3 attendu (valeur centrale)');
      final range = result.values
          .firstWhere((v) => v.label == 'Demi-amplitude de la fourchette attendue (±)');
      expect(central.value, closeTo(26.0, 1e-9));
      expect(central.unit, 'mmol/L');
      expect(range.value, closeTo(3.0, 1e-9));
    });

    test('acidose respiratoire chronique : HCO3 attendu = 24 + 0,35×(PaCO2 − 40)', () {
      // PaCO2 = 60 mmHg → HCO3 attendu = 24 + 0,35×20 = 31 mmol/L, ± 4 mmol/L.
      final result = calculateExpectedAcidBaseCompensation(
        disorder: PrimaryAcidBaseDisorder.acidoseRespiratoireChronique,
        measuredValue: 60,
      );
      final central =
          result.values.firstWhere((v) => v.label == 'HCO3 attendu (valeur centrale)');
      final range = result.values
          .firstWhere((v) => v.label == 'Demi-amplitude de la fourchette attendue (±)');
      expect(central.value, closeTo(31.0, 1e-9));
      expect(range.value, closeTo(4.0, 1e-9));
    });

    test('alcalose respiratoire aiguë : HCO3 attendu = 24 − 0,2×(40 − PaCO2)', () {
      // PaCO2 = 25 mmHg → HCO3 attendu = 24 − 0,2×15 = 21 mmol/L, ± 2 mmol/L.
      final result = calculateExpectedAcidBaseCompensation(
        disorder: PrimaryAcidBaseDisorder.alcaloseRespiratoireAigue,
        measuredValue: 25,
      );
      final central =
          result.values.firstWhere((v) => v.label == 'HCO3 attendu (valeur centrale)');
      final range = result.values
          .firstWhere((v) => v.label == 'Demi-amplitude de la fourchette attendue (±)');
      expect(central.value, closeTo(21.0, 1e-9));
      expect(range.value, closeTo(2.0, 1e-9));
    });

    test('alcalose respiratoire chronique : HCO3 attendu = 24 − 0,4×(40 − PaCO2)', () {
      // PaCO2 = 25 mmHg → HCO3 attendu = 24 − 0,4×15 = 18 mmol/L, ± 4 mmol/L.
      final result = calculateExpectedAcidBaseCompensation(
        disorder: PrimaryAcidBaseDisorder.alcaloseRespiratoireChronique,
        measuredValue: 25,
      );
      final central =
          result.values.firstWhere((v) => v.label == 'HCO3 attendu (valeur centrale)');
      final range = result.values
          .firstWhere((v) => v.label == 'Demi-amplitude de la fourchette attendue (±)');
      expect(central.value, closeTo(18.0, 1e-9));
      expect(range.value, closeTo(4.0, 1e-9));
    });

    test('rejette une valeur hors bornes physiologiques plausibles', () {
      expect(
        () => calculateExpectedAcidBaseCompensation(
          disorder: PrimaryAcidBaseDisorder.acidoseMetabolique,
          measuredValue: 500,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('measuredCompensatoryValue omis (null) : comportement inchangé, aucun avertissement', () {
      final result = calculateExpectedAcidBaseCompensation(
        disorder: PrimaryAcidBaseDisorder.acidoseMetabolique,
        measuredValue: 10,
      );
      expect(result.warnings, isEmpty);
    });

    test('measuredCompensatoryValue dans la fourchette attendue : compatible', () {
      // HCO3 = 10 -> PaCO2 attendue = 23 ± 2 (soit [21 ; 25]).
      final result = calculateExpectedAcidBaseCompensation(
        disorder: PrimaryAcidBaseDisorder.acidoseMetabolique,
        measuredValue: 10,
        measuredCompensatoryValue: 22,
      );
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
      expect(result.warnings.single.message, contains('compatible avec une compensation'));
    });

    test('measuredCompensatoryValue hors de la fourchette attendue : suggère un trouble mixte', () {
      // HCO3 = 10 -> PaCO2 attendue = 23 ± 2 (soit [21 ; 25]) ; 35 est hors fourchette.
      final result = calculateExpectedAcidBaseCompensation(
        disorder: PrimaryAcidBaseDisorder.acidoseMetabolique,
        measuredValue: 10,
        measuredCompensatoryValue: 35,
      );
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
      expect(result.warnings.single.message, contains('hors de la fourchette attendue'));
      expect(result.warnings.single.message, contains('mixte'));
    });
  });

  group('calculateBicarbonateChlorideRatio', () {
    test('rapport simple HCO3/Cl', () {
      // 24 / 100 = 0,24.
      final result = calculateBicarbonateChlorideRatio(
        bicarbonateValue: 24,
        chlorideValue: 100,
      );
      expect(result.values.single.value, closeTo(0.24, 1e-9));
      // Aucun seuil consensuel : avertissement honnête toujours présent.
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
      expect(result.warnings.single.message, contains('Aucun seuil consensuel'));
    });

    test('rejette un chlore nul (division par zéro)', () {
      expect(
        () => calculateBicarbonateChlorideRatio(bicarbonateValue: 24, chlorideValue: 0),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });
}
