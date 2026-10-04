import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

CalculationResult redCells() => calculateRedCellIndices(
  hemoglobinGdL: 15,
  hematocritPercent: 45,
  rbcTeraL: 5,
);

CalculationReport report(
  CalculationResult r, {
  bool comma = true,
  String? reference,
  List<ReportSection> extra = const [],
}) => CalculationReport(
  result: r,
  generatedAt: '04/10/2026 14:30',
  appVersion: '1.15.0',
  decimalComma: comma,
  reference: reference,
  extraSections: extra,
);

void main() {
  group('texte brut', () {
    test('contient équation, version, statut, entrées, résultats, sources, limites et avertissement', () {
      final t = report(redCells()).toPlainText();
      expect(
        t,
        contains('BioSigma — Constantes érythrocytaires (VGM, TCMH, CCMH)'),
      );
      expect(t, contains('Édité le 04/10/2026 14:30 · application 1.15.0'));
      expect(
        t,
        contains(
          'Identifiant : HEMATO_RED_CELL_INDICES_001 · version 1 · statut de validation : NON VALIDÉ',
        ),
      );
      expect(t, contains('Formule : VGM (fL) = Ht (%) × 10 / GR'));
      expect(t, contains('DONNÉES UTILISÉES'));
      expect(t, contains('Hémoglobine : 15.0 g/dL'));
      expect(t, contains('VGM : 90,0 fL'));
      expect(t, contains('TCMH : 30,0 pg'));
      expect(t, contains('CCMH : 33,3 g/dL'));
      expect(t, contains('SOURCES'));
      expect(t, contains('LIMITES D\'EMPLOI'));
      expect(t, contains(CalculationReport.disclaimer));
      expect(t, contains('PRÉCISIONS ANALYTIQUES ET LIMITES'));
      expect(t, isNot(contains('RECOMMANDATIONS PUBLIÉES')));
    });

    test('virgule ou point décimal selon le réglage', () {
      expect(
        report(redCells(), comma: true).toPlainText(),
        contains('VGM : 90,0 fL'),
      );
      expect(
        report(redCells(), comma: false).toPlainText(),
        contains('VGM : 90.0 fL'),
      );
    });

    test('référence libre : affichée si non vide, absente sinon', () {
      expect(
        report(redCells(), reference: 'ECH-0042').toPlainText(),
        contains('Référence : ECH-0042'),
      );
      expect(
        report(redCells(), reference: '   ').toPlainText(),
        isNot(contains('Référence :')),
      );
      expect(report(redCells()).toPlainText(), isNot(contains('Référence :')));
    });

    test('alertes séparées des repères ; résultat incomplet signalé', () {
      final r = calculateAbsoluteLeukocyteCounts(
        wbcGL: 8,
        neutrophilsPercent: 70,
        bandsPercent: 20,
        lymphocytesPercent: 30,
      );
      final t = report(r).toPlainText();
      expect(t, contains('ALERTES'));
      expect(t, contains('[BLOQUANT]'));
      expect(
        t.indexOf('ALERTES'),
        lessThan(t.indexOf('PRÉCISIONS ANALYTIQUES')),
      );

      final incomplete = calculateOutOfRangeDilution(
        dilutedResult: 250,
        resultUnit: 'U/L',
        totalFactor: 10,
        linearityMin: 10,
        linearityMax: 200,
      );
      final t2 = report(incomplete).toPlainText();
      expect(t2, contains('RÉSULTATS (calcul incomplet)'));
      expect(t2, contains('non calculé'));
    });

    test('sections supplémentaires reprises', () {
      final t = report(
        redCells(),
        extra: const [
          ReportSection('Étapes', ['Étape 1 : 100 µL']),
        ],
      ).toPlainText();
      expect(t, contains('ÉTAPES'));
      expect(t, contains('Étape 1 : 100 µL'));
    });

    test('aucune identité de patient : le rapport ne demande ni ne contient de champ nominatif', () {
      final t = report(redCells()).toPlainText().toLowerCase();
      for (final word in [
        'nom du patient',
        'date de naissance',
        'n° de sécurité',
        'adresse',
      ]) {
        expect(t.contains(word), isFalse, reason: word);
      }
      expect(t, contains('aucune identité de patient'));
    });
  });

  group('HTML', () {
    test('document complet et imprimable', () {
      final h = report(redCells()).toHtml();
      expect(h, startsWith('<!doctype html>'));
      expect(h, contains('<html lang="fr">'));
      expect(
        h,
        contains(
          '<title>BioSigma — Constantes érythrocytaires (VGM, TCMH, CCMH)</title>',
        ),
      );
      expect(h, contains('@page{size:A4'));
      expect(h, contains('<h2>Données utilisées</h2>'));
      expect(h, contains('90,0 fL'));
      expect(h, contains('HEMATO_RED_CELL_INDICES_001'));
    });

    test('rien de ce qui est saisi n\'est interprété comme du HTML (anti-injection)', () {
      const evil =
          '<script>alert(1)</script><img src=x onerror=alert(2)> & "q" \'s\'';
      final h = report(
        redCells(),
        reference: evil,
        extra: const [
          ReportSection(evil, [evil]),
        ],
      ).toHtml();
      expect(h, isNot(contains('<script>')));
      expect(h, isNot(contains('<img')));
      expect(h, contains('&lt;script&gt;alert(1)&lt;/script&gt;'));
      expect(h, contains('&amp;'));
      expect(h, contains('&quot;q&quot;'));
      expect(h, contains('&#39;s&#39;'));
    });

    test('escapeHtml', () {
      expect(
        CalculationReport.escapeHtml('<a href="x">&\'</a>'),
        '&lt;a href=&quot;x&quot;&gt;&amp;&#39;&lt;/a&gt;',
      );
    });

    test('le saut de ligne de la formule devient <br>', () {
      final r = calculateConversion(
        value: 1,
        fromUnit: 'mg/dL',
        toUnit: 'mg/L',
      );
      expect(report(r).toHtml(), contains('<br>'));
    });

    test('alertes en HTML avec leur gravité', () {
      final r = calculateAbsoluteLeukocyteCounts(
        wbcGL: 8,
        neutrophilsPercent: 70,
        bandsPercent: 20,
        lymphocytesPercent: 30,
      );
      final h = report(r).toHtml();
      expect(h, contains('<h2>Alertes</h2>'));
      expect(h, contains('Bloquant'));
    });
  });

  test('chaque équation du catalogue produit un rapport sans plantage (entrées du golden non requises : métadonnées seules)', () {
    for (final m in CalculatorCatalog.all) {
      final r = CalculationResult(
        formula: m,
        echoedInputs: const {'x': '1'},
        values: const [
          ResultValue(
            label: 'Résultat',
            value: 1.2345,
            unit: 'u',
            precision: 2,
          ),
        ],
      );
      final text = report(r).toPlainText();
      expect(text, contains(m.name), reason: m.id);
      expect(text, contains('statut de validation'), reason: m.id);
      expect(report(r).toHtml(), contains('</html>'), reason: m.id);
    }
  });
}
