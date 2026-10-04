// Entrées canoniques du « golden master » (backlog P0-02).
//
// Ces valeurs ne sont PAS des valeurs de référence scientifiques : elles
// servent uniquement à figer le comportement du code à la version
// `baseline-v1.6.0`, pour détecter toute modification silencieuse d'un
// résultat, d'une unité ou d'un avertissement. Elles ne valident aucune
// équation (voir docs/biosigma-lab/00-audit-et-architecture.md).

/// Valeur numérique, avec unité explicite (sinon unité par défaut du champ).
class N {
  const N(this.value, [this.unit]);
  final double value;
  final String? unit;
}

/// Valeur numérique avec l'unité par défaut du champ.
N n(num value, [String? unit]) => N(value.toDouble(), unit);

/// Indice de l'option d'une liste de choix.
class E {
  const E(this.index);
  final int index;
}

E e(int index) => E(index);

/// Entrées de base (un cas par équation). Les champs absents prennent la
/// valeur initiale de l'écran : nombre vide, case décochée, choix vide.
final Map<String, Map<String, Object>> goldenInputs = {
  'ckd_epi_creatinine_2021': {
    'age': n(60), 'sex': e(0), 'creatinine': n(70, 'µmol/L'), 'idmsConfirmed': true,
  },
  'ckd_epi_cystatin_c_2012': {
    'age': n(60), 'sex': e(0), 'cystatinC': n(1.0),
  },
  'ckd_epi_creatinine_cystatin_c_2021': {
    'age': n(60), 'sex': e(0), 'creatinine': n(70, 'µmol/L'), 'cystatinC': n(1.0),
    'idmsConfirmed': true,
  },
  'schwartz_bedside_pediatric': {
    'age': n(8), 'height': n(125), 'creatinine': n(45, 'µmol/L'),
  },
  'proteinuria_24h': {
    'concentration': n(300, 'mg/L'), 'volume': n(1500, 'mL'), 'duration': n(24, 'h'),
  },
  'urine_albumin_creatinine_ratio': {
    'albuminuria': n(30, 'mg/L'), 'creatinineUrine': n(8800, 'µmol/L'),
  },
  'urine_protein_creatinine_ratio': {
    'proteinuria': n(150, 'mg/L'), 'creatinineUrine': n(8800, 'µmol/L'),
  },
  'creatinine_clearance_timed': {
    'urineCreatinine': n(8800, 'µmol/L'), 'serumCreatinine': n(80, 'µmol/L'),
    'urineVolume': n(1440, 'mL'), 'duration': n(1440, 'min'),
  },
  'fractional_excretion_sodium': {
    'urineSodium': n(40), 'serumSodium': n(140),
    'urineCreatinine': n(8800, 'µmol/L'), 'serumCreatinine': n(80, 'µmol/L'),
  },
  'fractional_excretion_urea': {
    'urineUrea': n(200), 'serumUrea': n(6),
    'urineCreatinine': n(8800, 'µmol/L'), 'serumCreatinine': n(80, 'µmol/L'),
  },
  'quicki': {
    'fastingInsulin': n(15, 'µU/mL'), 'fastingGlucose': n(5, 'mmol/L'), 'fastingConfirmed': true,
  },
  'tyg_index': {
    'triglycerides': n(1.7, 'mmol/L'), 'fastingGlucose': n(5, 'mmol/L'), 'fastingConfirmed': true,
  },
  'homa_ir': {
    'fastingInsulin': n(10, 'µU/mL'), 'fastingGlucose': n(5, 'mmol/L'), 'fastingConfirmed': true,
  },
  'estimated_average_glucose_adag': {'hba1c': n(7.0, '%')},
  'ldl_panel': {
    'totalCholesterol': n(5.2, 'mmol/L'), 'hdl': n(1.3, 'mmol/L'),
    'triglycerides': n(1.5, 'mmol/L'), 'formula': e(0),
  },
  'atherogenic_index_of_plasma': {'triglycerides': n(1.5, 'mmol/L'), 'hdl': n(1.3, 'mmol/L')},
  'bmi': {'weightKg': n(70), 'heightCm': n(175)},
  'tyg_bmi': {
    'triglycerides': n(1.7, 'mmol/L'), 'fastingGlucose': n(5, 'mmol/L'),
    'weightKg': n(70), 'heightCm': n(175), 'fastingConfirmed': true,
  },
  'homa_beta': {
    'fastingInsulin': n(10, 'µU/mL'), 'fastingGlucose': n(5, 'mmol/L'), 'fastingConfirmed': true,
  },
  'ct_hdl_ratio': {'totalCholesterol': n(5.2, 'mmol/L'), 'hdl': n(1.3, 'mmol/L')},
  'apob_apoa1_ratio': {'apoB': n(1.0), 'apoA1': n(1.4)},
  'framingham_risk_score': {
    'age': n(55), 'sex': e(1), 'totalCholesterol': n(6.2, 'mmol/L'), 'hdl': n(1.2, 'mmol/L'),
    'systolicBloodPressure': n(145), 'treatedHypertension': false, 'currentSmoker': false,
  },
  'score2_risk': {
    'age': n(50), 'sex': e(1), 'region': e(0), 'totalCholesterol': n(5.5, 'mmol/L'),
    'hdl': n(1.3, 'mmol/L'), 'systolicBloodPressure': n(140), 'currentSmoker': true,
  },
  'anion_gap': {
    'sodium': n(140), 'chloride': n(104), 'bicarbonate': n(24), 'potassium': n(4.5),
    'albumin': n(40, 'g/L'),
  },
  'calculated_osmolarity_osmolar_gap': {
    'sodium': n(140), 'glucose': n(5.5, 'mmol/L'), 'urea': n(5), 'measuredOsmolality': n(290),
  },
  'corrected_sodium_hyperglycemia': {'sodiumMeasured': n(130), 'glucose': n(25, 'mmol/L')},
  'corrected_calcium_albumin': {'calcium': n(2.0, 'mmol/L'), 'albumin': n(30, 'g/L')},
  'tibc_from_transferrin': {'transferrin': n(250)},
  'transferrin_saturation': {'serumIron': n(80), 'tibc': n(350)},
  'globulins_ag_ratio': {'totalProtein': n(72, 'g/L'), 'albumin': n(42, 'g/L')},
  'indirect_bilirubin': {'totalBilirubin': n(20), 'directBilirubin': n(5)},
  'ast_alt_ratio_de_ritis': {'ast': n(40), 'alt': n(30)},
  'fib4': {'age': n(50), 'ast': n(40), 'platelets': n(200), 'alt': n(35)},
  'apri': {'ast': n(60), 'astUln': n(40), 'platelets': n(150)},
  'meld_na': {
    'creatinine': n(100, 'µmol/L'), 'bilirubin': n(50), 'inr': n(1.5), 'sodium': n(135),
    'onDialysis': false,
  },
  'albi_score': {'bilirubin': n(20), 'albumin': n(40, 'g/L')},
  'expected_acid_base_compensation': {'disorder': e(0), 'hco3': n(15), 'paco2': n(30)},
  'bicarbonate_chloride_ratio': {'bicarbonate': n(24), 'chloride': n(104)},
  'rosner_index': {
    'mixTime': n(38), 'normalPlasmaTime': n(12), 'patientPlasmaTime': n(70), 'phase': e(0),
  },
  'inr': {'patientPt': n(28), 'meanNormalPt': n(12), 'isi': n(1.2)},
  'aptt_ratio': {'patientApt': n(45), 'controlApt': n(30)},
  'serial_value_trend': {
    'analyteLabel': 'Créatinine', 'previousValue': n(80), 'currentValue': n(95),
  },
  'drvvt_normalized_ratio': {
    'patientScreen': n(45), 'normalScreen': n(35), 'patientConfirm': n(38), 'normalConfirm': n(33),
  },
  'sic_score': {'plateletCount': n(90), 'inr': n(1.5), 'sofaRespiratoryCardiovascularSubscore': n(2)},
  'has_bled_score': {
    'hypertensionUncontrolled': true, 'age': n(70), 'antiplateletOrNsaidUse': true,
  },
  'cha2ds2_vasc_score': {
    'congestiveHeartFailureOrLvDysfunction': true, 'hypertension': true, 'age': n(70),
    'female': true,
  },
  'padua_prediction_score': {'age': n(72), 'activeCancer': true, 'reducedMobility': true},
  'improve_bleeding_score': {
    'age': n(70), 'sex': e(1), 'gfr': n(45), 'plateletCount': n(120), 'inr': n(1.2),
    'currentCancer': true,
  },
  'caprini_score': {
    'age41to60': true, 'minorSurgeryPlanned': true, 'majorOpenSurgeryOver45Minutes': true,
    'malignancyCurrentOrPrevious': true, 'obesityBmiOver25': true,
  },
  'mentzer_index': {'mcv': n(70), 'rbc': n(5.5)},
  'shine_lal_index': {'mcv': n(70), 'mch': n(22)},
  'england_fraser_index': {'mcv': n(70), 'rbc': n(5.5), 'hb': n(10)},
  'green_king_index': {'mcv': n(70), 'rdw': n(20), 'hb': n(10)},
  'rdw_index': {'mcv': n(70), 'rdw': n(20), 'rbc': n(5.5)},
  'reticulocyte_indices_panel': {'reticulocytes': n(2.0), 'rbc': n(3.0), 'hematocrit': n(35)},
  'sii_index': {'platelets': n(250), 'neutrophils': n(6), 'lymphocytes': n(2)},
  'siri_index': {'neutrophils': n(6), 'monocytes': n(0.8), 'lymphocytes': n(2)},
  'red_cell_indices': {'hemoglobin': n(15), 'hematocrit': n(45), 'rbc': n(5)},
  'absolute_leukocyte_counts': {
    'wbc': n(8), 'neutrophils': n(60), 'bands': n(5), 'lymphocytes': n(30),
  },
};
