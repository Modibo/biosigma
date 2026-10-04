import '../models/errors.dart';
import '../rounding.dart';

/// Grandeur physique d'une unité de laboratoire.
///
/// Une concentration est une quantité (masse, quantité de matière,
/// équivalents ou activité catalytique) rapportée à un volume ; un débit
/// d'excrétion est une quantité rapportée à un temps.
enum LabDimension {
  mass('masse'),
  volume('volume'),
  amount('quantité de matière'),
  equivalent('équivalents'),
  massConcentration('concentration massique'),
  molarConcentration('concentration molaire'),
  equivalentConcentration('concentration en équivalents'),
  catalytic('activité catalytique'),
  catalyticConcentration('concentration d\'activité catalytique'),
  massRate('excrétion massique (par temps)'),
  amountRate('excrétion molaire (par temps)'),
  equivalentRate('excrétion en équivalents (par temps)'),
  flow('débit (volume par temps)'),
  bsaClearance('clairance rapportée à la surface corporelle'),
  pressure('pression'),
  temperature('température'),
  cellConcentration('numération cellulaire'),
  fraction('fraction'),
  osmolality('osmolalité'),
  length('longueur'),
  time('temps');

  const LabDimension(this.label);
  final String label;
}

/// Unité reconnue : symbole canonique, grandeur, et conversion affine vers
/// l'unité de base de la grandeur : `base = valeur × factorToBase + offsetToBase`
/// (le décalage n'est non nul que pour les températures).
///
/// Bases : g, L, mol, Eq, kat, g/L, mol/L, Eq/L, kat/L, g/s, mol/s, Eq/s,
/// L/s, Pa, K, cellules/L, fraction (1), osmol/kg, m, s.
class LabUnit {
  const LabUnit(this.symbol, this.dimension, this.factorToBase, {this.offsetToBase = 0});

  final String symbol;
  final LabDimension dimension;
  final double factorToBase;
  final double offsetToBase;

  /// Quantité rapportée à un volume (inclut l'activité catalytique).
  bool get isConcentration =>
      dimension == LabDimension.massConcentration ||
      dimension == LabDimension.molarConcentration ||
      dimension == LabDimension.equivalentConcentration ||
      dimension == LabDimension.catalyticConcentration;

  /// Nature de la quantité (sans le volume ni le temps) : `mass`, `amount`,
  /// `equivalent`, `catalytic` ; pour les autres grandeurs, la grandeur elle-même.
  LabDimension get quantityKind => switch (dimension) {
        LabDimension.massConcentration || LabDimension.massRate => LabDimension.mass,
        LabDimension.molarConcentration || LabDimension.amountRate => LabDimension.amount,
        LabDimension.equivalentConcentration || LabDimension.equivalentRate =>
          LabDimension.equivalent,
        LabDimension.catalyticConcentration => LabDimension.catalytic,
        _ => dimension,
      };

  /// Famille de conversion : deux unités de familles différentes ne sont
  /// jamais comparables. Au sein des familles `quantity`, `concentration` et
  /// `rate`, la nature (masse, mol, éq) peut changer avec une masse molaire
  /// ou une valence.
  String get family => switch (dimension) {
        LabDimension.mass || LabDimension.amount || LabDimension.equivalent => 'quantity',
        LabDimension.massConcentration ||
        LabDimension.molarConcentration ||
        LabDimension.equivalentConcentration =>
          'concentration',
        LabDimension.massRate ||
        LabDimension.amountRate ||
        LabDimension.equivalentRate =>
          'rate',
        _ => dimension.name,
      };

  @override
  String toString() => symbol;
}

/// Unités de laboratoire, traditionnelles et SI.
///
/// Tous les facteurs sont des **définitions** (préfixes SI, définition de la
/// minute, de l'unité enzymatique, du mmHg, du pouce…) : aucune constante
/// scientifique mesurée n'y figure. Toute conversion qui change de nature
/// de grandeur (masse ↔ quantité de matière ↔ équivalents) exige une masse
/// molaire ou une valence — saisie, ou issue de la base d'analytes
/// (`analyte_base.dart`) — voir `convert.dart`.
class LabUnits {
  LabUnits._();

