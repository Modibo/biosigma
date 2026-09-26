import 'calculators/hematology/inflammation_indices.dart';
import 'calculators/hematology/microcytic_indices.dart';
import 'calculators/hematology/reticulocytes.dart';
import 'calculators/hemostasis/afib_risk_scores.dart';
import 'calculators/hemostasis/caprini_score.dart';
import 'calculators/hemostasis/four_ts_score.dart';
import 'calculators/hemostasis/hospitalized_vte_risk_scores.dart';
import 'calculators/hemostasis/inr.dart';
import 'calculators/hemostasis/isth_dic_score.dart';
import 'calculators/hemostasis/lupus_and_sepsis_coagulopathy.dart';
import 'calculators/hemostasis/rosner_index.dart';
import 'calculators/ionogram/acid_base_compensation.dart';
import 'calculators/ionogram/anion_gap.dart';
import 'calculators/ionogram/calcium_correction.dart';
import 'calculators/ionogram/hepatic_scores.dart';
import 'calculators/ionogram/misc_biochemistry.dart';
import 'calculators/ionogram/osmolality.dart';
import 'calculators/ionogram/sodium_correction.dart';
import 'calculators/metabolic/anthropometric_and_ratios.dart';
import 'calculators/metabolic/cardiovascular_risk_scores.dart';
import 'calculators/metabolic/glycemic_conversions.dart';
import 'calculators/metabolic/insulin_resistance.dart';
import 'calculators/metabolic/lipids.dart';
import 'calculators/renal/ckd_epi.dart';
import 'calculators/renal/proteinuria.dart';
import 'calculators/renal/schwartz.dart';
import 'calculators/renal/urine_ratios.dart';
import 'models/formula_meta.dart';

/// Registre déclaratif de toutes les métadonnées de calcul disponibles dans
/// BioSigma. Sert de source unique pour la recherche, les catégories et
/// l'écran des références de l'application — ne référence aucune fonction
/// de calcul (leurs signatures diffèrent par calculateur), seulement leurs
/// [FormulaMeta].
class CalculatorCatalog {
  CalculatorCatalog._();

  static const List<FormulaMeta> all = [
    // Rénal et urines
    ckdEpiCreatinine2021Meta,
    ckdEpiCystatinC2012Meta,
    ckdEpiCreatinineCystatinC2021Meta,
    schwartzBedsidePediatricMeta,
    proteinuria24hMeta,
    urineAlbuminCreatinineRatioMeta,
    urineProteinCreatinineRatioMeta,
    creatinineClearanceTimedMeta,
    fractionalExcretionSodiumMeta,
    fractionalExcretionUreaMeta,

    // Cardiométabolique
    quickiMeta,
    tygMeta,
    homaIrMeta,
    estimatedAverageGlucoseAdagMeta,
    ldlPanelMeta,
    atherogenicIndexOfPlasmaMeta,
    bmiMeta,
    tygBmiMeta,
    homaBetaMeta,
    ctHdlRatioMeta,
    apoBApoA1RatioMeta,
    framinghamRiskScoreMeta,
    score2RiskMeta,

    // Ionogramme et biochimie générale
    anionGapMeta,
    calculatedOsmolarityOsmolarGapMeta,
    correctedSodiumHyperglycemiaMeta,
    correctedCalciumAlbuminMeta,
    tibcFromTransferrinMeta,
    transferrinSaturationMeta,
    globulinsAgRatioMeta,
    indirectBilirubinMeta,
    astAltRatioDeRitisMeta,
    fib4Meta,
    apriMeta,
    meldNaMeta,
    albiScoreMeta,
    expectedAcidBaseCompensationMeta,
    bicarbonateChlorideRatioMeta,

    // Hémostase
    rosnerIndexMeta,
    inrMeta,
    apttRatioMeta,
    serialValueTrendMeta,
    isthDicScoreMeta,
    fourTsScoreMeta,
    drvvtNormalizedRatioMeta,
    sicScoreMeta,
    hasBledScoreMeta,
    cha2ds2VascScoreMeta,
    paduaPredictionScoreMeta,
    improveBleedingScoreMeta,
    capriniScoreMeta,

    // Hématologie (NFS, réticulocytes)
    mentzerIndexMeta,
    shineLalIndexMeta,
    englandFraserIndexMeta,
    greenKingIndexMeta,
    rdwIndexMeta,
    reticulocyteIndicesPanelMeta,
    siiIndexMeta,
    siriIndexMeta,
  ];

  static List<FormulaMeta> byCategory(CalculatorCategory category) =>
      all.where((meta) => meta.category == category).toList(growable: false);

  static FormulaMeta? byId(String id) {
    for (final meta in all) {
      if (meta.id == id) return meta;
    }
    return null;
  }

  /// Recherche simple insensible à la casse sur le nom, le nom court et
  /// l'id — utilisée par l'écran d'accueil de l'application.
  static List<FormulaMeta> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((meta) =>
            meta.name.toLowerCase().contains(q) ||
            meta.shortName.toLowerCase().contains(q) ||
            meta.id.toLowerCase().contains(q))
        .toList(growable: false);
  }
}
