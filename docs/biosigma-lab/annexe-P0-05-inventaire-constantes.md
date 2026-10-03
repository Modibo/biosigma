# Annexe P0-05 — Inventaire des constantes numériques du moteur (existant)

> **Génération** : extraction mécanique en lecture seule le 2026-10-03 (commit de référence `cf1beae`), sur `packages/biosigma_core/lib/src/calculators` et `src/units`. Chaque ligne est la ligne de code telle qu'elle est écrite ; **rien n'a été retranscrit de mémoire**.
> **Ce que c'est** : les endroits où un nombre autre que 0, 1 ou 2 apparaît *dans le code* (coefficients, facteurs de conversion, bornes de validation, seuils d'interprétation codés en conditions), et les textes affichés qui citent un seuil (`≥`, `≤`, `<`, `>` ou « seuil »). Les références bibliographiques et les libellés d'unités sont volontairement exclus.
> **Ce que ce n'est pas** : ni une validation scientifique, ni un classement. Le tri entre *coefficient de la formule*, *seuil d'interprétation*, *borne de validation* et *facteur de conversion* reste à faire, constante par constante, avec sa source (suite de la phase 0, à autoriser). Les nombres 0, 1 et 2 ne sont pas détectés, ni les seuils écrits sans signe de comparaison ni mot-clé : l'inventaire n'est donc **pas garanti exhaustif** (limite connue).

**503 lignes dans 27 fichiers** (339 littéraux dans le code, 164 seuils cités dans des textes).


## `src/calculators/hematology/microcytic_indices.dart` (21)

| Ligne | Nature | Code |
|---|---|---|
| 47 | seuil cité dans un texte affiché | `'Un seuil indicatif de 13 a été proposé par Mentzer (valeur < 13 '` |
| 48 | seuil cité dans un texte affiché | `'évocatrice de trait thalassémique, > 13 évocatrice de carence '` |
| 70 | littéral numérique dans le code | `final directional = index < 13` |
| 72 | seuil cité dans un texte affiché | `"thalassémique qu'une carence martiale (seuil de 13 proposé par "` |
| 75 | seuil cité dans un texte affiché | `"martiale qu'un trait thalassémique (seuil de 13 proposé par "` |
| 131 | seuil cité dans un texte affiché | `'Un seuil indicatif de 1760 a été proposé par les auteurs (valeur '` |
| 132 | seuil cité dans un texte affiché | `'< 1760 évocatrice de trait thalassémique) ; ce seuil est '` |
| 152 | littéral numérique dans le code | `final index = (mcvFl * mcvFl * mchPg) / 100;` |
| 154 | littéral numérique dans le code | `final directional = index < 1760` |
| 156 | seuil cité dans un texte affiché | `'trait thalassémique (seuil de 1760 proposé par Shine & Lal, '` |
| 159 | seuil cité dans un texte affiché | `"carence martiale qu'un trait thalassémique (seuil de 1760 "` |
| 242 | littéral numérique dans le code | `final index = mcvFl - rbcTeraL - (5 * hbGDl) - 3.4;` |
| 313 | seuil cité dans un texte affiché | `'Un seuil indicatif de 72 a été proposé par les auteurs (valeur ≤ 72 '` |
| 335 | littéral numérique dans le code | `final index = (mcvFl * mcvFl * rdwPercent) / (hbGDl * 100);` |
| 337 | littéral numérique dans le code | `final directional = index <= 72` |
| 339 | seuil cité dans un texte affiché | `'trait thalassémique (seuil de 72 proposé par Green & King, '` |
| 417 | seuil cité dans un texte affiché | `'Un seuil indicatif de 220 a été proposé (valeur > 220 évocatrice de '` |
| 418 | seuil cité dans un texte affiché | `'carence martiale, < 220 évocatrice de trait thalassémique) ; ce '` |
| 442 | littéral numérique dans le code | `final directional = index >= 220` |
| 444 | seuil cité dans un texte affiché | `'(seuil de 220 rapporté par Jayabose et al., 1999).'` |
| 446 | seuil cité dans un texte affiché | `'(seuil de 220 rapporté par Jayabose et al., 1999).';` |

## `src/calculators/hematology/reticulocytes.dart` (11)

| Ligne | Nature | Code |
|---|---|---|
| 24 | littéral numérique dans le code | `if (hematocritPercent >= 40) return 1.0;` |
| 25 | littéral numérique dans le code | `if (hematocritPercent >= 30) return 1.5;` |
| 26 | littéral numérique dans le code | `if (hematocritPercent >= 20) return 2.0;` |
| 27 | littéral numérique dans le code | `return 2.5;` |
| 42 | seuil cité dans un texte affiché | `'maturation = 1,0 si Hct ≥ 40 % ; 1,5 si 30–39,9 % ; 2,0 si '` |
| 43 | seuil cité dans un texte affiché | `'20–29,9 % ; 2,5 si < 20 %',` |
| 63 | seuil cité dans un texte affiché | `'Non valide en cas de transfusion récente (< 2-3 jours) : le compte '` |
| 95 | littéral numérique dans le code | `final absoluteCount = (reticulocytePercent / 100) * rbcTeraL * 1000;` |
| 96 | littéral numérique dans le code | `final correctedRetic = reticulocytePercent * (hematocritPercent / 45);` |
| 131 | seuil cité dans un texte affiché | `? 'RPI < 2 : évocateur d\'une réponse médullaire inadaptée '` |
| 139 | seuil cité dans un texte affiché | `: 'RPI ≥ 2 (typiquement 2 à 3 ou plus) : évocateur d\'une '` |

## `src/calculators/hemostasis/afib_risk_scores.dart` (17)

| Ligne | Nature | Code |
|---|---|---|
| 71 | seuil cité dans un texte affiché | `'0-1 point = risque faible, 2 points = risque modéré, ≥ 3 points = '` |
| 105 | littéral numérique dans le code | `min: 18,` |
| 106 | littéral numérique dans le code | `max: 120,` |
| 116 | littéral numérique dans le code | `final elderlyPoints = ageYears > 65 ? 1 : 0;` |
| 131 | littéral numérique dans le code | `if (total >= 3) {` |
| 142 | seuil cité dans un texte affiché | `'Hypertension non contrôlée (PAS > 160 mmHg)':` |
| 148 | seuil cité dans un texte affiché | `'INR labile (TTR < 60 %)': labileInr ? 'Oui → 1 point' : 'Non → 0 point',` |
| 152 | seuil cité dans un texte affiché | `'Alcool excessif (≥ 8 verres/semaine)': alcoholExcess ? 'Oui → 1 point' : 'Non → 0 point',` |
| 160 | seuil cité dans un texte affiché | `'0-1 = faible, 2 = modéré, ≥ 3 = élevé, dérivée de Pisters et al. '` |
| 228 | seuil cité dans un texte affiché | `'formelle (classe I) sur un score ≥ 2 chez l\'homme et ≥ 3 chez '` |
| 266 | littéral numérique dans le code | `min: 18,` |
| 267 | littéral numérique dans le code | `max: 120,` |
| 273 | littéral numérique dans le code | `final agePoints = ageYears >= 75` |
| 275 | littéral numérique dans le code | `: ageYears >= 65` |
| 306 | seuil cité dans un texte affiché | `'I) : score ≥ 2 chez un homme.';` |
| 322 | seuil cité dans un texte affiché | `'I) : score ≥ 3 chez une femme.';` |
| 352 | seuil cité dans un texte affiché | `'Circulation 2024;149(1):e1-e156) : ≥ 2 chez l\'homme ou ≥ 3 '` |

## `src/calculators/hemostasis/caprini_score.dart` (18)

