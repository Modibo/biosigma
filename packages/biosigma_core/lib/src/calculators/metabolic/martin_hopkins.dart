import '../../models/errors.dart';
import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../validation.dart';

/// Tableau des facteurs triglycérides/VLDL-C de la méthode de Martin-Hopkins,
/// **saisi par l'utilisateur** (aucune valeur n'est embarquée : le tableau
/// publié compte 180 facteurs qui doivent être recopiés depuis la source).
///
/// Format CSV (séparateur « ; », virgule ou point décimal acceptés) :
/// ```
/// TG_min;nonHDL_min_1;nonHDL_min_2;…        ← 1re ligne : bornes inférieures du non-HDL-C (mg/dL)
/// TG_min_1;F11;F12;…                        ← lignes suivantes : borne inférieure des TG, puis un facteur par colonne
/// ```
/// Chaque strate est « borne incluse », jusqu'à la borne suivante exclue ; la
/// dernière s'étend vers le haut.
class MartinHopkinsTable {
  MartinHopkinsTable._(this.nonHdlLowerEdges, this.tgLowerEdges, this.factors);

  final List<double> nonHdlLowerEdges;
  final List<double> tgLowerEdges;

  /// `factors[ligne TG][colonne non-HDL]`.
  final List<List<double>> factors;

  /// Construit et valide un tableau ; lève [FormatException] avec un message
  /// précis (ligne/colonne) en cas de problème.
  factory MartinHopkinsTable.fromCsv(String csv) {
    final lines = csv
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length < 2) {
      throw const FormatException('Tableau vide : une ligne de bornes non-HDL et au moins une ligne de TG sont attendues.');
    }
    double num(String s, int line, int col) {
      final v = double.tryParse(s.trim().replaceAll(',', '.'));
      if (v == null || !v.isFinite) {
        throw FormatException('Ligne $line, colonne $col : « $s » n\'est pas un nombre.');
      }
      return v;
    }

    final header = lines.first.split(';');
    if (header.length < 2) {
      throw const FormatException('Ligne 1 : au moins une borne non-HDL est attendue après la première cellule.');
    }
    final nonHdl = [for (var c = 1; c < header.length; c++) num(header[c], 1, c + 1)];
    final tg = <double>[];
    final f = <List<double>>[];
    for (var r = 1; r < lines.length; r++) {
      final cells = lines[r].split(';');
      if (cells.length != header.length) {
        throw FormatException(
            'Ligne ${r + 1} : ${cells.length} colonnes au lieu de ${header.length}.');
      }
      tg.add(num(cells[0], r + 1, 1));
      f.add([
        for (var c = 1; c < cells.length; c++) num(cells[c], r + 1, c + 1),
      ]);
    }
    bool ascending(List<double> l) {
      for (var i = 1; i < l.length; i++) {
        if (l[i] <= l[i - 1]) return false;
      }
      return true;
    }

    if (!ascending(nonHdl)) {
      throw const FormatException('Les bornes non-HDL de la ligne 1 doivent être strictement croissantes.');
    }
    if (!ascending(tg)) {
      throw const FormatException('Les bornes de TG (1re colonne) doivent être strictement croissantes.');
    }
    for (var r = 0; r < f.length; r++) {
      for (var c = 0; c < f[r].length; c++) {
        if (f[r][c] <= 0) {
          throw FormatException('Ligne ${r + 2}, colonne ${c + 2} : le facteur doit être strictement positif.');
        }
      }
    }
    return MartinHopkinsTable._(nonHdl, tg, f);
  }

  int get cellCount => factors.fold(0, (s, r) => s + r.length);

  /// Facteur de la strate qui contient ces valeurs (mg/dL) ; `null` si les TG
  /// ou le non-HDL-C sont sous la première borne du tableau.
  double? factorFor({required double triglyceridesMgDl, required double nonHdlMgDl}) {
    final r = _stratum(tgLowerEdges, triglyceridesMgDl);
    final c = _stratum(nonHdlLowerEdges, nonHdlMgDl);
    if (r < 0 || c < 0) return null;
    return factors[r][c];
  }

  static int _stratum(List<double> edges, double v) {
    var idx = -1;
    for (var i = 0; i < edges.length; i++) {
      if (v >= edges[i]) idx = i;
    }
    return idx;
  }
}

