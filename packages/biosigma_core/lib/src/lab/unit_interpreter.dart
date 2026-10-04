import 'lab_units.dart';

/// Résultat de l'interprétation d'une unité saisie librement.
///
/// Règles (T-SAI-002) : jamais de supposition silencieuse. Toute réécriture
/// est tracée dans [notes] pour que l'interface la montre ; une ambiguïté
/// donne [unit] == `null` et des [suggestions] (« question »), sauf quand
/// l'écriture exacte est valide : elle est alors gardée, avec une mise en
/// garde ([cautions]) si une autre lecture, de grandeur différente, existe.
class UnitInterpretation {
  const UnitInterpretation({
    required this.input,
    this.unit,
    this.notes = const [],
    this.cautions = const [],
    this.suggestions = const [],
  });

  final String input;
  final LabUnit? unit;

  /// Réécritures effectuées (« mg/dl » lu comme « mg/dL »…).
  final List<String> notes;

  /// Autres lectures possibles de grandeur différente.
  final List<String> cautions;

  /// Propositions quand l'unité n'est pas reconnue ou est ambiguë.
  final List<String> suggestions;

  bool get recognized => unit != null;

  /// `true` si l'écriture saisie a été modifiée pour être reconnue.
  bool get rewritten => notes.isNotEmpty;
}

/// Interprète des unités écrites librement : « uL », « microlitre », « mg/100 mL »,
/// « mg/dl », « umol/l »…
class UnitInterpreter {
  UnitInterpreter._();

  static const _prefixWords = {
    'kilo': 'k', 'deci': 'd', 'déci': 'd', 'centi': 'c', 'milli': 'm',
    'micro': 'µ', 'nano': 'n', 'pico': 'p', 'femto': 'f',
  };
  static const _baseWords = {
    'litre': 'L', 'liter': 'L', 'gramme': 'g', 'gram': 'g', 'mole': 'mol', 'mol': 'mol',
    'katal': 'kat', 'equivalent': 'Eq', 'équivalent': 'Eq',
  };

  /// Sépare « 88 umol/l » en (« 88 », « umol/l »). Le nombre est lu tel quel
  /// (l'interface applique sa propre politique de séparateur décimal).
  static ({String number, String unit})? splitQuantity(String text) {
    final m = RegExp(r'^\s*(-?\s*[0-9][0-9\s.,]*?)\s*([^0-9\s.,\-][\s\S]*?)\s*$').firstMatch(text);
    if (m == null) return null;
    return (number: m.group(1)!.trim(), unit: m.group(2)!.trim());
  }

  static String _compact(String s) => s
      .trim()
      .replaceAll(RegExp(r'\s*/\s*'), '/')
      .replaceAll(RegExp(r'(?<=\d)\s+(?=[a-zA-Zµμ])'), '')
      .replaceAll(RegExp(r'\s+'), '');

  static String _wordsToSymbol(String raw) {
    var t = raw.trim().toLowerCase();
    t = t.replaceAll(RegExp(r'\s+(par|per)\s+'), '/');
    final parts = t.split('/').map((seg) {
      final s = seg.trim();
      final m = RegExp(r'^([a-zéè]+?)?(litres?|liters?|grammes?|grams?|moles?|mol|katals?|[eé]quivalents?)$')
          .firstMatch(s);
      if (m == null) return seg;
      final prefix = m.group(1);
      final base = m.group(2)!.replaceFirst(RegExp(r's$'), '');
      final baseSymbol = _baseWords[base] ?? _baseWords[base.replaceFirst(RegExp(r's$'), '')];
      if (baseSymbol == null) return seg;
      if (prefix == null) return baseSymbol;
      final p = _prefixWords[prefix];
      return p == null ? seg : '$p$baseSymbol';
    });
    return parts.join('/');
  }