| Ligne | Nature | Code |
|---|---|---|
| 124 | seuil cité dans un texte affiché | `'Chirurgie mineure prévue (< 45 min)': minorSurgeryPlanned,` |
| 130 | seuil cité dans un texte affiché | `'Obésité (IMC > 25)': obesityBmiOver25,` |
| 132 | seuil cité dans un texte affiché | `'Insuffisance cardiaque congestive (< 1 mois)':` |
| 134 | seuil cité dans un texte affiché | `'Sepsis (< 1 mois)': sepsisUnder1Month,` |
| 135 | seuil cité dans un texte affiché | `'Maladie pulmonaire grave dont pneumopathie (< 1 mois)':` |
| 140 | seuil cité dans un texte affiché | `'Grossesse ou post-partum (< 1 mois)': pregnancyOrPostpartumUnder1Month,` |
| 152 | seuil cité dans un texte affiché | `'Chirurgie majeure ouverte (> 45 min)': majorOpenSurgeryOver45Minutes,` |
| 153 | seuil cité dans un texte affiché | `'Chirurgie laparoscopique (> 45 min)': laparoscopicSurgeryOver45Minutes,` |
| 154 | seuil cité dans un texte affiché | `'Alitement/confinement au lit (> 72 h)': bedConfinementOver72Hours,` |
| 160 | seuil cité dans un texte affiché | `'Âge ≥ 75 ans': age75OrOlder,` |
| 180 | seuil cité dans un texte affiché | `'Fracture de la hanche, du bassin ou d\'un membre inférieur (< 1 mois)':` |
| 182 | seuil cité dans un texte affiché | `'AVC (< 1 mois)': strokeUnder1Month,` |
| 183 | seuil cité dans un texte affiché | `'Traumatisme multiple/grave (< 1 mois)': multipleTraumaUnder1Month,` |
| 184 | seuil cité dans un texte affiché | `'Lésion médullaire aiguë avec paralysie (< 1 mois)':` |
| 198 | littéral numérique dans le code | `threePointCount * 3 +` |
| 199 | littéral numérique dans le code | `fivePointCount * 5;` |
| 216 | littéral numérique dans le code | `} else if (total <= 4) {` |
| 222 | seuil cité dans un texte affiché | `'Score ≥ 5 : risque élevé selon les catégories ACCP/CHEST (Gould '` |

## `src/calculators/hemostasis/four_ts_score.dart` (7)

| Ligne | Nature | Code |
|---|---|---|
| 7 | seuil cité dans un texte affiché | `twoPoints(2, 'Chute des plaquettes > 50 % ET nadir ≥ 20 G/L'),` |
| 9 | seuil cité dans un texte affiché | `zeroPoint(0, 'Chute des plaquettes < 30 % OU nadir < 10 G/L');` |
| 19 | seuil cité dans un texte affiché | `'Début net entre le 5e et le 10e jour, ou chute ≤ 1 jour si exposition à l\'héparine dans les 30 derniers jours'),` |
| 21 | seuil cité dans un texte affiché | `'Chute compatible avec le 5e-10e jour mais mal documentée, ou début après le 10e jour, ou chute ≤ 1 jour si exposition 30-100 jours auparavant'),` |
| 23 | seuil cité dans un texte affiché | `'Chute des plaquettes récente (< 4 jours) sans exposition récente à l\'héparine');` |
| 137 | littéral numérique dans le code | `total >= 6` |
| 141 | littéral numérique dans le code | `: (total >= 4` |

## `src/calculators/hemostasis/hospitalized_vte_risk_scores.dart` (53)

| Ligne | Nature | Code |
|---|---|---|
| 27 | seuil cité dans un texte affiché | `'toilettes) ≥ 3 jours] + 3×[thrombophilie connue] + 2×[traumatisme '` |
| 28 | seuil cité dans un texte affiché | `'et/ou chirurgie récent(e), ≤ 1 mois] + 1×[âge ≥ 70 ans] + '` |
| 31 | seuil cité dans un texte affiché | `'rhumatologique] + 1×[obésité, IMC ≥ 30] + 1×[traitement hormonal en '` |
| 51 | seuil cité dans un texte affiché | `'Recommande l\'utilisation du score de Padua (seuil ≥ 4) pour '` |
| 58 | seuil cité dans un texte affiché | `'Patient adulte (≥ 18 ans) hospitalisé en service de médecine (non '` |
| 62 | seuil cité dans un texte affiché | `'Un score ≥ 4 définit le risque élevé de maladie thromboembolique '` |
| 64 | seuil cité dans un texte affiché | `"indiquée en l'absence de contre-indication) ; un score < 4 "` |
| 112 | littéral numérique dans le code | `Validation.checkInRange(ageYears, 'ageYears', 'Âge', min: 18, max: 120);` |
| 115 | littéral numérique dans le code | `final ageOver70 = ageYears >= 70;` |
| 125 | seuil cité dans un texte affiché | `'≥ 3 jours)':` |
| 132 | seuil cité dans un texte affiché | `'Traumatisme et/ou chirurgie récent(e) (≤ 1 mois)': recentTraumaOrSurgery,` |
| 136 | seuil cité dans un texte affiché | `'Âge ≥ 70 ans': ageOver70,` |
| 142 | seuil cité dans un texte affiché | `'Obésité (IMC ≥ 30)': obesityBmiOver30,` |
| 158 | littéral numérique dans le code | `final total = threeCount * 3 + twoCount * 2 + oneCount * 1;` |
| 160 | littéral numérique dans le code | `final highRisk = total >= 4;` |
| 184 | seuil cité dans un texte affiché | `? 'Score ≥ 4 : risque élevé de maladie thromboembolique '` |
| 190 | seuil cité dans un texte affiché | `: 'Score < 4 : risque faible de maladie thromboembolique '` |
| 218 | seuil cité dans un texte affiché | `'continus] + 2,5×[insuffisance rénale sévère, DFG < 30 mL/min/'` |
| 219 | seuil cité dans un texte affiché | `'1,73 m²] + 2,5×[insuffisance hépatique, INR > 1,5] + 3,5×[âge '` |
| 220 | seuil cité dans un texte affiché | `'≥ 85 ans] + 4×[plaquettes < 50×10⁹/L] + 4×[saignement dans les 3 '` |
| 246 | seuil cité dans un texte affiché | `'hémorragique (score IMPROVE, seuil ≥ 7) avant toute '` |
| 251 | seuil cité dans un texte affiché | `'Patient adulte (≥ 18 ans) hospitalisé en service de médecine, pour '` |
| 261 | seuil cité dans un texte affiché | `'Un score ≥ 7 définit le risque hémorragique élevé ; un score < 7 '` |
| 264 | seuil cité dans un texte affiché | `'Les paliers d\'âge (< 40 / 40-84 / ≥ 85 ans) et de fonction rénale '` |
| 265 | seuil cité dans un texte affiché | `'(≥ 60 / 30-59 / < 30 mL/min/1,73 m²) sont mutuellement exclusifs : '` |
| 298 | littéral numérique dans le code | `Validation.checkInRange(ageYears, 'ageYears', 'Âge', min: 18, max: 120);` |
| 301 | littéral numérique dans le code | `min: 0, max: 250);` |
| 309 | littéral numérique dans le code | `if (ageYears >= 85) {` |
| 310 | littéral numérique dans le code | `agePoints = 3.5;` |
| 311 | seuil cité dans un texte affiché | `ageLabel = 'Âge ≥ 85 ans';` |
| 312 | littéral numérique dans le code | `} else if (ageYears >= 40) {` |
| 313 | littéral numérique dans le code | `agePoints = 1.5;` |
| 317 | seuil cité dans un texte affiché | `ageLabel = 'Âge < 40 ans';` |
| 322 | littéral numérique dans le code | `if (gfrMlMin173m2 < 30) {` |
| 323 | littéral numérique dans le code | `renalPoints = 2.5;` |
| 324 | seuil cité dans un texte affiché | `renalLabel = 'Insuffisance rénale sévère (DFG < 30 mL/min/1,73 m²)';` |
| 325 | littéral numérique dans le code | `} else if (gfrMlMin173m2 < 60) {` |
| 330 | seuil cité dans un texte affiché | `renalLabel = 'DFG ≥ 60 mL/min/1,73 m² (pas de majoration)';` |
| 333 | littéral numérique dans le code | `final sexPoints = sex == Sex.male ? 1.0 : 0.0;` |
| 334 | littéral numérique dans le code | `final hepaticFailure = inr > 1.5;` |
| 335 | littéral numérique dans le code | `final hepaticPoints = hepaticFailure ? 2.5 : 0.0;` |
| 336 | littéral numérique dans le code | `final thrombocytopenia = plateletCountGL < 50;` |
| 337 | littéral numérique dans le code | `final plateletPoints = thrombocytopenia ? 4.0 : 0.0;` |
| 338 | littéral numérique dans le code | `final icuPoints = icuOrCcuAdmission ? 2.5 : 0.0;` |
| 339 | littéral numérique dans le code | `final cvcPoints = centralVenousCatheter ? 2.0 : 0.0;` |
| 340 | littéral numérique dans le code | `final rheumaticPoints = rheumaticDisease ? 2.0 : 0.0;` |
| 341 | littéral numérique dans le code | `final cancerPoints = currentCancer ? 2.0 : 0.0;` |
| 342 | littéral numérique dans le code | `final ulcerPoints = activeGastroduodenalUlcer ? 4.5 : 0.0;` |
| 343 | littéral numérique dans le code | `final bleedingPoints = bleedingInPrior3Months ? 4.0 : 0.0;` |
| 357 | littéral numérique dans le code | `final highRisk = total >= 7;` |
| 361 | seuil cité dans un texte affiché | `if (hepaticFailure) 'Insuffisance hépatique, INR > 1,5 (2,5 pt)',` |
| 362 | seuil cité dans un texte affiché | `if (thrombocytopenia) 'Plaquettes < 50×10⁹/L (4 pt)',` |
| 398 | seuil cité dans un texte affiché | `? 'Score ≥ 7 : risque hémorragique élevé selon les critères '` |

