import 'dart:math' as math;

import '../calculators/hemostasis/inr.dart';
import '../calculators/ionogram/anion_gap.dart';
import '../calculators/ionogram/misc_biochemistry.dart';
import '../calculators/metabolic/anthropometric_and_ratios.dart';
import '../calculators/metabolic/insulin_resistance.dart';
import '../calculators/renal/ckd_epi.dart';
import '../lab/analyte_base.dart';
import '../lab/dilution.dart';
import '../models/result.dart';
import '../models/sex.dart';
import '../registry/equation_registry.dart';

/// Mode enseignement (backlog P5-05) : exercices de calcul générés de façon
/// **déterministe** à partir d'un numéro (même numéro → même exercice). Le
/// corrigé est calculé par le moteur de l'application lui-même ; les tests le
/// recalculent indépendamment à partir de l'énoncé.
///
/// Les cas sont fictifs. Chaque exercice porte le statut de validation de
/// l'équation utilisée (aujourd'hui « NON VALIDÉ » pour toutes) : c'est un
/// entraînement au calcul, jamais une référence pour un résultat patient.
class Exercise {
  const Exercise({
    required this.kindId,
    required this.seed,
    required this.title,
    required this.equationId,
    required this.statement,
    required this.answerLabel,
    required this.answerUnit,
    required this.expected,
    required this.decimals,
    required this.solution,
    required this.statusLabel,
    this.inputs = const {},
  });

  final String kindId;
  final int seed;
  final String title;

  /// Identifiant (hérité) de l'équation du registre utilisée pour le corrigé.
  final String equationId;
  final String statement;
  final String answerLabel;
  final String answerUnit;

  /// Valeur du corrigé, non arrondie.
  final double expected;

  /// Nombre de décimales demandées pour la réponse.
  final int decimals;
  final List<String> solution;

  /// « NON VALIDÉ » / « VALIDÉ » / « RETIRÉ » (registre au moment de la génération).
  final String statusLabel;

  /// Données de l'énoncé, sous forme structurée (pour les tests et l'export).
  final Map<String, Object> inputs;

  /// Mention à afficher avec l'exercice.
  String get banner => statusLabel == 'VALIDÉ'
      ? 'Équation validée par un biologiste responsable (selon le registre de l\'application).'
      : 'Équation « $statusLabel » : exercice d\'entraînement uniquement, à ne pas utiliser '
          'pour un résultat patient. Cas fictif.';

  /// Corrigé arrondi au nombre de décimales demandé.
  double get expectedRounded {
    final f = math.pow(10, decimals).toDouble();
    return (expected * f).round() / f;
  }

  /// Vérifie une réponse : correcte si elle est égale au corrigé arrondi à
  /// [decimals] décimales (à une demi-unité du dernier chiffre près, sans plus).
  ExerciseCheck check(double? answer) {
    if (answer == null || !answer.isFinite) {
      return const ExerciseCheck(correct: false, message: 'Saisissez un nombre.');
    }
    final tolerance = 0.5 * math.pow(10, -decimals) + 1e-9;
    final ok = (answer - expected).abs() <= tolerance;
    return ExerciseCheck(
      correct: ok,
      message: ok ? 'Correct.' : 'Réponse différente du corrigé.',
    );
  }
}

class ExerciseCheck {
  const ExerciseCheck({required this.correct, required this.message});
  final bool correct;
  final String message;
}

typedef _Builder = Exercise Function(math.Random r, int seed);

class ExerciseKind {
  const ExerciseKind(this.id, this.title, this._build);
  final String id;
  final String title;
  final _Builder _build;
}

String _fmt(double v, [int d = 1]) => v.toStringAsFixed(d).replaceAll('.', ',');

String _status(String equationId) => (EquationRegistry.resolve(equationId)?.status ?? EquationStatus.notValidated).label;

double _first(CalculationResult r) => r.values.first.value!;

double _oneDecimal(math.Random r, int minTimes10, int maxTimes10) =>
    (minTimes10 + r.nextInt(maxTimes10 - minTimes10 + 1)) / 10;

/// Les types d'exercices proposés.
class ExerciseGenerator {
  ExerciseGenerator._();