  // Préfixes SI (symbole → puissance de dix).
  static const Map<String, double> _prefix = {
    'k': 1e3, '': 1.0, 'd': 1e-1, 'c': 1e-2, 'm': 1e-3, 'µ': 1e-6, 'n': 1e-9, 'p': 1e-12, 'f': 1e-15,
  };
  static const Map<String, List<String>> _allowedPrefixes = {
    'mol': ['', 'm', 'µ', 'n', 'p', 'f'],
    'Eq': ['', 'm', 'µ'],
    'g': ['k', '', 'm', 'µ', 'n', 'p', 'f'],
    'L': ['', 'd', 'c', 'm', 'µ', 'n', 'p'],
    'kat': ['', 'm', 'µ', 'n', 'p'],
    'U': ['', 'm', 'k'],
  };
  static const Map<String, LabDimension> _baseDimension = {
    'mol': LabDimension.amount,
    'Eq': LabDimension.equivalent,
    'g': LabDimension.mass,
    'L': LabDimension.volume,
    'kat': LabDimension.catalytic,
    'U': LabDimension.catalytic,
  };

  /// Facteur de l'unité enzymatique en katal : 1 U = 1 µmol/min = 1/60 µkat
  /// (définition).
  static const double _katPerU = 1e-6 / 60;

  // Unités à facteur propre (définitions), clé = symbole canonique.
  // Pression en Pa : 1 mmHg = 133,322387415 Pa (définition conventionnelle),
  // 1 atm = 101325 Pa, 1 Torr = 101325/760 Pa, 1 cmH2O = 98,0665 Pa.
  static const Map<String, (LabDimension, double)> _special = {
    // pression
    'Pa': (LabDimension.pressure, 1), 'hPa': (LabDimension.pressure, 100),
    'kPa': (LabDimension.pressure, 1000), 'mmHg': (LabDimension.pressure, 133.322387415),
    'Torr': (LabDimension.pressure, 101325 / 760), 'bar': (LabDimension.pressure, 1e5),
    'mbar': (LabDimension.pressure, 100), 'atm': (LabDimension.pressure, 101325),
    'cmH2O': (LabDimension.pressure, 98.0665),
    // numération cellulaire (par litre)
    '/L': (LabDimension.cellConcentration, 1), '/dL': (LabDimension.cellConcentration, 10),
    '/mL': (LabDimension.cellConcentration, 1e3), '/µL': (LabDimension.cellConcentration, 1e6),
    '/mm³': (LabDimension.cellConcentration, 1e6),
    'G/L': (LabDimension.cellConcentration, 1e9), '×10⁹/L': (LabDimension.cellConcentration, 1e9),
    'T/L': (LabDimension.cellConcentration, 1e12), '×10¹²/L': (LabDimension.cellConcentration, 1e12),
    '×10⁶/mL': (LabDimension.cellConcentration, 1e9), '×10³/µL': (LabDimension.cellConcentration, 1e9),
    '×10⁶/µL': (LabDimension.cellConcentration, 1e12), '×10³/mm³': (LabDimension.cellConcentration, 1e9),
    'K/µL': (LabDimension.cellConcentration, 1e9), 'M/µL': (LabDimension.cellConcentration, 1e12),
    // fraction
    '%': (LabDimension.fraction, 0.01), 'L/L': (LabDimension.fraction, 1),
    // osmolalité (osmol/kg ; 1 mmol/kg de particules = 1 mOsm/kg)
    'Osm/kg': (LabDimension.osmolality, 1), 'mOsm/kg': (LabDimension.osmolality, 1e-3),
    'mmol/kg': (LabDimension.osmolality, 1e-3),
    // longueur (1 in = 0,0254 m ; 1 ft = 0,3048 m : définitions)
    'm': (LabDimension.length, 1), 'cm': (LabDimension.length, 1e-2), 'mm': (LabDimension.length, 1e-3),
    'µm': (LabDimension.length, 1e-6), 'in': (LabDimension.length, 0.0254), 'ft': (LabDimension.length, 0.3048),
    // temps
    's': (LabDimension.time, 1), 'ms': (LabDimension.time, 1e-3), 'min': (LabDimension.time, 60),
    'h': (LabDimension.time, 3600), 'd': (LabDimension.time, 86400), '24h': (LabDimension.time, 86400),
    // clairance rapportée à 1,73 m² (base : mL/min/1,73 m²)
    'mL/min/1.73m²': (LabDimension.bsaClearance, 1),
    'mL/s/1.73m²': (LabDimension.bsaClearance, 60),
    // masses non métriques (1 lb = 453,59237 g ; 1 oz = 28,349523125 g : définitions)
    'lb': (LabDimension.mass, 453.59237), 'oz': (LabDimension.mass, 28.349523125),
    // écritures traditionnelles de concentrations massiques (base g/L)
    'mg%': (LabDimension.massConcentration, 0.01), 'g%': (LabDimension.massConcentration, 10),
    'µg%': (LabDimension.massConcentration, 1e-5),
    'g/100mL': (LabDimension.massConcentration, 10), 'mg/100mL': (LabDimension.massConcentration, 0.01),
  };