## `src/calculators/hemostasis/inr.dart` (2)

| Ligne | Nature | Code |
|---|---|---|
| 72 | seuil cité dans un texte affiché | `'TP moyen normal du laboratoire': '${meanNormalPtSeconds.toStringAsFixed(1)} s',` |
| 211 | littéral numérique dans le code | `final percentChange = (currentValue - previousValue) / previousValue * 100;` |

## `src/calculators/hemostasis/isth_dic_score.dart` (8)

| Ligne | Nature | Code |
|---|---|---|
| 12 | littéral numérique dans le code | `strong(3, 'Augmentation forte');` |
| 111 | littéral numérique dans le code | `final plateletPoints = plateletCountGL < 50` |
| 113 | littéral numérique dans le code | `: plateletCountGL < 100` |
| 119 | littéral numérique dans le code | `final ptPoints = ptProlongationSeconds < 3` |
| 121 | littéral numérique dans le code | `: ptProlongationSeconds < 6` |
| 127 | littéral numérique dans le code | `final fibrinogenPoints = fibrinogenCanonicalGL > 1.0 ? 0 : 1;` |
| 150 | littéral numérique dans le code | `total >= 5` |
| 151 | seuil cité dans un texte affiché | `? 'Score ≥ 5 : compatible avec une CIVD manifeste '` |

## `src/calculators/hemostasis/lupus_and_sepsis_coagulopathy.dart` (12)

| Ligne | Nature | Code |
|---|---|---|
| 78 | littéral numérique dans le code | `final percentCorrection = (screenRatio - confirmRatio) / screenRatio * 100;` |
| 84 | seuil cité dans un texte affiché | `'Temps de dépistage plasma normal': '${normalScreenSeconds.toStringAsFixed(1)} s',` |
| 86 | seuil cité dans un texte affiché | `'Temps de confirmation plasma normal': '${normalConfirmSeconds.toStringAsFixed(1)} s',` |
| 140 | seuil cité dans un texte affiché | `'Un score total ≥ 4 définit la coagulopathie induite par le sepsis '` |
| 169 | littéral numérique dans le code | `max: 4,` |
| 173 | littéral numérique dans le code | `final plateletPoints = plateletCountGL >= 150` |
| 175 | littéral numérique dans le code | `: plateletCountGL >= 100` |
| 179 | littéral numérique dans le code | `final inrPoints = inr <= 1.2` |
| 181 | littéral numérique dans le code | `: inr <= 1.4` |
| 212 | littéral numérique dans le code | `total >= 4` |
| 213 | seuil cité dans un texte affiché | `? 'Score ≥ 4 : compatible avec une coagulopathie induite par '` |
| 216 | seuil cité dans un texte affiché | `: 'Score < 4 : ne répond pas au seuil de coagulopathie induite '` |

## `src/calculators/hemostasis/rosner_index.dart` (4)

| Ligne | Nature | Code |
|---|---|---|
| 68 | littéral numérique dans le code | `(mixTimeSeconds - normalPlasmaTimeSeconds) / patientPlasmaTimeSeconds * 100;` |
| 70 | littéral numérique dans le code | `final interpretation = index < 15` |
| 83 | seuil cité dans un texte affiché | `'TCA plasma témoin normal': '${normalPlasmaTimeSeconds.toStringAsFixed(1)} s',` |
| 96 | seuil cité dans un texte affiché | `'$interpretation Ce seuil de 15 % correspond à la convention '` |

## `src/calculators/ionogram/acid_base_compensation.dart` (12)

| Ligne | Nature | Code |
|---|---|---|
| 125 | littéral numérique dans le code | `? Validation.checkInRange(measuredValue, 'measuredValue', fieldLabel, min: 3, max: 60)` |
| 127 | littéral numérique dans le code | `: Validation.checkInRange(measuredValue, 'measuredValue', fieldLabel, min: 10, max: 150),` |
| 137 | littéral numérique dans le code | `central = (1.5 * measuredValue) + 8;` |
| 142 | littéral numérique dans le code | `central = 40 + 0.7 * (measuredValue - 24);` |
| 143 | littéral numérique dans le code | `halfRange = 5;` |
| 147 | littéral numérique dans le code | `central = 24 + 0.1 * (measuredValue - 40);` |
| 148 | littéral numérique dans le code | `halfRange = 3;` |
| 152 | littéral numérique dans le code | `central = 24 + 0.35 * (measuredValue - 40);` |
| 153 | littéral numérique dans le code | `halfRange = 4;` |
| 157 | littéral numérique dans le code | `central = 24 - 0.2 * (40 - measuredValue);` |
| 162 | littéral numérique dans le code | `central = 24 - 0.4 * (40 - measuredValue);` |
| 163 | littéral numérique dans le code | `halfRange = 4;` |

## `src/calculators/ionogram/anion_gap.dart` (3)

| Ligne | Nature | Code |
|---|---|---|
| 72 | littéral numérique dans le code | `if (agSansK < 8) {` |
| 74 | littéral numérique dans le code | `} else if (agSansK <= 12) {` |
| 126 | littéral numérique dans le code | `final agCorrige = agSansK + 2.5 * (4.0 - albuminGDl);` |

## `src/calculators/ionogram/calcium_correction.dart` (6)

