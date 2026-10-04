// Moteur Martin-Hopkins : testé avec un tableau FICTIF (jamais utilisable
// cliniquement) pour ne vérifier que la mécanique — strates, bornes, erreurs.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

const _fictional = '''
TG_min;100;160
50;4,0;5,0
150;6,0;8,0
''';

void main() {
  final table = MartinHopkinsTable.fromCsv(_fictional);

  test('lecture : 2 lignes de TG × 2 colonnes de non-HDL, virgule décimale acceptée', () {
    expect(table.cellCount, 4);
    expect(table.factorFor(triglyceridesMgDl: 60, nonHdlMgDl: 110), 4.0);
    expect(table.factorFor(triglyceridesMgDl: 60, nonHdlMgDl: 170), 5.0);
    expect(table.factorFor(triglyceridesMgDl: 200, nonHdlMgDl: 110), 6.0);
    expect(table.factorFor(triglyceridesMgDl: 200, nonHdlMgDl: 170), 8.0);
  });

  test('bornes inférieures incluses : TG = 150 est dans la 2e ligne, non-HDL = 160 dans la 2e colonne', () {
    expect(table.factorFor(triglyceridesMgDl: 150, nonHdlMgDl: 160), 8.0);
    expect(table.factorFor(triglyceridesMgDl: 149.99, nonHdlMgDl: 159.99), 4.0);
  });

  test('sous la première borne : facteur introuvable', () {
    expect(table.factorFor(triglyceridesMgDl: 49, nonHdlMgDl: 110), isNull);
    expect(table.factorFor(triglyceridesMgDl: 60, nonHdlMgDl: 99), isNull);
  });

  test('LDL = CT − HDL − TG / F (calcul à la main : 230 − 50 − 200/8 = 155)', () {
    final r = calculateLdlMartinHopkins(
      totalCholesterolMgDl: 230, hdlMgDl: 50, triglyceridesMgDl: 200, table: table,
    );
    expect(r.values.single.value, closeTo(155.0, 1e-12));
    expect(r.echoedInputs['Facteur F (tableau saisi)'], '8.0');
    expect(r.warnings.any((w) => w.message.contains('tableau saisi')), isTrue);
  });

  test('TG au-dessus de la limite saisie : refus ; sans limite : calcul', () {
    expect(
      () => calculateLdlMartinHopkins(
        totalCholesterolMgDl: 230, hdlMgDl: 50, triglyceridesMgDl: 450, table: table,
        maxTriglyceridesMgDl: 400,
      ),
      throwsA(isA<CalculationInputException>()),
    );
    expect(
      calculateLdlMartinHopkins(
        totalCholesterolMgDl: 230, hdlMgDl: 50, triglyceridesMgDl: 450, table: table,
      ).isComplete,
      isTrue,
    );
  });

  test('HDL ≥ cholestérol total ou TG sous la première borne : refus motivé', () {
    expect(
      () => calculateLdlMartinHopkins(
        totalCholesterolMgDl: 100, hdlMgDl: 100, triglyceridesMgDl: 100, table: table,
      ),
      throwsA(isA<CalculationInputException>()),
    );
    expect(
      () => calculateLdlMartinHopkins(
        totalCholesterolMgDl: 230, hdlMgDl: 50, triglyceridesMgDl: 30, table: table,
      ),
      throwsA(isA<CalculationInputException>()),
    );
  });

  group('tableau invalide : message précis', () {
    void bad(String csv, String fragment) => expect(
          () => MartinHopkinsTable.fromCsv(csv),
          throwsA(isA<FormatException>().having((e) => e.message, 'message', contains(fragment))),
        );
    test('cas', () {
      bad('', 'vide');
      bad('TG;100\n', 'vide');
      bad('TG;100;160\n50;4;5;6', '4 colonnes au lieu de 3');
      bad('TG;100;160\n50;4;abc', '« abc »');
      bad('TG;160;100\n50;4;5', 'non-HDL');
      bad('TG;100;160\n150;4;5\n50;4;5', 'TG');
      bad('TG;100;160\n50;4;0', 'strictement positif');
    });
  });
}
