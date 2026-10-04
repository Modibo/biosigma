# Table de traçabilité scientifique — BioSigma

Chaque ligne correspond à un calculateur du moteur `biosigma_core`. L'identifiant (`id`)
correspond à la constante `FormulaMeta` du même nom (`<id>Meta`, camelCase) dans le code source,
dans `packages/biosigma_core/lib/src/calculators/<domaine>/`. Les cas de test listés sont
implémentés dans `packages/biosigma_core/test/calculators/<domaine>/` et vérifiés indépendamment
(valeurs calculées séparément du code testé, cf. `README.md` § Vérification).

Toutes les sources sont des publications ou recommandations d'organismes officiels ; aucun accès
réseau n'est nécessaire pour les consulter dans l'application (le texte des citations est
embarqué). Aucun seuil interprétatif clinique n'est codé en dur comme universel — voir
`README.md` § Décisions dépendant de la validation du laboratoire.

## Fonction rénale et urines

| Calcul (id) | Version / Source primaire | Formule | Unités internes | Population | Cas interdits | Limites principales |
|---|---|---|---|---|---|---|
| DFG CKD-EPI créatinine 2021 (`ckd_epi_creatinine_2021`) | Inker LA et al. *N Engl J Med.* 2021;385(19):1737-1749. | DFG = 142 × min(Scr/κ,1)^α × max(Scr/κ,1)^-1,200 × 0,9938^Âge × 1,012 [si femme] (κ=0,7/0,9 ; α=-0,241/-0,302) | Créatinine → µmol/L (calcul en mg/dL) | Adulte ≥ 18 ans | Âge < 18 ans ; IDMS non confirmé | IRA, grossesse, masse musculaire extrême, régime végétarien strict, créatine |
| DFG CKD-EPI cystatine C 2012 (`ckd_epi_cystatin_c_2012`) | Inker LA et al. *N Engl J Med.* 2012;367(1):20-29. | DFG = 133 × min(Cys/0,8,1)^-0,499 × max(Cys/0,8,1)^-1,328 × 0,996^Âge × 0,932 [si femme] | Cystatine C mg/L | Adulte ≥ 18 ans | Âge < 18 ans (équations pédiatriques non implémentées) | Dépend de facteurs non liés à la fonction rénale (inflammation, thyroïde, corticoïdes) |
| DFG CKD-EPI créatinine-cystatine C 2021 (`ckd_epi_creatinine_cystatin_c_2021`) | Inker LA et al. *N Engl J Med.* 2021;385(19):1737-1749. | DFG = 135 × min(Scr/κ,1)^α × max(Scr/κ,1)^-0,544 × min(Cys/0,8,1)^-0,323 × max(Cys/0,8,1)^-0,778 × 0,9961^Âge × 0,963 [si femme] | Créatinine µmol/L + cystatine C mg/L | Adulte ≥ 18 ans | Âge < 18 ans ; IDMS non confirmé | Idem créatinine seule + cystatine seule |
| DFG Schwartz bedside pédiatrique (`schwartz_bedside_pediatric`) | Schwartz GJ et al. *J Am Soc Nephrol.* 2009;20(3):629-637. | DFG = 0,413 × Taille(cm) / Créatinine(mg/dL) | Créatinine µmol/L ; taille cm | 1-18 ans (zone de transition 18-25 ans signalée) | Âge < 1 an ou > 25 ans | k historique différent (0,55) pour créatinine non standardisée IDMS |
| Protéinurie des 24 h (`proteinuria_24h`) | Contexte : KDIGO 2012 CKD Guideline. Kidney Int Suppl. 2013;3(1):1-150. (bilan de masse) | Masse = Concentration(mg/L) × Volume(L), rapportée à la durée réelle ; extrapolation 24h si collecte incomplète | Protéinurie mg/L ; volume mL ; durée min | Tout âge | — | Précision dépendante de l'exactitude du recueil déclaré |
| Rapport albumine/créatinine urinaire — UACR (`urine_albumin_creatinine_ratio`) | KDIGO 2012 CKD Guideline. Kidney Int Suppl. 2013;3(1):1-150. | ACR = Albumine(mg/L) / Créatinine(g/L ou mmol/L) | mg/g et mg/mmol | Tout âge | — | Variabilité du débit urinaire |
| Rapport protéines/créatinine urinaire — UPCR (`urine_protein_creatinine_ratio`) | KDIGO 2012 CKD Guideline. | Idem UACR, protéines totales | mg/g et mg/mmol | Tout âge | — | Moins précis que la protéinurie des 24h si débit variable |
| Clairance de la créatinine mesurée (`creatinine_clearance_timed`) | KDOQI Clinical Practice Guidelines (formule classique de bilan de masse) | ClCr = (Créat. urinaire × Volume) / (Créat. plasmatique × Durée) | Créatinine µmol/L ; volume mL ; durée min | Tout âge | — | Pas de correction de surface corporelle ; surestimation par sécrétion tubulaire |
| Fraction excrétée du sodium — FeNa (`fractional_excretion_sodium`) | Espinel CH. *JAMA.* 1976;236(6):579-581. | FeNa (%) = (UNa×PCr)/(PNa×UCr) × 100 | Na mmol/L ; créatinine µmol/L | Tout âge | — | Non interprétable sous diurétiques de l'anse récents |
| Fraction excrétée de l'urée — FeUrée (`fractional_excretion_urea`) | Carvounis CP et al. *Kidney Int.* 2002;62(6):2223-2229. | FeUrée (%) = (U_urée×PCr)/(S_urée×UCr) × 100 | Urée mmol/L ; créatinine µmol/L | Tout âge | — | Sensible aux diurétiques thiazidiques et à l'apport protéique |