| Ligne | Nature | Code |
|---|---|---|
| 59 | littéral numérique dans le code | `final correctedMgDl = calciumMgDl + 0.8 * (4.0 - albuminGDl);` |
| 64 | littéral numérique dans le code | `if (correctedMgDl < 8.5) {` |
| 66 | littéral numérique dans le code | `} else if (correctedMgDl <= 10.5) {` |
| 98 | seuil cité dans un texte affiché | `'hypocalcémie < 8,5 mg/dL [< 2,10 mmol/L] ; normal '` |
| 99 | seuil cité dans un texte affiché | `'8,5-10,5 mg/dL [2,10-2,55 mmol/L] ; hypercalcémie > 10,5 mg/dL '` |
| 100 | seuil cité dans un texte affiché | `'[> 2,55 mmol/L]).',` |

## `src/calculators/ionogram/hepatic_scores.dart` (38)

| Ligne | Nature | Code |
|---|---|---|
| 40 | seuil cité dans un texte affiché | `'≥ 2 fois/semaine ou hémodiafiltration continue ≥ 24 h dans la '` |
| 42 | seuil cité dans un texte affiché | `'Si MELD ≤ 11 : MELD-Na = MELD  ;  '` |
| 43 | seuil cité dans un texte affiché | `'Si MELD > 11 : MELD-Na = MELD + 1,32×(137 − Na) − '` |
| 70 | seuil cité dans un texte affiché | `applicablePopulation: 'Adulte ≥ 18 ans',` |
| 72 | seuil cité dans un texte affiché | `'Âge < 18 ans (utiliser le score pédiatrique PELD, non implémenté dans '` |
| 83 | seuil cité dans un texte affiché | `'mesurée > 4,0 mg/dL n\'est pas plafonnée dans cette implémentation '` |
| 115 | littéral numérique dans le code | `Validation.checkInRange(sodiumMmolL, 'sodiumMmolL', 'Sodium', min: 100, max: 170),` |
| 125 | littéral numérique dans le code | `final bilirubinMgDl = bilirubinUmolL / 17.1;` |
| 128 | littéral numérique dans le code | `final bilirubinForMeld = bilirubinMgDl < 1.0 ? 1.0 : bilirubinMgDl;` |
| 129 | littéral numérique dans le code | `final inrForMeld = inr < 1.0 ? 1.0 : inr;` |
| 134 | littéral numérique dans le code | `onDialysis ? 4.0 : (creatinineMgDl < 1.0 ? 1.0 : creatinineMgDl);` |
| 136 | littéral numérique dans le code | `final meldRaw = 3.78 * _ln(bilirubinForMeld) +` |
| 137 | littéral numérique dans le code | `11.2 * _ln(inrForMeld) +` |
| 138 | littéral numérique dans le code | `9.57 * _ln(creatinineForMeld) +` |
| 139 | littéral numérique dans le code | `6.43;` |
| 140 | littéral numérique dans le code | `final meld = meldRaw.clamp(6.0, 40.0);` |
| 144 | littéral numérique dans le code | `if (meld <= 11) {` |
| 147 | littéral numérique dans le code | `final sodiumClamped = sodiumMmolL.clamp(125.0, 137.0);` |
| 150 | littéral numérique dans le code | `1.32 * (137 - sodiumClamped) -` |
| 151 | littéral numérique dans le code | `(0.033 * meld * (137 - sodiumClamped));` |
| 153 | littéral numérique dans le code | `meldNa = meldNa.clamp(6.0, 40.0);` |
| 156 | littéral numérique dans le code | `if (meldNa < 10) {` |
| 158 | littéral numérique dans le code | `} else if (meldNa < 20) {` |
| 160 | littéral numérique dans le code | `} else if (meldNa < 30) {` |
| 162 | littéral numérique dans le code | `} else if (meldNa < 40) {` |
| 181 | seuil cité dans un texte affiché | `: '${sodiumMmolL.toStringAsFixed(1)} mmol/L (non utilisé : MELD ≤ 11)',` |
| 182 | seuil cité dans un texte affiché | `'Dialyse / hémodiafiltration continue ≥ 24 h': onDialysis ? 'Oui' : 'Non',` |
| 203 | seuil cité dans un texte affiché | `'Wiesner et al. 2003) — bandes qualitatives indicatives (< 10 '` |
| 204 | seuil cité dans un texte affiché | `'faible ; 10-19 modéré ; 20-29 important ; 30-39 élevé ; ≥ 40 très '` |
| 244 | seuil cité dans un texte affiché | `'Les seuils de grade ALBI publiés par Johnson et al. 2015 sont fournis '` |
| 245 | seuil cité dans un texte affiché | `'ici à titre informatif uniquement — grade 1 : ALBI ≤ −2,60 ; '` |
| 246 | seuil cité dans un texte affiché | `'grade 2 : −2,60 < ALBI ≤ −1,39 ; grade 3 : ALBI > −1,39. BioSigma '` |
| 271 | littéral numérique dans le code | `final albi = (_log10(bilirubinUmolL) * 0.66) + (albuminGL * -0.0852);` |
| 274 | littéral numérique dans le code | `if (albi <= -2.60) {` |
| 275 | seuil cité dans un texte affiché | `grade = 'Grade ALBI 1 (ALBI ≤ −2,60)';` |
| 276 | littéral numérique dans le code | `} else if (albi <= -1.39) {` |
| 277 | seuil cité dans un texte affiché | `grade = 'Grade ALBI 2 (−2,60 < ALBI ≤ −1,39)';` |
| 279 | seuil cité dans un texte affiché | `grade = 'Grade ALBI 3 (ALBI > −1,39)';` |

## `src/calculators/ionogram/misc_biochemistry.dart` (25)

| Ligne | Nature | Code |
|---|---|---|
| 46 | littéral numérique dans le code | `final tibc = transferrinMgDl * 1.42;` |
| 121 | littéral numérique dans le code | `final tsat = serumIronUgDl / tibcUgDl * 100;` |
| 124 | littéral numérique dans le code | `if (tsat > 45) {` |
| 126 | seuil cité dans un texte affiché | `'Saturation > 45 % : seuil de dépistage retenu par l\'AASLD 2011 '` |
| 129 | littéral numérique dans le code | `} else if (tsat < 20) {` |
| 131 | seuil cité dans un texte affiché | `'Saturation < 20 % : évocatrice d\'une carence en fer.';` |
| 241 | seuil cité dans un texte affiché | `? 'Rapport A/G bas ou inversé (< 1) : repère d\'enseignement '` |
| 247 | seuil cité dans un texte affiché | `: 'Rapport A/G ≥ 1 : dans la zone habituelle (repère '` |
| 249 | seuil cité dans un texte affiché | `'bas ou inversé, < 1, est classiquement associé à la '` |
| 376 | seuil cité dans un texte affiché | `'Rapport > 2 : évocateur d\'une hépatite alcoolique, selon un '` |
| 382 | seuil cité dans un texte affiché | `'Rapport < 1 : plus typique d\'une hépatite virale ou de la '` |
| 469 | littéral numérique dans le code | `if (fib4 < 1.30) {` |
| 470 | seuil cité dans un texte affiché | `interpretation = 'FIB-4 < 1,30 : faible probabilité de fibrose avancée.';` |
| 471 | littéral numérique dans le code | `} else if (fib4 <= 2.67) {` |
| 474 | seuil cité dans un texte affiché | `interpretation = 'FIB-4 > 2,67 : forte probabilité de fibrose avancée.';` |
| 529 | seuil cité dans un texte affiché | `note: "seuil de cirrhose (APRI > 2,0) endossé formellement par l'OMS "` |
| 530 | seuil cité dans un texte affiché | `'; les seuils de fibrose significative (≤ 0,5 / > 1,5) '` |
| 554 | littéral numérique dans le code | `final apri = (astUL / astUln * 100) / plateletsGL;` |
| 557 | littéral numérique dans le code | `if (apri <= 0.5) {` |
| 558 | seuil cité dans un texte affiché | `interpretation = 'APRI ≤ 0,5 : faible probabilité de fibrose '` |
| 561 | littéral numérique dans le code | `} else if (apri <= 1.5) {` |
| 563 | littéral numérique dans le code | `} else if (apri <= 2.0) {` |
| 564 | seuil cité dans un texte affiché | `interpretation = 'APRI > 1,5 : évocateur d\'une fibrose significative '` |
| 565 | seuil cité dans un texte affiché | `'(seuil de la cohorte de dérivation, Wai et al. 2003).';` |
| 567 | seuil cité dans un texte affiché | `interpretation = 'APRI > 2,0 : évocateur d\'une cirrhose — seuil '` |

