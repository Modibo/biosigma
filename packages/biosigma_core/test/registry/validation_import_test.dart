// Importation du registre de validation : seules les lignes complètes valident.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

const _header =
    'item_id;item_version;validator;reviewer;approver;date;scope;sources_reviewed;independent_cases;sheet_ref;decision';
const _v = 'Dr Exemple';

String _row({
  String id = 'METAB_BMI_001',
  String version = '1',
  String validator = _v,
  String reviewer = _v,
  String approver = _v,
  String date = '04/10/2026',
  String scope = 'formule, unités',
  String sources = 'Quetelet ; OMS',
  String cases = '2',
  String sheet = 'FV-2026-001',
  String decision = 'approuvé',
}) => [
  id,
  version,
  validator,
  reviewer,
  approver,
  date,
  scope,
  sources,
  cases,
  sheet,
  decision,
].map((f) => '"${f.replaceAll('"', '""')}"').join(';');

ValidationImportResult _import(List<String> rows) => importValidationCsv(
  '$_header\n${rows.join('\n')}\n',
  knownVersions: validationKnownVersions(),
);

void main() {
  group('lecture CSV', () {
    test('séparateur « ; » et « , », guillemets, virgules et guillemets dans un champ, CRLF', () {
      expect(parseCsv('a;b;c\r\n1;2;3\r\n'), [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
      ]);
      expect(parseCsv('a,b,c\n1,2,3'), [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
      ]);
      expect(parseCsv('a;b\n"x;y";"il dit ""oui"""\n'), [
        ['a', 'b'],
        ['x;y', 'il dit "oui"'],
      ]);
      expect(parseCsv('a;b\n\n1;2\n\n'), [
        ['a', 'b'],
        ['1', '2'],
      ], reason: 'lignes vides ignorées');
    });
  });

  group('lignes valides', () {
    test('une ligne complète donne une fiche approuvée', () {
      final r = _import([_row()]);
      expect(r.problems, isEmpty);
      expect(r.records.single.itemId, 'METAB_BMI_001');
      expect(r.records.single.validatedOn, DateTime.utc(2026, 10, 4));
      expect(r.records.single.decision, ValidationDecision.approved);
      expect(r.records.single.isComplete, isTrue);
      expect(r.records.single.rolesCumulated, isTrue);
      expect(
        validationStatusFor('METAB_BMI_001', 1, records: r.records),
        EquationStatus.validated,
      );
    });

    test(
      'date au format ISO, décision « rejeté », analyte, trois noms différents',
      () {
        final r = _import([
          _row(date: '2026-10-05', decision: 'rejeté'),
          _row(
            id: 'analyte:glucose',
            reviewer: 'Dr A',
            approver: 'Dr B',
            sheet: 'FV-2026-002',
          ),
        ]);
        expect(r.problems, isEmpty);
        expect(r.records[0].decision, ValidationDecision.rejected);
        expect(r.records[0].validatedOn, DateTime.utc(2026, 10, 5));
        expect(r.records[1].rolesCumulated, isFalse);
        expect(
          validationStatusFor('METAB_BMI_001', 1, records: [r.records[0]]),
          EquationStatus.withdrawn,
        );
      },
    );

    test('une ligne sans décision ne valide rien et n\'est pas une erreur', () {
      final r = _import([
        _row(decision: ''),
        _row(id: 'analyte:glucose', decision: ''),
      ]);
      expect(r.records, isEmpty);
      expect(r.problems, isEmpty);
      expect(r.skippedBlank, 2);
    });
  });

  group('lignes refusées (jamais enregistrées, même en partie)', () {
    void expectProblem(ValidationImportResult r, String fragment) {
      expect(r.records, isEmpty);
      expect(r.problems.single, contains(fragment));
    }

    test('champs manquants', () {
      expectProblem(_import([_row(sheet: '')]), 'sheet_ref');
      expectProblem(_import([_row(validator: ' ')]), 'validator');
      expectProblem(_import([_row(reviewer: '')]), 'reviewer');
      expectProblem(_import([_row(approver: '')]), 'approver');
      expectProblem(_import([_row(scope: '')]), 'scope');
      expectProblem(_import([_row(sources: '')]), 'sources_reviewed');
    });

    test('moins de 2 cas indépendants, cas non numériques', () {
      expectProblem(_import([_row(cases: '1')]), 'au moins 2 cas');
      expectProblem(_import([_row(cases: '0')]), 'au moins 2 cas');
      expectProblem(_import([_row(cases: '')]), 'au moins 2 cas');
      expectProblem(_import([_row(cases: 'deux')]), 'au moins 2 cas');
    });

    test('date illisible ou impossible', () {
      expectProblem(_import([_row(date: '')]), 'date illisible');
      expectProblem(_import([_row(date: '31/02/2026')]), 'date illisible');
      expectProblem(_import([_row(date: 'demain')]), 'date illisible');
    });

    test('identifiant inconnu, version différente de la version courante', () {
      expectProblem(_import([_row(id: 'INCONNU_001')]), 'identifiant inconnu');
      expectProblem(
        _import([_row(version: '2')]),
        'version 2 ≠ version courante 1',
      );
      expectProblem(_import([_row(version: 'x')]), 'version illisible');
    });

    test('décision non reconnue', () {
      expectProblem(_import([_row(decision: 'peut-être')]), 'non reconnue');
    });

    test('même élément deux fois avec décision', () {
      final r = _import([_row(), _row(sheet: 'FV-2026-009')]);
      expect(r.records.length, 1);
      expect(r.problems.single, contains('déjà présent'));
    });

    test(
      'une ligne refusée n\'empêche pas les autres lignes valides d\'être lues',
      () {
        final r = _import([_row(sheet: ''), _row(id: 'analyte:glucose')]);
        expect(r.records.single.itemId, 'analyte:glucose');
        expect(r.problems.length, 1);
        expect(r.problems.single, contains('ligne 2'));
      },
    );

    test('fichier vide ou colonnes absentes', () {
      expect(
        importValidationCsv(
          '',
          knownVersions: validationKnownVersions(),
        ).problems.single,
        'Fichier vide.',
      );
      final r = importValidationCsv(
        'item_id;decision\nMETAB_BMI_001;oui\n',
        knownVersions: validationKnownVersions(),
      );
      expect(r.records, isEmpty);
      expect(r.problems.single, contains('Colonnes absentes'));
    });
  });

  group('registre vierge exporté', () {
    final csv = exportValidationRegisterCsv();
    final rows = parseCsv(csv);

    test(
      'une ligne par élément validable : 79 équations/outils + 186 analytes',
      () {
        expect(
          rows.length - 1,
          EquationRegistry.all.length + AnalyteBase.all.length,
        );
        expect(rows.length - 1, validationKnownVersions().length);
        final ids = rows.skip(1).map((r) => r.first).toList();
        expect(ids.toSet().length, ids.length);
      },
    );

    test('rien n\'est validé : décision, date, fiche, sources et cas sont vides ; statut NON VALIDÉ', () {
      final h = rows.first;
      int col(String n) => h.indexOf(n);
      for (final r in rows.skip(1)) {
        for (final c in [
          'date',
          'scope',
          'sources_reviewed',
          'independent_cases',
          'sheet_ref',
          'decision',
        ]) {
          expect(r[col(c)], isEmpty, reason: '${r.first} / $c');
        }
        expect(r[col('current_status')], 'NON VALIDÉ');
      }
    });

    test('les trois rôles sont préremplis, les dossiers préparés et les points à relire indiqués', () {
      final h = rows.first;
      int col(String n) => h.indexOf(n);
      final ckd = rows.firstWhere(
        (r) => r.first == 'RENAL_CKD_EPI_CREATININE_2021_001',
      );
      expect(ckd[col('validator')], 'Dr Modibo Mouctar Coulibaly');
      expect(ckd[col('reviewer')], 'Dr Modibo Mouctar Coulibaly');
      expect(ckd[col('prepared_dossier')], contains('FV-PREP-001'));
      final glucose = rows.firstWhere((r) => r.first == 'analyte:glucose');
      expect(glucose[col('prepared_dossier')], contains('FV-PREP-002'));
      for (final id in [
        'IONO_FIB4_001',
        'HEMO_INR_001',
        'METAB_TYG_INDEX_001',
        'METAB_BMI_001',
        'METAB_HOMA_IR_001',
        'RENAL_CKD_EPI_CYSTATIN_C_2012_001',
        'RENAL_CKD_EPI_CREATININE_CYSTATIN_C_2021_001',
        'RENAL_SCHWARTZ_BEDSIDE_PEDIATRIC_001',
        'IONO_MELD_NA_001',
        'HEMO_CHA2DS2_VASC_SCORE_001',
        'HEMO_HAS_BLED_SCORE_001',
        'METAB_QUICKI_001',
        'analyte:creatinine',
        'analyte:sodium',
      ]) {
        final row = rows.firstWhere((r) => r.first == id);
        expect(
          row[col('prepared_dossier')],
          startsWith('fiches-de-validation/FV-PREP-'),
          reason: id,
        );
      }
      final fib4 = rows.firstWhere((r) => r.first == 'IONO_FIB4_001');
      expect(fib4[col('points_to_review')], contains('corrigé le 2026-10-04'));
      final tyg = rows.firstWhere((r) => r.first == 'METAB_TYG_INDEX_001');
      expect(tyg[col('points_to_review')], contains('4,5'));
      final apri = rows.firstWhere((r) => r.first == 'IONO_APRI_001');
      expect(
        apri[col('points_to_review')],
        contains('Référence à reconfirmer'),
      );
    });

    test('importer le registre vierge : 0 fiche, 0 problème, toutes les lignes ignorées', () {
      final r = importValidationCsv(
        csv,
        knownVersions: validationKnownVersions(),
      );
      expect(r.records, isEmpty);
      expect(r.problems, isEmpty);
      expect(r.skippedBlank, rows.length - 1);
    });

    test('remplir une seule ligne du registre : une seule fiche, les 260 autres restent non validées', () {
      final lines = csv.split('\n');
      final i = lines.indexWhere((l) => l.startsWith('"IONO_FIB4_001"'));
      expect(i, greaterThan(0));
      final cells = parseCsv('${lines.first}\n${lines[i]}').last;
      final h = rows.first;
      void set(String c, String v) => cells[h.indexOf(c)] = v;
      set('date', '04/10/2026');
      set('scope', 'formule, constantes, unités');
      set('sources_reviewed', 'Sterling 2006');
      set('independent_cases', '3');
      set('sheet_ref', 'FV-2026-010');
      set('decision', 'approuvé');
      final filled = [
        lines.first,
        cells.map((c) => '"${c.replaceAll('"', '""')}"').join(';'),
      ].join('\n');
      final r = importValidationCsv(
        filled,
        knownVersions: validationKnownVersions(),
      );
      expect(r.problems, isEmpty);
      expect(r.records.single.itemId, 'IONO_FIB4_001');
      expect(
        validationStatusFor('IONO_FIB4_001', 1, records: r.records),
        EquationStatus.validated,
      );
      expect(
        validationStatusFor('IONO_APRI_001', 1, records: r.records),
        EquationStatus.notValidated,
      );
    });
  });

  group('génération du fichier Dart', () {
    test(
      'contient les champs et échappe apostrophes, antislash et sauts de ligne',
      () {
        final r = _import([
          _row(sources: "l'article \\ 2021\nligne 2", scope: 'portée'),
        ]);
        final dart = generateValidationDart(r.records);
        expect(dart, contains('FICHIER GÉNÉRÉ'));
        expect(dart, contains("itemId: 'METAB_BMI_001'"));
        expect(dart, contains('validatedOn: DateTime.utc(2026, 10, 4)'));
        expect(
          dart,
          contains("sourcesReviewed: 'l\\'article \\\\ 2021 ligne 2'"),
        );
        expect(dart, contains('independentCases: 2'));
        expect(dart, contains('decision: ValidationDecision.approved'));
      },
    );

    test('le fichier généré compile : liste non constante (DateTime n\'est pas constant)', () {
      // Garde-fou : une première version générait « const List » et ne compilait pas
      // dès qu'une fiche existait (DateTime.utc n'est pas une expression constante).
      final dart = generateValidationDart(_import([_row()]).records);
      expect(
        dart,
        contains('final List<ValidationRecord> generatedValidationRecords = ['),
      );
      expect(dart, isNot(contains('const List<ValidationRecord>')));
      expect(dart, isNot(contains('const ValidationRecord(')));
      expect(
        RegExp(r'^\s+ValidationRecord\($', multiLine: true).hasMatch(dart),
        isTrue,
      );
    });

    test('aucune fiche : liste vide valide', () {
      expect(
        generateValidationDart(const []),
        contains('generatedValidationRecords = ['),
      );
    });
  });

  test('le fichier de données livré est vide : aucune validation enregistrée à ce jour', () {
    expect(validationRecords, isEmpty);
  });
}
