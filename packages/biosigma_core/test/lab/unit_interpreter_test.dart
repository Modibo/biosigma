// T-SAI-002 : unités saisies librement (« uL », « microlitre », « mg/100 mL », « mg/dl »…).
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  UnitInterpretation i(String s) => UnitInterpreter.interpret(s);

  group('écritures reconnues, avec trace', () {
    for (final (input, symbol) in const [
      ('uL', 'µL'),
      ('microlitre', 'µL'),
      ('microlitres', 'µL'),
      ('mg/100 mL', 'mg/100mL'),
      ('mg/dl', 'mg/dL'),
      ('umol/l', 'µmol/L'),
      ('MG/DL', 'mg/dL'),
      ('MEQ/L', 'mEq/L'),
      ('mmol / l', 'mmol/L'),
      ('millimole par litre', 'mmol/L'),
      ('milligramme par décilitre', 'mg/dL'),
      ('milligrammes par decilitre', 'mg/dL'),
      ('µmol/l', 'µmol/L'),
      ('ug/ml', 'µg/mL'),
    ]) {
      test('« $input » → « $symbol »', () {
        final r = i(input);
        expect(r.recognized, isTrue, reason: input);
        expect(r.unit!.symbol, symbol);
        expect(r.suggestions, isEmpty);
      });
    }

    test('une écriture exacte n\'a aucune note', () {
      for (final s in ['mmol/L', 'mg/dL', 'µL', 'U/L', 'mmHg', '°C']) {
        final r = i(s);
        expect(r.recognized, isTrue, reason: s);
        expect(r.notes, isEmpty, reason: s);
        expect(r.cautions, isEmpty, reason: s);
      }
    });

    test('toute réécriture est tracée (la casse corrigée est à confirmer)', () {
      final r = i('mg/dl');
      expect(r.rewritten, isTrue);
      expect(r.notes.single, contains('casse corrigée'));
      expect(r.notes.single, contains('mg/dL'));
    });
  });

  group('ambiguïtés : jamais de supposition silencieuse', () {
    test('« G/L » est valide (milliards de cellules/L) mais avertit qu\'il ne désigne pas g/L', () {
      final r = i('G/L');
      expect(r.recognized, isTrue);
      expect(r.unit!.dimension, LabDimension.cellConcentration);
      expect(r.cautions.single, contains('g/L'));
    });

    test('« g/L » : aucune mise en garde', () {
      final r = i('g/L');
      expect(r.unit!.dimension, LabDimension.massConcentration);
      expect(r.cautions, isEmpty);
    });

    test('« Mmol/L » (méga) n\'est pas reconnue : question, proposition « mmol/L »', () {
      final r = i('Mmol/L');
      expect(r.recognized, isFalse);
      expect(r.cautions.single, contains('méga'));
      expect(r.suggestions, ['mmol/L']);
    });

    test('« u/l » n\'est pas devinée : proposition « U/L »', () {
      final r = i('u/l');
      expect(r.recognized, isFalse);
      expect(r.suggestions, contains('U/L'));
    });

    test('unité inconnue : pas de conversion, propositions proches', () {
      final r = i('mmoll');
      expect(r.recognized, isFalse);
      expect(r.suggestions, contains('mmol/L'));
      expect(i('zzzz').suggestions, isEmpty);
      expect(i('').recognized, isFalse);
    });
  });

  group('séparation valeur / unité', () {
    test('cas courants', () {
      for (final (text, number, unit) in const [
        ('88 umol/l', '88', 'umol/l'),
        ('1,5g/dL', '1,5', 'g/dL'),
        ('0.7 mg/dl', '0.7', 'mg/dl'),
        ('1 000 mg/dL', '1 000', 'mg/dL'),
        ('1.234,5 mmol/L', '1.234,5', 'mmol/L'),
        ('5000 /µL', '5000', '/µL'),
        ('37 °C', '37', '°C'),
        ('  12   mmol / L ', '12', 'mmol / L'),
      ]) {
        final r = UnitInterpreter.splitQuantity(text);
        expect(r, isNotNull, reason: text);
        expect(r!.number, number, reason: text);
        expect(r.unit, unit, reason: text);
      }
    });

    test('sans unité ou sans nombre : null', () {
      expect(UnitInterpreter.splitQuantity('12'), isNull);
      expect(UnitInterpreter.splitQuantity('mmol/L'), isNull);
      expect(UnitInterpreter.splitQuantity(''), isNull);
    });
  });

  test('l\'unité interprétée convertit exactement comme l\'écriture canonique', () {
    final a = calculateConversion(value: 100, fromUnit: i('mg/dl').unit!.symbol, toUnit: 'g/L');
    final b = calculateConversion(value: 100, fromUnit: 'mg/dL', toUnit: 'g/L');
    expect(a.values.first.value, b.values.first.value);
    expect(a.values.first.value, closeTo(1.0, 1e-12));
  });
}