## `src/calculators/ionogram/osmolality.dart` (2)

| Ligne | Nature | Code |
|---|---|---|
| 98 | littéral numérique dans le code | `final gapCategory = trouOsmolaire > 10 ? 'élevé' : 'non élevé';` |
| 101 | seuil cité dans un texte affiché | `'toxicologie clinique : > 10 mOsm/kg considéré comme élevé — nous '` |

## `src/calculators/ionogram/sodium_correction.dart` (8)

| Ligne | Nature | Code |
|---|---|---|
| 60 | littéral numérique dans le code | `final correctionKatz = sodiumValue + 1.6 * (glucoseMgDl - 100) / 100;` |
| 61 | littéral numérique dans le code | `final correctionHillier = sodiumValue + 2.4 * (glucoseMgDl - 100) / 100;` |
| 64 | littéral numérique dans le code | `if (value < 135) return 'hyponatrémie';` |
| 65 | littéral numérique dans le code | `if (value <= 145) return 'normal';` |
| 70 | littéral numérique dans le code | `if (glucoseMgDl <= 100) {` |
| 72 | seuil cité dans un texte affiché | `'Correction peu pertinente pour une glycémie ≤ 1,00 g/L (5,55 mmol/L).',` |
| 78 | seuil cité dans un texte affiché | `'clinique standard) : < 135 mmol/L hyponatrémie, 135-145 mmol/L '` |
| 79 | seuil cité dans un texte affiché | `'normal, > 145 mmol/L hypernatrémie — appliqués ici à la valeur '` |

## `src/calculators/metabolic/anthropometric_and_ratios.dart` (16)

| Ligne | Nature | Code |
|---|---|---|
| 46 | seuil cité dans un texte affiché | `"Les bandes de l'OMS (maigreur < 18,5 ; poids normal 18,5–24,9 ; "` |
| 47 | seuil cité dans un texte affiché | `'surpoids 25,0–29,9 ; obésité ≥ 30,0 kg/m²) sont affichées à titre '` |
| 132 | seuil cité dans un texte affiché | `'Glycémie à jeun ≤ 3,5 mmol/L (0,63 g/L) : dénominateur nul ou '` |
| 217 | littéral numérique dans le code | `final heightM = heightCm / 100;` |
| 225 | littéral numérique dans le code | `if (bmi < 18.5) return 'maigreur (< 18,5 kg/m²)';` |
| 226 | littéral numérique dans le code | `if (bmi < 25.0) return 'poids normal (18,5-24,9 kg/m²)';` |
| 227 | littéral numérique dans le code | `if (bmi < 30.0) return 'surpoids (25,0-29,9 kg/m²)';` |
| 228 | littéral numérique dans le code | `if (bmi < 35.0) return 'obésité classe I (30,0-34,9 kg/m²)';` |
| 229 | littéral numérique dans le code | `if (bmi < 40.0) return 'obésité classe II (35,0-39,9 kg/m²)';` |
| 230 | seuil cité dans un texte affiché | `return 'obésité classe III (≥ 40,0 kg/m²)';` |
| 252 | seuil cité dans un texte affiché | `"l'ère NCEP) : < 4 souhaitable, ≥ 5 risque élevé. Ce ratio n'est "` |
| 294 | littéral numérique dans le code | `final heightM = heightCmValue / 100;` |
| 358 | littéral numérique dans le code | `final heightM = heightCmValue / 100;` |
| 374 | littéral numérique dans le code | `ResultValue(label: 'Indice TyG (composante)', value: tyg, unit: '', precision: 3),` |
| 402 | littéral numérique dans le code | `if (glucoseMmolL <= 3.5) {` |
| 413 | littéral numérique dans le code | `final homaBeta = (20 * insulinUUmL) / (glucoseMmolL - 3.5);` |

## `src/calculators/metabolic/cardiovascular_risk_scores.dart` (114)

