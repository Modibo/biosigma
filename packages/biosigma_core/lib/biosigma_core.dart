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
export 'src/calculators/metabolic/anthropometric_and_ratios.dart';
export 'src/calculators/metabolic/cardiovascular_risk_scores.dart';

// Calculateurs — ionogramme / biochimie générale
export 'src/calculators/ionogram/anion_gap.dart';
export 'src/calculators/ionogram/osmolality.dart';
export 'src/calculators/ionogram/sodium_correction.dart';
export 'src/calculators/ionogram/calcium_correction.dart';
export 'src/calculators/ionogram/misc_biochemistry.dart';
export 'src/calculators/ionogram/hepatic_scores.dart';
export 'src/calculators/ionogram/acid_base_compensation.dart';

// Calculateurs — hémostase
export 'src/calculators/hemostasis/rosner_index.dart';
export 'src/calculators/hemostasis/inr.dart';
export 'src/calculators/hemostasis/isth_dic_score.dart';
export 'src/calculators/hemostasis/four_ts_score.dart';
export 'src/calculators/hemostasis/lupus_and_sepsis_coagulopathy.dart';
export 'src/calculators/hemostasis/afib_risk_scores.dart';
export 'src/calculators/hemostasis/hospitalized_vte_risk_scores.dart';
export 'src/calculators/hemostasis/caprini_score.dart';

// Calculateurs — hématologie (NFS, réticulocytes)
export 'src/calculators/hematology/microcytic_indices.dart';
export 'src/calculators/hematology/reticulocytes.dart';
export 'src/calculators/hematology/inflammation_indices.dart';

export 'src/lab/lab_units.dart';
export 'src/lab/convert.dart';
export 'src/lab/analyte_base.dart';
export 'src/lab/dilution.dart';
export 'src/lab/prepare.dart';
export 'src/lab/count.dart';
export 'src/lab/microbiology.dart';
export 'src/lab/quality.dart';
export 'src/lab/smart_solver.dart';
export 'src/lab/pipette.dart';

export 'src/catalog.dart';
export 'src/rounding.dart';
export 'src/registry/equation_registry.dart';
