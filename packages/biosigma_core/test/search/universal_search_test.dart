import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

SearchHit? top(String q) {
  final r = universalSearch(q);
  return r.isEmpty ? null : r.first;
}

void main() {
  group('abréviations et synonymes courants', () {
    test('« dfg » trouve d\'abord les calculs CKD-EPI et Schwartz', () {
      final r = universalSearch('dfg');
      expect(r.first.kind, SearchKind.calculator);
      final ids = r
          .where((h) => h.kind == SearchKind.calculator)
          .map((h) => h.id);
      expect(
        ids,
        containsAll([
          'ckd_epi_creatinine_2021',
          'ckd_epi_cystatin_c_2012',
          'schwartz_bedside_pediatric',
        ]),
      );
    });

    test('« imc » → IMC ; « vgm » → constantes érythrocytaires ; « tp » → INR ; « tca » → ratio TCA', () {
      expect(top('imc')!.id, 'bmi');
      expect(top('vgm')!.id, 'red_cell_indices');
      expect(universalSearch('tp').any((h) => h.id == 'inr'), isTrue);
      expect(universalSearch('tca').any((h) => h.id == 'aptt_ratio'), isTrue);
    });

    test('« civd » et « tih » → les scores guidés', () {
      expect(top('civd')!.id, 'isth_dic_score');
      expect(top('tih')!.id, 'four_ts_score');
    });
  });

  group('analytes, unités, modules', () {
    test('« glucose » → l\'analyte en tête', () {
      final t = top('glucose')!;
      expect(t.kind, SearchKind.analyte);
      expect(t.id, 'glucose');
    });

    test(
      '« mmhg » → l\'unité ; « µmol » (avec accent) → des unités molaires',
      () {
        expect(top('mmHg')!.kind, SearchKind.unit);
        expect(top('mmhg')!.id, 'mmHg');
        expect(
          universalSearch('µmol')
              .where((h) => h.kind == SearchKind.unit)
              .map((h) => h.id),
          contains('µmol/L'),
        );
        expect(
          universalSearch('umol').where((h) => h.kind == SearchKind.unit),
          isNotEmpty,
        );
      },
    );

    test('« dilution » → module Dilute ; « tampon » → Prepare ; « ufc » → Microbiology', () {
      expect(top('dilution')!.module, LabModule.dilute);
      expect(
        universalSearch('tampon').any((h) => h.module == LabModule.prepare),
        isTrue,
      );
      expect(top('ufc')!.module, LabModule.microbiology);
    });

    test('une phrase libre propose un module, à confirmer', () {
      final r = universalSearch(
        'je veux diluer 100 µL de sérum dans 900 µL de diluant',
      );
      final hit = r.firstWhere((h) => h.module == LabModule.dilute);
      expect(hit.subtitle, contains('à confirmer'));
    });
  });

  group('comportement de la recherche', () {
    test('insensible à la casse et aux accents', () {
      expect(
        universalSearch('EOSINOPHILES')
            .any((h) => h.id == 'differential_cells'),
        isTrue,
      );
      expect(
        universalSearch('éosinophiles')
            .any((h) => h.id == 'differential_cells'),
        isTrue,
      );
      expect(
        universalSearch('creatinine').map((h) => h.id),
        contains('creatinine'),
      );
      expect(
        universalSearch('CRÉATININE').map((h) => h.id),
        contains('creatinine'),
      );
    });

    test('tous les mots doivent correspondre (ET)', () {
      final r = universalSearch('ckd cystatine')
          .where((h) => h.kind == SearchKind.calculator)
          .map((h) => h.id)
          .toList();
      expect(r, isNotEmpty);
      expect(r, everyElement(contains('cystatin')));
      expect(universalSearch('glucose zzzzzz'), isEmpty);
    });

    test('requête vide ou sans correspondance : liste vide', () {
      expect(universalSearch(''), isEmpty);
      expect(universalSearch('   '), isEmpty);
      expect(universalSearch('qqqqqqqq'), isEmpty);
    });

    test('résultats triés par score décroissant, limite respectée', () {
      final r = universalSearch('a', limit: 10);
      expect(r.length, lessThanOrEqualTo(10));
      for (var i = 1; i < r.length; i++) {
        expect(r[i - 1].score, greaterThanOrEqualTo(r[i].score));
      }
    });

    test('pas de doublons de résultat', () {
      final r = universalSearch('sodium');
      final keys = r.map((h) => '${h.kind.name}:${h.id}').toList();
      expect(keys.toSet().length, keys.length);
    });
  });

  group('couverture : tout est retrouvable', () {
    test('chaque calcul par son nom court', () {
      for (final m in CalculatorCatalog.all) {
        final ids = universalSearch(m.shortName, limit: 80).map((h) => h.id);
        expect(ids, contains(m.id), reason: m.shortName);
      }
    });

    test('chaque analyte par son nom', () {
      for (final a in AnalyteBase.all) {
        final hits = universalSearch(
          a.name,
          limit: 80,
        ).where((h) => h.kind == SearchKind.analyte);
        expect(hits.map((h) => h.id), contains(a.id), reason: a.name);
      }
    });

    test('chaque module par son nom', () {
      for (final m in LabModule.values) {
        expect(
          universalSearch(m.label).any((h) => h.module == m),
          isTrue,
          reason: m.label,
        );
      }
    });

    test('chaque synonyme référence un calcul existant', () {
      for (final id in searchSynonyms.keys) {
        expect(CalculatorCatalog.byId(id), isNotNull, reason: id);
      }
    });
  });

  test('foldText : accents, casse, symboles', () {
    expect(foldText('Éosinophiles'), 'eosinophiles');
    expect(foldText('µmol/L'), 'umol/l');
    expect(foldText('HCO₃⁻'), 'hco3-');
  });
}
