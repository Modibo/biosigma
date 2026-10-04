// P3-04 : la comparaison de la valeur compensatoire mesurée à la fourchette
// attendue est accessible depuis l'interface (l'autre champ, s'il est saisi).
import 'package:biosigma/data/calculator_registry_hepatic_acidbase.dart';
import 'package:biosigma/models/calculator_field.dart';
import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter_test/flutter_test.dart';

CalculationResult _run(
  PrimaryAcidBaseDisorder d, {
  double? hco3,
  double? paco2,
}) => expectedAcidBaseCompensationDefinition.compute({
  'disorder': d,
  'hco3': NumericEntry(hco3, 'mmol/L'),
  'paco2': NumericEntry(paco2, 'mmHg'),
});

bool _hasComparison(CalculationResult r) =>
    r.warnings.any((w) => w.message.startsWith('La valeur mesurée'));

void main() {
  test('trouble métabolique : PaCO2 mesurée dans la fourchette attendue (HCO3 15 → 30,5 ± 2)', () {
    final r = _run(
      PrimaryAcidBaseDisorder.acidoseMetabolique,
      hco3: 15,
      paco2: 30,
    );
    expect(r.values.first.value, closeTo(30.5, 1e-9));
    expect(r.warnings.single.message, contains('compatible'));
    expect(r.echoedInputs['PaCO2 mesurée'], '30.0 mmHg');
  });

  test('trouble métabolique : PaCO2 mesurée hors fourchette → mention de trouble surajouté possible', () {
    final r = _run(
      PrimaryAcidBaseDisorder.acidoseMetabolique,
      hco3: 15,
      paco2: 40,
    );
    expect(r.warnings.single.message, contains('hors de la fourchette'));
    expect(r.warnings.single.message, contains('à corréler cliniquement'));
  });

  test('trouble respiratoire : le HCO3 mesuré saisi en plus est comparé à la fourchette de HCO3', () {
    // Acidose respiratoire chronique, PaCO2 60 → HCO3 attendu 24 + 0,35 × 20 = 31 ± 4.
    final inside = _run(
      PrimaryAcidBaseDisorder.acidoseRespiratoireChronique,
      paco2: 60,
      hco3: 30,
    );
    expect(inside.values.first.value, closeTo(31, 1e-9));
    expect(inside.warnings.single.message, contains('compatible'));
    final outside = _run(
      PrimaryAcidBaseDisorder.acidoseRespiratoireChronique,
      paco2: 60,
      hco3: 22,
    );
    expect(outside.warnings.single.message, contains('hors de la fourchette'));
  });

  test(
    'sans seconde valeur, aucune comparaison : le résultat est celui d\'avant',
    () {
      expect(
        _hasComparison(
          _run(PrimaryAcidBaseDisorder.acidoseMetabolique, hco3: 15),
        ),
        isFalse,
      );
      expect(
        _hasComparison(
          _run(PrimaryAcidBaseDisorder.acidoseRespiratoireAigue, paco2: 60),
        ),
        isFalse,
      );
    },
  );

  test(
    'la comparaison ne modifie ni la valeur centrale ni la demi-amplitude',
    () {
      final a = _run(PrimaryAcidBaseDisorder.alcaloseMetabolique, hco3: 34);
      final b = _run(
        PrimaryAcidBaseDisorder.alcaloseMetabolique,
        hco3: 34,
        paco2: 70,
      );
      expect(b.values.map((v) => v.value), a.values.map((v) => v.value));
    },
  );
}
