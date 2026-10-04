import '../models/errors.dart';
import '../rounding.dart';

/// Grandeur physique d'une unité de laboratoire.
///
/// Une concentration est une quantité (masse, quantité de matière ou
/// équivalents) rapportée à un volume.
enum LabDimension {
  mass('masse'),
  volume('volume'),
  amount('quantité de matière'),
  equivalent('équivalents'),
  massConcentration('concentration massique'),
  molarConcentration('concentration molaire'),
  equivalentConcentration("concentration en équivalents");

  const LabDimension(this.label);
  final String label;
}

/// Unité reconnue : symbole canonique, grandeur et facteur vers l'unité de
/// base de la grandeur (g, L, mol, Eq, g/L, mol/L, Eq/L).
class LabUnit {
  const LabUnit(this.symbol, this.dimension, this.factorToBase);

  final String symbol;
  final LabDimension dimension;
  final double factorToBase;

  bool get isConcentration =>
      dimension == LabDimension.massConcentration ||
      dimension == LabDimension.molarConcentration ||
      dimension == LabDimension.equivalentConcentration;

  /// Nature de la quantité (sans le volume) : `mass`, `amount` ou `equivalent`.
  LabDimension get quantityKind => switch (dimension) {
        LabDimension.massConcentration => LabDimension.mass,
        LabDimension.molarConcentration => LabDimension.amount,
        LabDimension.equivalentConcentration => LabDimension.equivalent,
        _ => dimension,
      };

  @override
  String toString() => symbol;
}

/// Unités de laboratoire fondées uniquement sur les préfixes du Système
/// international (puissances de dix) : aucune constante scientifique n'y
/// figure. Toute conversion qui change de nature de grandeur (masse ↔
/// quantité de matière ↔ équivalents) exige une masse molaire ou une
/// valence fournie par l'utilisateur — voir `convert.dart`.
class LabUnits {
  LabUnits._();

  // Préfixes SI autorisés par unité de base (symbole → puissance de dix).
  static const Map<String, double> _prefix = {
    'k': 1e3, '': 1.0, 'd': 1e-1, 'm': 1e-3, 'µ': 1e-6, 'n': 1e-9, 'p': 1e-12,
  };
  static const Map<String, List<String>> _allowedPrefixes = {
    'mol': ['', 'm', 'µ', 'n', 'p'],
    'Eq': ['', 'm', 'µ'],
    'g': ['k', '', 'm', 'µ', 'n', 'p'],
    'L': ['', 'd', 'm', 'µ', 'n'],
  };
  static const Map<String, LabDimension> _baseDimension = {
    'mol': LabDimension.amount,
    'Eq': LabDimension.equivalent,
    'g': LabDimension.mass,
    'L': LabDimension.volume,
  };

  // « u » et « μ » (grec) s'écrivent « µ » ; « eq » s'écrit « Eq ».
  static String _normalize(String raw) => raw
      .trim()
      .replaceAll('μ', 'µ')
      .replaceFirst(RegExp(r'^u'), 'µ')
      .replaceAll('/u', '/µ')
      .replaceAllMapped(RegExp(r'eq(?=/|$)'), (_) => 'Eq');

  static LabUnit? _parseSimple(String symbol) {
    for (final base in ['mol', 'Eq', 'g', 'L']) {
      if (!symbol.endsWith(base)) continue;
      final prefix = symbol.substring(0, symbol.length - base.length);
      if (!_allowedPrefixes[base]!.contains(prefix)) continue;
      return LabUnit(symbol, _baseDimension[base]!, _prefix[prefix]!);
    }
    return null;
  }

  /// Reconnaît un symbole (`mg`, `µL`, `mmol/L`, `mg/dL`…). Accepte « u »
  /// comme écriture de « µ » (`uL`, `ug/mL`). Renvoie `null` si le symbole
  /// n'est pas reconnu : jamais de supposition.
  static LabUnit? parse(String raw) {
    final text = _normalize(raw);
    if (text.isEmpty) return null;
    final parts = text.split('/');
    if (parts.length == 1) return _parseSimple(text);
    if (parts.length != 2) return null;
    final numerator = _parseSimple(parts[0]);
    final denominator = _parseSimple(parts[1]);
    if (numerator == null || denominator == null) return null;
    if (denominator.dimension != LabDimension.volume) return null;
    final dimension = switch (numerator.dimension) {
      LabDimension.mass => LabDimension.massConcentration,
      LabDimension.amount => LabDimension.molarConcentration,
      LabDimension.equivalent => LabDimension.equivalentConcentration,
      _ => null,
    };
    if (dimension == null) return null;
    return LabUnit(text, dimension, numerator.factorToBase / denominator.factorToBase);
  }

  /// Comme [parse], mais lève une erreur de champ en français.
  static LabUnit require(String raw, String fieldId, String label) {
    final unit = parse(raw);
    if (unit == null) {
      throw CalculationInputException([
        FieldError(fieldId: fieldId, message: 'Unité « $raw » non reconnue pour $label.'),
      ]);
    }
    return unit;
  }

  // Listes proposées dans l'interface (les autres écritures restent
  // acceptées par [parse]).
  static const List<String> masses = ['kg', 'g', 'mg', 'µg', 'ng', 'pg'];
  static const List<String> volumes = ['L', 'dL', 'mL', 'µL', 'nL'];
  static const List<String> amounts = ['mol', 'mmol', 'µmol', 'nmol', 'pmol'];
  static const List<String> equivalents = ['Eq', 'mEq', 'µEq'];
  static const List<String> massConcentrations = [
    'g/L', 'mg/L', 'µg/L', 'ng/L', 'g/dL', 'mg/dL', 'µg/dL', 'mg/mL', 'µg/mL', 'ng/mL', 'pg/mL',
  ];
  static const List<String> molarConcentrations = [
    'mol/L', 'mmol/L', 'µmol/L', 'nmol/L', 'pmol/L',
  ];
  static const List<String> equivalentConcentrations = ['Eq/L', 'mEq/L', 'µEq/L'];

  /// Toutes les unités proposées pour les conversions, regroupées par grandeur.
  static const Map<LabDimension, List<String>> offered = {
    LabDimension.mass: masses,
    LabDimension.amount: amounts,
    LabDimension.equivalent: equivalents,
    LabDimension.volume: volumes,
    LabDimension.massConcentration: massConcentrations,
    LabDimension.molarConcentration: molarConcentrations,
    LabDimension.equivalentConcentration: equivalentConcentrations,
  };

  /// Voir [RoundingPolicy.decimalsForSignificant] (règle `FMT_ARRONDI_001`).
  static int decimalsForSignificant(double value, {int significant = 4}) =>
      RoundingPolicy.decimalsForSignificant(value, significant: significant);

}
