// Gouvernance de validation (D-12) : le code ne suppose jamais une validation.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

ValidationRecord rec({
  String id = 'METAB_BMI_001',
  int version = 1,
  String validator = 'Dr Exemple',
  String role = 'Biologiste médical responsable',
  String scope = 'formule, unités, domaine',
  String sources = 'Quetelet 1835 ; OMS',
  int cases = 2,
  String sheet = 'FV-2026-001',
  String reviewer = 'Dr Exemple',
  String approver = 'Dr Exemple',
  ValidationDecision decision = ValidationDecision.approved,
}) => ValidationRecord(
  itemId: id,
  itemVersion: version,
  validatorName: validator,
  validatorRole: role,
  validatedOn: DateTime.utc(2026, 10, 5),
  scope: scope,
  sourcesReviewed: sources,
  independentCases: cases,
  sheetReference: sheet,
  technicalReviewerName: reviewer,
  approverName: approver,
  decision: decision,
);

void main() {
  test(
    'à ce jour, aucune fiche : aucune équation ni aucun analyte n\'est validé',
    () {
      expect(validationRecords, isEmpty);
      expect(
        EquationRegistry.all.every(
          (r) => r.status == EquationStatus.notValidated,
        ),
        isTrue,
      );
    },
  );

  test('une fiche complète valide la version concernée', () {
    expect(
      validationStatusFor('METAB_BMI_001', 1, records: [rec()]),
      EquationStatus.validated,
    );
  });

  test(
    'une fiche pour une autre version ne valide pas la version courante',
    () {
      expect(
        validationStatusFor('METAB_BMI_001', 2, records: [rec(version: 1)]),
        EquationStatus.notValidated,
      );
    },
  );

  test('une fiche pour un autre élément ne valide rien', () {
    expect(
      validationStatusFor(
        'METAB_BMI_001',
        1,
        records: [rec(id: 'RENAL_X_001')],
      ),
      EquationStatus.notValidated,
    );
  });

  test('toute fiche incomplète est ignorée', () {
    for (final r in [
      rec(validator: ' '),
      rec(role: ''),
      rec(scope: ''),
      rec(sources: ''),
      rec(sheet: ''),
      rec(reviewer: ' '),
      rec(approver: ''),
      rec(cases: 1),
      rec(cases: 0),
      rec(version: 0),
    ]) {
      expect(r.isComplete, isFalse);
      expect(
        validationStatusFor('METAB_BMI_001', 1, records: [r]),
        EquationStatus.notValidated,
      );
    }
  });

  test(
    'une fiche rejetée marque l\'élément comme retiré, avant toute approbation',
    () {
      expect(
        validationStatusFor(
          'METAB_BMI_001',
          1,
          records: [
            rec(),
            rec(decision: ValidationDecision.rejected, sheet: 'FV-2026-002'),
          ],
        ),
        EquationStatus.withdrawn,
      );
    },
  );

  test('analytes : l\'identifiant « analyte:<id> » suit la même règle', () {
    expect(
      validationStatusFor(
        'analyte:glucose',
        1,
        records: [rec(id: 'analyte:glucose')],
      ),
      EquationStatus.validated,
    );
    expect(
      validationStatusFor('analyte:glucose', 1),
      EquationStatus.notValidated,
    );
  });

  test('cumul des trois rôles : visible, et sans effet sur la validité', () {
    final cumul = rec();
    expect(cumul.rolesCumulated, isTrue);
    expect(
      validationStatusFor('METAB_BMI_001', 1, records: [cumul]),
      EquationStatus.validated,
    );

    final separated = rec(reviewer: 'Dr Autre', approver: 'Dr Troisième');
    expect(separated.rolesCumulated, isFalse);
    expect(
      validationStatusFor('METAB_BMI_001', 1, records: [separated]),
      EquationStatus.validated,
    );
  });
}