| Ligne | Nature | Code |
|---|---|---|
| 50 | seuil cité dans un texte affiché | `'catégories de risque (faible < 10 % ; intermédiaire 10-20 % ; '` |
| 51 | seuil cité dans un texte affiché | `'élevé > 20 %) habituellement associées à ce score',` |
| 113 | littéral numérique dans le code | `if (age < 40) return 0; // 20-39 (borne basse pratique : 30 ans, cf. validation)` |
| 114 | littéral numérique dans le code | `if (age < 50) return 1; // 40-49` |
| 115 | littéral numérique dans le code | `if (age < 60) return 2; // 50-59` |
| 116 | littéral numérique dans le code | `if (age < 70) return 3; // 60-69` |
| 117 | littéral numérique dans le code | `return 4; // 70-79` |
| 123 | littéral numérique dans le code | `if (tcMgDl < 160) return 0;` |
| 124 | littéral numérique dans le code | `if (tcMgDl < 200) return 1;` |
| 125 | littéral numérique dans le code | `if (tcMgDl < 240) return 2;` |
| 126 | littéral numérique dans le code | `if (tcMgDl < 280) return 3;` |
| 127 | littéral numérique dans le code | `return 4;` |
| 133 | littéral numérique dans le code | `if (sbpMmHg < 120) return 0;` |
| 134 | littéral numérique dans le code | `if (sbpMmHg < 130) return 1;` |
| 135 | littéral numérique dans le code | `if (sbpMmHg < 140) return 2;` |
| 136 | littéral numérique dans le code | `if (sbpMmHg < 160) return 3;` |
| 137 | littéral numérique dans le code | `return 4;` |
| 142 | littéral numérique dans le code | `if (age < 35) return -9; // 20-34` |
| 143 | littéral numérique dans le code | `if (age < 40) return -4; // 35-39` |
| 144 | littéral numérique dans le code | `if (age < 45) return 0; // 40-44` |
| 145 | littéral numérique dans le code | `if (age < 50) return 3; // 45-49` |
| 146 | littéral numérique dans le code | `if (age < 55) return 6; // 50-54` |
| 147 | littéral numérique dans le code | `if (age < 60) return 8; // 55-59` |
| 148 | littéral numérique dans le code | `if (age < 65) return 10; // 60-64` |
| 149 | littéral numérique dans le code | `if (age < 70) return 11; // 65-69` |
| 150 | littéral numérique dans le code | `if (age < 75) return 12; // 70-74` |
| 151 | littéral numérique dans le code | `return 13; // 75-79 (hors du domaine validé 30-74, table complète pour référence)` |
| 156 | littéral numérique dans le code | `if (age < 35) return -7; // 20-34` |
| 157 | littéral numérique dans le code | `if (age < 40) return -3; // 35-39` |
| 158 | littéral numérique dans le code | `if (age < 45) return 0; // 40-44` |
| 159 | littéral numérique dans le code | `if (age < 50) return 3; // 45-49` |
| 160 | littéral numérique dans le code | `if (age < 55) return 6; // 50-54` |
| 161 | littéral numérique dans le code | `if (age < 60) return 8; // 55-59` |
| 162 | littéral numérique dans le code | `if (age < 65) return 10; // 60-64` |
| 163 | littéral numérique dans le code | `if (age < 70) return 12; // 65-69` |
| 164 | littéral numérique dans le code | `if (age < 75) return 14; // 70-74` |
| 165 | littéral numérique dans le code | `return 16; // 75-79 (hors du domaine validé 30-74, table complète pour référence)` |
| 170 | littéral numérique dans le code | `[0, 4, 7, 9, 11], // 20-39` |
| 171 | littéral numérique dans le code | `[0, 3, 5, 6, 8], // 40-49` |
| 172 | littéral numérique dans le code | `[0, 2, 3, 4, 5], // 50-59` |
| 173 | littéral numérique dans le code | `[0, 1, 1, 2, 3], // 60-69` |
| 174 | littéral numérique dans le code | `[0, 0, 0, 1, 1], // 70-79` |
| 179 | littéral numérique dans le code | `[0, 4, 8, 11, 13], // 20-39` |
| 180 | littéral numérique dans le code | `[0, 3, 6, 8, 10], // 40-49` |
| 181 | littéral numérique dans le code | `[0, 2, 4, 5, 7], // 50-59` |
| 182 | littéral numérique dans le code | `[0, 1, 2, 3, 4], // 60-69` |
| 183 | littéral numérique dans le code | `[0, 1, 1, 2, 2], // 70-79` |
| 187 | littéral numérique dans le code | `const List<int> _menSmokerPoints = [8, 5, 3, 1, 1];` |
| 190 | littéral numérique dans le code | `const List<int> _womenSmokerPoints = [9, 7, 4, 2, 1];` |
| 194 | littéral numérique dans le code | `if (hdlMgDl >= 60) return -1;` |
| 195 | littéral numérique dans le code | `if (hdlMgDl >= 50) return 0;` |
| 196 | littéral numérique dans le code | `if (hdlMgDl >= 40) return 1;` |
| 204 | littéral numérique dans le code | `const List<int> _menSbpTreated = [0, 1, 2, 2, 3];` |
| 207 | littéral numérique dans le code | `const List<int> _womenSbpUntreated = [0, 1, 2, 3, 4];` |
| 210 | littéral numérique dans le code | `const List<int> _womenSbpTreated = [0, 3, 4, 5, 6];` |
| 215 | littéral numérique dans le code | `if (points >= 17) return const _RiskBand(30, qualifier: '≥');` |
| 217 | littéral numérique dans le code | `0: 1, 1: 1, 2: 1, 3: 1, 4: 1, //` |
| 218 | littéral numérique dans le code | `5: 2, 6: 2, 7: 3, 8: 4, 9: 5, //` |
| 219 | littéral numérique dans le code | `10: 6, 11: 8, 12: 10, 13: 12, 14: 16, //` |
| 220 | littéral numérique dans le code | `15: 20, 16: 25, //` |
| 231 | littéral numérique dans le code | `if (riskPercent < 10) return 'risque faible (< 10 %)';` |
| 232 | littéral numérique dans le code | `if (riskPercent <= 20) {` |
| 235 | seuil cité dans un texte affiché | `return 'risque élevé, équivalent à une maladie coronarienne établie (> 20 %)';` |
| 240 | littéral numérique dans le code | `if (points < 9) return const _RiskBand(1, qualifier: '<');` |
| 241 | littéral numérique dans le code | `if (points >= 25) return const _RiskBand(30, qualifier: '≥');` |
| 243 | littéral numérique dans le code | `9: 1, 10: 1, 11: 1, 12: 1, //` |
| 244 | littéral numérique dans le code | `13: 2, 14: 2, 15: 3, 16: 4, 17: 5, //` |
| 245 | littéral numérique dans le code | `18: 6, 19: 8, 20: 11, 21: 14, 22: 17, //` |
| 246 | littéral numérique dans le code | `23: 22, 24: 27, //` |
| 273 | littéral numérique dans le code | `if (age < 30 \|\| age > 74) {` |
| 523 | littéral numérique dans le code | `age: 0.3742,` |
| 524 | littéral numérique dans le code | `smoking: 0.6012,` |
| 525 | littéral numérique dans le code | `systolicBloodPressure: 0.2777,` |
| 526 | littéral numérique dans le code | `totalCholesterol: 0.1458,` |
| 527 | littéral numérique dans le code | `hdl: -0.2698,` |
| 528 | littéral numérique dans le code | `ageSmoking: -0.0755,` |
| 529 | littéral numérique dans le code | `ageSystolicBloodPressure: -0.0255,` |
| 530 | littéral numérique dans le code | `ageTotalCholesterol: -0.0281,` |
| 531 | littéral numérique dans le code | `ageHdl: 0.0426,` |
| 532 | littéral numérique dans le code | `baselineSurvival: 0.9605,` |
| 536 | littéral numérique dans le code | `age: 0.4648,` |
| 537 | littéral numérique dans le code | `smoking: 0.7744,` |
| 538 | littéral numérique dans le code | `systolicBloodPressure: 0.3131,` |
| 539 | littéral numérique dans le code | `totalCholesterol: 0.1002,` |
| 540 | littéral numérique dans le code | `hdl: -0.2606,` |
| 541 | littéral numérique dans le code | `ageSmoking: -0.1088,` |
| 542 | littéral numérique dans le code | `ageSystolicBloodPressure: -0.0277,` |
| 543 | littéral numérique dans le code | `ageTotalCholesterol: -0.0226,` |
| 544 | littéral numérique dans le code | `ageHdl: 0.0613,` |
| 545 | littéral numérique dans le code | `baselineSurvival: 0.9776,` |
| 558 | littéral numérique dans le code | `RiskRegion.low: _Score2RegionScale(-0.5699, 0.7476),` |
| 559 | littéral numérique dans le code | `RiskRegion.moderate: _Score2RegionScale(-0.1565, 0.8009),` |
| 560 | littéral numérique dans le code | `RiskRegion.high: _Score2RegionScale(0.3207, 0.9360),` |
| 561 | littéral numérique dans le code | `RiskRegion.veryHigh: _Score2RegionScale(0.5836, 0.8294),` |
| 565 | littéral numérique dans le code | `RiskRegion.low: _Score2RegionScale(-0.7380, 0.7019),` |
| 566 | littéral numérique dans le code | `RiskRegion.moderate: _Score2RegionScale(-0.3143, 0.7701),` |
| 567 | littéral numérique dans le code | `RiskRegion.high: _Score2RegionScale(0.5710, 0.9369),` |
| 568 | littéral numérique dans le code | `RiskRegion.veryHigh: _Score2RegionScale(0.9412, 0.8329),` |
| 576 | littéral numérique dans le code | `if (age < 50) {` |
| 577 | littéral numérique dans le code | `if (riskPercent < 2.5) return 'risque faible à modéré (< 2,5 %)';` |
| 578 | littéral numérique dans le code | `if (riskPercent < 7.5) return 'risque élevé (2,5 à < 7,5 %)';` |
| 579 | seuil cité dans un texte affiché | `return 'risque très élevé (≥ 7,5 %)';` |
| 582 | littéral numérique dans le code | `if (riskPercent < 5) return 'risque faible à modéré (< 5 %)';` |
| 583 | littéral numérique dans le code | `if (riskPercent < 10) return 'risque élevé (5 à < 10 %)';` |
| 584 | seuil cité dans un texte affiché | `return 'risque très élevé (≥ 10 %)';` |
| 699 | littéral numérique dans le code | `if (age < 40 \|\| age > 69) {` |
| 734 | littéral numérique dans le code | `final centeredAge = (age - 60) / 5;` |
| 735 | littéral numérique dans le code | `final centeredSbp = (systolicBloodPressure - 120) / 20;` |
| 736 | littéral numérique dans le code | `final centeredTc = (tcMmolL - 6) / 1;` |
| 737 | littéral numérique dans le code | `final centeredHdl = (hdlMmolL - 1.3) / 0.5;` |
| 738 | littéral numérique dans le code | `final smoke = currentSmoker ? 1.0 : 0.0;` |
| 755 | littéral numérique dans le code | `if (uncalibratedRisk <= 0) uncalibratedRisk = 1e-12;` |
| 756 | littéral numérique dans le code | `if (uncalibratedRisk >= 1) uncalibratedRisk = 1 - 1e-12;` |
| 761 | littéral numérique dans le code | `final riskPercent = calibratedRisk * 100;` |