  static final List<ExerciseKind> kinds = [
    ExerciseKind('bmi', 'IMC', (r, seed) {
      final w = 45 + r.nextInt(66), h = 150 + r.nextInt(46);
      final res = calculateBmi(weightKgValue: w.toDouble(), heightCmValue: h.toDouble());
      return Exercise(
        kindId: 'bmi', seed: seed, title: 'IMC', equationId: 'bmi',
        statement: 'Une personne pèse $w kg et mesure $h cm. Calculez son indice de masse corporelle.',
        answerLabel: 'IMC', answerUnit: 'kg/m²', expected: res.values.first.value!, decimals: 1,
        solution: [
          'IMC = poids (kg) / taille (m)².',
          'Taille en mètres : $h cm = ${_fmt(h / 100, 2)} m.',
          'IMC = $w / ${_fmt(h / 100, 2)}² = ${_fmt(res.values.first.value!, 2)} kg/m².',
        ],
        statusLabel: _status('bmi'),
        inputs: {'poids_kg': w, 'taille_cm': h},
      );
    }),
    ExerciseKind('homa_ir', 'HOMA-IR', (r, seed) {
      final ins = _oneDecimal(r, 30, 300), glu = _oneDecimal(r, 40, 70);
      final res = calculateHomaIr(
        fastingInsulinValue: ins, fastingInsulinUnit: 'µU/mL',
        fastingGlucoseValue: glu, fastingGlucoseUnit: 'mmol/L', fastingConfirmed: true,
      );
      return Exercise(
        kindId: 'homa_ir', seed: seed, title: 'HOMA-IR', equationId: 'homa_ir',
        statement: 'À jeun : insulinémie ${_fmt(ins)} µU/mL, glycémie ${_fmt(glu)} mmol/L. Calculez l\'indice HOMA-IR.',
        answerLabel: 'HOMA-IR', answerUnit: '', expected: _first(res), decimals: 2,
        solution: [
          'HOMA-IR = glycémie (mmol/L) × insulinémie (µU/mL) / 22,5.',
          'HOMA-IR = ${_fmt(glu)} × ${_fmt(ins)} / 22,5 = ${_fmt(_first(res), 3)}.',
        ],
        statusLabel: _status('homa_ir'),
        inputs: {'insuline_uUmL': ins, 'glycemie_mmolL': glu},
      );
    }),
    ExerciseKind('quicki', 'QUICKI', (r, seed) {
      final ins = _oneDecimal(r, 30, 300), glu = 70 + r.nextInt(41);
      final res = calculateQuicki(
        fastingInsulinValue: ins, fastingInsulinUnit: 'µU/mL',
        fastingGlucoseValue: glu.toDouble(), fastingGlucoseUnit: 'mg/dL', fastingConfirmed: true,
      );
      return Exercise(
        kindId: 'quicki', seed: seed, title: 'QUICKI', equationId: 'quicki',
        statement: 'À jeun : insulinémie ${_fmt(ins)} µU/mL, glycémie $glu mg/dL. Calculez l\'indice QUICKI.',
        answerLabel: 'QUICKI', answerUnit: '', expected: _first(res), decimals: 3,
        solution: [
          'QUICKI = 1 / (log₁₀ insulinémie [µU/mL] + log₁₀ glycémie [mg/dL]).',
          'QUICKI = 1 / (log₁₀ ${_fmt(ins)} + log₁₀ $glu) = ${_fmt(_first(res), 4)}.',
        ],
        statusLabel: _status('quicki'),
        inputs: {'insuline_uUmL': ins, 'glycemie_mgdL': glu},
      );
    }),
    ExerciseKind('tyg', 'Indice TyG', (r, seed) {
      final tg = 80 + r.nextInt(221), glu = 80 + r.nextInt(51);
      final res = calculateTyg(
        triglyceridesValue: tg.toDouble(), triglyceridesUnit: 'mg/dL',
        fastingGlucoseValue: glu.toDouble(), fastingGlucoseUnit: 'mg/dL', fastingConfirmed: true,
      );
      return Exercise(
        kindId: 'tyg', seed: seed, title: 'Indice TyG', equationId: 'tyg_index',
        statement: 'À jeun : triglycérides $tg mg/dL, glycémie $glu mg/dL. Calculez l\'indice TyG.',
        answerLabel: 'TyG', answerUnit: '', expected: _first(res), decimals: 2,
        solution: [
          'TyG = ln[(triglycérides mg/dL × glycémie mg/dL) / 2] (logarithme népérien).',
          'TyG = ln[($tg × $glu) / 2] = ${_fmt(_first(res), 3)}.',
        ],
        statusLabel: _status('tyg_index'),
        inputs: {'tg_mgdL': tg, 'glycemie_mgdL': glu},
      );
    }),
    ExerciseKind('fib4', 'FIB-4', (r, seed) {
      final age = 30 + r.nextInt(46), ast = 20 + r.nextInt(101), alt = 20 + r.nextInt(101), plt = 100 + r.nextInt(251);
      final res = calculateFib4(
        ageYears: age.toDouble(), astUL: ast.toDouble(), plateletsGL: plt.toDouble(), altUL: alt.toDouble(),
      );
      return Exercise(
        kindId: 'fib4', seed: seed, title: 'FIB-4', equationId: 'fib4',
        statement: 'Âge $age ans, ASAT $ast U/L, ALAT $alt U/L, plaquettes $plt G/L. Calculez le FIB-4.',
        answerLabel: 'FIB-4', answerUnit: '', expected: _first(res), decimals: 2,
        solution: [
          'FIB-4 = (âge × ASAT) / (plaquettes [G/L] × √ALAT).',
          'FIB-4 = ($age × $ast) / ($plt × √$alt) = ${_fmt(_first(res), 3)}.',
        ],
        statusLabel: _status('fib4'),
        inputs: {'age': age, 'ast': ast, 'alt': alt, 'plaquettes': plt},
      );
    }),
    ExerciseKind('inr', 'INR', (r, seed) {
      final pt = _oneDecimal(r, 120, 400), mnpt = _oneDecimal(r, 110, 130), isi = _oneDecimal(r, 9, 14);
      final res = calculateInr(patientPtSeconds: pt, meanNormalPtSeconds: mnpt, isi: isi);
      return Exercise(
        kindId: 'inr', seed: seed, title: 'INR', equationId: 'inr',
        statement: 'TP du patient ${_fmt(pt)} s ; TP moyen normal du laboratoire ${_fmt(mnpt)} s ; '
            'ISI du réactif ${_fmt(isi)}. Calculez l\'INR.',
        answerLabel: 'INR', answerUnit: '', expected: _first(res), decimals: 2,
        solution: [
          'INR = (TP patient / TP moyen normal) ^ ISI.',
          'INR = (${_fmt(pt)} / ${_fmt(mnpt)}) ^ ${_fmt(isi)} = ${_fmt(_first(res), 3)}.',
        ],
        statusLabel: _status('inr'),
        inputs: {'tp_patient': pt, 'tp_normal': mnpt, 'isi': isi},
      );
    }),
    ExerciseKind('ckd_epi_2021', 'DFG CKD-EPI 2021', (r, seed) {
      final age = 25 + r.nextInt(61), scr = _oneDecimal(r, 6, 25), female = r.nextBool();
      final res = calculateCkdEpiCreatinine2021(
        age: age.toDouble(), sex: female ? Sex.female : Sex.male,
        creatinineValue: scr, creatinineUnit: 'mg/dL', idmsConfirmed: true,
      );
      return Exercise(
        kindId: 'ckd_epi_2021', seed: seed, title: 'DFG CKD-EPI 2021', equationId: 'ckd_epi_creatinine_2021',
        statement: '${female ? 'Une femme' : 'Un homme'} de $age ans, créatininémie ${_fmt(scr)} mg/dL '
            '(dosage standardisé IDMS). Estimez le DFG par l\'équation CKD-EPI créatinine 2021.',
        answerLabel: 'DFG estimé', answerUnit: 'mL/min/1,73 m²', expected: _first(res), decimals: 0,
        solution: [
          'DFG = 142 × min(Scr/κ ; 1)^α × max(Scr/κ ; 1)^−1,200 × 0,9938^âge × 1,012 [si femme].',
          'κ = ${female ? '0,7' : '0,9'} ; α = ${female ? '−0,241' : '−0,302'}.',
          'Résultat : ${_fmt(_first(res), 1)} mL/min/1,73 m².',
        ],
        statusLabel: _status('ckd_epi_creatinine_2021'),
        inputs: {'age': age, 'creatinine_mgdL': scr, 'femme': female},
      );
    }),
    ExerciseKind('anion_gap', 'Trou anionique', (r, seed) {
      final na = 130 + r.nextInt(16), cl = 95 + r.nextInt(16), hco3 = 15 + r.nextInt(14);
      final res = calculateAnionGap(
        sodiumValue: na.toDouble(), chlorideValue: cl.toDouble(), bicarbonateValue: hco3.toDouble(),
      );
      return Exercise(
        kindId: 'anion_gap', seed: seed, title: 'Trou anionique', equationId: 'anion_gap',
        statement: 'Sodium $na mmol/L, chlorures $cl mmol/L, bicarbonates $hco3 mmol/L. '
            'Calculez le trou anionique (sans potassium).',
        answerLabel: 'Trou anionique', answerUnit: 'mmol/L', expected: _first(res), decimals: 0,
        solution: [
          'Trou anionique = Na⁺ − (Cl⁻ + HCO₃⁻).',
          'Trou anionique = $na − ($cl + $hco3) = ${na - (cl + hco3)} mmol/L.',
        ],
        statusLabel: _status('anion_gap'),
        inputs: {'na': na, 'cl': cl, 'hco3': hco3},
      );
    }),
    ExerciseKind('creatinine_conversion', 'Conversion de la créatinine', (r, seed) {
      final v = _oneDecimal(r, 5, 30);
      final res = calculateAnalyteUnitConversion(
        analyteId: 'creatinine', value: v, fromUnit: 'mg/dL', toUnit: 'µmol/L',
      );
      return Exercise(
        kindId: 'creatinine_conversion', seed: seed, title: 'Conversion de la créatinine',
        equationId: 'lab_convert_analyte',
        statement: 'Une créatininémie est rendue à ${_fmt(v)} mg/dL. Exprimez-la en µmol/L '
            '(masse molaire de la créatinine : 113,12 g/mol).',
        answerLabel: 'Créatininémie', answerUnit: 'µmol/L', expected: _first(res), decimals: 0,
        solution: [
          'Concentration molaire = concentration massique / masse molaire.',
          '${_fmt(v)} mg/dL = ${_fmt(v * 10, 0)} mg/L ; ${_fmt(v * 10, 0)} mg/L / 113,12 g/mol '
              '= ${_fmt(_first(res), 1)} µmol/L.',
        ],
        statusLabel: _status('lab_convert_analyte'),
        inputs: {'creatinine_mgdL': v},
      );
    }),
    ExerciseKind('dilution_v1', 'Volume à prélever pour une dilution', (r, seed) {
      final c1 = [100, 200, 250, 500][r.nextInt(4)], c2 = [5, 10, 20, 25, 40][r.nextInt(5)], v2 = [10, 20, 25, 50][r.nextInt(4)];
      final res = calculateDilution(
        c1: c1.toDouble(), c1Unit: 'mg/dL', c2: c2.toDouble(), c2Unit: 'mg/dL',
        v2: v2.toDouble(), v2Unit: 'mL',
      );
      final v1 = res.values.firstWhere((v) => v.label.contains('V1'), orElse: () => res.values.first);
      return Exercise(
        kindId: 'dilution_v1', seed: seed, title: 'Dilution', equationId: 'lab_dilution_c1v1',
        statement: 'On dispose d\'une solution mère à $c1 mg/dL. On veut $v2 mL de solution à $c2 mg/dL. '
            'Quel volume de solution mère faut-il prélever ?',
        answerLabel: 'Volume V1 à prélever', answerUnit: 'mL', expected: v1.value!, decimals: 2,
        solution: [
          'C1·V1 = C2·V2, donc V1 = C2·V2 / C1.',
          'V1 = $c2 × $v2 / $c1 = ${_fmt(c2 * v2 / c1, 3)} mL.',
        ],
        statusLabel: _status('lab_dilution_c1v1'),
        inputs: {'c1': c1, 'c2': c2, 'v2': v2},
      );
    }),
  ];

  static ExerciseKind? kindById(String id) {
    for (final k in kinds) {
      if (k.id == id) return k;
    }
    return null;
  }

  /// Génère l'exercice de ce type et de ce numéro (déterministe).
  static Exercise generate(String kindId, int seed) {
    final kind = kindById(kindId);
    if (kind == null) throw ArgumentError('Type d\'exercice inconnu : $kindId');
    return kind._build(math.Random(seed), seed);
  }
}
