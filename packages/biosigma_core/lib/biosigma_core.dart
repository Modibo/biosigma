/// Moteur de calcul pur de BioSigma.
///
/// Bibliothèque Dart sans dépendance Flutter : modèles, conversions
/// d'unités et fonctions de calcul de biochimie clinique et d'hémostase.
library;

export 'src/models/reference.dart';
export 'src/models/formula_meta.dart';
export 'src/models/result.dart';
export 'src/models/errors.dart';
export 'src/models/sex.dart';
export 'src/units/analyte.dart';
export 'src/units/unit_spec.dart';
export 'src/units/unit_registry.dart';
export 'src/validation.dart';

// Calculateurs — rénal
export 'src/calculators/renal/ckd_epi.dart';
export 'src/calculators/renal/schwartz.dart';
export 'src/calculators/renal/proteinuria.dart';
export 'src/calculators/renal/urine_ratios.dart';

// Calculateurs — cardiométabolique
export 'src/calculators/metabolic/insulin_resistance.dart';
export 'src/calculators/metabolic/glycemic_conversions.dart';
export 'src/calculators/metabolic/lipids.dart';

// Calculateurs — ionogramme / biochimie générale
export 'src/calculators/ionogram/anion_gap.dart';
export 'src/calculators/ionogram/osmolality.dart';
export 'src/calculators/ionogram/sodium_correction.dart';
export 'src/calculators/ionogram/calcium_correction.dart';
export 'src/calculators/ionogram/misc_biochemistry.dart';

// Calculateurs — hémostase
export 'src/calculators/hemostasis/rosner_index.dart';
export 'src/calculators/hemostasis/inr.dart';
export 'src/calculators/hemostasis/isth_dic_score.dart';
export 'src/calculators/hemostasis/four_ts_score.dart';

export 'src/catalog.dart';