## `src/calculators/metabolic/glycemic_conversions.dart` (4)

| Ligne | Nature | Code |
|---|---|---|
| 30 | seuil cité dans un texte affiché | `note: "objectif d'HbA1c habituel < 7 %, à individualiser",` |
| 66 | littéral numérique dans le code | `final eagMgDl = 28.7 * a1cPercent - 46.7;` |
| 82 | seuil cité dans un texte affiché | `'(ADA) : HbA1c < 7 % (< 53 mmol/mol) pour de nombreux adultes non '` |
| 86 | seuil cité dans un texte affiché | `"certains patients ; cible plus souple < 8 % chez d'autres, en cas "` |

## `src/calculators/metabolic/insulin_resistance.dart` (6)

| Ligne | Nature | Code |
|---|---|---|
| 39 | littéral numérique dans le code | `displayPrecision: 4,` |
| 67 | littéral numérique dans le code | `displayPrecision: 3,` |
| 111 | seuil cité dans un texte affiché | `'population (ex. QUICKI < 0,33-0,35 évocateur d\'une insulinorésistance), '` |
| 185 | littéral numérique dans le code | `ResultValue(label: 'QUICKI', value: quicki, unit: '', precision: 4),` |
| 226 | littéral numérique dans le code | `ResultValue(label: 'Indice TyG', value: tyg, unit: '', precision: 3),` |
| 253 | littéral numérique dans le code | `final homaIr = (glucoseMmolL * insulinUUmL) / 22.5;` |

## `src/calculators/metabolic/lipids.dart` (20)

| Ligne | Nature | Code |
|---|---|---|
| 32 | seuil cité dans un texte affiché | `'LDL (Friedewald) = CT − HDL − TG/5 (mg/dL ; domaine valide TG < 400 '` |
| 36 | seuil cité dans un texte affiché | `'valide TG < 800 mg/dL)  \|  non-HDL = CT − HDL  \|  CT/HDL = CT/HDL  \|  '` |
| 111 | seuil cité dans un texte affiché | `'(< 0,11 faible ; 0,11-0,21 intermédiaire ; > 0,21 élevé), non '` |
| 121 | littéral numérique dans le code | `displayPrecision: 3,` |
| 132 | littéral numérique dans le code | `if (ldlMgDl < 100) return 'optimal (< 100 mg/dL, soit < 2,6 mmol/L)';` |
| 133 | littéral numérique dans le code | `if (ldlMgDl < 130) {` |
| 136 | littéral numérique dans le code | `if (ldlMgDl < 160) {` |
| 137 | seuil cité dans un texte affiché | `return 'limite haute (130-159 mg/dL, soit 3,4-4,1 mmol/L)';` |
| 139 | littéral numérique dans le code | `if (ldlMgDl < 190) return 'haut (160-189 mg/dL, soit 4,1-4,9 mmol/L)';` |
| 140 | seuil cité dans un texte affiché | `return 'très haut (≥ 190 mg/dL, soit ≥ 4,9 mmol/L)';` |
| 175 | littéral numérique dans le code | `if (tgMgDl >= 400) {` |
| 183 | littéral numérique dans le code | `ldlMgDl = tcMgDl - hdlMgDl - tgMgDl / 5;` |
| 186 | littéral numérique dans le code | `if (tgMgDl >= 800) {` |
| 195 | littéral numérique dans le code | `ldlMgDl = tcMgDl / 0.948 -` |
| 196 | littéral numérique dans le code | `hdlMgDl / 0.971 -` |
| 197 | littéral numérique dans le code | `(tgMgDl / 8.56 + tgMgDl * nonHdlMgDl / 2140 - tgMgDl * tgMgDl / 16100) -` |
| 198 | littéral numérique dans le code | `9.44;` |
| 303 | littéral numérique dans le code | `ResultValue(label: 'AIP', value: aip, unit: '', precision: 3),` |
| 310 | seuil cité dans un texte affiché | `'cardiovasculaire faible si AIP < 0,11 ; intermédiaire si 0,11 à '` |
| 311 | seuil cité dans un texte affiché | `'0,21 ; élevé si > 0,21 (log10[TG/HDL-C], TG et HDL-C exprimés en '` |

## `src/calculators/renal/ckd_epi.dart` (38)

| Ligne | Nature | Code |
|---|---|---|
| 38 | seuil cité dans un texte affiché | `applicablePopulation: 'Adulte ≥ 18 ans',` |
| 39 | seuil cité dans un texte affiché | `forbiddenConditions: ['Âge < 18 ans'],` |
| 80 | seuil cité dans un texte affiché | `applicablePopulation: 'Adulte ≥ 18 ans',` |
| 81 | seuil cité dans un texte affiché | `forbiddenConditions: ['Âge < 18 ans'],` |
| 120 | seuil cité dans un texte affiché | `applicablePopulation: 'Adulte ≥ 18 ans',` |
| 121 | seuil cité dans un texte affiché | `forbiddenConditions: ['Âge < 18 ans'],` |
| 148 | littéral numérique dans le code | `if (egfr >= 90) {` |
| 151 | littéral numérique dans le code | `} else if (egfr >= 60) {` |
| 154 | littéral numérique dans le code | `} else if (egfr >= 45) {` |
| 157 | littéral numérique dans le code | `} else if (egfr >= 30) {` |
| 160 | littéral numérique dans le code | `} else if (egfr >= 15) {` |
| 168 | seuil cité dans un texte affiché | `'Stade KDIGO $stage : DFG $description (grille KDIGO — G1 ≥ 90, '` |
| 169 | seuil cité dans un texte affiché | `'G2 60-89, G3a 45-59, G3b 30-44, G4 15-29, G5 < 15 mL/min/1,73 m²). '` |
| 198 | littéral numérique dans le code | `if (age < 18) {` |
| 203 | seuil cité dans un texte affiché | `"Cette équation s'applique à l'adulte (≥ 18 ans) ; utiliser "` |
| 224 | littéral numérique dans le code | `final kappa = sex == Sex.female ? 0.7 : 0.9;` |
| 225 | littéral numérique dans le code | `final alpha = sex == Sex.female ? -0.241 : -0.302;` |
| 226 | littéral numérique dans le code | `final egfr = 142 *` |
| 228 | littéral numérique dans le code | `math.pow(math.max(scrMgDl / kappa, 1), -1.200) *` |
| 229 | littéral numérique dans le code | `math.pow(0.9938, age) *` |
| 230 | littéral numérique dans le code | `(sex == Sex.female ? 1.012 : 1.0);` |
| 264 | littéral numérique dans le code | `if (age < 18) {` |
| 269 | seuil cité dans un texte affiché | `"Cette équation s'applique à l'adulte (≥ 18 ans) ; les équations "` |
| 279 | littéral numérique dans le code | `final egfr = 133 *` |
| 280 | littéral numérique dans le code | `math.pow(math.min(cystatinCCanonicalMgL / 0.8, 1), -0.499) *` |
| 281 | littéral numérique dans le code | `math.pow(math.max(cystatinCCanonicalMgL / 0.8, 1), -1.328) *` |
| 282 | littéral numérique dans le code | `math.pow(0.996, age) *` |
| 283 | littéral numérique dans le code | `(sex == Sex.female ? 0.932 : 1.0);` |
| 324 | littéral numérique dans le code | `if (age < 18) {` |
| 329 | seuil cité dans un texte affiché | `"Cette équation s'applique à l'adulte (≥ 18 ans) ; utiliser "` |
| 352 | littéral numérique dans le code | `final kappa = sex == Sex.female ? 0.7 : 0.9;` |
| 353 | littéral numérique dans le code | `final alpha = sex == Sex.female ? -0.241 : -0.302;` |
| 354 | littéral numérique dans le code | `final egfr = 135 *` |
| 356 | littéral numérique dans le code | `math.pow(math.max(scrMgDl / kappa, 1), -0.544) *` |
| 357 | littéral numérique dans le code | `math.pow(math.min(cystatinCCanonicalMgL / 0.8, 1), -0.323) *` |
| 358 | littéral numérique dans le code | `math.pow(math.max(cystatinCCanonicalMgL / 0.8, 1), -0.778) *` |
| 359 | littéral numérique dans le code | `math.pow(0.9961, age) *` |
| 360 | littéral numérique dans le code | `(sex == Sex.female ? 0.963 : 1.0);` |