  static const Map<String, LabUnit> _temperatures = {
    'K': LabUnit('K', LabDimension.temperature, 1),
    '°C': LabUnit('°C', LabDimension.temperature, 1, offsetToBase: 273.15),
    // °F → K : (F + 459,67) × 5/9
    '°F': LabUnit('°F', LabDimension.temperature, 5 / 9, offsetToBase: 459.67 * 5 / 9),
  };

  // Écritures acceptées → symbole canonique : « u »/« μ » → « µ », « eq » →
  // « Eq », « UI »/« IU » → « U » (unité enzymatique), exposants écrits ^.
  static String _normalize(String raw) {
    var t = raw.trim().replaceAll('μ', 'µ');
    t = t.replaceFirst(RegExp(r'^u(?=[a-zA-Z])'), 'µ').replaceAll('/u', '/µ');
    t = t.replaceAllMapped(RegExp(r'eq(?=/|$)'), (_) => 'Eq');
    t = t.replaceAllMapped(RegExp(r'(^|/)(m|k)?(IU|UI)(?=/|$)'), (m) => '${m[1]}${m[2] ?? ''}U');
    t = t
        .replaceAll('x10^9/L', '×10⁹/L')
        .replaceAll('×10^9/L', '×10⁹/L')
        .replaceAll('x10^12/L', '×10¹²/L')
        .replaceAll('×10^12/L', '×10¹²/L')
        .replaceAll('/mm3', '/mm³')
        .replaceAll('degC', '°C')
        .replaceAll('degF', '°F');
    return t;
  }

  static LabUnit? _parseSimple(String symbol) {
    final special = _special[symbol];
    if (special != null) return LabUnit(symbol, special.$1, special.$2);
    final temp = _temperatures[symbol];
    if (temp != null) return temp;
    for (final base in ['mol', 'Eq', 'kat', 'g', 'L', 'U']) {
      if (!symbol.endsWith(base)) continue;
      final prefix = symbol.substring(0, symbol.length - base.length);
      if (!_allowedPrefixes[base]!.contains(prefix)) continue;
      final dim = _baseDimension[base]!;
      final factor = base == 'U' ? _prefix[prefix]! * _katPerU : _prefix[prefix]!;
      return LabUnit(symbol, dim, factor);
    }
    return null;
  }