## Glucides, insulinorésistance et cardiométabolisme

| Calcul (id) | Version / Source primaire | Formule | Unités internes | Population | Cas interdits | Limites principales |
|---|---|---|---|---|---|---|
| QUICKI (`quicki`) | Katz A et al. *J Clin Endocrinol Metab.* 2000;85(7):2402-2410. | QUICKI = 1 / [log10(Insuline µU/mL) + log10(Glycémie mg/dL)] | Insuline µU/mL ; glycémie mg/dL (formule) | Adulte, à jeun | Prélèvement non à jeun (non confirmé) | Indice indirect, non un clamp euglycémique |
| TyG (`tyg_index`) | Simental-Mendía LE et al. *Metab Syndr Relat Disord.* 2008;6(4):299-304. | TyG = ln[(TG mg/dL × Glycémie mg/dL)/2] | TG et glycémie mg/dL (formule) | Adulte, à jeun | Prélèvement non à jeun | Autres conventions de parenthésage existent dans la littérature : ne pas comparer les seuils entre conventions |
| HOMA-IR (`homa_ir`) | Matthews DR et al. *Diabetologia.* 1985;28(7):412-419. | HOMA-IR = (Glycémie mmol/L × Insuline µU/mL) / 22,5 | Glycémie mmol/L ; insuline µU/mL | Adulte, à jeun | Prélèvement non à jeun | Indice indirect ; seuils dépendants de la population et du dosage d'insuline |
| Glycémie moyenne estimée — eAG (`estimated_average_glucose_adag`) | Nathan DM et al. (ADAG). *Diabetes Care.* 2008;31(8):1473-1478. | eAG (mg/dL) = 28,7 × HbA1c(%) − 46,7 | HbA1c % (NGSP) | Adulte | Hémoglobinopathie, anémie hémolytique, carence martiale, grossesse, IRC terminale | Estimation de population, peut différer de la moyenne individuelle réelle |
| Panel LDL (Friedewald / Sampson), non-HDL, ratios, cholestérol résiduel (`ldl_panel`) | Friedewald WT et al. *Clin Chem.* 1972;18(6):499-502. ; Sampson M et al. *JAMA Cardiol.* 2020;5(5):540-548. | Friedewald : LDL = TC−HDL−TG/5 (mg/dL). Sampson : équation NIH-2 (cf. code) | Cholestérol et TG mg/dL (formules) | Adulte | Friedewald : TG ≥ 4,52 mmol/L (400 mg/dL). Sampson : TG ≥ 800 mg/dL. Chylomicronémie/dysbêtalipoprotéinémie type III non détectable | Martin-Hopkins non implémenté (table à 180 cellules, risque de transcription) |
| Indice athérogène du plasma — AIP (`atherogenic_index_of_plasma`) | Dobiásová M, Frohlich J. *Clin Biochem.* 2001;34(7):583-588. | AIP = log10(TG mmol/L / HDL mmol/L) | **mmol/L obligatoire** (conversion préalable) | Adulte | — | Ne pas confondre avec le ratio TG/HDL simple (mg/dL, convention différente) |