## `src/calculators/renal/proteinuria.dart` (11)

| Ligne | Nature | Code |
|---|---|---|
| 62 | littéral numérique dans le code | `final massMg = concentrationMgLCanonical * (volumeMlCanonical / 1000);` |
| 63 | littéral numérique dans le code | `final durationHours = durationMinCanonical / 60;` |
| 74 | littéral numérique dans le code | `value: massMg / 1000,` |
| 76 | littéral numérique dans le code | `precision: 3,` |
| 82 | littéral numérique dans le code | `final isExactly24h = (durationMinCanonical - 1440).abs() < 0.5;` |
| 92 | littéral numérique dans le code | `value: massMg / 1000,` |
| 94 | littéral numérique dans le code | `precision: 3,` |
| 96 | littéral numérique dans le code | `} else if (durationMinCanonical < 1440) {` |
| 97 | littéral numérique dans le code | `final extrapolatedMg = massMg * (1440 / durationMinCanonical);` |
| 121 | littéral numérique dans le code | `final mgPer24hEquivalent = massMg * (1440 / durationMinCanonical);` |
| 127 | littéral numérique dans le code | `mgPer24hEquivalent >= 3500` |

## `src/calculators/renal/schwartz.dart` (5)

| Ligne | Nature | Code |
|---|---|---|
| 31 | seuil cité dans un texte affiché | `note: 'stades du DFG G1-G5 (interprétation clinique, ≥ 2 ans)',` |
| 37 | seuil cité dans un texte affiché | `forbiddenConditions: ['Âge < 1 an ou > 25 ans'],` |
| 69 | littéral numérique dans le code | `if (ageYears < 1 \|\| ageYears > 25) {` |
| 84 | littéral numérique dans le code | `final egfr = 0.413 * heightCm / scrMgDl;` |
| 87 | littéral numérique dans le code | `if (ageYears >= 18 && ageYears <= 25) {` |

## `src/calculators/renal/urine_ratios.dart` (15)

| Ligne | Nature | Code |
|---|---|---|
| 115 | seuil cité dans un texte affiché | `note: "formule et seuils classiques d'interprétation (< 1 % / > 2 %)",` |
| 144 | seuil cité dans un texte affiché | `note: "formule et seuils classiques d'interprétation (< 35 % / > 50 %)",` |
| 172 | littéral numérique dans le code | `if (ratioMgG < 30) {` |
| 175 | littéral numérique dans le code | `} else if (ratioMgG <= 300) {` |
| 185 | seuil cité dans un texte affiché | `'— A1 < 30 mg/g [< 3 mg/mmol], A2 30-300 mg/g [3-30 mg/mmol], A3 '` |
| 186 | seuil cité dans un texte affiché | `'> 300 mg/g [> 30 mg/mmol]).',` |
| 200 | seuil cité dans un texte affiché | `"approximative d'usage clinique, un PCR ≥ 3000-3500 mg/g (soit ≥ "` |
| 228 | littéral numérique dans le code | `final creatGL = creatMgDl * 0.01;` |
| 229 | littéral numérique dans le code | `final creatMmolL = creatUmolLCanonical / 1000;` |
| 374 | littéral numérique dans le code | `final feNa = (urineSodiumValue * pCrCanonical) / (serumSodiumValue * uCrCanonical) * 100;` |
| 409 | seuil cité dans un texte affiché | `'FeNa $interpretation (repères classiques : < 1 % prérénal, > 2 % '` |
| 438 | littéral numérique dans le code | `final feUrea = (urineUreaValue * pCrCanonical) / (serumUreaValue * uCrCanonical) * 100;` |
| 463 | littéral numérique dans le code | `if (feUrea < 35) {` |
| 465 | littéral numérique dans le code | `} else if (feUrea > 50) {` |
| 474 | seuil cité dans un texte affiché | `"diurétiques quand la FeNa n'est pas interprétable : < 35 % prérénal, "` |

## `src/units/unit_registry.dart` (27)

| Ligne | Nature | Code |
|---|---|---|
| 33 | littéral numérique dans le code | `'µmol/L': UnitSpec('µmol/L', 1.0),` |
| 35 | littéral numérique dans le code | `'mg/dL': UnitSpec('mg/dL', 88.42),` |
| 38 | littéral numérique dans le code | `'mg/L': UnitSpec('mg/L', 1.0),` |
| 41 | littéral numérique dans le code | `'mmol/L': UnitSpec('mmol/L', 1.0),` |
| 43 | littéral numérique dans le code | `'mg/dL': UnitSpec('mg/dL', 0.0555),` |
| 46 | littéral numérique dans le code | `'mmol/L': UnitSpec('mmol/L', 1.0),` |
| 48 | littéral numérique dans le code | `'mg/dL': UnitSpec('mg/dL', 0.0113),` |
| 51 | littéral numérique dans le code | `'mg/L': UnitSpec('mg/L', 1.0),` |
| 52 | littéral numérique dans le code | `'g/L': UnitSpec('g/L', 1000.0),` |
| 53 | littéral numérique dans le code | `'mg/dL': UnitSpec('mg/dL', 10.0),` |
| 56 | littéral numérique dans le code | `'mL': UnitSpec('mL', 1.0),` |
| 57 | littéral numérique dans le code | `'L': UnitSpec('L', 1000.0),` |
| 60 | littéral numérique dans le code | `'min': UnitSpec('min', 1.0),` |
| 61 | littéral numérique dans le code | `'h': UnitSpec('h', 60.0),` |
| 64 | littéral numérique dans le code | `'g/L': UnitSpec('g/L', 1.0),` |
| 65 | littéral numérique dans le code | `'g/dL': UnitSpec('g/dL', 10.0),` |
| 68 | littéral numérique dans le code | `'mmol/L': UnitSpec('mmol/L', 1.0),` |
| 70 | littéral numérique dans le code | `'mg/dL': UnitSpec('mg/dL', 0.2495),` |
| 73 | littéral numérique dans le code | `'g/L': UnitSpec('g/L', 1.0),` |
| 74 | littéral numérique dans le code | `'mg/dL': UnitSpec('mg/dL', 0.01),` |
| 77 | littéral numérique dans le code | `'µU/mL': UnitSpec('µU/mL', 1.0),` |
| 79 | littéral numérique dans le code | `'pmol/L': UnitSpec('pmol/L', 1 / 6.945),` |
| 83 | littéral numérique dans le code | `'%': UnitSpec('%', 1.0),` |
| 86 | littéral numérique dans le code | `'mmol/mol': UnitSpec('mmol/mol', 1 / 10.929, offset: 2.15),` |
| 89 | littéral numérique dans le code | `'mmol/L': UnitSpec('mmol/L', 1.0),` |
| 95 | littéral numérique dans le code | `'g/L': UnitSpec('g/L', 2.586),` |
| 96 | littéral numérique dans le code | `'mg/dL': UnitSpec('mg/dL', 0.02586),` |
