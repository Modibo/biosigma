import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('Registre d\'équations (T-REG-003)', () {
    test('les 59 identifiants historiques résolvent tous', () {
      for (final meta in CalculatorCatalog.all) {
        final record = EquationRegistry.resolve(meta.id);
        expect(record, isNotNull, reason: meta.id);
        expect(record!.legacyId, meta.id);
        expect(record.fromCatalog, isTrue);
      }
      expect(CalculatorCatalog.all.length, 59);
    });

    test('identifiant stable et historique résolvent vers la même entrée', () {
      for (final record in EquationRegistry.all) {
        expect(EquationRegistry.resolve(record.stableId), same(record));
        expect(EquationRegistry.resolve(record.legacyId), same(record));
        expect(EquationRegistry.stableIdFor(record.legacyId), record.stableId);
      }
    });

    test('identifiants stables uniques, de forme FAMILLE_NOM_NNN', () {
      final stable = EquationRegistry.all.map((r) => r.stableId).toList();
      expect(stable.toSet().length, stable.length);
      for (final id in stable) {
        expect(RegExp(r'^[A-Z]+_[A-Z0-9_]+_\d{3}$').hasMatch(id), isTrue, reason: id);
      }
    });

    test('les identifiants historiques sont tous distincts des identifiants stables', () {
      final all = EquationRegistry.all;
      final legacy = all.map((r) => r.legacyId).toSet();
      final stable = all.map((r) => r.stableId).toSet();
      expect(legacy.intersection(stable), isEmpty);
    });

    test('inconnu : null ; aucune équation n\'est « VALIDÉ » sans fiche de validation', () {
      expect(EquationRegistry.resolve('n_importe_quoi'), isNull);
      expect(EquationRegistry.all.every((r) => r.status == EquationStatus.notValidated), isTrue);
    });

    test('les outils Lab sont enregistrés mais hors catalogue', () {
      final lab = EquationRegistry.all.where((r) => !r.fromCatalog);
      expect(lab.length, 13);
      expect(lab.every((r) => r.family == 'LAB'), isTrue);
      expect(EquationRegistry.resolve('lab_dilution_c1v1')!.stableId, 'LAB_LAB_DILUTION_C1V1_001');
    });

    test('version entière 1 pour toutes les entrées actuelles, libellé de version conservé', () {
      for (final r in EquationRegistry.all) {
        expect(r.version, 1);
        expect(r.versionLabel, r.meta.version);
      }
    });
  });

  group('Politique d\'arrondi FMT_ARRONDI_001 (T-ARR-001)', () {
    test('égalité exacte : arrondi vers l\'extérieur', () {
      expect(RoundingPolicy.format(2.5, 0), '3');
      expect(RoundingPolicy.format(-2.5, 0), '-3');
      expect(RoundingPolicy.format(0.125, 2), '0.13');
    });

    test('décimal non représentable : arrondi de la valeur binaire exacte (1,005 → 1,00)', () {
      expect(RoundingPolicy.format(1.005, 2), '1.00');
    });

    test('nombre de décimales demandé respecté, sans arrondi intermédiaire', () {
      expect(RoundingPolicy.format(1 / 3, 4), '0.3333');
      expect(RoundingPolicy.format(2 / 3, 4), '0.6667');
      expect(RoundingPolicy.format(5, 2), '5.00');
    });

    test('chiffres significatifs, y compris puissances de dix exactes', () {
      expect(RoundingPolicy.decimalsForSignificant(1000), 0);
      expect(RoundingPolicy.decimalsForSignificant(999.9), 1);
      expect(RoundingPolicy.decimalsForSignificant(100), 1);
      expect(RoundingPolicy.decimalsForSignificant(5.55), 3);
      expect(RoundingPolicy.decimalsForSignificant(0.00123), 6);
      expect(RoundingPolicy.decimalsForSignificant(-5.55), 3);
      expect(RoundingPolicy.decimalsForSignificant(0), 2);
      expect(RoundingPolicy.decimalsForSignificant(double.nan), 2);
      expect(RoundingPolicy.decimalsForSignificant(1e-15), 12);
      expect(RoundingPolicy.decimalsForSignificant(1234.5, significant: 6), 2);
    });

    test('LabUnits délègue à la politique (même résultat)', () {
      for (final v in [0.5, 1, 7.3, 12, 100, 1000, 54321, 1e-4]) {
        expect(LabUnits.decimalsForSignificant(v.toDouble()),
            RoundingPolicy.decimalsForSignificant(v.toDouble()));
      }
    });

    test('la règle est nommée et décrite', () {
      expect(RoundingPolicy.ruleId, 'FMT_ARRONDI_001');
      expect(RoundingPolicy.description, contains('sans arrondi intermédiaire'));
    });
  });
}
