import 'package:biosigma_core/biosigma_core.dart';

import '../../models/quiz_question.dart';

final QuizModule quizIonogram = QuizModule(
  id: 'quiz_ionogram',
  title: 'Ionogramme, gaz du sang et biochimie générale',
  category: CalculatorCategory.ionogram,
  questions: [
    const QuizQuestion(
      id: 'ionogram_1',
      type: QuizQuestionType.scientificSource,
      prompt: 'La correction du trou anionique pour l\'albuminémie a été décrite en 1998 par :',
      options: ['Figge J et al.', 'Emmett M & Narins RG', 'Payne RB et al.', 'Katz MA'],
      correctIndex: 0,
      explanation:
          'Figge J, Jabor A, Kazda A, Fencl V. Anion Gap and Hypoalbuminemia. Crit Care Med. '
          '1998;26(11):1807-1810. Le trou anionique de base (sans correction) provient lui '
          'd\'Emmett M, Narins RG. Medicine (Baltimore). 1977;56(1):38-54.',
    ),
    const QuizQuestion(
      id: 'ionogram_2',
      type: QuizQuestionType.scientificSource,
      prompt: 'Le score FIB-4 a été développé initialement dans quelle population de patients ?',
      options: [
        'Patients co-infectés VIH/VHC (Sterling et al., 2006)',
        'Patients diabétiques de type 2',
        'Patients insuffisants rénaux chroniques',
        'Femmes enceintes',
      ],
      correctIndex: 0,
      explanation:
          'Sterling RK et al. Hepatology. 2006;43(6):1317-1325 — utilisé plus largement en '
          'hépatologie depuis, avec des seuils dépendant du contexte et de l\'âge.',
    ),
    const QuizQuestion(
      id: 'ionogram_3',
      type: QuizQuestionType.scientificSource,
      prompt: 'Le rapport ASAT/ALAT porte le nom de quel auteur, qui l\'a décrit en 1957 ?',
      options: ['De Ritis', 'Wai', 'Sterling', 'Espinel'],
      correctIndex: 0,
      explanation:
          'De Ritis F, Coltorti M, Giusti G. Clin Chim Acta. 1957;2(1):70-74 — d\'où le nom '
          '« rapport de De Ritis ».',
    ),
    const QuizQuestion(
      id: 'ionogram_4',
      type: QuizQuestionType.clinicalCase,
      prompt: 'On dispose d\'une osmolalité mesurée par osmométrie ET d\'une osmolarité calculée. '
          'Peut-on alors parler de « trou osmolaire » ?',
      options: [
        'Oui — c\'est la différence entre les deux qui définit le trou osmolaire',
        'Non, le trou osmolaire se calcule uniquement à partir du trou anionique',
        'Oui, mais seulement en estimant l\'osmolalité à partir de la formule',
        'Non, ces deux grandeurs ne peuvent jamais être comparées',
      ],
      correctIndex: 0,
      explanation:
          'Trou osmolaire = Osmolalité mesurée − Osmolarité calculée. Il ne doit être calculé que '
          'si une osmolalité mesurée est réellement disponible, jamais estimée — et jamais appelée '
          '« osmolalité mesurée » une valeur qui a en fait été calculée.',
    ),
    const QuizQuestion(
      id: 'ionogram_5',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient très hyperglycémique a un sodium mesuré bas. Faut-il conclure '
          'directement à une hyponatrémie vraie ?',
      options: [
        'Non — envisager d\'abord une pseudo-hyponatrémie de dilution liée à l\'hyperglycémie, et '
            'calculer le sodium corrigé',
        'Oui, le sodium mesuré est toujours la valeur qui compte',
        'Non, il faut ignorer le sodium mesuré et ne garder que le sodium corrigé',
        'La glycémie n\'a aucun effet sur l\'interprétation du sodium',
      ],
      correctIndex: 0,
      explanation:
          'Le sodium corrigé (coefficient de Katz 1,6 ou de Hillier 2,4, les deux étant rapportés '
          'dans la littérature) tient compte de cet effet de dilution osmotique.',
    ),
    const QuizQuestion(
      id: 'ionogram_6',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un calcium ionisé a été mesuré directement (gazométrie). Doit-on le remplacer par '
          'un calcium corrigé calculé à partir de l\'albuminémie ?',
      options: [
        'Non — le calcium ionisé mesuré prime toujours sur une estimation calculée',
        'Oui, le calcul est toujours plus fiable que la mesure directe',
        'Cela dépend uniquement de l\'albuminémie du patient',
        'Les deux valeurs sont automatiquement interchangeables',
      ],
      correctIndex: 0,
      explanation:
          'Le calcium corrigé pour l\'albuminémie est une estimation indirecte ; elle ne remplace '
          'jamais un calcium ionisé mesuré, qui doit rester une donnée distincte.',
    ),
    const QuizQuestion(
      id: 'ionogram_7',
      type: QuizQuestionType.vocabulary,
      prompt: 'Que signifie CTF, calculable à partir de la transferrinémie ?',
      options: [
        'Capacité totale de fixation du fer',
        'Coefficient de Transport du Fer',
        'Concentration Totale en Ferritine',
        'Clairance Tubulaire du Fer',
      ],
      correctIndex: 0,
      explanation: 'CTF (µg/dL) ≈ Transferrine (mg/dL) × 1,42 — facteur usuel, à confirmer selon '
          'le réactif du laboratoire.',
    ),
    const QuizQuestion(
      id: 'ionogram_8',
      type: QuizQuestionType.vocabulary,
      prompt: 'Dans le calcul de l\'APRI, que désigne LSN ?',
      options: [
        'La limite supérieure de la normale (de l\'ASAT, définie localement)',
        'Le seuil de significativité statistique',
        'Le taux sérique normalisé',
        'Un synonyme de CTF',
      ],
      correctIndex: 0,
      explanation:
          'La LSN de l\'ASAT doit être définie par le laboratoire lui-même — jamais une valeur '
          'universelle codée en dur.',
    ),

    // ------------------------------------------------------------------
    // Trou anionique (anion_gap.dart)
    // ------------------------------------------------------------------
    const QuizQuestion(
      id: "ionogram_9",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient cirrhotique présente une hypoalbuminémie sévère (albuminémie mesurée à "
          "20 g/L, soit 2,0 g/dL) et un trou anionique de base calculé à 8 mmol/L. Comment la "
          "littérature propose-t-elle d'ajuster ce trou anionique pour tenir compte de "
          "l'hypoalbuminémie ?",
      options: [
        "En ajoutant 2,5 × (4,0 − albuminémie en g/dL) au trou anionique de base (Figge et al., 1998)",
        "En multipliant le trou anionique de base par l'albuminémie en g/dL",
        "En soustrayant 2,5 × (4,0 − albuminémie en g/dL) au trou anionique de base",
        "Aucun ajustement n'est proposé dans la littérature en cas d'hypoalbuminémie",
      ],
      correctIndex: 0,
      explanation:
          "Figge J, Jabor A, Kazda A, Fencl V. Anion Gap and Hypoalbuminemia. Crit Care Med. "
          "1998;26(11):1807-1810 : trou anionique corrigé = trou anionique de base + "
          "2,5 × (4,0 − albuminémie en g/dL).",
    ),
    const QuizQuestion(
      id: "ionogram_10",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Une patiente présente un syndrome néphrotique avec une albuminémie effondrée. Le "
          "laboratoire souhaite corriger le trou anionique pour cette hypoalbuminémie avant "
          "interprétation. Quelle formule de correction est documentée ?",
      options: [
        "Trou anionique corrigé = trou anionique de base + 2,5 × (4,0 − albuminémie en g/dL)",
        "Trou anionique corrigé = trou anionique de base − 4,0 × albuminémie en g/dL",
        "Trou anionique corrigé = trou anionique de base divisé par l'albuminémie en g/dL",
        "Trou anionique corrigé = trou anionique de base + albuminémie en g/dL",
      ],
      correctIndex: 0,
      explanation:
          "Correction de Figge et al. (Crit Care Med. 1998;26(11):1807-1810) : trou anionique + "
          "2,5 × (4,0 − albuminémie en g/dL).",
    ),
    const QuizQuestion(
      id: "ionogram_11",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient en acidocétose diabétique présente une hyperkaliémie et une "
          "hypoalbuminémie. Le laboratoire calcule le trou anionique avec potassium ET sans "
          "potassium, puis veut appliquer la correction pour l'albuminémie. À quelle variante "
          "cette correction doit-elle être appliquée, selon la convention documentée ?",
      options: [
        "Toujours à la variante sans potassium",
        "Toujours à la variante avec potassium, car elle est plus complète",
        "Indifféremment à l'une ou l'autre variante, selon la préférence du biologiste",
        "À la moyenne des deux variantes",
      ],
      correctIndex: 0,
      explanation:
          "La correction pour l'albuminémie (Figge 1998) est appliquée par convention à la "
          "variante du trou anionique sans potassium, même lorsqu'une variante avec potassium a "
          "aussi été calculée.",
    ),
    const QuizQuestion(
      id: "ionogram_12",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient insuffisant rénal chronique en hyperkaliémie a un trou anionique calculé "
          "selon les deux variantes (avec et sans potassium). Une hypoalbuminémie associée "
          "nécessite une correction. Quelle affirmation est exacte, selon la documentation du "
          "calcul ?",
      options: [
        "La correction pour l'albuminémie s'applique par convention à la variante sans "
            "potassium, même si la variante avec potassium a aussi été calculée",
        "La correction pour l'albuminémie s'applique à la variante avec potassium en présence "
            "d'hyperkaliémie",
        "La correction pour l'albuminémie ne peut être appliquée qu'en l'absence de toute "
            "variante avec potassium",
        "Le choix de la variante à corriger dépend du taux de potassium du patient",
      ],
      correctIndex: 0,
      explanation:
          "Convention documentée : correction albumine (Figge 1998) appliquée à la variante du "
          "trou anionique sans potassium.",
    ),
    const QuizQuestion(
      id: "ionogram_13",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un laboratoire compare son trou anionique habituel à celui d'un laboratoire voisin "
          "qui utilise une méthode différente de dosage du chlore (potentiométrie directe vs "
          "indirecte). Les deux laboratoires obtiennent des valeurs de référence légèrement "
          "différentes pour le trou anionique. Comment interpréter cet écart ?",
      options: [
        "Les valeurs de référence du trou anionique dépendent de la méthode de dosage du chlore "
            "et des bicarbonates ; il ne faut pas appliquer un seuil universel",
        "Il s'agit nécessairement d'une erreur analytique dans l'un des deux laboratoires",
        "Le trou anionique est un paramètre standardisé internationalement, indépendant de la "
            "méthode",
        "Seule la méthode par potentiométrie directe est validée pour le trou anionique",
      ],
      correctIndex: 0,
      explanation:
          "Limitation documentée : les valeurs de référence dépendent de la méthode de dosage du "
          "chlore et des bicarbonates du laboratoire (photométrie, potentiométrie "
          "indirecte/directe) ; ne pas appliquer un seuil universel.",
    ),
    const QuizQuestion(
      id: "ionogram_14",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Chez un patient en acidocétose diabétique dont le ionogramme comprend le potassium, "
          "le laboratoire souhaite calculer le trou anionique en tenant compte du potassium. "
          "Quelle est la formule correspondante documentée ?",
      options: [
        "(Sodium + Potassium) − (Chlore + Bicarbonates)",
        "Sodium − (Chlore + Bicarbonates + Potassium)",
        "(Sodium − Potassium) − (Chlore + Bicarbonates)",
        "Sodium − (Chlore − Bicarbonates) + Potassium",
      ],
      correctIndex: 0,
      explanation:
          "Variante avec potassium documentée : trou anionique = (Na + K) − (Cl + HCO3).",
    ),
    const QuizQuestion(
      id: "ionogram_15",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Le trou anionique doit-il être interprété différemment chez un nourrisson par "
          "rapport à un adulte, selon la population d'application documentée pour ce calcul ?",
      options: [
        "Non — la population d'application documentée est « tout âge », sans restriction "
            "pédiatrique particulière",
        "Oui, le calcul n'est documenté comme validé que chez l'adulte",
        "Oui, il n'est documenté comme applicable que chez le nouveau-né",
        "Le calcul n'est jamais applicable avant un âge précis selon la documentation",
      ],
      correctIndex: 0,
      explanation:
          "La métadonnée applicablePopulation du trou anionique est « Tout âge ».",
    ),
    const QuizQuestion(
      id: "ionogram_16",
      type: QuizQuestionType.scientificSource,
      prompt:
          "Le trou anionique de base (sans correction pour l'albuminémie) a été décrit par "
          "quels auteurs, en 1977 ?",
      options: [
        "Emmett M & Narins RG",
        "Figge J et al.",
        "Payne RB et al.",
        "Sterling RK et al.",
      ],
      correctIndex: 0,
      explanation:
          "Emmett M, Narins RG. Clinical Use of the Anion Gap. Medicine (Baltimore). "
          "1977;56(1):38-54.",
    ),
    const QuizQuestion(
      id: "ionogram_17",
      type: QuizQuestionType.vocabulary,
      prompt:
          "Dans la formule du trou anionique avec potassium, quel terme est ajouté au sodium "
          "avant de soustraire (chlore + bicarbonates) ?",
      options: [
        "Le potassium",
        "Le calcium",
        "L'albumine",
        "Le magnésium",
      ],
      correctIndex: 0,
      explanation:
          "Variante avec potassium : (Na + K) − (Cl + HCO3), documentée à côté de la variante "
          "sans potassium (Na − (Cl + HCO3)).",
    ),

    // ------------------------------------------------------------------
    // Osmolarité calculée et trou osmolaire (osmolality.dart)
    // ------------------------------------------------------------------
    const QuizQuestion(
      id: "ionogram_18",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient est admis pour suspicion d'intoxication au méthanol. Le laboratoire ne "
          "dispose que de l'osmolarité calculée (à partir du sodium, de la glycémie et de "
          "l'urée) ; aucune osmolalité mesurée par osmométrie n'a été réalisée. Peut-on rendre "
          "un trou osmolaire dans ce contexte ?",
      options: [
        "Non — le trou osmolaire ne doit être calculé que si une osmolalité mesurée par "
            "osmométrie (point de congélation) est réellement disponible, jamais estimée",
        "Oui, en estimant l'osmolalité mesurée à partir de la formule calculée",
        "Oui, le trou osmolaire peut toujours être déduit du trou anionique",
        "Oui, à condition de multiplier l'osmolarité calculée par un facteur correcteur",
      ],
      correctIndex: 0,
      explanation:
          "Limitation documentée : le trou osmolaire ne doit être calculé que si une osmolalité "
          "mesurée par osmométrie est disponible, jamais estimée.",
    ),
    const QuizQuestion(
      id: "ionogram_19",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Aux urgences, un patient comateux fait suspecter une intoxication à l'éthylène "
          "glycol. Le clinicien demande un « trou osmolaire », mais le laboratoire n'a pas "
          "encore reçu l'échantillon dédié à l'osmométrie. Que doit répondre le biologiste ?",
      options: [
        "Le trou osmolaire ne peut pas être calculé tant qu'une osmolalité mesurée par "
            "osmométrie n'est pas disponible ; il ne doit pas être estimé",
        "Le trou osmolaire peut être approché en doublant l'osmolarité calculée",
        "L'osmolarité calculée peut directement remplacer l'osmolalité mesurée dans la formule "
            "du trou osmolaire",
        "Le trou osmolaire n'a jamais d'intérêt en contexte toxicologique",
      ],
      correctIndex: 0,
      explanation:
          "Convention documentée : sans osmolalité mesurée fournie, aucun trou osmolaire n'est "
          "calculé (il n'est ni omis avec une valeur nulle, ni estimé).",
    ),
    const QuizQuestion(
      id: "ionogram_20",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Sur un compte-rendu, un interne assimile directement l'« osmolarité calculée » "
          "(mOsm/L) à l'« osmolalité mesurée » (mOsm/kg) pour un patient âgé déshydraté, sans "
          "réserve. Que faut-il rappeler, selon la documentation du calcul ?",
      options: [
        "Osmolarité (par litre de solution) et osmolalité (par kg d'eau) ne sont pas "
            "rigoureusement identiques, bien qu'assimilées en pratique clinique courante",
        "Ces deux grandeurs sont mathématiquement identiques dans tous les cas",
        "L'osmolarité ne peut jamais être comparée à l'osmolalité, même approximativement",
        "L'osmolalité est toujours le double de l'osmolarité calculée",
      ],
      correctIndex: 0,
      explanation:
          "Limitation documentée : osmolarité et osmolalité ne sont pas rigoureusement "
          "identiques, bien qu'assimilées en pratique clinique courante.",
    ),
    const QuizQuestion(
      id: "ionogram_21",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un biologiste junior demande si l'on peut, en routine, présenter l'osmolarité "
          "calculée comme si elle était l'osmolalité mesurée. Quelle est la réponse la plus "
          "rigoureuse d'après la documentation du calcul ?",
      options: [
        "Ces deux grandeurs, bien qu'assimilées en pratique courante, ne sont pas rigoureusement "
            "identiques (par litre de solution vs par kg d'eau)",
        "Oui, elles sont interchangeables sans réserve dans tous les contextes",
        "Non, l'osmolarité calculée est toujours le double de l'osmolalité mesurée",
        "Non, ces deux grandeurs n'ont aucun rapport entre elles",
      ],
      correctIndex: 0,
      explanation:
          "Limitation documentée sur l'assimilation pratique, mais non rigoureuse, entre "
          "osmolarité et osmolalité.",
    ),
    const QuizQuestion(
      id: "ionogram_22",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Chez un patient insuffisant rénal, un technicien saisit directement la valeur de "
          "l'urée sanguine exprimée en azote uréique (BUN, mg/dL) dans le champ « urée » du "
          "calcul d'osmolarité, sans conversion. Pourquoi cela pose-t-il un problème "
          "méthodologique ?",
      options: [
        "La formule documentée requiert l'urée en mmol/L, et non l'azote uréique (BUN)",
        "La formule requiert le BUN en mg/dL directement, sans conversion",
        "L'urée n'intervient pas dans le calcul de l'osmolarité",
        "Le BUN et l'urée en mmol/L sont rigoureusement la même valeur numérique",
      ],
      correctIndex: 0,
      explanation:
          "helpText documenté : « Urée en mmol/L — et non azote uréique / BUN ».",
    ),
    const QuizQuestion(
      id: "ionogram_23",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Pour un patient en acidocétose diabétique, quelles variables entrent dans le calcul "
          "de l'osmolarité calculée, selon la formule documentée (Smithline-Gardner) ?",
      options: [
        "2 × sodium, plus la glycémie (mmol/L), plus l'urée (mmol/L)",
        "Sodium seul, multiplié par 2",
        "Sodium + potassium + chlore",
        "Glycémie et urée uniquement, sans le sodium",
      ],
      correctIndex: 0,
      explanation:
          "Équation documentée : Osmolarité calculée = 2×Na + Glycémie(mmol/L) + Urée(mmol/L).",
    ),
    const QuizQuestion(
      id: "ionogram_24",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un petit laboratoire ne dispose pas d'osmomètre et ne peut donc pas mesurer "
          "l'osmolalité par point de congélation. Un clinicien demande néanmoins un trou "
          "osmolaire pour orienter vers une intoxication. Que doit faire le laboratoire ?",
      options: [
        "Ne pas rendre de trou osmolaire : il ne doit être calculé que si une osmolalité mesurée "
            "par osmométrie est réellement disponible",
        "Estimer l'osmolalité mesurée à partir de l'osmolarité calculée pour obtenir un trou "
            "osmolaire approximatif",
        "Rendre un trou osmolaire égal à zéro par défaut",
        "Utiliser le trou anionique à la place du trou osmolaire",
      ],
      correctIndex: 0,
      explanation:
          "Le trou osmolaire n'apparaît que s'il est effectivement calculable à partir d'une "
          "osmolalité mesurée fournie ; il n'est jamais estimé.",
    ),
    const QuizQuestion(
      id: "ionogram_25",
      type: QuizQuestionType.scientificSource,
      prompt:
          "La formule de l'osmolarité calculée (2×Na + glycémie + urée) et la notion de trou "
          "osmolaire ont été décrites par quels auteurs, en 1976 ?",
      options: [
        "Smithline N & Gardner KD Jr (JAMA)",
        "Sterling RK et al.",
        "Wai CT et al.",
        "Katz MA",
      ],
      correctIndex: 0,
      explanation:
          "Smithline N, Gardner KD Jr. Gaps—Anionic and Osmolal. JAMA. 1976;236(14):1594-1597.",
    ),

    // ------------------------------------------------------------------
    // Sodium corrigé pour hyperglycémie (sodium_correction.dart)
    // ------------------------------------------------------------------
    const QuizQuestion(
      id: "ionogram_26",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient en acidocétose diabétique présente une hyperglycémie sévère et un sodium "
          "mesuré abaissé. Le laboratoire calcule le sodium corrigé. Que doit afficher le "
          "compte-rendu, selon la documentation du calcul ?",
      options: [
        "Les deux sodiums corrigés, selon le coefficient de Katz (1,6) ET selon le coefficient "
            "de Hillier (2,4), affichés ensemble",
        "Uniquement le sodium corrigé selon Katz, seule référence retenue",
        "Uniquement le sodium corrigé selon Hillier, plus récent donc préféré",
        "La moyenne arithmétique des deux sodiums corrigés",
      ],
      correctIndex: 0,
      explanation:
          "Les deux coefficients (Katz 1973, Hillier 1999) sont rapportés dans la littérature et "
          "toujours calculés et affichés ensemble ; le laboratoire choisit et documente celui "
          "qu'il retient en pratique.",
    ),
    const QuizQuestion(
      id: "ionogram_27",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Une patiente âgée est admise pour un état hyperosmolaire hyperglycémique avec une "
          "natrémie mesurée basse. Le biologiste hésite à ne rendre que le sodium corrigé selon "
          "Hillier, jugé plus sensible. Que recommande la documentation du calcul ?",
      options: [
        "Calculer et afficher systématiquement les deux sodiums corrigés (Katz et Hillier) côte "
            "à côte, sans en écarter un",
        "Ne rendre que le coefficient de Hillier, les deux étant redondants",
        "Ne rendre que le coefficient de Katz, seul historiquement validé",
        "Ne rendre aucun sodium corrigé en cas d'état hyperosmolaire",
      ],
      correctIndex: 0,
      explanation:
          "Les deux coefficients de correction sont toujours calculés ensemble, l'un ne "
          "remplaçant jamais l'autre.",
    ),
    const QuizQuestion(
      id: "ionogram_28",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un laboratoire souhaite harmoniser sa pratique concernant le sodium corrigé pour "
          "hyperglycémie, alors que Katz (1,6) et Hillier (2,4) sont tous deux rapportés dans "
          "la littérature. Que doit faire le laboratoire, selon la documentation ?",
      options: [
        "Choisir et documenter en interne quel coefficient il retient en pratique clinique",
        "Utiliser exclusivement le coefficient le plus élevé par principe de précaution",
        "Alterner aléatoirement entre les deux coefficients selon les patients",
        "Ne calculer le sodium corrigé qu'à la demande explicite du clinicien",
      ],
      correctIndex: 0,
      explanation:
          "Limitation documentée : les deux coefficients sont rapportés dans la littérature ; le "
          "laboratoire doit choisir et documenter celui qu'il retient en pratique.",
    ),
    const QuizQuestion(
      id: "ionogram_29",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient présente une glycémie proche de 1,00 g/L (100 mg/dL, soit environ "
          "5,55 mmol/L). Le sodium corrigé est tout de même calculé automatiquement. Quelle "
          "information accompagne ce résultat, selon le calcul documenté ?",
      options: [
        "Un avertissement indiquant que la correction est peu pertinente pour une glycémie "
            "proche ou en dessous de 1,00 g/L",
        "Un message d'erreur bloquant tout rendu de résultat",
        "Une majoration automatique du coefficient de correction",
        "Aucune information particulière n'est jamais générée par le calcul",
      ],
      correctIndex: 0,
      explanation:
          "Une glycémie ≤ 100 mg/dL (5,55 mmol/L) génère un avertissement documenté de sévérité "
          "« info », la correction perdant alors sa pertinence.",
    ),
    const QuizQuestion(
      id: "ionogram_30",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient a une glycémie saisie en mmol/L dans le dossier. Pour appliquer la "
          "formule du sodium corrigé documentée (coefficient × (glycémie − 100)/100), dans "
          "quelle unité la glycémie doit-elle être exprimée ?",
      options: [
        "En mg/dL (la glycémie en mmol/L doit être convertie au préalable)",
        "En mmol/L directement, sans conversion",
        "En g/L, sans conversion",
        "L'unité n'a aucune importance pour cette formule",
      ],
      correctIndex: 0,
      explanation:
          "Équation documentée : Na corrigé = Na mesuré + coefficient × (Glycémie mg/dL − "
          "100)/100.",
    ),
    const QuizQuestion(
      id: "ionogram_31",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Chez un patient hyperglycémique associant une dysprotéinémie, un interne propose de "
          "ne rendre que le coefficient de Hillier (2,4), le jugeant plus « moderne » que celui "
          "de Katz. Est-ce conforme à la documentation du calcul ?",
      options: [
        "Non — les deux coefficients doivent être calculés et affichés ensemble, aucun ne "
            "remplaçant l'autre",
        "Oui, Hillier est documenté comme la seule méthode valide depuis 1999",
        "Oui, car Katz est documenté comme obsolète",
        "Non, seul Katz doit être affiché, Hillier étant réservé à la recherche",
      ],
      correctIndex: 0,
      explanation:
          "Les deux coefficients (Katz 1973, Hillier 1999) sont toujours calculés et affichés "
          "ensemble, sans que l'un remplace l'autre.",
    ),
    const QuizQuestion(
      id: "ionogram_32",
      type: QuizQuestionType.scientificSource,
      prompt:
          "Le coefficient de correction du sodium de 1,6 pour l'hyperglycémie a été proposé par "
          "quel auteur, en 1973 ?",
      options: [
        "Katz MA (N Engl J Med)",
        "Hillier TA",
        "Payne RB",
        "Figge J",
      ],
      correctIndex: 0,
      explanation:
          "Katz MA. Hyperglycemia-Induced Hyponatremia — Calculation of Expected Serum Sodium "
          "Depression. N Engl J Med. 1973;289(16):843-844.",
    ),
    const QuizQuestion(
      id: "ionogram_33",
      type: QuizQuestionType.scientificSource,
      prompt:
          "Le coefficient de correction du sodium de 2,4 pour l'hyperglycémie a été proposé par "
          "quels auteurs, en 1999 ?",
      options: [
        "Hillier TA, Abbott RD, Barrett EJ (Am J Med)",
        "Katz MA",
        "Sterling RK et al.",
        "Wai CT et al.",
      ],
      correctIndex: 0,
      explanation:
          "Hillier TA, Abbott RD, Barrett EJ. Hyponatremia: Evaluating the Correction Factor for "
          "Hyperglycemia. Am J Med. 1999;106(4):399-403.",
    ),

    // ------------------------------------------------------------------
    // Calcium corrigé pour l'albuminémie (calcium_correction.dart)
    // ------------------------------------------------------------------
    const QuizQuestion(
      id: "ionogram_34",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient de réanimation a un calcium ionisé mesuré directement par gazométrie, et "
          "présente par ailleurs une hypoalbuminémie. Le laboratoire a aussi calculé un calcium "
          "corrigé pour l'albuminémie. Comment ces deux résultats doivent-ils être considérés ?",
      options: [
        "Le calcium ionisé mesuré prime toujours ; le calcium corrigé calculé ne doit jamais le "
            "remplacer et reste une donnée distincte",
        "Le calcium corrigé calculé remplace systématiquement le calcium ionisé mesuré, plus "
            "simple à interpréter",
        "Seule la moyenne des deux valeurs doit être rendue",
        "Le calcium ionisé mesuré doit être retiré du compte-rendu au profit du calcul",
      ],
      correctIndex: 0,
      explanation:
          "Limitation documentée : le calcium corrigé est une estimation indirecte qui ne "
          "remplace jamais un calcium ionisé mesuré, donnée distincte à conserver.",
    ),
    const QuizQuestion(
      id: "ionogram_35",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "En post-opératoire, un patient a un calcium ionisé mesuré normal, mais une "
          "albuminémie basse conduisant à un calcium corrigé calculé faussement évocateur "
          "d'hypocalcémie. Quelle est la conduite documentée ?",
      options: [
        "Conserver et interpréter le calcium ionisé mesuré comme donnée de référence, sans le "
            "remplacer par le calcul",
        "Remplacer le calcium ionisé mesuré par le calcium corrigé calculé, jugé plus "
            "représentatif",
        "Ignorer le calcium ionisé mesuré et ne conserver que le calcul",
        "Considérer les deux valeurs comme rigoureusement interchangeables",
      ],
      correctIndex: 0,
      explanation:
          "Le calcium corrigé ne remplace jamais un calcium ionisé mesuré, qui doit toujours "
          "être saisi et interprété comme une donnée distincte.",
    ),
    const QuizQuestion(
      id: "ionogram_36",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient atteint de myélome multiple présente une dysprotéinémie marquée. Le "
          "calcium corrigé pour l'albuminémie est calculé. Quelle limite documentée s'applique "
          "à ce résultat dans ce contexte ?",
      options: [
        "La formule est moins fiable en cas de dysprotéinémie marquée, comme dans le myélome",
        "La formule est au contraire plus fiable en cas de dysprotéinémie",
        "Le myélome ne modifie en rien la fiabilité de la formule",
        "La formule ne peut être appliquée qu'en cas de myélome",
      ],
      correctIndex: 0,
      explanation:
          "Limitation documentée : moins fiable en cas d'acidose ou d'alcalose sévère, ou de "
          "dysprotéinémie marquée (ex. myélome).",
    ),
    const QuizQuestion(
      id: "ionogram_37",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Une patiente présente des vomissements incoercibles entraînant une alcalose "
          "métabolique sévère. Un calcium corrigé pour l'albuminémie est calculé en complément "
          "du bilan phosphocalcique. Que faut-il garder à l'esprit, selon la documentation ?",
      options: [
        "La formule est moins fiable en cas d'alcalose sévère",
        "L'alcalose sévère améliore la fiabilité de la formule",
        "L'alcalose n'a aucune influence documentée sur cette formule",
        "La formule devient alors la référence absolue, supplantant le calcium ionisé",
      ],
      correctIndex: 0,
      explanation:
          "Limitation documentée : moins fiable en cas d'acidose ou d'alcalose sévère.",
    ),
    const QuizQuestion(
      id: "ionogram_38",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Une patiente présente un syndrome néphrotique avec une albuminémie basse et un "
          "calcium mesuré. Quelle est la formule de correction documentée (Payne, 1973) à "
          "appliquer ?",
      options: [
        "Calcium corrigé (mg/dL) = Calcium mesuré (mg/dL) + 0,8 × (4,0 − albuminémie en g/dL)",
        "Calcium corrigé (mg/dL) = Calcium mesuré (mg/dL) − 0,8 × (4,0 − albuminémie en g/dL)",
        "Calcium corrigé (mg/dL) = Calcium mesuré (mg/dL) × 0,8 × albuminémie en g/dL",
        "Calcium corrigé (mg/dL) = 0,8 × Calcium mesuré (mg/dL) / albuminémie en g/dL",
      ],
      correctIndex: 0,
      explanation:
          "Équation documentée (Payne 1973) : Ca corrigé (mg/dL) = Ca mesuré (mg/dL) + "
          "0,8 × (4,0 − albuminémie en g/dL).",
    ),
    const QuizQuestion(
      id: "ionogram_39",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Chez un patient cirrhotique hypoalbuminémique, un clinicien demande le détail du "
          "calcul du calcium corrigé pour l'albuminémie. Quel coefficient est appliqué à "
          "l'écart entre 4,0 g/dL et l'albuminémie mesurée, selon la formule de Payne (1973) ?",
      options: [
        "0,8",
        "1,6",
        "2,4",
        "2,5",
      ],
      correctIndex: 0,
      explanation:
          "Le coefficient documenté de la formule de Payne (1973) est 0,8 (à ne pas confondre "
          "avec le 1,6 de Katz, le 2,4 de Hillier, ou le 2,5 de Figge pour d'autres calculs).",
    ),
    const QuizQuestion(
      id: "ionogram_40",
      type: QuizQuestionType.scientificSource,
      prompt:
          "La formule de correction du calcium sérique pour l'albuminémie a été décrite par "
          "quels auteurs, en 1973 ?",
      options: [
        "Payne RB, Little AJ, Williams RB, Milner JR (Br Med J)",
        "Katz MA",
        "Figge J et al.",
        "Emmett M & Narins RG",
      ],
      correctIndex: 0,
      explanation:
          "Payne RB, Little AJ, Williams RB, Milner JR. Interpretation of Serum Calcium in "
          "Patients With Abnormal Serum Proteins. Br Med J. 1973;4(5893):643-646.",
    ),

    // ------------------------------------------------------------------
    // CTF / saturation de la transferrine (misc_biochemistry.dart)
    // ------------------------------------------------------------------
    const QuizQuestion(
      id: "ionogram_41",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Chez une patiente suivie pour anémie microcytaire, seul le dosage de la transferrine "
          "est disponible (pas de CTF mesurée directement). Le laboratoire calcule la CTF à "
          "partir de la transferrine. Quelle formule est documentée pour cette estimation ?",
      options: [
        "CTF (µg/dL) = Transferrine (mg/dL) × 1,42, facteur usuel à confirmer selon le réactif "
            "du laboratoire",
        "CTF (µg/dL) = Transferrine (mg/dL) / 1,42, valeur fixe universelle",
        "CTF (µg/dL) = Transferrine (mg/dL) × 2,4",
        "CTF (µg/dL) = Transferrine (mg/dL) − 1,42",
      ],
      correctIndex: 0,
      explanation:
          "Équation documentée : CTF (µg/dL) = Transferrine (mg/dL) × 1,42 — facteur usuel, à "
          "confirmer selon le réactif du laboratoire.",
    ),
    const QuizQuestion(
      id: "ionogram_42",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un laboratoire change de fournisseur de réactif pour le dosage de la transferrine. "
          "La CTF calculée par le facteur ×1,42 diffère légèrement des CTF calculées "
          "auparavant. Comment interpréter cet écart, selon les limites documentées du calcul ?",
      options: [
        "Le facteur ×1,42 est un facteur usuel approximatif, supposant une saturation théorique "
            "de la transferrine en fer, qui peut varier légèrement selon la méthode",
        "Il s'agit forcément d'une erreur de calibration à corriger immédiatement",
        "Le facteur ×1,42 est une constante physique universelle qui ne peut jamais varier",
        "La CTF calculée ne dépend jamais du réactif utilisé",
      ],
      correctIndex: 0,
      explanation:
          "Limitation documentée : facteur approximatif supposant une saturation théorique de "
          "la transferrine en fer ; peut varier légèrement selon la méthode.",
    ),
    const QuizQuestion(
      id: "ionogram_43",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Une suspicion d'hémochromatose conduit à calculer le coefficient de saturation de la "
          "transferrine à partir du fer sérique et de la CTF. Dans quelle unité ces deux "
          "paramètres doivent-ils être exprimés pour appliquer la formule documentée ?",
      options: [
        "Tous deux en µg/dL",
        "Fer sérique en mg/dL et CTF en µg/dL",
        "Tous deux en mmol/L",
        "Fer sérique en µg/dL et CTF en g/L",
      ],
      correctIndex: 0,
      explanation:
          "helpText documenté : fer sérique et CTF en µg/dL (utiliser le calcul de CTF à partir "
          "de la transferrine si seule celle-ci est disponible).",
    ),
    const QuizQuestion(
      id: "ionogram_44",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Chez une femme enceinte suivie pour anémie, seule la transferrinémie est disponible "
          "au laboratoire. Une estimation de la CTF est demandée par le clinicien. Quel facteur "
          "multiplicateur usuel est appliqué à la transferrine (en mg/dL) pour obtenir la CTF "
          "théorique (en µg/dL) ?",
      options: [
        "1,42",
        "0,8",
        "2,5",
        "1,6",
      ],
      correctIndex: 0,
      explanation:
          "Facteur usuel documenté : ×1,42 (à ne pas confondre avec le 0,8 de Payne, le 2,5 de "
          "Figge ou le 1,6 de Katz utilisés dans d'autres calculs de ce module).",
    ),
    const QuizQuestion(
      id: "ionogram_45",
      type: QuizQuestionType.scientificSource,
      prompt:
          "La méthode de calcul du coefficient de saturation de la transferrine (fer sérique / "
          "CTF × 100) s'appuie sur les recommandations de quel organisme, publiées en 1978 ?",
      options: [
        "International Committee for Standardization in Haematology (ICSH)",
        "Organisation mondiale de la santé (OMS)",
        "Société française de biologie clinique",
        "College of American Pathologists (CAP)",
      ],
      correctIndex: 0,
      explanation:
          "International Committee for Standardization in Haematology (ICSH). Recommendations "
          "for Measurement of Serum Iron in Serum. Br J Haematol. 1978;38(2):291-294.",
    ),
    const QuizQuestion(
      id: "ionogram_46",
      type: QuizQuestionType.vocabulary,
      prompt:
          "Que représente le coefficient de saturation de la transferrine, calculable à partir "
          "du fer sérique et de la CTF ?",
      options: [
        "Le rapport fer sérique / CTF, exprimé en pourcentage",
        "La somme du fer sérique et de la CTF",
        "La CTF divisée par la ferritine",
        "Le produit du fer sérique par la CTF",
      ],
      correctIndex: 0,
      explanation:
          "Équation documentée : Saturation (%) = Fer sérique (µg/dL) / CTF (µg/dL) × 100.",
    ),

    // ------------------------------------------------------------------
    // Globulines et rapport albumine/globulines (misc_biochemistry.dart)
    // ------------------------------------------------------------------
    const QuizQuestion(
      id: "ionogram_47",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient cirrhotique présente une hypergammaglobulinémie sur l'électrophorèse, "
          "mais le laboratoire souhaite aussi calculer les globulines par un calcul rapide à "
          "partir des protéines totales et de l'albuminémie. Quelle est la formule documentée ?",
      options: [
        "Globulines (g/L) = Protéines totales (g/L) − Albumine (g/L)",
        "Globulines (g/L) = Protéines totales (g/L) + Albumine (g/L)",
        "Globulines (g/L) = Albumine (g/L) − Protéines totales (g/L)",
        "Globulines (g/L) = Protéines totales (g/L) / Albumine (g/L)",
      ],
      correctIndex: 0,
      explanation:
          "Équation documentée : Globulines (g/L) = Protéines totales (g/L) − Albumine (g/L) "
          "(bilan de masse).",
    ),
    const QuizQuestion(
      id: "ionogram_48",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Chez un patient présentant un pic monoclonal suspecté, le calcul des globulines par "
          "différence (protéines totales − albumine) est réalisé en routine. Quelle limite ce "
          "calcul comporte-t-il, selon la documentation ?",
      options: [
        "C'est une estimation indirecte des globulines ; l'électrophorèse des protéines "
            "sériques reste la référence pour caractériser les fractions protéiques",
        "Ce calcul remplace totalement l'électrophorèse des protéines, devenue inutile",
        "Ce calcul est documenté comme plus précis que l'électrophorèse pour identifier un pic "
            "monoclonal",
        "Ce calcul ne peut jamais être réalisé chez un patient présentant une dysprotéinémie",
      ],
      correctIndex: 0,
      explanation:
          "Limitation documentée : estimation indirecte des globulines ; l'électrophorèse des "
          "protéines sériques reste la référence pour caractériser les fractions protéiques.",
    ),
    const QuizQuestion(
      id: "ionogram_49",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient présente un syndrome inflammatoire chronique avec élévation des "
          "globulines. Le laboratoire calcule le rapport albumine/globulines (A/G). Comment ce "
          "rapport est-il défini, selon la documentation du calcul ?",
      options: [
        "Rapport A/G = Albumine / Globulines",
        "Rapport A/G = Globulines / Albumine",
        "Rapport A/G = Albumine × Globulines",
        "Rapport A/G = (Albumine + Globulines) / 2",
      ],
      correctIndex: 0,
      explanation: "Équation documentée : Rapport A/G = Albumine / Globulines.",
    ),
    const QuizQuestion(
      id: "ionogram_50",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un technicien saisit par erreur une albuminémie supérieure aux protéines totales du "
          "même patient dans le calcul des globulines. Que se passe-t-il, selon la logique de "
          "validation documentée du calcul ?",
      options: [
        "Le calcul est refusé : l'albuminémie ne peut pas dépasser les protéines totales",
        "Le calcul renvoie des globulines négatives sans avertissement",
        "Le calcul arrondit automatiquement l'albuminémie au niveau des protéines totales",
        "Le calcul ignore l'albuminémie et n'affiche que les protéines totales",
      ],
      correctIndex: 0,
      explanation:
          "Le calcul lève une erreur de saisie dès lors que l'albuminémie dépasse les protéines "
          "totales.",
    ),
    const QuizQuestion(
      id: "ionogram_51",
      type: QuizQuestionType.vocabulary,
      prompt:
          "Dans le rapport albumine/globulines (A/G), que représente le numérateur ?",
      options: [
        "L'albuminémie",
        "Les globulines",
        "Les protéines totales",
        "La CTF",
      ],
      correctIndex: 0,
      explanation: "Rapport A/G = Albumine / Globulines : l'albumine est au numérateur.",
    ),

    // ------------------------------------------------------------------
    // Bilirubine indirecte (misc_biochemistry.dart)
    // ------------------------------------------------------------------
    const QuizQuestion(
      id: "ionogram_52",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un nouveau-né présente un ictère à bilirubine non conjuguée prédominante. Le "
          "laboratoire ne dispose pas d'un dosage direct de la bilirubine indirecte, mais des "
          "bilirubines totale et directe. Comment la bilirubine indirecte est-elle obtenue, "
          "selon le calcul documenté ?",
      options: [
        "Par différence : Bilirubine indirecte = Bilirubine totale − Bilirubine directe",
        "Par addition : Bilirubine indirecte = Bilirubine totale + Bilirubine directe",
        "Par un dosage enzymatique spécifique intégré au calcul",
        "Bilirubine indirecte = Bilirubine directe / Bilirubine totale",
      ],
      correctIndex: 0,
      explanation:
          "Équation documentée (bilan de masse) : Bilirubine indirecte = Bilirubine totale − "
          "Bilirubine directe.",
    ),
    const QuizQuestion(
      id: "ionogram_53",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient adulte présente une anémie hémolytique avec élévation de la bilirubine "
          "totale et une bilirubine directe restant basse. Le laboratoire calcule la bilirubine "
          "indirecte (non conjuguée). Quelle formule est appliquée ?",
      options: [
        "Bilirubine indirecte = Bilirubine totale − Bilirubine directe (bilan de masse)",
        "Bilirubine indirecte = Bilirubine totale × Bilirubine directe",
        "Bilirubine indirecte = (Bilirubine totale + Bilirubine directe) / 2",
        "Bilirubine indirecte = Bilirubine directe − Bilirubine totale",
      ],
      correctIndex: 0,
      explanation:
          "Équation documentée : Bilirubine indirecte = Bilirubine totale − Bilirubine directe.",
    ),
    const QuizQuestion(
      id: "ionogram_54",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Lors de la saisie des résultats d'un patient ictérique, la bilirubine directe est "
          "enregistrée par erreur à une valeur supérieure à la bilirubine totale. Que doit "
          "faire le calcul, selon sa logique documentée ?",
      options: [
        "Refuser le calcul : la bilirubine directe ne peut pas dépasser la bilirubine totale",
        "Calculer une bilirubine indirecte négative et l'afficher telle quelle",
        "Remplacer automatiquement la bilirubine totale par la bilirubine directe",
        "Ignorer la bilirubine directe et n'utiliser que la bilirubine totale",
      ],
      correctIndex: 0,
      explanation:
          "Le calcul lève une erreur de saisie si la bilirubine directe dépasse la bilirubine "
          "totale.",
    ),

    // ------------------------------------------------------------------
    // Rapport ASAT/ALAT — De Ritis (misc_biochemistry.dart)
    // ------------------------------------------------------------------
    const QuizQuestion(
      id: "ionogram_55",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient présente une hépatite virale aiguë avec une ASAT et une ALAT élevées. Le "
          "laboratoire calcule le rapport ASAT/ALAT (De Ritis). Comment ce rapport est-il "
          "défini ?",
      options: [
        "Rapport De Ritis = ASAT / ALAT",
        "Rapport De Ritis = ALAT / ASAT",
        "Rapport De Ritis = ASAT × ALAT",
        "Rapport De Ritis = ASAT − ALAT",
      ],
      correctIndex: 0,
      explanation: "Équation documentée : Rapport De Ritis = ASAT / ALAT.",
    ),
    const QuizQuestion(
      id: "ionogram_56",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Chez un patient suspect d'hépatopathie alcoolique, l'ASAT est proportionnellement "
          "plus élevée que l'ALAT. Pour objectiver ce rapport, quelle formule le laboratoire "
          "applique-t-il, selon la documentation ?",
      options: [
        "Le rapport ASAT/ALAT, ASAT au numérateur et ALAT au dénominateur",
        "Le rapport ALAT/ASAT, ALAT au numérateur",
        "La somme ASAT + ALAT divisée par 2",
        "La différence ASAT − ALAT, sans division",
      ],
      correctIndex: 0,
      explanation: "Équation documentée : Rapport De Ritis = ASAT / ALAT.",
    ),
    const QuizQuestion(
      id: "ionogram_57",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Dans le bilan d'une stéatohépatite non alcoolique (NASH), le rapport ASAT/ALAT (De "
          "Ritis) est calculé pour compléter l'évaluation biologique. Quelle grandeur figure au "
          "numérateur de ce rapport ?",
      options: [
        "L'ASAT",
        "L'ALAT",
        "Les plaquettes",
        "L'âge du patient",
      ],
      correctIndex: 0,
      explanation: "Équation documentée : Rapport De Ritis = ASAT / ALAT.",
    ),
    const QuizQuestion(
      id: "ionogram_58",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Pour calculer le rapport ASAT/ALAT (De Ritis) chez un patient donné, dans quelle "
          "unité les deux transaminases doivent-elles être exprimées, selon la documentation du "
          "calcul ?",
      options: [
        "En U/L",
        "En µmol/L",
        "En g/L",
        "En mmol/L",
      ],
      correctIndex: 0,
      explanation: "helpText documenté : ASAT et ALAT en U/L.",
    ),
    const QuizQuestion(
      id: "ionogram_59",
      type: QuizQuestionType.vocabulary,
      prompt: "Pourquoi le rapport ASAT/ALAT est-il appelé « rapport de De Ritis » ?",
      options: [
        "Du nom de l'auteur (De Ritis F) qui l'a décrit avec ses coauteurs en 1957",
        "Parce que De Ritis est le nom de l'enzyme ASAT",
        "Parce que c'est l'unité de mesure des transaminases",
        "Il s'agit d'un acronyme sans rapport avec un auteur",
      ],
      correctIndex: 0,
      explanation:
          "De Ritis F, Coltorti M, Giusti G. Clin Chim Acta. 1957;2(1):70-74.",
    ),

    // ------------------------------------------------------------------
    // Score FIB-4 (misc_biochemistry.dart)
    // ------------------------------------------------------------------
    const QuizQuestion(
      id: "ionogram_60",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Le score FIB-4 est calculé chez un patient suivi pour hépatite B chronique, sans "
          "co-infection VIH ni VHC. Que faut-il garder à l'esprit, selon la population "
          "d'application documentée pour ce score ?",
      options: [
        "Le FIB-4 a été développé initialement chez des patients co-infectés VIH/VHC, mais est "
            "utilisé plus largement en hépatologie, avec des seuils dépendant du contexte et de "
            "l'âge, à valider localement",
        "Le FIB-4 n'est documenté comme valide que chez les patients co-infectés VIH/VHC",
        "Le FIB-4 est documenté comme indépendant de l'âge et du contexte clinique",
        "Le FIB-4 n'a jamais été validé en dehors des essais cliniques initiaux",
      ],
      correctIndex: 0,
      explanation:
          "applicablePopulation documentée : adulte, développé chez les patients co-infectés "
          "VIH/VHC, utilisé plus largement en hépatologie avec des seuils dépendant du contexte "
          "et de l'âge — à valider localement.",
    ),
    const QuizQuestion(
      id: "ionogram_61",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Chez un patient âgé suivi pour stéatose hépatique non alcoolique (NAFLD), le FIB-4 "
          "est calculé. Un clinicien applique le même seuil d'interprétation que chez un adulte "
          "jeune. Que rappelle la documentation du score à ce sujet ?",
      options: [
        "Les seuils d'interprétation du FIB-4 dépendent du contexte clinique et de l'âge, et "
            "doivent être validés localement",
        "Le seuil du FIB-4 est documenté comme universel, identique quel que soit l'âge",
        "Le FIB-4 est documenté comme non calculable chez un patient de plus de 60 ans",
        "L'âge n'entre jamais en compte selon la documentation du FIB-4",
      ],
      correctIndex: 0,
      explanation:
          "applicablePopulation documentée : seuils dépendant du contexte et de l'âge, à valider "
          "localement.",
    ),
    const QuizQuestion(
      id: "ionogram_62",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un pédiatre souhaite utiliser le score FIB-4 chez un enfant suivi pour une "
          "hépatopathie. Que dit la population d'application documentée pour ce score ?",
      options: [
        "Le FIB-4 est documenté comme applicable à l'adulte",
        "Le FIB-4 est documenté comme applicable exclusivement à l'enfant",
        "Le FIB-4 est documenté comme applicable à tout âge, sans restriction",
        "Aucune population d'application n'est précisée dans la documentation du FIB-4",
      ],
      correctIndex: 0,
      explanation: "applicablePopulation documentée pour le FIB-4 : Adulte.",
    ),
    const QuizQuestion(
      id: "ionogram_63",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Pour calculer le score FIB-4 chez un patient donné, dans quelle unité la numération "
          "plaquettaire doit-elle être exprimée, selon l'aide documentée du calcul ?",
      options: [
        "En G/L (×10⁹/L)",
        "En /mm³ directement",
        "En mmol/L",
        "En g/L (grammes par litre)",
      ],
      correctIndex: 0,
      explanation: "helpText documenté : plaquettes en G/L (×10⁹/L).",
    ),
    const QuizQuestion(
      id: "ionogram_64",
      type: QuizQuestionType.scientificSource,
      prompt:
          "Dans quelle revue et quelle année le score FIB-4 a-t-il été publié par Sterling et "
          "al. ?",
      options: [
        "Hepatology, 2006",
        "The Lancet, 1998",
        "N Engl J Med, 1973",
        "JAMA, 1976",
      ],
      correctIndex: 0,
      explanation:
          "Sterling RK et al. Development of a Simple Noninvasive Index to Predict Significant "
          "Fibrosis in Patients With HIV/HCV Coinfection. Hepatology. 2006;43(6):1317-1325.",
    ),

    // ------------------------------------------------------------------
    // Score APRI (misc_biochemistry.dart)
    // ------------------------------------------------------------------
    const QuizQuestion(
      id: "ionogram_65",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un patient suivi pour hépatite C chronique a un score APRI calculé par deux "
          "laboratoires différents, utilisant chacun leur propre limite supérieure de la "
          "normale (LSN) de l'ASAT. Les résultats diffèrent légèrement. Pourquoi, selon la "
          "documentation du calcul ?",
      options: [
        "La LSN de l'ASAT doit être définie localement par chaque laboratoire, et non fixée à "
            "une valeur universelle",
        "Il s'agit nécessairement d'une erreur de calcul dans l'un des deux laboratoires",
        "La LSN de l'ASAT est documentée comme une constante internationale identique pour tous "
            "les laboratoires",
        "Le score APRI ne dépend jamais de la LSN de l'ASAT",
      ],
      correctIndex: 0,
      explanation:
          "helpText documenté : limite supérieure de la normale (ULN) de l'ASAT définie "
          "localement par le laboratoire.",
    ),
    const QuizQuestion(
      id: "ionogram_66",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un pédiatre envisage d'utiliser le score APRI chez un enfant présentant une "
          "hépatopathie. Que précise la population d'application documentée pour ce score ?",
      options: [
        "Le score APRI est documenté comme applicable à l'adulte",
        "Le score APRI est documenté comme applicable à tout âge sans restriction",
        "Le score APRI est documenté comme réservé exclusivement à l'enfant",
        "Aucune population d'application n'est précisée dans la documentation de l'APRI",
      ],
      correctIndex: 0,
      explanation: "applicablePopulation documentée pour l'APRI : Adulte.",
    ),
    const QuizQuestion(
      id: "ionogram_67",
      type: QuizQuestionType.clinicalCase,
      prompt:
          "Un laboratoire reçoit un résultat d'APRI calculé par un centre externe, sans que la "
          "LSN de l'ASAT utilisée soit précisée. Peut-on réinterpréter directement ce résultat "
          "avec la LSN propre au laboratoire receveur ?",
      options: [
        "Non sans précaution — la LSN de l'ASAT doit être définie localement, et un APRI calculé "
            "avec une LSN différente n'est pas directement comparable",
        "Oui, la LSN de l'ASAT est documentée comme universelle",
        "Oui, car le score APRI ne dépend pas de la LSN de l'ASAT",
        "Non, le score APRI ne peut jamais être transmis d'un laboratoire à un autre",
      ],
      correctIndex: 0,
      explanation:
          "helpText documenté : LSN de l'ASAT définie localement par le laboratoire — jamais une "
          "valeur universelle codée en dur.",
    ),
    const QuizQuestion(
      id: "ionogram_68",
      type: QuizQuestionType.scientificSource,
      prompt:
          "Le score APRI (AST to Platelet Ratio Index) a été décrit par quels auteurs, dans "
          "quelle revue, en 2003 ?",
      options: [
        "Wai CT et al., Hepatology",
        "Sterling RK et al., Hepatology",
        "De Ritis F et al., Clin Chim Acta",
        "Payne RB et al., Br Med J",
      ],
      correctIndex: 0,
      explanation:
          "Wai CT, Greenson JK, Fontana RJ, et al. A Simple Noninvasive Index Can Predict Both "
          "Significant Fibrosis and Cirrhosis in Patients With Chronic Hepatitis C. Hepatology. "
          "2003;38(2):518-526.",
    ),
  ],
);