const FormulaMeta ldlMartinHopkinsMeta = FormulaMeta(
  id: 'ldl_martin_hopkins',
  name: 'LDL-cholestérol calculé — Martin-Hopkins (tableau saisi)',
  shortName: 'LDL Martin-Hopkins',
  category: CalculatorCategory.metabolic,
  version: 'Martin-Hopkins 2013 (tableau fourni par l\'utilisateur)',
  equation: 'LDL-C = CT − HDL-C − TG / F, F = facteur du tableau selon les strates de TG et de non-HDL-C (mg/dL)',
  sources: [
    Reference(
      citation: 'Martin SS, Blaha MJ, Elshazly MB, et al. Comparison of a novel method vs the Friedewald equation '
          'for estimating low-density lipoprotein cholesterol levels from the standard lipid profile. '
          'JAMA. 2013;310(19):2061-2068.',
      note: 'Le tableau des facteurs n\'est pas embarqué : il est saisi par l\'utilisateur depuis la publication.',
    ),
  ],
  applicablePopulation: 'Adulte, profil lipidique (selon la source)',
  forbiddenConditions: ['Triglycérides ou non-HDL-C sous la première borne du tableau saisi'],
  limitations: [
    'Le résultat n\'est exact que si le tableau saisi est identique à celui de la publication : '
        'à relire cellule par cellule avant tout usage.',
  ],
);

/// LDL-C par la méthode de Martin-Hopkins à partir d'un tableau saisi.
/// Toutes les concentrations en mg/dL ; [maxTriglyceridesMgDl] (facultatif,
/// saisi) fixe la limite haute des TG au-delà de laquelle le calcul est refusé.
CalculationResult calculateLdlMartinHopkins({
  required double totalCholesterolMgDl,
  required double hdlMgDl,
  required double triglyceridesMgDl,
  required MartinHopkinsTable table,
  double? maxTriglyceridesMgDl,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(totalCholesterolMgDl, 'totalCholesterolMgDl', 'Cholestérol total'),
    Validation.checkPositive(hdlMgDl, 'hdlMgDl', 'HDL-cholestérol'),
    Validation.checkPositive(triglyceridesMgDl, 'triglyceridesMgDl', 'Triglycérides'),
  ]);
  if (maxTriglyceridesMgDl != null && triglyceridesMgDl > maxTriglyceridesMgDl) {
    throw CalculationInputException([
      FieldError(
        fieldId: 'triglyceridesMgDl',
        message: 'Triglycérides au-dessus de la limite saisie (${maxTriglyceridesMgDl.toStringAsFixed(0)} mg/dL) : '
            'LDL-C non calculé.',
      ),
    ]);
  }
  final nonHdl = totalCholesterolMgDl - hdlMgDl;
  if (nonHdl <= 0) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'hdlMgDl',
        message: 'Le HDL-cholestérol doit être inférieur au cholestérol total.',
      ),
    ]);
  }
  final factor = table.factorFor(triglyceridesMgDl: triglyceridesMgDl, nonHdlMgDl: nonHdl);
  if (factor == null) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'triglyceridesMgDl',
        message: 'Triglycérides ou non-HDL-C sous la première borne du tableau saisi : facteur introuvable.',
      ),
    ]);
  }
  final ldl = nonHdl - triglyceridesMgDl / factor;
  return CalculationResult(
    formula: ldlMartinHopkinsMeta,
    echoedInputs: {
      'Cholestérol total': '${totalCholesterolMgDl.toStringAsFixed(1)} mg/dL',
      'HDL-cholestérol': '${hdlMgDl.toStringAsFixed(1)} mg/dL',
      'Triglycérides': '${triglyceridesMgDl.toStringAsFixed(1)} mg/dL',
      'Non-HDL-C': '${nonHdl.toStringAsFixed(1)} mg/dL',
      'Facteur F (tableau saisi)': factor.toString(),
    },
    values: [
      ResultValue(label: 'LDL-C (Martin-Hopkins)', value: ldl, unit: 'mg/dL', precision: 0),
    ],
    warnings: const [
      CalculationWarning(
        'Le facteur provient d\'un tableau saisi par l\'utilisateur : le résultat ne vaut que ce que vaut ce tableau.',
        severity: WarningSeverity.caution,
      ),
    ],
  );
}