  /// Corrections de casse à effet certain : la lettre « l » finale d'un
  /// segment qui est un volume (`dl`, `ml`, `l`) devient « L » ; « meq » →
  /// « mEq » ; un texte entièrement en capitales est passé en minuscules
  /// avant ces corrections.
  static String _fixCase(String compact) {
    var t = compact;
    final hasLower = RegExp(r'[a-zµ]').hasMatch(t);
    if (!hasLower) t = t.toLowerCase();
    t = t.split('/').map((seg) {
      if (RegExp(r'^(d|c|m|µ|μ|u|n|p)?l$').hasMatch(seg)) {
        return '${seg.substring(0, seg.length - 1)}L';
      }
      return seg.replaceFirstMapped(RegExp(r'^(m|µ|μ|u)?eq$'), (m) => '${m.group(1) ?? ''}Eq');
    }).join('/');
    return t;
  }

  static String _describe(LabUnit u) => u.dimension.label;

  static final List<String> _allOffered = [
    for (final l in LabUnits.offered.values) ...l,
  ];

  static int _distance(String a, String b) {
    final m = a.length, n = b.length;
    var prev = List<int>.generate(n + 1, (j) => j);
    for (var i = 1; i <= m; i++) {
      final cur = List<int>.filled(n + 1, 0)..[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        cur[j] = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost].reduce((x, y) => x < y ? x : y);
      }
      prev = cur;
    }
    return prev[n];
  }

  static List<String> _suggest(String raw) {
    final needle = raw.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final scored = <(int, String)>[];
    for (final s in _allOffered.toSet()) {
      final d = _distance(needle, s.toLowerCase());
      if (d <= 2) scored.add((d, s));
    }
    scored.sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
    return [for (final s in scored.take(3)) s.$2];
  }

  static List<String> _cautionsFor(String exact, LabUnit unit) {
    final out = <String>[];
    final alt = <String>{
      exact.toLowerCase(),
      _fixCase(exact.toLowerCase()),
    }..remove(exact);
    for (final a in alt) {
      final other = LabUnits.parse(a);
      if (other != null && other.dimension != unit.dimension) {
        out.add('« $exact » est lu comme ${_describe(unit)} ; pour ${_describe(other)}, écrivez « ${other.symbol} ».');
      }
    }
    return out;
  }

  static UnitInterpretation interpret(String raw) {
    final input = raw;
    final compact = _compact(raw);
    if (compact.isEmpty) {
      return UnitInterpretation(input: input, notes: const [], suggestions: const []);
    }

    UnitInterpretation ok(LabUnit u, List<String> notes, [List<String> cautions = const []]) =>
        UnitInterpretation(input: input, unit: u, notes: notes, cautions: cautions);

    // 1. Écriture exacte (avec espaces retirés).
    final exact = LabUnits.parse(compact);
    if (exact != null) {
      final notes = <String>[
        if (exact.symbol != raw.trim()) '« ${raw.trim()} » lu comme « ${exact.symbol} ».',
      ];
      return ok(exact, notes, _cautionsFor(compact, exact));
    }

    // 2. Noms en toutes lettres (microlitre, milligramme par décilitre…).
    final fromWords = _wordsToSymbol(raw);
    if (fromWords != raw.toLowerCase().trim() || RegExp(r'\s(par|per)\s').hasMatch(raw)) {
      final u = LabUnits.parse(_compact(fromWords));
      if (u != null) {
        return ok(u, ['« ${raw.trim()} » lu comme « ${u.symbol} ».']);
      }
    }

    // 3. « M » majuscule devant une base : milli ou méga ? On ne choisit pas.
    if (RegExp(r'(^|/)M(mol|g|L|Eq|kat)').hasMatch(compact)) {
      final alt = compact.replaceAllMapped(RegExp(r'(^|/)M(mol|g|L|Eq|kat)'), (m) => '${m[1]}m${m[2]}');
      final suggestion = LabUnits.parse(alt) != null ? [alt] : <String>[];
      return UnitInterpretation(
        input: input,
        notes: const [],
        cautions: const [
          '« M » majuscule désigne méga, jamais milli : précisez l\'unité voulue.',
        ],
        suggestions: suggestion,
      );
    }

    // 4. Corrections de casse à effet certain.
    final fixed = _fixCase(compact);
    if (fixed != compact) {
      final u = LabUnits.parse(fixed);
      if (u != null) {
        return ok(u, ['« ${raw.trim()} » lu comme « ${u.symbol} » (casse corrigée) : à confirmer.']);
      }
    }

    // 5. Non reconnue : propositions proches.
    return UnitInterpretation(input: input, suggestions: _suggest(compact));
  }
}
