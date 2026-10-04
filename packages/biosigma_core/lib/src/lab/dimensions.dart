import 'dart:math' as math;

import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';
import '../validation.dart';
import 'lab_units.dart';

/// Modèle dimensionnel des unités (backlog P1-10) : une unité est un facteur
/// numérique et un vecteur d'exposants sur six grandeurs de base.
///
/// Bases : masse (M, kg), longueur (L, m), temps (T, s), quantité de matière
/// (N, mol), température (Θ, K) et équivalents (E, Eq). Le volume est L³
/// (1 L = 10⁻³ m³). Une unité composée quelconque (mg/dL, mL/min/1,73 m²,
/// µmol/min/L, mg/kg/d, kg/m²…) se lit en un facteur et une dimension : deux
/// unités sont convertibles par un simple facteur si, et seulement si, leurs
/// dimensions sont égales. M, N et E sont des *natures* d'une même quantité :
/// le passage de l'une à l'autre exige une masse molaire (M ↔ N) ou une valence
/// (N ↔ E), toujours saisies, jamais déduites.
class Dim {
  const Dim._(this._e);

  /// Exposants dans l'ordre M, L, T, N, Θ, E.
  final List<int> _e;

  static const List<String> _symbols = ['M', 'L', 'T', 'N', 'Θ', 'E'];

  static const Dim dimensionless = Dim._([0, 0, 0, 0, 0, 0]);
  static const Dim mass = Dim._([1, 0, 0, 0, 0, 0]);
  static const Dim length = Dim._([0, 1, 0, 0, 0, 0]);
  static const Dim time = Dim._([0, 0, 1, 0, 0, 0]);
  static const Dim amount = Dim._([0, 0, 0, 1, 0, 0]);
  static const Dim temperature = Dim._([0, 0, 0, 0, 1, 0]);
  static const Dim equivalent = Dim._([0, 0, 0, 0, 0, 1]);
  static const Dim volume = Dim._([0, 3, 0, 0, 0, 0]);

  Dim operator *(Dim o) => Dim._([for (var i = 0; i < 6; i++) _e[i] + o._e[i]]);
  Dim operator /(Dim o) => Dim._([for (var i = 0; i < 6; i++) _e[i] - o._e[i]]);
  Dim pow(int n) => Dim._([for (final x in _e) x * n]);

  int exponentOf(int index) => _e[index];

