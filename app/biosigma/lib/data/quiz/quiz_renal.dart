import 'package:biosigma_core/biosigma_core.dart';

import '../../models/quiz_question.dart';

final QuizModule quizRenal = QuizModule(
  id: 'quiz_renal',
  title: 'Fonction rénale et urines',
  category: CalculatorCategory.renal,
  questions: [
    const QuizQuestion(
      id: 'renal_1',
      type: QuizQuestionType.scientificSource,
      prompt: "L'équation CKD-EPI créatinine 2021 (sans coefficient racial) a été publiée par :",
      options: [
        'Inker LA et al., N Engl J Med 2021',
        'Cockcroft DW & Gault MH, Nephron 1976',
        'Levey AS et al., Ann Intern Med 1999 (MDRD)',
        'Schwartz GJ et al., J Am Soc Nephrol 2009',
      ],
      correctIndex: 0,
      explanation:
          "L'équation CKD-EPI 2021 (créatinine, cystatine C, et combinée) provient d'Inker LA et al., "
          'N Engl J Med. 2021;385(19):1737-1749 — développée avec le NKF-ASN Task Force pour retirer '
          "le coefficient racial des équations précédentes.",
    ),
    const QuizQuestion(
      id: 'renal_2',
      type: QuizQuestionType.scientificSource,
      prompt: "L'équation de Schwartz « bedside » (k = 0,413), utilisée en pédiatrie, date de :",
      options: ['1976', '1999', '2009', '2021'],
      correctIndex: 2,
      explanation:
          'Schwartz GJ, Muñoz A, Schneider MF, et al. J Am Soc Nephrol. 2009;20(3):629-637. '
          "La constante historique de 1976 (k=0,55) correspondait à un dosage de créatinine non "
          'standardisé IDMS — ne pas la confondre avec la version bedside actuelle.',
    ),
    const QuizQuestion(
      id: 'renal_3',
      type: QuizQuestionType.scientificSource,
      prompt: 'Le rapport albumine/créatinine urinaire (mg/g ou mg/mmol) comme alternative à la '
          'protéinurie des 24 h est notamment formalisé par :',
      options: [
        'Les recommandations KDIGO 2012 sur la maladie rénale chronique',
        'Friedewald WT et al., 1972',
        "L'OMS, système INR/ISI",
        'De Ritis F et al., 1957',
      ],
      correctIndex: 0,
      explanation:
          'Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. KDIGO 2012 Clinical '
          'Practice Guideline for the Evaluation and Management of Chronic Kidney Disease.',
    ),
    const QuizQuestion(
      id: 'renal_4',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un enfant de 8 ans présente une insuffisance rénale suspectée. Quelle équation '
          "d'estimation du DFG choisir plutôt qu'une équation CKD-EPI ?",
      options: [
        'Schwartz bedside pédiatrique',
        'CKD-EPI créatinine 2021',
        'CKD-EPI cystatine C 2012',
        "N'importe laquelle, elles sont interchangeables",
      ],
      correctIndex: 0,
      explanation:
          "Les équations CKD-EPI sont validées chez l'adulte (≥ 18 ans). Chez l'enfant, Schwartz "
          "bedside est l'équation adaptée — ne jamais appliquer automatiquement CKD-EPI à l'enfant.",
    ),
    const QuizQuestion(
      id: 'renal_5',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient a une masse musculaire atypique (amputation, cachexie sévère) qui rend '
          'la créatinine peu fiable pour estimer le DFG. Quel second marqueur envisager ?',
      options: [
        'La cystatine C',
        "L'urée seule",
        'Le calcium corrigé',
        'La bilirubine indirecte',
      ],
      correctIndex: 0,
      explanation:
          "La cystatine C est moins dépendante de la masse musculaire que la créatinine. L'équation "
          'combinée créatinine-cystatine C 2021 permet de comparer les trois résultats côte à côte, '
          'sans mélanger les versions.',
    ),
    const QuizQuestion(
      id: 'renal_6',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient sous diurétiques de l\'anse présente une insuffisance rénale aiguë. La '
          'fraction excrétée du sodium (FeNa) est-elle interprétable de façon fiable ?',
      options: [
        'Non — les diurétiques de l\'anse invalident le FeNa ; la FeUrée est préférable',
        'Oui, sans réserve',
        'Seulement si le patient est aussi diabétique',
        'Le FeNa remplace alors la créatininémie',
      ],
      correctIndex: 0,
      explanation:
          'Le FeNa est non interprétable sous diurétiques de l\'anse récents. La fraction excrétée de '
          "l'urée (FeUrée) est moins sensible à cet effet, bien que sensible aux thiazidiques et à "
          "l'apport protéique.",
    ),
    const QuizQuestion(
      id: 'renal_7',
      type: QuizQuestionType.vocabulary,
      prompt: 'Que signifie IDMS, condition analytique requise pour CKD-EPI et Schwartz ?',
      options: [
        'Isotope Dilution Mass Spectrometry (méthode de référence de standardisation)',
        'International Diabetes Monitoring Standard',
        'Indice de Distribution du Métabolisme Sérique',
        'Institut de Dosage et de Mesure Sanguine',
      ],
      correctIndex: 0,
      explanation:
          "L'IDMS (spectrométrie de masse par dilution isotopique) est la méthode de référence à "
          "laquelle doit être calibré le dosage de la créatinine pour que les équations CKD-EPI/"
          'Schwartz restent valides.',
    ),
    const QuizQuestion(
      id: 'renal_8',
      type: QuizQuestionType.vocabulary,
      prompt: 'Dans « rapport ACR urinaire », que signifie ACR ?',
      options: [
        'Albumin-to-Creatinine Ratio (rapport albumine/créatinine)',
        'Acute Creatinine Response',
        'Analyse de Clairance Rénale',
        'Albumin Clearance Rate',
      ],
      correctIndex: 0,
      explanation:
          'ACR = Albumin-to-Creatinine Ratio, exprimé en mg/g ou mg/mmol selon la convention retenue '
          'par le laboratoire.',
    ),
    const QuizQuestion(
      id: 'renal_9',
      type: QuizQuestionType.clinicalCase,
      prompt: "Une adolescente de 15 ans est explorée pour une protéinurie découverte à "
          "l'école. Le biologiste hésite entre CKD-EPI créatinine 2021 et Schwartz "
          'bedside pour estimer le DFG. Que doit-il faire ?',
      options: [
        "Utiliser Schwartz bedside, car CKD-EPI créatinine 2021 est réservée à l'adulte (≥ 18 ans)",
        "Utiliser CKD-EPI créatinine 2021, car l'adolescente pèse un poids d'adulte",
        'Calculer les deux équations et moyenner les résultats',
        "Utiliser CKD-EPI cystatine C 2012, qui n'a pas de restriction d'âge",
      ],
      correctIndex: 0,
      explanation:
          "CKD-EPI créatinine 2021 (comme la version cystatine C 2012 et la version combinée) "
          "est validée uniquement chez l'adulte ≥ 18 ans (condition interdite : âge < 18 ans). "
          "Chez l'adolescente de 15 ans, Schwartz bedside reste l'équation adaptée (population "
          'applicable : 1 à 18 ans).',
    ),
    const QuizQuestion(
      id: 'renal_10',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un biologiste reçoit une créatininémie pour un calcul de DFG par CKD-EPI '
          'créatinine 2021, mais ne peut pas confirmer que la méthode de dosage utilisée '
          'est standardisée IDMS. Que doit-il faire ?',
      options: [
        "Ne pas calculer le DFG tant que la standardisation IDMS n'est pas confirmée",
        'Calculer quand même, en signalant simplement le résultat comme approximatif',
        'Appliquer un facteur de correction de 10 % au résultat',
        "Utiliser Schwartz bedside à la place, qui ne nécessite pas de standardisation IDMS",
      ],
      correctIndex: 0,
      explanation:
          'La condition analytique de CKD-EPI créatinine 2021 exige une créatinine sérique '
          "standardisée IDMS ; sans confirmation, le calcul ne doit pas être effectué. "
          "Schwartz bedside a la même exigence (créatinine standardisée IDMS, méthode "
          'enzymatique), donc cette option est également invalide.',
    ),
    const QuizQuestion(
      id: 'renal_11',
      type: QuizQuestionType.clinicalCase,
      prompt: "Une femme enceinte de 28 semaines d'aménorrhée a une créatininémie prescrite "
          'pour surveiller sa fonction rénale. Le DFG peut-il être estimé par CKD-EPI '
          'créatinine 2021 ?',
      options: [
        "Non — la grossesse fait partie des situations où l'équation n'est pas valide",
        'Oui, sans restriction particulière',
        'Oui, à condition d\'ajouter un coefficient correcteur pour la grossesse',
        'Non, mais uniquement au-delà de 30 semaines d\'aménorrhée',
      ],
      correctIndex: 0,
      explanation:
          'Les limitations de CKD-EPI créatinine 2021 précisent que l\'équation n\'est pas '
          "valide en cas de grossesse (au même titre que l'insuffisance rénale aiguë, la masse "
          "musculaire extrême, le régime végétarien strict ou la complémentation en créatine).",
    ),
    const QuizQuestion(
      id: 'renal_12',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient grabataire présente une amyotrophie sévère avec une masse '
          'musculaire très réduite. Le DFG calculé par CKD-EPI créatinine 2021 à partir de '
          'sa créatininémie est-il fiable ?',
      options: [
        'Non — la masse musculaire extrême fait partie des limitations documentées de '
            "l'équation",
        "Oui, l'équation corrige automatiquement le résultat pour la masse musculaire",
        'Oui, à condition de multiplier le résultat par 1,2',
        'Non, uniquement si le patient est également diabétique',
      ],
      correctIndex: 0,
      explanation:
          'Les limitations de CKD-EPI créatinine 2021 (et de la version combinée '
          "créatinine-cystatine C) précisent que l'équation n'est pas valide en cas de masse "
          'musculaire extrême.',
    ),
    const QuizQuestion(
      id: 'renal_13',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient culturiste amateur consomme une complémentation en créatine depuis '
          'plusieurs mois et souhaite un bilan rénal. Que faut-il savoir avant d\'interpréter '
          'le DFG CKD-EPI créatinine 2021 ?',
      options: [
        "La complémentation en créatine fait partie des situations où l'équation n'est pas "
            'valide',
        "La créatine n'a aucun effet documenté sur la créatininémie ni sur le DFG estimé",
        'Il faut doubler le DFG calculé pour compenser',
        'Il faut utiliser Schwartz bedside chez tout sportif, quel que soit son âge',
      ],
      correctIndex: 0,
      explanation:
          'La complémentation en créatine figure explicitement parmi les limitations de '
          'CKD-EPI créatinine 2021 : elle peut élever la créatininémie indépendamment du DFG '
          "réel, rendant l'équation non valide dans ce contexte.",
    ),
    const QuizQuestion(
      id: 'renal_14',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Une patiente suit un régime végétalien strict depuis plusieurs années. Le '
          'laboratoire doit-il tenir compte de ce régime avant de rendre un DFG CKD-EPI '
          'créatinine 2021 ?',
      options: [
        'Oui — le régime végétarien strict fait partie des limitations documentées de '
            "l'équation",
        "Non, le régime alimentaire n'a aucune influence documentée",
        'Non, sauf en cas de régime hyperprotéiné',
        "Oui, mais uniquement chez l'enfant",
      ],
      correctIndex: 0,
      explanation:
          'Les limitations de CKD-EPI créatinine 2021 mentionnent explicitement le régime '
          "végétarien strict comme situation où l'équation n'est pas valide.",
    ),
    const QuizQuestion(
      id: 'renal_15',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient hospitalisé présente une créatininémie en ascension rapide sur 48 '
          'heures, évoquant une insuffisance rénale aiguë. Peut-on appliquer CKD-EPI '
          'créatinine 2021 pour estimer son DFG ?',
      options: [
        "Non — l'insuffisance rénale aiguë fait partie des limitations documentées de "
            "l'équation",
        "Oui, l'équation est conçue spécifiquement pour l'insuffisance rénale aiguë",
        'Oui, à condition de répéter le dosage deux fois par jour',
        'Non, sauf si le patient est en réanimation',
      ],
      correctIndex: 0,
      explanation:
          "CKD-EPI créatinine 2021 n'est pas valide en cas d'insuffisance rénale aiguë : dans "
          "ce contexte, la créatininémie n'est pas à l'équilibre et ne reflète pas fidèlement "
          'le DFG au moment du prélèvement.',
    ),
    const QuizQuestion(
      id: 'renal_16',
      type: QuizQuestionType.clinicalCase,
      prompt: "Un néphrologue souhaite un DFG précis avant d'ajuster la posologie d'un "
          'médicament à marge thérapeutique étroite, chez un patient dont la situation '
          "clinique est jugée atypique. L'estimation par CKD-EPI créatinine 2021 suffit-elle "
          'toujours ?',
      options: [
        'Non — l\'équation ne remplace pas une mesure de clairance lorsque celle-ci est '
            'cliniquement indiquée',
        "Oui, l'estimation par équation est toujours suffisante quel que soit le contexte",
        'Oui, car l\'équation a une précision supérieure à toute mesure de clairance',
        'Non, il faut alors utiliser exclusivement la formule de Cockcroft-Gault',
      ],
      correctIndex: 0,
      explanation:
          'Une limitation documentée de CKD-EPI créatinine 2021 rappelle qu\'elle ne remplace '
          'pas une mesure de clairance lorsque celle-ci est cliniquement indiquée.',
    ),
    const QuizQuestion(
      id: 'renal_17',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient est actuellement sous corticothérapie au long cours pour une '
          'polyarthrite. Son DFG est estimé par CKD-EPI cystatine C 2012. Quelle limite '
          'faut-il garder à l\'esprit ?',
      options: [
        'La cystatine C peut être modifiée par la corticothérapie, indépendamment du DFG réel',
        "La corticothérapie n'a aucune influence documentée sur la cystatine C",
        "La corticothérapie invalide uniquement les équations à base de créatinine",
        'La corticothérapie impose de diviser par deux le résultat de cystatine C',
      ],
      correctIndex: 0,
      explanation:
          'Les limitations de CKD-EPI cystatine C 2012 précisent que la cystatine C peut être '
          'modifiée par l\'inflammation, la corticothérapie, les dysthyroïdies et l\'obésité, '
          'indépendamment du DFG.',
    ),
    const QuizQuestion(
      id: 'renal_18',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un enfant de 10 ans nécessite une estimation du DFG. Le laboratoire dispose '
          "d'un dosage de cystatine C mais pas de créatininémie récente. CKD-EPI cystatine C "
          '2012 peut-elle être appliquée ?',
      options: [
        'Non — cette équation est réservée à l\'adulte et les équations pédiatriques de '
            'cystatine C ne sont pas implémentées dans ce calculateur',
        "Oui, la cystatine C n'a pas de restriction d'âge",
        'Oui, à condition de multiplier le résultat par la surface corporelle',
        'Non, il faut alors doubler la constante utilisée pour les adultes',
      ],
      correctIndex: 0,
      explanation:
          'CKD-EPI cystatine C 2012 s\'applique à l\'adulte ≥ 18 ans (âge < 18 ans = condition '
          'interdite) ; les équations pédiatriques de cystatine C ne sont pas implémentées '
          'dans ce calculateur.',
    ),
    const QuizQuestion(
      id: 'renal_19',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Le laboratoire calcule un DFG par l\'équation combinée CKD-EPI '
          'créatinine-cystatine C 2021. Quelles conditions analytiques doivent être réunies '
          'avant de rendre ce résultat ?',
      options: [
        'Créatinine standardisée IDMS ET cystatine C standardisée sur le matériau de '
            'référence IRMM/ERM-DA471/IFCC',
        "Seule la créatinine doit être standardisée IDMS, la cystatine C n'a pas d'exigence",
        "Seule la cystatine C doit être standardisée, la créatinine n'a pas d'exigence",
        "Aucune condition analytique particulière n'est requise pour l'équation combinée",
      ],
      correctIndex: 0,
      explanation:
          "L'équation combinée nécessite les deux conditions analytiques documentées : "
          'créatinine sérique standardisée IDMS et dosage de cystatine C standardisé '
          '(matériau de référence IRMM/ERM-DA471/IFCC).',
    ),
    const QuizQuestion(
      id: 'renal_20',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un adolescent de 16 ans a bénéficié d\'un dosage simultané de créatininémie '
          'et de cystatine C. Peut-on calculer l\'équation combinée CKD-EPI '
          'créatinine-cystatine C 2021 ?',
      options: [
        "Non — cette équation, comme les autres CKD-EPI, est réservée à l'adulte ≥ 18 ans",
        "Oui, l'équation combinée n'a pas de restriction d'âge contrairement aux équations "
            'simples',
        'Oui, à condition d\'utiliser la constante pédiatrique k=0,413',
        "Non, uniquement parce que la cystatine C n'est pas dosable chez l'adolescent",
      ],
      correctIndex: 0,
      explanation:
          "L'équation combinée CKD-EPI créatinine-cystatine C 2021 a pour population "
          'applicable l\'adulte ≥ 18 ans (âge < 18 ans = condition interdite), au même titre '
          'que les équations créatinine seule et cystatine C seule.',
    ),
    const QuizQuestion(
      id: 'renal_21',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un biologiste calcule l\'équation combinée CKD-EPI créatinine-cystatine C '
          '2021 sans avoir vérifié que la créatininémie est standardisée IDMS. Est-ce '
          'conforme ?',
      options: [
        'Non — la confirmation de la standardisation IDMS est requise avant le calcul, comme '
            'pour l\'équation créatinine seule',
        "Oui, car seule la cystatine C nécessite une standardisation dans l'équation combinée",
        "Oui, la standardisation IDMS n'est nécessaire qu'au-delà de 65 ans",
        'Non, mais uniquement si le patient est une femme',
      ],
      correctIndex: 0,
      explanation:
          "L'équation combinée reprend la même exigence que CKD-EPI créatinine 2021 : la "
          'standardisation IDMS de la créatininémie doit être confirmée avant le calcul du '
          'DFG.',
    ),
    const QuizQuestion(
      id: 'renal_22',
      type: QuizQuestionType.clinicalCase,
      prompt: "Un patient de 27 ans, suivi depuis l'enfance pour une maladie rénale "
          'génétique, se présente pour un bilan. Quelle équation d\'estimation du DFG est '
          'adaptée ?',
      options: [
        'CKD-EPI créatinine 2021, car il a dépassé la limite haute d\'application de '
            'Schwartz bedside (25 ans)',
        "Schwartz bedside, car il a été suivi depuis l'enfance",
        'Aucune des deux : il faut attendre 30 ans',
        'Schwartz bedside, avec la constante k=0,55',
      ],
      correctIndex: 0,
      explanation:
          'Schwartz bedside est limitée à 1-25 ans (condition interdite : âge < 1 an ou > 25 '
          "ans) ; au-delà, il faut utiliser l'équation CKD-EPI adulte, comme le rappelle sa "
          'documentation.',
    ),
    const QuizQuestion(
      id: 'renal_23',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un nourrisson de 8 mois est exploré pour une suspicion de malformation '
          'rénale. Le biologiste peut-il appliquer Schwartz bedside pour estimer le DFG ?',
      options: [
        "Non — la formule ne s'applique qu'à partir de 1 an",
        "Oui, sans restriction d'âge minimale",
        'Oui, à condition d\'exprimer la taille en mètres et non en centimètres',
        'Non, uniquement si le nourrisson pèse moins de 5 kg',
      ],
      correctIndex: 0,
      explanation:
          'La condition interdite documentée pour Schwartz bedside est un âge < 1 an ou > 25 '
          "ans ; chez un nourrisson de 8 mois, la formule est hors de sa population "
          'applicable.',
    ),
    const QuizQuestion(
      id: 'renal_24',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un jeune homme de 19 ans, suivi en pédiatrie depuis toujours pour une '
          'néphropathie, a un DFG estimé par Schwartz bedside. Le calcul aboutit-il sans '
          'réserve ?',
      options: [
        'Non — un avertissement rappelle qu\'entre 18 et 25 ans, l\'équation CKD-EPI adulte '
            'doit être envisagée selon le contexte clinique',
        'Oui, aucune réserve ne s\'applique entre 18 et 25 ans',
        'Non, le calcul est impossible avant 25 ans révolus',
        'Oui, mais uniquement si le patient est une femme',
      ],
      correctIndex: 0,
      explanation:
          'Schwartz bedside reste calculable de 1 à 25 ans, mais un avertissement signale la '
          'zone de transition 18-25 ans : selon le contexte clinique, l\'équation CKD-EPI '
          'adulte peut être envisagée en complément.',
    ),
    const QuizQuestion(
      id: 'renal_25',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un laboratoire pédiatrique dose la créatinine par méthode de Jaffé non '
          'standardisée IDMS. La constante k=0,413 de Schwartz bedside reste-t-elle '
          'valable ?',
      options: [
        'Non — cette constante n\'est valable que pour une créatinine standardisée IDMS '
            'dosée par méthode enzymatique',
        'Oui, la constante est indépendante de la méthode de dosage',
        'Oui, à condition de multiplier le résultat par 2',
        "Non, il faut alors utiliser CKD-EPI créatinine 2021 chez l'enfant",
      ],
      correctIndex: 0,
      explanation:
          'La condition analytique documentée précise que k=0,413 est valable pour une '
          'créatinine standardisée IDMS dosée par méthode enzymatique. CKD-EPI reste réservée '
          'à l\'adulte, ce qui exclut la dernière option.',
    ),
    const QuizQuestion(
      id: 'renal_26',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un interne retrouve, dans un ancien dossier, un DFG pédiatrique calculé avec '
          'une constante k=0,55. Que doit-il en conclure ?',
      options: [
        "Il s'agit probablement de l'ancienne constante de Schwartz, valable pour une "
            'créatinine dosée par méthode de Jaffé non standardisée IDMS, à ne pas confondre '
            'avec la version bedside actuelle (k=0,413)',
        "Il s'agit d'une erreur de saisie : aucune constante k=0,55 n'a jamais existé",
        "C'est la constante utilisée chez l'adulte par CKD-EPI",
        'C\'est la constante actuelle recommandée depuis 2009',
      ],
      correctIndex: 0,
      explanation:
          'La documentation de Schwartz bedside précise que la constante historique k=0,55 '
          'correspondait à un dosage de créatinine non standardisé IDMS — à distinguer de la '
          'constante bedside actuelle k=0,413 (Schwartz et al., 2009).',
    ),
    const QuizQuestion(
      id: 'renal_27',
      type: QuizQuestionType.clinicalCase,
      prompt: 'En réanimation, un patient recevant une perfusion continue de furosémide '
          'développe une insuffisance rénale aiguë. Le FeNa calculé à partir d\'un '
          'ionogramme urinaire est-il interprétable ?',
      options: [
        "Non — les diurétiques de l'anse invalident le FeNa ; la FeUrée est préférable dans "
            'ce contexte',
        "Oui, le furosémide n'affecte pas le FeNa",
        'Oui, à condition d\'arrêter le furosémide 2 heures avant le prélèvement',
        "Non, aucun marqueur urinaire n'est alors utilisable",
      ],
      correctIndex: 0,
      explanation:
          "La limitation documentée du FeNa précise qu'il n'est pas interprétable sous "
          "diurétiques, en particulier les diurétiques de l'anse récents comme le "
          'furosémide ; la fraction excrétée de l\'urée (FeUrée) est alors préférable.',
    ),
    const QuizQuestion(
      id: 'renal_28',
      type: QuizQuestionType.clinicalCase,
      prompt: "Un patient suivi de longue date pour une insuffisance rénale chronique "
          'stable présente une créatininémie stable depuis des mois. Le calcul d\'un FeNa '
          'est-il pertinent dans ce contexte ?',
      options: [
        'Non — le FeNa est documenté pour l\'adulte en contexte d\'insuffisance rénale '
            'AIGUË, pas pour une IRC stable',
        'Oui, le FeNa est validé dans tous les contextes d\'insuffisance rénale',
        'Oui, à condition de le répéter chaque semaine',
        "Non, le FeNa n'est validé que chez l'enfant",
      ],
      correctIndex: 0,
      explanation:
          'La population applicable documentée pour le FeNa est « Adulte, insuffisance '
          'rénale aiguë » — son usage hors de ce contexte, notamment dans une IRC stable, '
          "n'est pas celui pour lequel l'outil est décrit.",
    ),
    const QuizQuestion(
      id: 'renal_29',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient hospitalisé a un apport protéique très irrégulier (alternance de '
          'jeûne et de renutrition). Quelle limite faut-il garder à l\'esprit en '
          'interprétant sa FeUrée ?',
      options: [
        'La FeUrée peut être altérée par un apport protéique très variable',
        "L'apport protéique n'a aucune influence documentée sur la FeUrée",
        'La FeUrée nécessite un apport protéique fixe supérieur à 2 g/kg/j pour être '
            'calculée',
        'La FeUrée remplace alors le dosage de l\'urée plasmatique',
      ],
      correctIndex: 0,
      explanation:
          'La limitation documentée de la FeUrée indique qu\'elle peut être altérée par un '
          'apport protéique très variable, en plus des diurétiques thiazidiques — elle reste '
          "toutefois moins sensible que le FeNa aux diurétiques de l'anse.",
    ),
    const QuizQuestion(
      id: 'renal_30',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient hypertendu sous diurétique thiazidique développe une insuffisance '
          'rénale aiguë. La FeUrée calculée est-elle à interpréter avec prudence ?',
      options: [
        'Oui — les diurétiques thiazidiques peuvent altérer la FeUrée',
        "Non, seuls les diurétiques de l'anse affectent la FeUrée",
        'Non, la FeUrée est totalement indépendante de tout traitement diurétique',
        'Oui, mais uniquement si le patient est aussi sous IEC',
      ],
      correctIndex: 0,
      explanation:
          "La documentation de la FeUrée précise qu'elle peut être altérée par les "
          "diurétiques thiazidiques (et par un apport protéique très variable), tout en "
          "restant moins sensible que le FeNa aux diurétiques de l'anse.",
    ),
    const QuizQuestion(
      id: 'renal_31',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un technicien saisit les concentrations de sodium urinaire et plasmatique '
          'pour un calcul de FeNa. Doit-il convertir les unités avant saisie ?',
      options: [
        'Non — le sodium est saisi en mmol/L, en valeurs brutes, sans conversion d\'unité',
        'Oui, il faut convertir le sodium en g/L au préalable',
        'Oui, il faut convertir le sodium en mg/dL comme pour la créatinine',
        'Non, mais il faut diviser la valeur par 1000 avant saisie',
      ],
      correctIndex: 0,
      explanation:
          'L\'aide documentée du FeNa précise : « Sodium en mmol/L (valeurs brutes, sans '
          'conversion d\'unité) ».',
    ),
    const QuizQuestion(
      id: 'renal_32',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un dossier médical rapporte une « urée sanguine » en mg/dL sous l\'appellation '
          'BUN (blood urea nitrogen). Peut-on saisir directement cette valeur dans le calcul '
          'de FeUrée sans vérification ?',
      options: [
        "Non — la FeUrée doit être calculée avec l'urée en mmol/L, et non avec l'azote "
            'uréique (BUN)',
        'Oui, BUN et urée en mmol/L sont rigoureusement la même grandeur',
        'Oui, à condition de multiplier le BUN par 100',
        "Non, la FeUrée n'accepte que des valeurs en g/L",
      ],
      correctIndex: 0,
      explanation:
          'L\'aide documentée de la FeUrée précise : « Urée en mmol/L (et non azote uréique '
          '/ BUN) » — une confusion entre ces deux grandeurs fausserait le calcul.',
    ),
    const QuizQuestion(
      id: 'renal_33',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Une patiente très polydipsique présente une diurèse très variable d\'un jour '
          'à l\'autre. Le rapport albumine/créatinine (ACR) sur échantillon est-il aussi '
          'précis qu\'une protéinurie des 24 heures dans ce contexte ?',
      options: [
        'Non — l\'ACR (comme le PCR) est moins précis que la protéinurie des 24 h en cas de '
            'variation importante du débit urinaire',
        "Oui, l'ACR est toujours plus précis que la protéinurie des 24 h",
        "Oui, car l'ACR corrige automatiquement les variations de diurèse",
        'Non, mais uniquement si la patiente est diabétique',
      ],
      correctIndex: 0,
      explanation:
          "La limitation documentée de l'ACR (et du PCR) urinaire précise qu'ils sont moins "
          "précis que la protéinurie des 24 h en cas de variation importante du débit "
          'urinaire (nycthéméral, hydratation).',
    ),
    const QuizQuestion(
      id: 'renal_34',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Chez un patient au stade avancé d\'insuffisance rénale chronique, une '
          'clairance de la créatinine mesurée sur urines de 24 h est réalisée. Le résultat '
          'obtenu risque-t-il de biaiser l\'estimation du DFG réel ?',
      options: [
        'Oui — la sécrétion tubulaire de créatinine entraîne une surestimation du DFG réel, '
            "en particulier aux stades avancés d'IRC",
        'Non, la clairance mesurée est toujours exacte quel que soit le stade',
        'Oui, mais elle sous-estime systématiquement le DFG réel',
        'Non, ce biais ne concerne que les urines minutées de moins de 24 h',
      ],
      correctIndex: 0,
      explanation:
          'La limitation documentée de la clairance de la créatinine mesurée précise qu\'elle '
          "surestime le DFG réel du fait de la sécrétion tubulaire de créatinine, notamment "
          "aux stades avancés d'insuffisance rénale chronique.",
    ),
    const QuizQuestion(
      id: 'renal_35',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient de très petite taille et un patient de forte corpulence ont '
          'chacun une clairance de la créatinine mesurée sur recueil urinaire minuté. '
          'Peut-on comparer directement leurs résultats bruts ?',
      options: [
        'Avec prudence — la clairance mesurée ne corrige pas pour la surface corporelle, '
            'contrairement aux DFG estimés en mL/min/1,73 m²',
        'Oui, sans aucune réserve : les deux résultats sont directement comparables',
        'Non, il est impossible de mesurer une clairance chez un patient de petite taille',
        'Oui, car la formule intègre automatiquement le poids du patient',
      ],
      correctIndex: 0,
      explanation:
          'La limitation documentée de la clairance de la créatinine mesurée indique qu\'elle '
          'ne corrige pas pour la surface corporelle, à la différence des équations '
          "d'estimation du DFG rapportées en mL/min/1,73 m².",
    ),
    const QuizQuestion(
      id: 'renal_36',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient rapporte un recueil urinaire de 18 heures au lieu des 24 heures '
          'prescrites. Le laboratoire rend-il directement la valeur mesurée comme une '
          '« protéinurie des 24 heures » ?',
      options: [
        'Non — un avertissement signale de ne pas confondre la valeur mesurée sur la période '
            'réelle avec l\'extrapolation à 24 h',
        "Oui, la durée de recueil n'a aucune incidence sur l'interprétation",
        'Oui, toute collecte est automatiquement considérée comme une protéinurie des 24 h',
        'Non, le résultat est alors ininterprétable et ne doit pas être rendu',
      ],
      correctIndex: 0,
      explanation:
          'Pour une collecte inférieure à 24 h, un résultat extrapolé à 24 h est calculé, '
          'mais un avertissement précise de ne pas confondre la valeur mesurée sur la '
          'période réelle de collecte avec cette extrapolation.',
    ),
    const QuizQuestion(
      id: 'renal_37',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un service de soins rapporte un recueil urinaire de 30 heures pour une '
          'protéinurie. Comment le résultat est-il rendu ?',
      options: [
        'Rapporté sur la durée réelle de collecte (30 h), sans extrapolation à 24 h',
        'Toujours extrapolé à 24 h, quelle que soit la durée réelle',
        'Refusé automatiquement car supérieur à 24 h',
        'Divisé arbitrairement en deux périodes de 15 h',
      ],
      correctIndex: 0,
      explanation:
          'Pour une durée de recueil supérieure à 24 h, un avertissement documenté précise '
          'que le résultat est rapporté sur la durée réelle de collecte, non extrapolé.',
    ),
    const QuizQuestion(
      id: 'renal_38',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient ambulatoire réalise seul son recueil urinaire des 24 heures à '
          'domicile. Quelle limite méthodologique s\'applique à l\'interprétation du '
          'résultat final ?',
      options: [
        'La précision dépend de l\'exactitude de la durée réelle et du volume total '
            'réellement collectés, tels que déclarés par le patient',
        "Aucune limite : le résultat est indépendant de la fiabilité du recueil déclaré",
        'Le résultat est automatiquement corrigé si le patient se trompe de durée',
        'La limite ne s\'applique qu\'aux recueils réalisés en établissement de soins',
      ],
      correctIndex: 0,
      explanation:
          'La limitation documentée de la protéinurie des 24 h rappelle que la précision du '
          'résultat dépend de l\'exactitude du recueil (durée réelle, volume total réellement '
          'collecté) déclaré par le patient ou le service de soins.',
    ),
    const QuizQuestion(
      id: 'renal_39',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient en anasarque, avec une masse musculaire cliniquement jugée très '
          'réduite, doit bénéficier d\'une estimation du DFG. La créatininémie seule '
          'est-elle suffisamment fiable pour CKD-EPI créatinine 2021 ?',
      options: [
        'Non — la masse musculaire extrême invalide l\'équation ; la cystatine C est un '
            'second marqueur moins dépendant de la masse musculaire',
        "Oui, l'œdème n'a aucune influence sur l'interprétation de la créatininémie",
        'Oui, à condition de corriger le poids par le poids sec théorique',
        "Non, aucun autre marqueur n'est alors disponible dans ce calculateur",
      ],
      correctIndex: 0,
      explanation:
          "CKD-EPI créatinine 2021 n'est pas valide en cas de masse musculaire extrême. La "
          'cystatine C, moins dépendante de la masse musculaire, est le second marqueur à '
          "envisager, l'équation combinée créatinine-cystatine C 2021 permettant de comparer "
          'les résultats côte à côte.',
    ),
    const QuizQuestion(
      id: 'renal_40',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un interne propose de remplacer le dosage de la créatininémie par un calcul '
          'de FeNa pour suivre la fonction rénale d\'un patient en réanimation. Cette '
          'proposition est-elle fondée ?',
      options: [
        'Non — le FeNa se calcule lui-même à partir de la créatininémie et de la '
            'créatininurie ; il ne peut pas s\'y substituer',
        'Oui, le FeNa est un substitut validé de la créatininémie',
        'Oui, à condition de le calculer deux fois par jour',
        'Non, uniquement parce que le FeNa est plus coûteux à réaliser',
      ],
      correctIndex: 0,
      explanation:
          'Le FeNa se calcule à partir de la créatininémie (et de la créatininurie) ; il ne '
          'peut donc pas s\'y substituer. C\'est un outil d\'orientation diagnostique en '
          'insuffisance rénale aiguë chez l\'adulte, pas un remplacement du dosage '
          'plasmatique.',
    ),
    const QuizQuestion(
      id: 'renal_41',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient de 17 ans et 11 mois, presque majeur, est adressé pour un bilan '
          'rénal. Le biologiste peut-il déjà appliquer CKD-EPI créatinine 2021 puisque '
          "l'âge adulte est presque atteint ?",
      options: [
        'Non — la condition documentée est stricte : âge < 18 ans exclut l\'équation, quelle '
            'que soit la proximité de la majorité',
        "Oui, un écart de moins d'un mois est négligeable",
        "Oui, à condition d'arrondir l'âge à 18 ans",
        "Non, il faut alors attendre l'âge de 21 ans",
      ],
      correctIndex: 0,
      explanation:
          'La condition interdite documentée pour les équations CKD-EPI est un âge < 18 ans, '
          "sans tolérance ni arrondi mentionné ; Schwartz bedside reste l'équation adaptée "
          "tant que l'âge adulte n'est pas atteint.",
    ),
    const QuizQuestion(
      id: 'renal_42',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient végétalien strict bénéficie d\'un dosage simultané de '
          'créatininémie et de cystatine C. L\'équation combinée CKD-EPI '
          'créatinine-cystatine C 2021 échappe-t-elle à la limitation liée au régime '
          'alimentaire ?',
      options: [
        'Non — l\'équation combinée partage les mêmes limitations que la version créatinine '
            'seule, dont le régime végétarien strict',
        "Oui, la composante cystatine C annule l'effet du régime alimentaire sur la "
            'créatinine',
        "Oui, car l'équation combinée n'utilise pas la créatininémie",
        'Non, mais uniquement si le patient est un homme',
      ],
      correctIndex: 0,
      explanation:
          'Les limitations documentées de l\'équation combinée CKD-EPI créatinine-cystatine C '
          '2021 sont identiques à celles de la version créatinine seule : non valide '
          "notamment en cas de régime végétarien strict, de masse musculaire extrême, de "
          "grossesse, d'insuffisance rénale aiguë ou de complémentation en créatine.",
    ),
    const QuizQuestion(
      id: 'renal_43',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient suivi pour une hypothyroïdie traitée bénéficie d\'une estimation '
          'du DFG par CKD-EPI cystatine C 2012. Quelle limite documentée s\'applique ?',
      options: [
        'Les dysthyroïdies peuvent modifier la cystatine C indépendamment du DFG réel',
        "L'hypothyroïdie invalide uniquement les équations à base de créatinine",
        'Aucune limite documentée ne concerne la fonction thyroïdienne',
        'L\'hypothyroïdie impose de diviser le résultat de cystatine C par deux',
      ],
      correctIndex: 0,
      explanation:
          'Les limitations de CKD-EPI cystatine C 2012 précisent que la cystatine C peut être '
          'modifiée par l\'inflammation, la corticothérapie, les dysthyroïdies et l\'obésité, '
          'indépendamment du DFG réel.',
    ),
    const QuizQuestion(
      id: 'renal_44',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient présentant une obésité sévère (IMC > 40) fait doser sa cystatine '
          'C pour une estimation du DFG par CKD-EPI cystatine C 2012. L\'obésité peut-elle '
          'influencer ce résultat indépendamment du DFG ?',
      options: [
        'Oui — l\'obésité fait partie des situations documentées pouvant modifier la '
            'cystatine C indépendamment du DFG',
        'Non, la cystatine C est totalement indépendante de la corpulence',
        'Oui, mais uniquement chez la femme',
        "Non, seule la créatininémie est affectée par l'obésité",
      ],
      correctIndex: 0,
      explanation:
          'La documentation de CKD-EPI cystatine C 2012 indique que la cystatine C peut être '
          'modifiée par l\'inflammation, la corticothérapie, les dysthyroïdies et l\'obésité, '
          'indépendamment du DFG.',
    ),
    const QuizQuestion(
      id: 'renal_45',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient présente un syndrome inflammatoire aigu marqué (CRP élevée) lors '
          'du dosage de cystatine C utilisé pour CKD-EPI cystatine C 2012. Faut-il '
          'interpréter le DFG obtenu avec prudence ?',
      options: [
        'Oui — l\'inflammation peut modifier la cystatine C indépendamment du DFG réel',
        "Non, l'inflammation n'a aucun effet documenté sur la cystatine C",
        'Oui, mais seulement si la CRP dépasse 300 mg/L',
        "Non, l'inflammation affecte uniquement la créatininémie",
      ],
      correctIndex: 0,
      explanation:
          'Les limitations documentées de CKD-EPI cystatine C 2012 indiquent que '
          "l'inflammation, la corticothérapie, les dysthyroïdies et l'obésité peuvent "
          'modifier la cystatine C indépendamment du DFG réel.',
    ),
    const QuizQuestion(
      id: 'renal_46',
      type: QuizQuestionType.scientificSource,
      prompt: 'L\'équation CKD-EPI cystatine C 2012 (utilisée seule, sans créatinine) a été '
          'publiée par :',
      options: [
        'Inker LA et al., N Engl J Med 2012;367(1):20-29',
        'Inker LA et al., N Engl J Med 2021;385(19):1737-1749',
        'Schwartz GJ et al., J Am Soc Nephrol 2009',
        'Espinel CH, JAMA 1976',
      ],
      correctIndex: 0,
      explanation:
          'Inker LA, Schmid CH, Tighiouart H, et al. Estimating Glomerular Filtration Rate '
          'from Serum Creatinine and Cystatin C. N Engl J Med. 2012;367(1):20-29 — à ne pas '
          'confondre avec la publication de 2021 qui a introduit les équations sans '
          'coefficient racial.',
    ),
    const QuizQuestion(
      id: 'renal_47',
      type: QuizQuestionType.scientificSource,
      prompt: 'Le test de la fraction excrétée du sodium (FeNa) comme outil de diagnostic '
          'différentiel de l\'insuffisance rénale aiguë a été décrit par :',
      options: [
        'Espinel CH, JAMA 1976;236(6):579-581',
        'Carvounis CP et al., Kidney Int 2002',
        'Inker LA et al., N Engl J Med 2021',
        'KDIGO CKD Work Group, 2012',
      ],
      correctIndex: 0,
      explanation:
          'Espinel CH. The FENa Test. Use in the Differential Diagnosis of Acute Renal '
          'Failure. JAMA. 1976;236(6):579-581.',
    ),
    const QuizQuestion(
      id: 'renal_48',
      type: QuizQuestionType.scientificSource,
      prompt: 'La fraction excrétée de l\'urée (FeUrée), utile notamment sous diurétiques de '
          'l\'anse, a été décrite par :',
      options: [
        'Carvounis CP, Nisar S, Guro-Razuman S., Kidney Int 2002;62(6):2223-2229',
        'Espinel CH, JAMA 1976',
        'Schwartz GJ et al., J Am Soc Nephrol 2009',
        'Inker LA et al., N Engl J Med 2012',
      ],
      correctIndex: 0,
      explanation:
          'Carvounis CP, Nisar S, Guro-Razuman S. Significance of the Fractional Excretion '
          'of Urea in the Differential Diagnosis of Acute Renal Failure. Kidney Int. '
          '2002;62(6):2223-2229.',
    ),
    const QuizQuestion(
      id: 'renal_49',
      type: QuizQuestionType.scientificSource,
      prompt: 'La formule classique de bilan de masse utilisée pour la clairance de la '
          'créatinine mesurée sur urines minutées ou 24 h s\'appuie sur les recommandations '
          'de :',
      options: [
        'National Kidney Foundation — KDOQI Clinical Practice Guidelines',
        'KDIGO CKD Work Group, 2012',
        'Inker LA et al., N Engl J Med 2021',
        'OMS, système INR/ISI',
      ],
      correctIndex: 0,
      explanation:
          'La source documentée de la clairance de la créatinine mesurée est : National '
          'Kidney Foundation. KDOQI Clinical Practice Guidelines and Clinical Practice '
          'Recommendations.',
    ),
    const QuizQuestion(
      id: 'renal_50',
      type: QuizQuestionType.scientificSource,
      prompt: 'Le contexte clinique de l\'évaluation de la protéinurie (recueil minuté ou '
          '24 h) référencé dans ce calculateur s\'appuie sur :',
      options: [
        'KDIGO CKD Work Group. Kidney Int Suppl. 2013;3(1):1-150',
        'Friedewald WT et al., 1972',
        'De Ritis F et al., 1957',
        'Schwartz GJ et al., 2009',
      ],
      correctIndex: 0,
      explanation:
          'La référence documentée pour le contexte clinique de la protéinurie des 24 heures '
          'est le KDIGO 2012 Clinical Practice Guideline for the Evaluation and Management '
          'of Chronic Kidney Disease, Kidney Int Suppl. 2013;3(1):1-150.',
    ),
    const QuizQuestion(
      id: 'renal_51',
      type: QuizQuestionType.vocabulary,
      prompt: 'Dans la condition analytique de CKD-EPI cystatine C 2012, à quoi correspond '
          'la mention « matériau de référence IRMM/ERM-DA471/IFCC » ?',
      options: [
        'Le matériau de référence certifié auquel doit être calibré le dosage de cystatine C '
            'pour que l\'équation reste valide',
        'Un protocole de recueil urinaire minuté',
        'Une unité de mesure spécifique à la créatinine',
        'Le nom de la cohorte ayant servi à développer l\'équation',
      ],
      correctIndex: 0,
      explanation:
          'La condition analytique documentée précise que le dosage de cystatine C doit être '
          'standardisé sur le matériau de référence IRMM/ERM-DA471/IFCC — l\'équivalent, pour '
          'la cystatine C, de la standardisation IDMS pour la créatinine.',
    ),
    const QuizQuestion(
      id: 'renal_52',
      type: QuizQuestionType.vocabulary,
      prompt: "L'acronyme FeNa, utilisé dans l'exploration de l'insuffisance rénale aiguë, "
          'signifie :',
      options: [
        'Fraction excrétée du sodium',
        'Facteur d\'excrétion néphrologique',
        'Filtration excrétoire natrémique',
        'Fraction endogène du sodium',
      ],
      correctIndex: 0,
      explanation:
          'FeNa = fraction excrétée du sodium = (Na urinaire × Créat. plasmatique) / (Na '
          'plasmatique × Créat. urinaire) × 100.',
    ),
    const QuizQuestion(
      id: 'renal_53',
      type: QuizQuestionType.scientificSource,
      prompt: 'Ce calculateur cite les « KDOQI Clinical Practice Guidelines » comme source '
          'de la clairance de la créatinine mesurée. Quelle organisation est à l\'origine de '
          'ces recommandations ?',
      options: [
        'La National Kidney Foundation',
        "L'Organisation mondiale de la santé",
        'La Société de néphrologie française',
        'Le NKF-ASN Task Force ayant produit CKD-EPI 2021',
      ],
      correctIndex: 0,
      explanation:
          'La source documentée est : « National Kidney Foundation. KDOQI Clinical Practice '
          'Guidelines and Clinical Practice Recommendations. »',
    ),
    const QuizQuestion(
      id: 'renal_54',
      type: QuizQuestionType.vocabulary,
      prompt: 'Dans le contexte de ce calculateur rénal, l\'acronyme PCR urinaire désigne :',
      options: [
        'Le rapport protéines/créatinine urinaire',
        'La réaction de polymérisation en chaîne (biologie moléculaire)',
        'La protéine C réactive urinaire',
        'Le produit de clairance rénale',
      ],
      correctIndex: 0,
      explanation:
          'Dans ce calculateur, PCR désigne le rapport protéines/créatinine urinaire (PCR = '
          'Protéinurie totale (mg/L) / Créatininurie (g/L ou mmol/L)) — à ne pas confondre '
          'avec d\'autres significations de ce sigle utilisées dans d\'autres disciplines.',
    ),
    const QuizQuestion(
      id: 'renal_55',
      type: QuizQuestionType.vocabulary,
      prompt: 'Le calculateur de rapport albumine/créatinine (ACR) urinaire de BioSigma rend '
          'le résultat :',
      options: [
        'Dans les deux conventions d\'unité, mg/g ET mg/mmol, simultanément',
        'Uniquement en mg/g',
        'Uniquement en mg/mmol',
        'En g/L, comme la créatininurie',
      ],
      correctIndex: 0,
      explanation:
          'Le calcul du rapport albumine/créatinine urinaire renvoie deux valeurs de '
          'résultat, l\'une en mg/g et l\'autre en mg/mmol, selon la convention retenue par '
          'le laboratoire.',
    ),
  ],
);