## Ionogramme, gaz du sang et biochimie générale

| Calcul (id) | Version / Source primaire | Formule | Unités internes | Population | Cas interdits | Limites principales |
|---|---|---|---|---|---|---|
| Trou anionique ± K, corrigé albumine (`anion_gap`) | Emmett M, Narins RG. *Medicine (Baltimore).* 1977;56(1):38-54. ; correction : Figge J et al. *Crit Care Med.* 1998;26(11):1807-1810. | AG = Na−(Cl+HCO3) ; AG+K = (Na+K)−(Cl+HCO3) ; AG corrigé = AG + 2,5×(4,0−Alb g/dL) | Na/Cl/HCO3/K mmol/L ; albumine g/L | Tout âge | — | Références dépendantes de la méthode de dosage du laboratoire |
| Osmolarité calculée et trou osmolaire (`calculated_osmolarity_osmolar_gap`) | Smithline N, Gardner KD Jr. *JAMA.* 1976;236(14):1594-1597. | Osm calculée = 2×Na + Glycémie(mmol/L) + Urée(mmol/L) ; trou = Osm mesurée − Osm calculée | Na mmol/L ; glycémie mmol/L ; urée mmol/L | Tout âge | Trou osmolaire jamais calculé sans osmolalité mesurée fournie | Osmolarité (par L) ≠ osmolalité (par kg d'eau), assimilées en pratique courante |
| Sodium corrigé pour hyperglycémie (`corrected_sodium_hyperglycemia`) | Katz MA. *N Engl J Med.* 1973;289(16):843-844. ; Hillier TA et al. *Am J Med.* 1999;106(4):399-403. | Na corrigé = Na + coefficient×(Glycémie mg/dL−100)/100 (coefficient 1,6 ou 2,4) | Na mmol/L ; glycémie mg/dL (formule) | Tout âge | — | Les deux coefficients publiés sont fournis ; choix à documenter par le laboratoire |
| Calcium corrigé pour l'albuminémie (`corrected_calcium_albumin`) | Payne RB et al. *Br Med J.* 1973;4(5893):643-646. | Ca corrigé (mg/dL) = Ca mesuré + 0,8×(4,0−Alb g/dL) | Calcium mmol/L ; albumine g/L | Tout âge | — | Estimation ; ne remplace jamais un calcium ionisé mesuré |
| CTF calculée à partir de la transferrine (`tibc_from_transferrin`) | Facteur usuel de biochimie clinique (×1,42) | CTF (µg/dL) = Transferrine (mg/dL) × 1,42 | Transferrine mg/dL | Tout âge | — | Facteur à confirmer selon le réactif du laboratoire |
| Saturation de la transferrine (`transferrin_saturation`) | ICSH. *Br J Haematol.* 1978;38(2):291-294. | TSAT (%) = Fer sérique / CTF × 100 | Fer et CTF µg/dL | Tout âge | — | Dépendant de la méthode analytique |
| Globulines calculées et rapport A/G (`globulins_ag_ratio`) | Calcul standard (protéines totales − albumine) | Globulines = PT − Alb ; A/G = Alb/Globulines | g/L | Tout âge | — | Estimation indirecte ; électrophorèse = référence |
| Bilirubine indirecte (`indirect_bilirubin`) | Calcul standard (bilan de masse) | Indirecte = Totale − Directe | µmol/L | Tout âge | Directe > Totale | — |
| Rapport ASAT/ALAT — De Ritis (`ast_alt_ratio_de_ritis`) | De Ritis F et al. *Clin Chim Acta.* 1957;2(1):70-74. | Ratio = ASAT/ALAT | U/L | Tout âge | — | — |
| FIB-4 (`fib4`) | Sterling RK et al. *Hepatology.* 2006;43(6):1317-1325. | FIB-4 = (Âge×ASAT)/(Plaquettes×√ALAT) | Âge ans ; U/L ; G/L | Adulte | — | Seuils dépendants du contexte (VIH/VHC, NAFLD/MASLD) et de l'âge |
| APRI (`apri`) | Wai CT et al. *Hepatology.* 2003;38(2):518-526. | APRI = (ASAT/LSN×100)/Plaquettes | U/L ; G/L | Adulte | LSN non fournie par le laboratoire | LSN doit être définie localement, jamais une valeur universelle |

## Hémostase

| Calcul (id) | Version / Source primaire | Formule | Unités internes | Population | Cas interdits | Limites principales |
|---|---|---|---|---|---|---|
| Indice de Rosner (`rosner_index`) | Rosner E et al. *Thromb Haemost.* 1987;57(2):144-147. | Indice = [(TCA mélange−TCA témoin normal)/TCA patient] × 100 | secondes | Bilan d'allongement du TCA | — | Interprétation dépendante du réactif/protocole/labo ; ne conclut pas seule à un anticoagulant lupique |
| INR (`inr`) | Kirkwood TB. *Thromb Haemost.* 1983;49:238-244. ; système OMS INR/ISI | INR = (TP patient/TP moyen normal)^ISI | secondes ; ISI sans unité | Sous AVK | — | Aucune recommandation de dose fournie |
| Ratio TCA patient/témoin (`aptt_ratio`) | Calcul standard | Ratio = TCA patient/TCA témoin | secondes | Tout âge | — | Références dépendantes du réactif/analyseur |
| Suivi de valeurs sériées (`serial_value_trend`) | Calcul arithmétique standard | Variation absolue et relative entre deux mesures | selon l'analyte | Tout âge | Valeur précédente nulle → variation relative non calculée | Ne recommande aucune dose |
| Score ISTH de CIVD (`isth_dic_score`) | Taylor FB Jr et al. (ISTH). *Thromb Haemost.* 2001;86(5):1327-1330. | Somme de 4 sous-scores (plaquettes, marqueur de fibrine, allongement TP, fibrinogène) | G/L ; secondes ; g/L | Pathologie associée à un risque de CIVD | Absence de pathologie associée ; donnée manquante → « score incomplet » | Interprétation toujours affichée (décision D-03) ; non validée par un biologiste responsable |
| Score 4Ts (`four_ts_score`) | Lo GK et al. (Warkentin). *J Thromb Haemost.* 2006;4(4):759-765. | Somme de 4 sous-scores catégoriels (0-2 points chacun) | catégoriel | Suspicion de TIH | Donnée manquante → « score incomplet » | Interprétation toujours affichée (décision D-03) ; non validée par un biologiste responsable |

| Constantes érythrocytaires (`red_cell_indices`) | Relations de définition attribuées à Wintrobe — citation primaire à compléter | VGM = Ht×10/GR ; TCMH = Hb×10/GR ; CCMH = Hb×100/Ht | Hb g/dL ; Ht % ; GR ×10¹²/L → fL, pg, g/dL | Tout âge | Ht ∉ ]0 ; 100] ; valeurs ≤ 0 | Aucun intervalle de référence comparé |
| Valeurs absolues leucocytaires (`absolute_leukocyte_counts`) | Pourcentage × numération / 100 (définition) | ANC = WBC×(N%+bandes%)/100 ; ALC = WBC×L%/100 | ×10⁹/L ; % → ×10⁹/L et /µL | Tout âge | Pourcentage hors 0-100 ; somme > 100 % bloquante | Aucun seuil de neutropénie/lymphopénie |

## Points signalés plutôt que devinés

- **LDL Martin-Hopkins** : volontairement non implémenté (table de facteurs ajustés à 180 cellules ;
  risque de transcription jugé trop élevé sans validation externe formelle). Friedewald et Sampson
  couvrent la majorité des cas d'usage.
- **Facteur insuline µU/mL → pmol/L (×6,945)** : dépend de l'étalon international du dosage
  (1ʳᵉ préparation de référence OMS 66/304) — affiché avec cette réserve, jamais silencieusement.
- **Facteur transferrine → CTF (×1,42)** et **saturation transferrine** : facteurs usuels de
  biochimie clinique, à confirmer selon les recommandations du fournisseur du réactif du
  laboratoire.
- **Ratio TG/HDL simple vs indice athérogène du plasma (AIP)** : deux conventions d'unités
  différentes (mg/dL vs mmol/L obligatoire) délibérément distinguées pour éviter toute confusion
  de seuils entre les deux.
