// Politique de saisie décimale (backlog P0-04, risque R-01, tests T-SAI-001) :
// une saisie ambiguë n'est jamais interprétée avec un facteur 10 ou 1000.
import 'package:biosigma/models/app_settings.dart';
import 'package:biosigma/services/number_format_service.dart';
import 'package:flutter_test/flutter_test.dart';

double? _c(String s) => NumberFormatService.parse(s, DecimalSeparator.comma);
double? _p(String s) => NumberFormatService.parse(s, DecimalSeparator.dot);

void main() {
  group('mode virgule (défaut)', () {
    test('la virgule est le séparateur décimal', () {
      expect(_c('1,5'), 1.5);
      expect(_c('0,7'), 0.7);
      expect(_c('140'), 140);
      expect(_c('  12,25 '), 12.25);
    });

    test('un point isolé est refusé (plus de facteur 10 silencieux)', () {
      for (final s in ['1.5', '0.7', '70.25', '1.234', '12.3456']) {
        expect(_c(s), isNull, reason: s);
        expect(NumberFormatService.ambiguityMessage(s, DecimalSeparator.comma), isNotNull, reason: s);
      }
    });

    test('un point de milliers non ambigu reste accepté', () {
      expect(_c('1.234.567'), 1234567);
      expect(_c('1.234,5'), 1234.5);
    });

    test('un point mal placé est refusé', () {
      for (final s in ['1,5.2', '12.34.5', '.5', '1.2345,5']) {
        expect(_c(s), isNull, reason: s);
      }
    });

    test('les espaces (insécables compris) sont des séparateurs de milliers', () {
      expect(_c('1 500'), 1500);
      expect(_c('1 500,5'), 1500.5);
      expect(_c('1 500'), 1500);
    });
  });

  group('mode point', () {
    test('le point est le séparateur décimal', () {
      expect(_p('1.5'), 1.5);
      expect(_p('0.7'), 0.7);
    });

    test('une virgule isolée est refusée (« 1,5 » ne vaut plus 15)', () {
      for (final s in ['1,5', '0,7', '1,234']) {
        expect(_p(s), isNull, reason: s);
      }
    });

    test('une virgule de milliers non ambiguë reste acceptée', () {
      expect(_p('1,234,567'), 1234567);
      expect(_p('1,234.5'), 1234.5);
    });
  });

  group('cas communs', () {
    test('vide ou non numérique renvoie null sans message d\'ambiguïté', () {
      expect(_c(''), isNull);
      expect(_c('   '), isNull);
      expect(_c(','), isNull);
      expect(NumberFormatService.ambiguityMessage('', DecimalSeparator.comma), isNull);
      expect(NumberFormatService.ambiguityMessage('1,5', DecimalSeparator.comma), isNull);
    });

    test('le message nomme le séparateur attendu et un exemple', () {
      final m = NumberFormatService.ambiguityMessage('1.5', DecimalSeparator.comma)!;
      expect(m, contains('la virgule'));
      expect(m, contains('1,5'));
      final q = NumberFormatService.ambiguityMessage('1,5', DecimalSeparator.dot)!;
      expect(q, contains('le point'));
      expect(q, contains('1.5'));
    });

    test('format reste inchangé', () {
      expect(NumberFormatService.format(1.5, DecimalSeparator.comma, precision: 2), '1,50');
      expect(NumberFormatService.format(1.5, DecimalSeparator.dot, precision: 2), '1.50');
    });
  });
}
