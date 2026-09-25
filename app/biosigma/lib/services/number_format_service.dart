import '../models/app_settings.dart';

/// Formatage et analyse de nombres décimaux selon le réglage
/// virgule/point de l'utilisateur, avec gestion explicite et non ambiguë
/// des séparateurs de milliers.
///
/// Convention retenue : le séparateur décimal choisi dans les réglages est
/// TOUJOURS le séparateur décimal ; l'autre caractère (point ou virgule)
/// ainsi que les espaces (y compris insécables) rencontrés dans la saisie
/// sont TOUJOURS traités comme des séparateurs de milliers et supprimés.
/// Ce choix élimine toute ambiguïté (ex. en mode virgule, "1.234,5"
/// vaut 1234,5 ; en mode point, "1,234.5" vaut 1234.5).
class NumberFormatService {
  NumberFormatService._();

  /// Retourne `null` si la saisie est vide, non numérique, ou si le
  /// résultat n'est pas un nombre fini (NaN/infini interdits).
  static double? parse(String input, DecimalSeparator separator) {
    var text = input.trim();
    if (text.isEmpty) return null;

    text = text.replaceAll(' ', '').replaceAll(' ', '');

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
    final text = value.toStringAsFixed(precision);
    return separator == DecimalSeparator.comma ? text.replaceAll('.', ',') : text;
  }
}