  /// Reconnaît un symbole (`mg`, `µL`, `mmol/L`, `mg/dL`, `U/L`, `mmHg`,
  /// `×10⁹/L`, `mg/24h`…). Accepte « u » comme écriture de « µ » (`uL`,
  /// `ug/mL`). Renvoie `null` si le symbole n'est pas reconnu : jamais de
  /// supposition.
  static LabUnit? parse(String raw) {
    final text = _normalize(raw);
    if (text.isEmpty) return null;
    final whole = _special[text];
    if (whole != null) return LabUnit(text, whole.$1, whole.$2);
    final temp = _temperatures[text];
    if (temp != null) return temp;

    final parts = text.split('/');
    if (parts.length == 1) return _parseSimple(text);
    if (parts.length != 2) return null;
    final numerator = _parseSimple(parts[0]);
    final denominator = _parseSimple(parts[1]);
    if (numerator == null || denominator == null) return null;

    if (denominator.dimension == LabDimension.volume) {
      final dimension = switch (numerator.dimension) {
        LabDimension.mass => LabDimension.massConcentration,
        LabDimension.amount => LabDimension.molarConcentration,
        LabDimension.equivalent => LabDimension.equivalentConcentration,
        LabDimension.catalytic => LabDimension.catalyticConcentration,
        _ => null,
      };
      if (dimension == null) return null;
      return LabUnit(text, dimension, numerator.factorToBase / denominator.factorToBase);
    }
    if (denominator.dimension == LabDimension.time) {
      final dimension = switch (numerator.dimension) {
        LabDimension.mass => LabDimension.massRate,
        LabDimension.amount => LabDimension.amountRate,
        LabDimension.equivalent => LabDimension.equivalentRate,
        LabDimension.volume => LabDimension.flow,
        _ => null,
      };
      if (dimension == null) return null;
      return LabUnit(text, dimension, numerator.factorToBase / denominator.factorToBase);
    }
    return null;
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
  static const List<String> masses = ['kg', 'g', 'mg', 'µg', 'ng', 'pg', 'fg', 'lb', 'oz'];
  static const List<String> volumes = ['L', 'dL', 'cL', 'mL', 'µL', 'nL', 'pL'];
  static const List<String> amounts = ['mol', 'mmol', 'µmol', 'nmol', 'pmol', 'fmol'];
  static const List<String> equivalents = ['Eq', 'mEq', 'µEq'];
  static const List<String> massConcentrations = [
    'g/L', 'mg/L', 'µg/L', 'ng/L', 'pg/L', 'g/dL', 'mg/dL', 'µg/dL', 'ng/dL', 'g/mL', 'mg/mL', 'µg/mL',
    'ng/mL', 'pg/mL', 'mg%', 'g%',
  ];
  static const List<String> molarConcentrations = [
    'mol/L', 'mmol/L', 'µmol/L', 'nmol/L', 'pmol/L', 'fmol/L', 'mmol/dL', 'µmol/dL', 'mmol/mL',
    'nmol/mL', 'pmol/mL',
  ];
  static const List<String> equivalentConcentrations = ['Eq/L', 'mEq/L', 'µEq/L', 'mEq/dL', 'mEq/mL'];
  static const List<String> catalytics = ['U', 'mU', 'kU', 'kat', 'mkat', 'µkat', 'nkat'];
  static const List<String> catalyticConcentrations = [
    'U/L', 'kU/L', 'mU/L', 'U/mL', 'mU/mL', 'kat/L', 'mkat/L', 'µkat/L', 'nkat/L', 'µkat/mL',
  ];
  static const List<String> massRates = [
    'g/24h', 'mg/24h', 'µg/24h', 'g/d', 'mg/d', 'g/h', 'mg/h', 'µg/min', 'mg/min',
  ];
  static const List<String> amountRates = ['mol/24h', 'mmol/24h', 'µmol/24h', 'mmol/d', 'µmol/d', 'mmol/h'];
  static const List<String> equivalentRates = ['mEq/24h', 'mEq/d', 'mEq/h'];
  static const List<String> flows = [
    'L/24h', 'mL/24h', 'L/h', 'mL/h', 'L/min', 'mL/min', 'µL/min', 'mL/s', 'L/s',
  ];
  static const List<String> bsaClearances = ['mL/min/1.73m²', 'mL/s/1.73m²'];
  static const List<String> pressures = ['mmHg', 'kPa', 'Pa', 'hPa', 'Torr', 'mbar', 'bar', 'atm', 'cmH2O'];
  static const List<String> temperatures = ['°C', '°F', 'K'];
  static const List<String> cellConcentrations = [
    '×10⁹/L', 'G/L', '/µL', '/mm³', '×10³/µL', 'K/µL', '×10¹²/L', 'T/L', 'M/µL', '×10⁶/mL', '/mL', '/L',
  ];
  static const List<String> fractions = ['%', 'L/L'];
  static const List<String> osmolalities = ['mOsm/kg', 'mmol/kg', 'Osm/kg'];
  static const List<String> lengths = ['m', 'cm', 'mm', 'µm', 'in', 'ft'];
  static const List<String> times = ['s', 'ms', 'min', 'h', 'd'];

  /// Toutes les unités proposées pour les conversions, regroupées par grandeur.
  static const Map<LabDimension, List<String>> offered = {
    LabDimension.mass: masses,
    LabDimension.amount: amounts,
    LabDimension.equivalent: equivalents,
    LabDimension.volume: volumes,
    LabDimension.massConcentration: massConcentrations,
    LabDimension.molarConcentration: molarConcentrations,
    LabDimension.equivalentConcentration: equivalentConcentrations,
    LabDimension.catalytic: catalytics,
    LabDimension.catalyticConcentration: catalyticConcentrations,
    LabDimension.massRate: massRates,
    LabDimension.amountRate: amountRates,
    LabDimension.equivalentRate: equivalentRates,
    LabDimension.flow: flows,
    LabDimension.bsaClearance: bsaClearances,
    LabDimension.pressure: pressures,
    LabDimension.temperature: temperatures,
    LabDimension.cellConcentration: cellConcentrations,
    LabDimension.fraction: fractions,
    LabDimension.osmolality: osmolalities,
    LabDimension.length: lengths,
    LabDimension.time: times,
  };

  /// Familles de conversion proposées dans le menu « Grandeur » : libellé et
  /// unités. Au sein d'une famille, toutes les unités sont comparables
  /// (avec masse molaire / valence quand la nature change).
  static const List<({String key, String label, List<String> units})> families = [
    (key: 'concentration', label: 'Concentration (masse, mol, éq par volume)',
     units: [...massConcentrations, ...molarConcentrations, ...equivalentConcentrations]),
    (key: 'quantity', label: 'Quantité (masse, mol, éq)', units: [...masses, ...amounts, ...equivalents]),
    (key: 'catalyticConcentration', label: 'Activité enzymatique (par volume)', units: catalyticConcentrations),
    (key: 'catalytic', label: 'Activité enzymatique (absolue)', units: catalytics),
    (key: 'cellConcentration', label: 'Numération cellulaire', units: cellConcentrations),
    (key: 'pressure', label: 'Pression (gaz du sang…)', units: pressures),
    (key: 'temperature', label: 'Température', units: temperatures),
    (key: 'fraction', label: 'Fraction (hématocrite…)', units: fractions),
    (key: 'osmolality', label: 'Osmolalité', units: osmolalities),
    (key: 'rate', label: 'Excrétion (par temps : g/24 h, mmol/24 h…)',
     units: [...massRates, ...amountRates, ...equivalentRates]),
    (key: 'bsaClearance', label: 'Clairance rapportée à 1,73 m² (DFG)', units: bsaClearances),
    (key: 'flow', label: 'Débit (volume par temps)', units: flows),
    (key: 'volume', label: 'Volume', units: volumes),
    (key: 'length', label: 'Longueur', units: lengths),
    (key: 'time', label: 'Temps', units: times),
  ];

  /// Voir [RoundingPolicy.decimalsForSignificant] (règle `FMT_ARRONDI_001`).
  static int decimalsForSignificant(double value, {int significant = 4}) =>
      RoundingPolicy.decimalsForSignificant(value, significant: significant);
}