  @override
  bool operator ==(Object other) {
    if (other is! Dim) return false;
    for (var i = 0; i < 6; i++) {
      if (_e[i] != other._e[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_e);

  static const _sup = {'-': '⁻', '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹'};

  /// Écriture « M·L⁻³ » ; « 1 » pour une grandeur sans dimension.
  String get formula {
    final parts = <String>[];
    for (var i = 0; i < 6; i++) {
      final x = _e[i];
      if (x == 0) continue;
      parts.add(x == 1 ? _symbols[i] : '${_symbols[i]}${'$x'.split('').map((c) => _sup[c]!).join()}');
    }
    return parts.isEmpty ? '1' : parts.join('·');
  }

  static final Map<Dim, String> _names = {
    dimensionless: 'grandeur sans dimension (rapport)',
    mass: 'masse',
    length: 'longueur',
    time: 'temps',
    amount: 'quantité de matière',
    equivalent: 'équivalents',
    temperature: 'température',
    volume: 'volume',
    mass / volume: 'concentration massique',
    amount / volume: 'concentration molaire',
    equivalent / volume: 'concentration en équivalents',
    amount / time: 'débit de quantité de matière (activité catalytique)',
    mass / time: 'débit massique (excrétion)',
    equivalent / time: 'débit d\'équivalents',
    volume / time: 'débit volumique',
    amount / volume / time: 'activité catalytique volumique',
    mass / length.pow(2): 'masse par surface',
    length / time: 'vitesse (ex. clairance rapportée à la surface corporelle)',
    amount / mass: 'quantité de matière par masse (osmolalité…)',
    mass / (length * time.pow(2)): 'pression',
    dimensionless / volume: 'inverse d\'un volume (numération par volume)',
    dimensionless / time: 'fréquence (par unité de temps)',
    volume / mass: 'volume par masse',
  };

  /// Nom français de la grandeur quand il est connu, sinon la formule.
  String get name => _names[this] ?? 'grandeur de dimension $formula';

  @override
  String toString() => formula;
}

/// Unité lue : texte, facteur vers les unités de base (kg, m, s, mol, K, Eq) et dimension.
class DimUnit {
  const DimUnit(this.text, this.dim, this.factor);
  final String text;
  final Dim dim;

  /// `valeur dans l'unité de base = valeur × factor`.
  final double factor;
}

/// Résultat de la lecture d'une unité : une unité, ou une raison en français.
class DimUnitParse {
  const DimUnitParse.ok(DimUnit this.unit) : error = null;
  const DimUnitParse.error(String this.error) : unit = null;
  final DimUnit? unit;
  final String? error;
}

class _Atom {
  const _Atom(this.dim, this.factor, [this.prefixes = const []]);
  final Dim dim;
  final double factor;
  final List<String> prefixes;
}

const Map<String, double> _prefixFactor = {
  'k': 1e3, 'h': 1e2, 'd': 1e-1, 'c': 1e-2, 'm': 1e-3, 'µ': 1e-6, 'n': 1e-9, 'p': 1e-12, 'f': 1e-15,
};

final Dim _pressure = Dim.mass / (Dim.length * Dim.time.pow(2));
final Dim _catalytic = Dim.amount / Dim.time;

final Map<String, _Atom> _atoms = {
  'g': _Atom(Dim.mass, 1e-3, ['k', 'm', 'µ', 'n', 'p', 'f']),
  'L': _Atom(Dim.volume, 1e-3, ['d', 'c', 'm', 'µ', 'n', 'p']),
  'm': _Atom(Dim.length, 1, ['k', 'c', 'm', 'µ', 'n']),
  's': _Atom(Dim.time, 1, ['m', 'µ', 'n']),
  'min': _Atom(Dim.time, 60),
  'h': _Atom(Dim.time, 3600),
  'd': _Atom(Dim.time, 86400),
  'mol': _Atom(Dim.amount, 1, ['m', 'µ', 'n', 'p', 'f']),
  'Osm': _Atom(Dim.amount, 1, ['m', 'µ']),
  'Eq': _Atom(Dim.equivalent, 1, ['m', 'µ']),
  'kat': _Atom(_catalytic, 1, ['m', 'µ', 'n', 'p']),
  'U': _Atom(_catalytic, 1e-6 / 60, ['m', 'k']),
  'K': _Atom(Dim.temperature, 1),
  'Pa': _Atom(_pressure, 1, ['k', 'h']),
  'bar': _Atom(_pressure, 1e5, ['m']),
  'atm': _Atom(_pressure, 101325),
  'mmHg': _Atom(_pressure, 133.322387415),
  'Torr': _Atom(_pressure, 101325 / 760),
  'cmH2O': _Atom(_pressure, 98.0665),
  'lb': _Atom(Dim.mass, 0.45359237),
  'oz': _Atom(Dim.mass, 0.028349523125),
  'in': _Atom(Dim.length, 0.0254),
  'ft': _Atom(Dim.length, 0.3048),
  '%': _Atom(Dim.dimensionless, 0.01),
  'cell': _Atom(Dim.dimensionless, 1),
  'cells': _Atom(Dim.dimensionless, 1),
  'M': _Atom(Dim.amount / Dim.volume, 1e3, ['m', 'µ', 'n', 'p']), // molaire : mol/L
};

const Map<String, double> _countMultipliers = {'G': 1e9, 'T': 1e12, 'M': 1e6, 'K': 1e3};

const Map<String, int> _superscript = {
  '⁰': 0, '¹': 1, '²': 2, '³': 3, '⁴': 4, '⁵': 5, '⁶': 6, '⁷': 7, '⁸': 8, '⁹': 9,
};

/// Lit et analyse une unité composée.
class UnitAnalyzer {
  UnitAnalyzer._();

  static String _normalize(String raw) {
    var t = raw.trim().replaceAll('μ', 'µ').replaceAll('×', '*').replaceAll('·', '*');
    t = t.replaceAll(RegExp(r'\s*/\s*'), '/');
    t = t.replaceAll(RegExp(r'(?<=\d)\s+(?=[a-zA-Zµ%])'), '');
    t = t.replaceAll(RegExp(r'\s+'), '*');
    t = t.replaceAll('IU', 'U').replaceAll('UI', 'U');
    t = t.replaceAllMapped(RegExp(r'\bx(?=10)'), (_) => '*');
    return t;
  }

  /// Symbole (éventuellement préfixé) sans exposant.
  static (Dim, double)? _symbol(String s) {
    final atom = _atoms[s];
    if (atom != null) return (atom.dim, atom.factor);
    final trad = _traditionalFactors[s];
    if (trad != null) return trad;
    if (s.startsWith('u') && s.length > 1) {
      final alt = _symbol('µ${s.substring(1)}');
      if (alt != null) return alt;
    }
    for (final entry in _atoms.entries) {
      final base = entry.key;
      if (entry.value.prefixes.isEmpty || !s.endsWith(base) || s.length <= base.length) continue;
      final prefix = s.substring(0, s.length - base.length);
      if (entry.value.prefixes.contains(prefix)) {
        return (entry.value.dim, entry.value.factor * _prefixFactor[prefix]!);
      }
    }
    return null;
  }

  static final Map<String, (Dim, double)> _traditionalFactors = {
    // 1 mg/100 mL = 10 mg/L = 0,01 g/L = 0,01 kg/m³ ; mg% = mg/100 mL.
    'mg%': (Dim.mass / Dim.volume, 1e-3 * 10 * 1e0),
    'g%': (Dim.mass / Dim.volume, 10.0),
    'µg%': (Dim.mass / Dim.volume, 1e-6 * 10),
  };

  /// Terme : [littéral] [symbole [exposant]].
  static (Dim, double)? _term(String term, List<String> problems) {
    var t = term;
    if (t.isEmpty) return (Dim.dimensionless, 1);
    var factor = 1.0;
    var dim = Dim.dimensionless;

    // Littéral : 10^n, 10⁹, ou nombre décimal.
    final lit = RegExp(r'^(?:\*?10(?:\^(-?\d+)|([⁰¹²³⁴⁵⁶⁷⁸⁹]+))|(\d+(?:[.,]\d+)?))').firstMatch(t);
    if (lit != null) {
      if (lit.group(1) != null) {
        factor *= math.pow(10, int.parse(lit.group(1)!)).toDouble();
      } else if (lit.group(2) != null) {
        final exp = lit.group(2)!.split('').map((c) => _superscript[c]!).join();
        factor *= math.pow(10, int.parse(exp)).toDouble();
      } else {
        factor *= double.parse(lit.group(3)!.replaceAll(',', '.'));
      }
      t = t.substring(lit.end);
      if (t.startsWith('*')) t = t.substring(1);
      if (t.isEmpty) return (dim, factor);
    }

    // Symbole entier (cmH2O, mmHg…) puis symbole + exposant.
    final whole = _symbol(t);
    if (whole != null) return (whole.$1, factor * whole.$2);
    final m = RegExp(r'^(.*?)(?:\^(-?\d+)|([⁻⁰¹²³⁴⁵⁶⁷⁸⁹]+)|([23]))$').firstMatch(t);
    if (m != null) {
      final sym = _symbol(m.group(1)!);
      if (sym != null) {
        final int exp;
        if (m.group(2) != null) {
          exp = int.parse(m.group(2)!);
        } else if (m.group(3) != null) {
          final neg = m.group(3)!.startsWith('⁻');
          final digits = m.group(3)!.replaceAll('⁻', '').split('').map((c) => _superscript[c]!).join();
          exp = (neg ? -1 : 1) * int.parse(digits);
        } else {
          exp = int.parse(m.group(4)!);
        }
        return (sym.$1.pow(exp), factor * math.pow(sym.$2, exp).toDouble());
      }
    }
    problems.add('« $t » n\'est pas une unité reconnue');
    return null;
  }

  /// Produit de termes séparés par « * ».
  static (Dim, double)? _segment(String segment, List<String> problems) {
    var dim = Dim.dimensionless;
    var factor = 1.0;
    // Un littéral « 10*9 » s'écrit 10^9 : on le protège avant de séparer.
    final protectedSeg = segment.replaceAllMapped(RegExp(r'10\*(-?\d+)'), (m) => '10^${m[1]}');
    for (final part in protectedSeg.split('*')) {
      final r = _term(part, problems);
      if (r == null) return null;
      dim = dim * r.$1;
      factor *= r.$2;
    }
    return (dim, factor);
  }

  /// Analyse [raw] : unité (dimension, facteur) ou raison du refus.
  static DimUnitParse parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return const DimUnitParse.error('Unité vide.');
    if (text.contains('(') || text.contains(')')) {
      return const DimUnitParse.error('Les parenthèses ne sont pas prises en charge : écrivez l\'unité avec « / » et « · ».');
    }
    if (RegExp(r'°|degC|degF').hasMatch(text)) {
      return const DimUnitParse.error(
          'Les échelles de température décalées (°C, °F) se convertissent dans le mode « Unités » ; seul le kelvin (K) est accepté ici.');
    }
    var t = _normalize(text);
    final problems = <String>[];
    final segments = t.split('/');

    // Multiplicateur de numération : G/L, T/L, M/µL, K/µL (numérateur seul).
    var first = segments.first;
    var countFactor = 1.0;
    if (segments.length > 1 && _countMultipliers.containsKey(first)) {
      countFactor = _countMultipliers[first]!;
      first = '';
    } else if (first.isEmpty && !text.startsWith('/')) {
      return const DimUnitParse.error('Unité mal formée.');
    }
    final n = first.isEmpty ? (Dim.dimensionless, 1.0) : _segment(first, problems);
    if (n == null) return DimUnitParse.error('${problems.first} ; essayez une autre écriture (ex. mg/dL, µmol/min/L, kg/m²).');
    var dim = n.$1;
    var factor = n.$2 * countFactor;
    for (final seg in segments.skip(1)) {
      if (seg.isEmpty) return const DimUnitParse.error('Unité mal formée : « / » sans dénominateur.');
      final d = _segment(seg, problems);
      if (d == null) return DimUnitParse.error('${problems.first} ; essayez une autre écriture (ex. mg/dL, µmol/min/L, kg/m²).');
      dim = dim / d.$1;
      factor /= d.$2;
    }
    return DimUnitParse.ok(DimUnit(text, dim, factor));
  }
}

/// Ce qu'il faut pour convertir [from] en [to].
class ConversionPlan {
  const ConversionPlan.direct()
      : possible = true,
        needsMolarMass = false,
        needsValence = false,
        reason = null;
  const ConversionPlan.withNature({required this.needsMolarMass, required this.needsValence})
      : possible = true,
        reason = null;
  const ConversionPlan.impossible(String this.reason)
      : possible = false,
        needsMolarMass = false,
        needsValence = false;

  final bool possible;
  final bool needsMolarMass;
  final bool needsValence;
  final String? reason;
  bool get isDirect => possible && !needsMolarMass && !needsValence;
}

const int _iM = 0, _iN = 3, _iE = 5;

/// Analyse dimensionnelle de la conversion [from] → [to].
ConversionPlan planConversion(DimUnit from, DimUnit to) {
  if (from.dim == to.dim) return const ConversionPlan.direct();
  // Les trois natures de quantité (M, N, E) ne diffèrent que par leur exposant ;
  // le reste (volume, temps, surface…) doit être identique.
  int nature(Dim d) {
    final present = [for (final i in [_iM, _iN, _iE]) if (d.exponentOf(i) != 0) i];
    if (present.length != 1 || d.exponentOf(present.first) != 1) return -1;
    return present.first;
  }

  final a = nature(from.dim), b = nature(to.dim);
  if (a < 0 || b < 0) {
    return ConversionPlan.impossible(
        'Les dimensions ne sont pas compatibles : ${from.dim.name} (${from.dim.formula}) et ${to.dim.name} (${to.dim.formula}).');
  }
  Dim rest(Dim d, int n) {
    final e = d / (n == _iM ? Dim.mass : n == _iN ? Dim.amount : Dim.equivalent);
    return e;
  }

  if (rest(from.dim, a) != rest(to.dim, b)) {
    return ConversionPlan.impossible(
        'Les dimensions ne sont pas compatibles : ${from.dim.name} (${from.dim.formula}) et ${to.dim.name} (${to.dim.formula}), '
        'même en changeant la nature (masse, mole, équivalents) de la quantité.');
  }
  final needsMolarMass = a == _iM || b == _iM;
  final needsValence = a == _iE || b == _iE;
  return ConversionPlan.withNature(needsMolarMass: needsMolarMass, needsValence: needsValence);
}

/// Conversion générale d'unités composées par analyse dimensionnelle.
const FormulaMeta dimensionalConvertMeta = FormulaMeta(
  id: 'lab_convert_dimensional',
  name: 'Conversion d\'unités composées (analyse dimensionnelle)',
  shortName: 'Convert (unités composées)',
  category: CalculatorCategory.laboratory,
  version: 'Dimensions 1 — six grandeurs de base ; masse molaire et valence saisies',
  equation:
      'Chaque unité = facteur × dimension (M, L, T, N, Θ, E) ; même dimension : valeur × (facteur de départ / facteur d\'arrivée)\n'
      'Masse → quantité de matière : n = m / M   (M en g/mol, saisie)   |   Quantité de matière → équivalents : éq = n × z   (z : valence, saisie)',
  sources: [
    Reference(
      citation: 'Bureau international des poids et mesures (BIPM). Le Système international d\'unités (SI), '
          'brochure, 9e édition, 2019.',
      note: 'préfixes, unités de base et unités dérivées ; analyse dimensionnelle',
    ),
  ],
  applicablePopulation: 'Sans objet (conversion de grandeurs, indépendante du patient).',
  analyticalConditions: [
    'La masse molaire doit correspondre à la forme chimique réellement dosée (sel, hydrate, forme libre) : '
        'BioSigma ne la fournit pas et ne la vérifie pas.',
  ],
  limitations: [
    'Seule une conversion par facteur est possible : les échelles décalées (°C, °F) et les relations non '
        'proportionnelles (ex. HbA1c % NGSP ↔ mmol/mol IFCC) ne sont pas des conversions par facteur.',
    'Une grandeur sans dimension (%, rapports) est convertie par simple changement d\'échelle : à vérifier '
        'que la grandeur s\'y prête.',
    'Les parenthèses et les exposants non entiers ne sont pas pris en charge.',
  ],
  displayPrecision: 4,
  helpText: 'Saisissez une valeur, son unité (ex. mg/dL, µmol/min/L, mg/kg/d, kg/m²) et l\'unité d\'arrivée.',
);

String _n(double v) => v.toString();

/// Convertit [value] de [fromUnit] vers [toUnit] par analyse dimensionnelle.
CalculationResult calculateDimensionalConversion({
  required double? value,
  required String fromUnit,
  required String toUnit,
  double? molarMassGPerMol,
  double? valence,
}) {
  Validation.raiseIfAny([Validation.checkProvided(value, 'value', 'La valeur')]);
  final a = UnitAnalyzer.parse(fromUnit);
  final b = UnitAnalyzer.parse(toUnit);
  final errors = <FieldError>[
    if (a.error != null) FieldError(fieldId: 'fromUnit', message: 'Unité de départ : ${a.error}'),
    if (b.error != null) FieldError(fieldId: 'toUnit', message: 'Unité d\'arrivée : ${b.error}'),
  ];
  if (errors.isNotEmpty) throw CalculationInputException(errors);
  final from = a.unit!, to = b.unit!;

  final plan = planConversion(from, to);
  if (!plan.possible) {
    throw CalculationInputException([FieldError(fieldId: 'toUnit', message: 'Conversion impossible. ${plan.reason}')]);
  }
  final checks = <FieldError?>[];
  if (plan.needsMolarMass) {
    checks.add(molarMassGPerMol == null
        ? const FieldError(
            fieldId: 'molarMass',
            message: 'La masse molaire (g/mol) est requise pour passer d\'une masse à une quantité de matière ; '
                'BioSigma ne la déduit jamais.')
        : Validation.checkPositive(molarMassGPerMol, 'molarMass', 'La masse molaire'));
  }
  if (plan.needsValence) {
    checks.add(valence == null
        ? const FieldError(
            fieldId: 'valence',
            message: 'La valence est requise pour passer de moles à des équivalents ; BioSigma ne la déduit jamais.')
        : Validation.checkPositive(valence, 'valence', 'La valence'));
  }
  Validation.raiseIfAny(checks);

  var base = value! * from.factor;
  if (!plan.isDirect) {
    // Quantité exprimée en M (kg), N (mol) ou E (Eq) → mol → nature d'arrivée.
    int nature(Dim d) => [_iM, _iN, _iE].firstWhere((i) => d.exponentOf(i) != 0);
    final a0 = nature(from.dim), b0 = nature(to.dim);
    final molarKg = molarMassGPerMol == null ? null : molarMassGPerMol / 1000; // kg/mol
    final mol = a0 == _iM ? base / molarKg! : a0 == _iE ? base / valence! : base;
    base = b0 == _iM ? mol * molarKg! : b0 == _iE ? mol * valence! : mol;
  }
  final converted = base / to.factor;
  final direct = plan.isDirect;
  final factor = from.factor / to.factor;

  return CalculationResult(
    formula: dimensionalConvertMeta,
    echoedInputs: {
      'Valeur saisie': '${_n(value)} ${from.text}',
      'Conversion vers': to.text,
      'Dimension de départ': '${from.dim.name} (${from.dim.formula})',
      'Dimension d\'arrivée': '${to.dim.name} (${to.dim.formula})',
      'Méthode': direct
          ? 'même dimension : simple facteur ${_n(factor)}'
          : 'passage par la quantité de matière'
              '${plan.needsMolarMass ? ' avec la masse molaire saisie' : ''}'
              '${plan.needsMolarMass && plan.needsValence ? ' et' : ''}'
              '${plan.needsValence ? ' avec la valence saisie' : ''}',
      if (plan.needsMolarMass) 'Masse molaire saisie': '${_n(molarMassGPerMol!)} g/mol',
      if (plan.needsValence) 'Valence saisie': _n(valence!),
    },
    values: [
      ResultValue(
        label: 'Valeur convertie',
        value: converted,
        unit: to.text,
        precision: LabUnits.decimalsForSignificant(converted),
      ),
    ],
    warnings: [
      if (plan.needsMolarMass)
        const CalculationWarning(
          'La masse molaire est celle que vous avez saisie ; BioSigma ne la vérifie pas. Elle doit correspondre à '
          'la forme chimique dosée (sel, hydrate, forme libre).',
          severity: WarningSeverity.caution,
        ),
      if (plan.needsValence)
        const CalculationWarning(
          'La valence est celle que vous avez saisie ; BioSigma ne la vérifie pas.',
          severity: WarningSeverity.caution,
        ),
      if (from.dim == Dim.dimensionless && to.dim == Dim.dimensionless)
        const CalculationWarning(
          'Grandeur sans dimension : la conversion est un simple changement d\'échelle. Elle ne convient pas aux '
          'grandeurs dont l\'échelle est définie par une relation (ex. HbA1c en % NGSP et en mmol/mol IFCC : '
          'utilisez le mode Analyte).',
          severity: WarningSeverity.caution,
        ),
    ],
  );
}
