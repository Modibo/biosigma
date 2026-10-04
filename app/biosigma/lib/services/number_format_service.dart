import 'package:biosigma_core/biosigma_core.dart';

import '../models/app_settings.dart';

/// Formatage et analyse de nombres décimaux selon le réglage
/// virgule/point de l'utilisateur.
///
/// Politique de saisie (backlog P0-04, risque R-01) : le séparateur choisi
/// dans les réglages est TOUJOURS le séparateur décimal. L'autre caractère
/// (point ou virgule) n'est accepté comme séparateur de milliers que s'il
/// ne peut PAS être pris pour une décimale, c'est-à-dire dans des groupes
/// de trois chiffres répétés ou suivis d'une partie décimale
/// (« 1.234.567 », « 1.234,5 » en mode virgule). Dans tous les autres cas
/// (« 1.5 », « 0.7 », « 1.234 » en mode virgule), la saisie est REFUSÉE avec
/// un message : une valeur ambiguë n'est jamais interprétée en silence, car
/// elle pourrait être lue avec un facteur 10 ou 1000 d'écart. Les espaces
/// (y compris insécables) sont toujours des séparateurs de milliers.
class NumberFormatService {
  NumberFormatService._();

  static String _normalizeSpaces(String input) =>
      input.trim().replaceAll(' ', '').replaceAll('\u00A0', '').replaceAll('\u202F', '');

  /// Message d'erreur si la saisie contient le séparateur « étranger »
  /// dans un emploi ambigu ; `null` sinon (saisie vide, claire ou invalide
  /// pour une autre raison).
  static String? ambiguityMessage(String input, DecimalSeparator separator) {
    final text = _normalizeSpaces(input);
    final decimal = separator == DecimalSeparator.comma ? ',' : '.';
    final foreign = separator == DecimalSeparator.comma ? '.' : ',';
    if (!text.contains(foreign)) return null;
    if (_isUnambiguousThousands(text, decimal, foreign)) return null;
    final decimalName = separator == DecimalSeparator.comma ? 'la virgule' : 'le point';
    final example = separator == DecimalSeparator.comma ? '1,5' : '1.5';
    return 'Séparateur ambigu : le séparateur décimal choisi est $decimalName '
        '(saisissez $example). Un « $foreign » seul n\'est pas interprété, '
        'pour éviter une erreur d\'un facteur 10. '
        'Le séparateur peut être changé dans Réglages.';
  }

  static bool _isUnambiguousThousands(String text, String decimal, String foreign) {
    final f = RegExp.escape(foreign);
    final d = RegExp.escape(decimal);
    final pattern = RegExp('^\\d{1,3}($f\\d{3})+($d\\d*)?\$');
    if (!pattern.hasMatch(text)) return false;
    final groups = foreign.allMatches(text).length;
    return groups >= 2 || text.contains(decimal);
  }

  /// Retourne `null` si la saisie est vide, non numérique, ambiguë
  /// (voir [ambiguityMessage]) ou si le résultat n'est pas un nombre fini.
  static double? parse(String input, DecimalSeparator separator) {
    var text = _normalizeSpaces(input);
    if (text.isEmpty) return null;
    if (ambiguityMessage(input, separator) != null) return null;

    if (separator == DecimalSeparator.comma) {
      text = text.replaceAll('.', ''); // milliers
      text = text.replaceAll(',', '.'); // décimal -> format Dart
    } else {
      text = text.replaceAll(',', ''); // milliers
    }

    final value = double.tryParse(text);
    if (value == null || value.isNaN || value.isInfinite) return null;
    return value;
  }

  static String format(double value, DecimalSeparator separator, {int precision = 2}) {
    if (!value.isFinite) return '—';
    final text = RoundingPolicy.format(value, precision);
    return separator == DecimalSeparator.comma ? text.replaceAll('.', ',') : text;
  }
}
