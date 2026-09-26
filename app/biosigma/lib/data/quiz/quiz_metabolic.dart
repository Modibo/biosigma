import 'package:biosigma_core/biosigma_core.dart';

import '../../models/quiz_question.dart';

final QuizModule quizMetabolic = QuizModule(
  id: 'quiz_metabolic',
  title: 'Glucides, insulinorésistance et cardiométabolisme',
  category: CalculatorCategory.metabolic,
  questions: [
    const QuizQuestion(
      id: 'metabolic_1',
      type: QuizQuestionType.scientificSource,
      prompt: "L'indice QUICKI (Quantitative Insulin Sensitivity Check Index) a été proposé en "
          '2000 par :',
      options: [
        'Katz A et al.',
        'Matthews DR et al.',
        'Simental-Mendía LE et al.',
        'Friedewald WT et al.',
      ],
      correctIndex: 0,
      explanation:
          'Katz A, Nambi SS, Mather K, et al. J Clin Endocrinol Metab. 2000;85(7):2402-2410.',
    ),
    const QuizQuestion(
      id: 'metabolic_2',
      type: QuizQuestionType.scientificSource,
      prompt: "La conversion de l'HbA1c en glycémie moyenne estimée (eAG) repose sur l'étude :",
      options: ['ADAG (Nathan et al., 2008)', 'DCCT (1993)', 'UKPDS (1998)', 'ACCORD (2008)'],
      correctIndex: 0,
      explanation:
          'A1c-Derived Average Glucose (ADAG) Study Group — Nathan DM et al. Diabetes Care. '
          '2008;31(8):1473-1478. eAG (mg/dL) = 28,7 × HbA1c(%) − 46,7.',
    ),
    const QuizQuestion(
      id: 'metabolic_3',
      type: QuizQuestionType.scientificSource,
      prompt: "L'équation historique de Friedewald pour estimer le LDL-cholestérol date de :",
      options: ['1972', '1985', '2001', '2020'],
      correctIndex: 0,
      explanation:
          'Friedewald WT, Levy RI, Fredrickson DS. Clin Chem. 1972;18(6):499-502. L\'équation plus '
          'récente de Sampson (JAMA Cardiol. 2020) couvre un domaine de validité plus large en '
          'triglycérides.',
    ),
    const QuizQuestion(
      id: 'metabolic_4',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient a des triglycérides à 5,0 mmol/L (~440 mg/dL). Peut-on estimer son '
          'LDL-cholestérol par l\'équation de Friedewald ?',
      options: [
        'Non — hors domaine de validité (seuil ≈ 4,52 mmol/L / 400 mg/dL)',
        'Oui, sans restriction',
        'Oui, mais seulement chez la femme',
        'Non, car Friedewald ne s\'applique jamais aux triglycérides élevés, quel que soit le seuil',
      ],
      correctIndex: 0,
      explanation:
          'Au-delà de ce seuil, Friedewald sort de son domaine de validité mathématique. L\'équation '
          'de Sampson tolère des triglycérides plus élevés, avec sa propre limite.',
    ),
    const QuizQuestion(
      id: 'metabolic_5',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Pourquoi le prélèvement doit-il être strictement à jeun pour interpréter QUICKI, '
          'HOMA-IR ou le TyG ?',
      options: [
        'Ces indices reposent sur la glycémie et/ou l\'insulinémie à jeun ; un prélèvement '
            'post-prandial invalide leur interprétation',
        'Ce n\'est qu\'une recommandation de confort, sans impact sur le résultat',
        'Seule la glycémie doit être à jeun, l\'insuline peut être post-prandiale',
        'C\'est requis uniquement pour la conversion des unités',
      ],
      correctIndex: 0,
      explanation:
          'Les trois indices sont des indices indirects d\'insulinorésistance construits pour des '
          'valeurs à jeun (≥ 8 h) ; un prélèvement non à jeun rend le résultat ininterprétable.',
    ),
    const QuizQuestion(
      id: 'metabolic_6',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Deux laboratoires publient un TyG avec des conventions différentes (unités, '
          'parenthésage). Peut-on comparer directement leurs seuils publiés ?',
      options: [
        'Non — les conventions ne sont pas interchangeables',
        'Oui, le TyG est toujours calculé de la même façon',
        'Oui, à condition de convertir uniquement la glycémie',
        'La question ne se pose pas, le TyG n\'a qu\'une seule convention possible',
      ],
      correctIndex: 0,
      explanation:
          'Il existe dans la littérature différentes conventions de notation ou de placement des '
          'parenthèses pour le TyG (unités mg/dL vs mmol/L, dénominateur différent) : ne jamais '
          'comparer un résultat à un seuil publié pour une autre convention.',
    ),
    const QuizQuestion(
      id: 'metabolic_7',
      type: QuizQuestionType.vocabulary,
      prompt: 'Que signifie AIP ?',
      options: [
        'Indice athérogène du plasma (Atherogenic Index of Plasma)',
        'Analyse Immédiate du Profil lipidique',
        'Albumin Insulin Product',
        'Acide gras Insaturé Plasmatique',
      ],
      correctIndex: 0,
      explanation:
          "AIP = log10(Triglycérides mmol/L / HDL-C mmol/L), convention Dobiásová-Frohlich 2001 — "
          'toujours en mmol/L, à ne pas confondre avec le simple ratio TG/HDL en mg/dL.',
    ),
    const QuizQuestion(
      id: 'metabolic_8',
      type: QuizQuestionType.vocabulary,
      prompt: 'Que signifie HOMA dans « HOMA-IR » ?',
      options: [
        'Homeostasis Model Assessment',
        'Hormonal Insulin Model Analysis',
        'Hepatic Output Metabolic Assessment',
        'Homogeneous Marker Assay',
      ],
      correctIndex: 0,
      explanation: 'Matthews DR et al. Diabetologia. 1985;28(7):412-419.',
    ),
    const QuizQuestion(
      id: 'metabolic_9',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Une patiente diabétique de type 2 a un bilan lipidique avec CT et HDL connus, et '
          'des triglycérides à 4,8 mmol/L (~425 mg/dL). Le clinicien souhaite un LDL calculé par '
          "l'équation de Friedewald. Que faire ?",
      options: [
        'Ne pas calculer le LDL par Friedewald : les triglycérides dépassent le seuil de validité '
            '(4,52 mmol/L / 400 mg/dL) ; utiliser Sampson ou une mesure directe',
        "Calculer normalement, Friedewald n'a pas de limite en triglycérides",
        'Calculer, mais diviser le résultat par deux',
        'Impossible de calculer un LDL chez un patient diabétique, quelle que soit la méthode',
      ],
      correctIndex: 0,
      explanation:
          'Le domaine de validité de Friedewald est bloqué pour TG ≥ 4,52 mmol/L (400 mg/dL) ; '
          "l'équation de Sampson (JAMA Cardiol. 2020) tolère un seuil plus élevé (< 800 mg/dL), "
          'sinon recourir à une mesure directe.',
    ),
    const QuizQuestion(
      id: 'metabolic_10',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Une femme enceinte présente une hypertriglycéridémie physiologique du 3e trimestre, '
          'avec des triglycérides à 4,6 mmol/L (~405 mg/dL). Le LDL peut-il être estimé par '
          'Friedewald ?',
      options: [
        'Non, les triglycérides sont hors du domaine de validité de Friedewald (≥ 4,52 mmol/L / '
            '400 mg/dL)',
        'Oui, la grossesse ne modifie pas le domaine de validité de la formule',
        'Oui, mais uniquement au 3e trimestre',
        "Non, car Friedewald est contre-indiqué chez toute femme enceinte quel que soit le taux "
            'de triglycérides',
      ],
      correctIndex: 0,
      explanation:
          'Le blocage de Friedewald dépend uniquement du taux de triglycérides (seuil 4,52 '
          'mmol/L / 400 mg/dL), pas du contexte clinique en lui-même ; ici le seuil est dépassé.',
    ),
    const QuizQuestion(
      id: 'metabolic_11',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient suivi pour syndrome métabolique a des triglycérides à 3,9 mmol/L '
          '(~345 mg/dL), avec CT et HDL disponibles. Le LDL peut-il être calculé par Friedewald ?',
      options: [
        'Oui, ce taux reste sous le seuil de blocage de 4,52 mmol/L (400 mg/dL)',
        'Non, tout patient avec syndrome métabolique est exclu de Friedewald',
        'Non, le seuil de blocage est de 3,0 mmol/L',
        "Oui, mais seulement avec l'équation de Sampson",
      ],
      correctIndex: 0,
      explanation:
          'Le LDL Friedewald = CT − HDL − TG/5 reste calculable tant que les triglycérides sont '
          '< 4,52 mmol/L (400 mg/dL) ; ici la valeur est en dessous du seuil bloquant.',
    ),
    const QuizQuestion(
      id: 'metabolic_12',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient présente une hypertriglycéridémie sévère à 9,6 mmol/L (~850 mg/dL). '
          "L'équation de Sampson est sélectionnée pour estimer le LDL. Que se passe-t-il ?",
      options: [
        "Le LDL n'est pas calculé : ce taux dépasse le seuil de validité de Sampson (800 mg/dL) ; "
            'une mesure directe est nécessaire',
        "Le LDL est calculé normalement, Sampson n'a aucune limite",
        'Le LDL est calculé mais avec une précision réduite de moitié',
        'Il faut alors obligatoirement basculer sur Friedewald',
      ],
      correctIndex: 0,
      explanation:
          "L'équation de Sampson (NIH équation 2) est elle aussi bornée : au-delà de 800 mg/dL de "
          'triglycérides, le calcul est bloqué et une mesure directe du LDL est recommandée.',
    ),
    const QuizQuestion(
      id: 'metabolic_13',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient a des triglycérides à 7,9 mmol/L (~700 mg/dL). Quelle équation de LDL '
          'calculé reste utilisable dans ce cas, parmi celles disponibles dans BioSigma ?',
      options: [
        'Sampson uniquement (domaine valide < 800 mg/dL) ; Friedewald est bloqué dès 400 mg/dL',
        'Friedewald uniquement',
        'Les deux équations, au choix',
        'Aucune des deux, quel que soit le taux',
      ],
      correctIndex: 0,
      explanation:
          'À 700 mg/dL, les triglycérides dépassent le seuil de Friedewald (400 mg/dL) mais '
          'restent sous celui de Sampson (800 mg/dL) : seule Sampson (JAMA Cardiol. 2020) reste '
          'dans son domaine de validité.',
    ),
    const QuizQuestion(
      id: 'metabolic_14',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un prélèvement pour insulinémie et glycémie a été réalisé 2 heures après le '
          'déjeuner, puis utilisé pour calculer un QUICKI. Ce résultat est-il interprétable ?',
      options: [
        'Non, QUICKI nécessite un prélèvement strictement à jeun',
        'Oui, seule la glycémie doit être à jeun',
        "Oui, le caractère post-prandial n'affecte que la précision d'un chiffre après la virgule",
        'Non, mais uniquement si le patient est diabétique',
      ],
      correctIndex: 0,
      explanation:
          'La population applicable de QUICKI (Katz 2000) est précisée comme adulte avec '
          'prélèvement strictement à jeun ; un prélèvement post-prandial invalide son '
          'interprétation.',
    ),
    const QuizQuestion(
      id: 'metabolic_15',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Chez un patient hospitalisé, la glycémie et l\'insulinémie destinées au calcul du '
          "HOMA-IR ont été prélevées après une perfusion glucosée, sans respecter le jeûne. Que "
          'peut-on conclure du résultat ?',
      options: [
        "Il n'est pas interprétable : HOMA-IR requiert un prélèvement à jeun",
        'Il reste valable car HOMA-IR ne dépend pas du statut nutritionnel',
        'Il est valable si on multiplie le résultat par un facteur de correction',
        'Il est valable uniquement pour la composante insulinémie',
      ],
      correctIndex: 0,
      explanation:
          'HOMA-IR (Matthews 1985) est applicable à l\'adulte avec prélèvement à jeun ; un '
          'prélèvement non à jeun rend le résultat ininterprétable, comme pour QUICKI et le TyG.',
    ),
    const QuizQuestion(
      id: 'metabolic_16',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient ambulatoire arrive au laboratoire après un petit-déjeuner copieux pour '
          'un bilan incluant triglycérides et glycémie destinées au calcul de l\'indice TyG. '
          'Faut-il reporter le prélèvement ?',
      options: [
        "Oui, l'indice TyG est validé pour un prélèvement à jeun chez l'adulte",
        'Non, le TyG peut être calculé indifféremment à jeun ou non',
        'Non, seul le poids du patient influence la validité du TyG',
        'Oui, mais uniquement si le patient est un enfant',
      ],
      correctIndex: 0,
      explanation:
          "La population applicable du TyG (Simental-Mendía 2008) est l'adulte avec prélèvement "
          'à jeun ; un contexte post-prandial ne correspond pas à ce cadre validé.',
    ),
    const QuizQuestion(
      id: 'metabolic_17',
      type: QuizQuestionType.clinicalCase,
      prompt: "Un biologiste consulte un article utilisant l'indice TyG en mmol/L, avec un seuil "
          'diagnostique donné. Il souhaite comparer ce seuil à un TyG calculé par BioSigma '
          '(convention mg/dL, ln[(TG×Glucose)/2]). Est-ce comparable directement ?',
      options: [
        "Non, les conventions d'unités du TyG ne sont pas interchangeables",
        'Oui, ln transforme les unités automatiquement',
        'Oui, à condition d\'ajouter 2 au résultat',
        "Non, mais uniquement si le patient est un homme",
      ],
      correctIndex: 0,
      explanation:
          'Il existe dans la littérature différentes conventions du TyG (unités mg/dL vs mmol/L, '
          'dénominateur différent) : ne jamais comparer un résultat à un seuil publié pour une '
          'autre convention.',
    ),
    const QuizQuestion(
      id: 'metabolic_18',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Deux laboratoires calculent chacun un indice TyG pour le même patient, mais l\'un '
          'utilise un dénominateur différent de celui implémenté dans BioSigma. Les deux valeurs '
          'numériques obtenues peuvent-elles être interprétées avec le même seuil ?',
      options: [
        'Non — chaque convention de calcul du TyG a ses propres seuils publiés, non transposables',
        "Oui, le dénominateur n'affecte jamais le résultat final",
        'Oui, tant que la glycémie est identique dans les deux calculs',
        "La question ne se pose pas, il n'existe qu'une seule convention possible pour le TyG",
      ],
      correctIndex: 0,
      explanation:
          'Le TyG existe dans la littérature avec plusieurs conventions de notation ou de '
          'placement des parenthèses ; ne jamais comparer un résultat calculé selon une '
          'convention à un seuil publié pour une autre.',
    ),
    const QuizQuestion(
      id: 'metabolic_19',
      type: QuizQuestionType.clinicalCase,
      prompt: "Un patient porteur connu d'une hémoglobinopathie (drépanocytose) a une HbA1c "
          "dosée, à partir de laquelle on calcule une eAG (glycémie moyenne estimée). Cette eAG "
          'est-elle fiable ?',
      options: [
        'Non — une hémoglobinopathie affecte la durée de vie érythrocytaire et invalide '
            "l'interprétation de l'HbA1c/eAG",
        "Oui, l'hémoglobinopathie n'a aucun effet sur l'HbA1c",
        "Oui, à condition de doubler la valeur d'HbA1c avant le calcul",
        'Non, mais uniquement si le patient est aussi diabétique',
      ],
      correctIndex: 0,
      explanation:
          'Les hémoglobinopathies figurent parmi les conditions qui affectent la durée de vie '
          "érythrocytaire : l'HbA1c — et donc l'eAG qui en dérive (équation ADAG, Nathan 2008) — "
          'ne reflète alors plus fidèlement la glycémie moyenne.',
    ),
    const QuizQuestion(
      id: 'metabolic_20',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Une patiente présente une anémie hémolytique active. Une HbA1c est tout de même '
          'dosée et une eAG calculée. Comment interpréter ce résultat ?',
      options: [
        "Avec prudence : l'anémie hémolytique altère la durée de vie érythrocytaire et rend "
            "l'eAG non fiable",
        "Sans réserve, l'anémie n'affecte que la numération, pas l'HbA1c",
        'En ajoutant systématiquement 10 mg/dL au résultat',
        "L'eAG devient alors plus précise qu'en l'absence d'anémie",
      ],
      correctIndex: 0,
      explanation:
          "L'anémie hémolytique fait partie des conditions documentées qui, en modifiant la "
          "durée de vie érythrocytaire, invalident la fiabilité de l'HbA1c et donc de l'eAG "
          'calculée.',
    ),
    const QuizQuestion(
      id: 'metabolic_21',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient présente une carence martiale confirmée. Une HbA1c est dosée pour '
          'estimer une eAG. Le résultat doit-il être interprété comme chez un patient sans '
          'carence ?',
      options: [
        'Non — la carence martiale affecte la durée de vie érythrocytaire et fait partie des '
            "conditions qui invalident la fiabilité de l'eAG",
        "Oui, la carence martiale n'a aucune influence documentée sur l'HbA1c",
        'Oui, à condition de corriger le résultat par la ferritine',
        'Non, uniquement si la carence est associée à une grossesse',
      ],
      correctIndex: 0,
      explanation:
          'La carence martiale figure explicitement parmi les conditions documentées (avec '
          "hémoglobinopathie, anémie hémolytique, grossesse, IRC terminale) qui rendent l'HbA1c "
          "et l'eAG non fiables.",
    ),
    const QuizQuestion(
      id: 'metabolic_22',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Une femme enceinte au 2e trimestre a une HbA1c dosée pour suivi glycémique, '
          'convertie en eAG. Cette conversion doit-elle être interprétée comme en dehors de la '
          'grossesse ?',
      options: [
        'Non — la grossesse fait partie des conditions documentées qui invalident la fiabilité '
            "de l'eAG dérivée de l'HbA1c",
        "Oui, la grossesse ne modifie jamais l'interprétation de l'HbA1c",
        'Oui, uniquement au 1er trimestre',
        'Non, uniquement en cas de jumeaux',
      ],
      correctIndex: 0,
      explanation:
          "La grossesse est listée parmi les situations où l'HbA1c ne reflète plus fidèlement la "
          "glycémie moyenne, du fait de son impact sur la durée de vie érythrocytaire, rendant "
          "l'eAG calculée peu fiable.",
    ),
    const QuizQuestion(
      id: 'metabolic_23',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient en insuffisance rénale chronique terminale, dialysé, a une HbA1c dosée '
          'puis convertie en eAG. Peut-on se fier à cette eAG comme reflet de sa glycémie moyenne '
          'réelle ?',
      options: [
        "Non — l'insuffisance rénale terminale fait partie des conditions documentées qui "
            "invalident la fiabilité de l'eAG",
        'Oui, la dialyse normalise la durée de vie érythrocytaire',
        'Oui, sans aucune réserve',
        'Non, uniquement si le patient est aussi diabétique de type 1',
      ],
      correctIndex: 0,
      explanation:
          "L'insuffisance rénale terminale est explicitement citée comme condition affectant la "
          "durée de vie érythrocytaire et donc la fiabilité de l'HbA1c/eAG (équation ADAG, "
          'Nathan 2008).',
    ),
    const QuizQuestion(
      id: 'metabolic_24',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient équipé d\'un capteur de glucose en continu (CGM) a une moyenne '
          'glycémique mesurée sur 14 jours nettement différente de l\'eAG calculée à partir de '
          'son HbA1c. Comment expliquer cet écart, en l\'absence de toute condition invalidant '
          "l'HbA1c ?",
      options: [
        "L'eAG est une estimation statistique de population, qui peut différer notablement de la "
            'moyenne glycémique individuelle réelle',
        "C'est impossible, l'eAG et la moyenne du CGM doivent toujours être strictement "
            'identiques',
        'Le CGM est nécessairement en panne dans ce cas',
        'L\'écart signifie automatiquement une hémoglobinopathie sous-jacente',
      ],
      correctIndex: 0,
      explanation:
          "L'eAG (équation ADAG) est une estimation statistique de population ; elle peut "
          'différer notablement de la moyenne glycémique individuelle réelle mesurée par '
          'auto-surveillance ou capteur continu.',
    ),
    const QuizQuestion(
      id: 'metabolic_25',
      type: QuizQuestionType.clinicalCase,
      prompt: "Un patient diabétique tient un carnet d'auto-surveillance glycémique dont la "
          "moyenne s'écarte de l'eAG calculée à partir de son HbA1c, sans qu'aucune anomalie "
          'érythrocytaire ne soit connue. Quelle est l\'interprétation méthodologiquement '
          'correcte ?',
      options: [
        "Cet écart est attendu : l'eAG reste une estimation statistique, non une mesure "
            'individuelle exacte',
        'Le carnet du patient doit être considéré comme faux',
        "L'HbA1c doit être redosée en urgence dans tous les cas",
        "L'eAG est toujours plus précise que l'auto-surveillance, quel que soit le contexte",
      ],
      correctIndex: 0,
      explanation:
          "La limitation documentée de l'eAG est claire : il s'agit d'une estimation statistique "
          'de population, qui peut différer notablement de la moyenne glycémique individuelle '
          'réelle obtenue par auto-surveillance.',
    ),
    const QuizQuestion(
      id: 'metabolic_26',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Pour un même patient, un biologiste calcule à la fois le ratio TG/HDL (en mg/dL) '
          'fourni dans le panel lipidique et l\'indice AIP (Dobiásová-Frohlich), et obtient deux '
          'valeurs numériques très différentes. Est-ce une erreur ?',
      options: [
        'Non — le ratio TG/HDL (mg/dL) et l\'AIP (calculé en mmol/L) ne sont pas la même grandeur '
            'et ne sont pas numériquement comparables',
        'Oui, une seule des deux valeurs peut être correcte',
        "Non, mais alors l'AIP doit être arrondi au TG/HDL",
        "Oui, il faut toujours que les deux indices soient strictement égaux",
      ],
      correctIndex: 0,
      explanation:
          "L'AIP ne doit pas être confondu avec le simple ratio TG/HDL en mg/dL (convention "
          "McLaughlin) : ils sont numériquement différents car les deux analytes n'ont pas le "
          'même facteur de conversion mg/dL vers mmol/L.',
    ),
    const QuizQuestion(
      id: 'metabolic_27',
      type: QuizQuestionType.clinicalCase,
      prompt: "Une jeune patiente dyslipidémique demande pourquoi son « ratio TG/HDL » affiché "
          'dans le compte-rendu diffère de son « indice athérogène du plasma (AIP) » alors que '
          'les deux semblent comparer les mêmes analytes. Que répondre ?',
      options: [
        'Ce sont deux indices distincts : le ratio TG/HDL est un simple rapport en mg/dL, l\'AIP '
            'est un log10 du même rapport mais obligatoirement en mmol/L',
        "Il s'agit d'une erreur de saisie du logiciel",
        'Les deux indices sont identiques et l\'écart est impossible',
        "L'AIP est simplement le double du ratio TG/HDL",
      ],
      correctIndex: 0,
      explanation:
          'AIP = log10(Triglycérides mmol/L / HDL-C mmol/L) (Dobiásová-Frohlich 2001), à ne pas '
          'confondre avec le simple ratio TG/HDL en mg/dL du panel lipidique, qui utilise une '
          "autre convention d'unité.",
    ),
    const QuizQuestion(
      id: 'metabolic_28',
      type: QuizQuestionType.clinicalCase,
      prompt: "Un logiciel externe calcule un « AIP » directement à partir de triglycérides et "
          "d'HDL saisis en mg/dL, sans conversion. Ce résultat est-il conforme à la définition de "
          "l'AIP telle que documentée dans BioSigma ?",
      options: [
        "Non — l'AIP est défini comme log10(TG/HDL) avec les deux analytes obligatoirement en "
            'mmol/L',
        "Oui, l'unité n'a aucune importance pour un log10",
        'Oui, à condition d\'utiliser une base 2 plutôt que 10',
        "Non, car l'AIP ne s'applique qu'aux triglycérides, jamais au HDL",
      ],
      correctIndex: 0,
      explanation:
          "La formule documentée de l'AIP (Dobiásová-Frohlich 2001) impose des triglycérides et "
          'un HDL-C exprimés en mmol/L ; un calcul direct en mg/dL sans conversion ne correspond '
          'pas à cette définition.',
    ),
    const QuizQuestion(
      id: 'metabolic_29',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un laboratoire ne rapporte la glycémie qu\'en mg/dL et souhaite tout de même '
          'calculer un HOMA-IR sans repasser par le mmol/L. Est-ce possible selon les formes '
          'documentées de la formule ?',
      options: [
        'Oui — il existe une forme équivalente en mg/dL : HOMA-IR = (Glycémie mg/dL × '
            'Insulinémie µU/mL) / 405',
        'Non, HOMA-IR n\'existe que sous forme SI en mmol/L',
        'Oui, mais le résultat sera le double de la forme SI',
        'Non, il faut alors utiliser QUICKI à la place',
      ],
      correctIndex: 0,
      explanation:
          'La forme SI (Matthews 1985, diviseur 22,5 avec la glycémie en mmol/L) a une forme '
          'équivalente en mg/dL avec un diviseur de 405, donnant le même résultat numérique à la '
          'conversion près.',
    ),
    const QuizQuestion(
      id: 'metabolic_30',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un interne demande pourquoi le diviseur du HOMA-IR est tantôt 22,5 tantôt 405 '
          'selon les articles consultés. Quelle est l\'explication documentée ?',
      options: [
        'Ce sont deux formes équivalentes de la même formule, selon que la glycémie est exprimée '
            'en mmol/L (22,5) ou en mg/dL (405)',
        'Le diviseur 405 correspond à une version obsolète et erronée de la formule',
        "Le diviseur dépend de l'âge du patient",
        "Le diviseur 22,5 s'applique uniquement à l'enfant",
      ],
      correctIndex: 0,
      explanation:
          'HOMA-IR forme SI = (Glycémie mmol/L × Insulinémie µU/mL)/22,5 ; sa forme équivalente '
          'en mg/dL utilise un diviseur de 405, pour un résultat numérique identique à la '
          "conversion d'unité près.",
    ),
    const QuizQuestion(
      id: 'metabolic_31',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un clinicien souhaite appliquer, à sa patientèle locale, un seuil de HOMA-IR '
          'publié dans une cohorte étrangère utilisant une autre méthode de dosage de '
          "l'insuline. Est-ce méthodologiquement approprié sans validation locale ?",
      options: [
        'Non — les seuils publiés de HOMA-IR varient selon la population et la méthode de dosage '
            "de l'insuline, et doivent être validés localement",
        'Oui, HOMA-IR est standardisé internationalement et le seuil est universel',
        'Oui, à condition d\'ajouter 22,5 au seuil publié',
        'Non, HOMA-IR ne doit jamais être interprété avec un seuil, quel qu\'il soit',
      ],
      correctIndex: 0,
      explanation:
          'La documentation de HOMA-IR précise explicitement que les seuils publiés varient '
          "selon la population et la méthode de dosage de l'insuline, et doivent être validés "
          'localement.',
    ),
    const QuizQuestion(
      id: 'metabolic_32',
      type: QuizQuestionType.clinicalCase,
      prompt: "Deux laboratoires utilisent des trousses immunologiques différentes pour doser "
          "l'insulinémie utilisée dans le calcul du HOMA-IR. Les valeurs de HOMA-IR obtenues "
          'pour un même patient théorique seraient-elles nécessairement superposables à un seuil '
          'unique ?',
      options: [
        "Non — la méthode de dosage de l'insuline influence les seuils publiés, qui doivent être "
            'validés localement',
        "Oui, toutes les trousses de dosage de l'insuline sont interchangeables sans réserve",
        "Oui, car le HOMA-IR ne dépend pas de l'insulinémie",
        "Non, car le HOMA-IR n'utilise jamais l'insulinémie",
      ],
      correctIndex: 0,
      explanation:
          'Les limitations documentées du HOMA-IR indiquent que les seuils varient selon la '
          "population ET la méthode de dosage de l'insuline — à valider localement.",
    ),
    const QuizQuestion(
      id: 'metabolic_33',
      type: QuizQuestionType.clinicalCase,
      prompt: "Un résultat de QUICKI est communiqué comme « preuve directe » du niveau "
          "d'insulinosensibilité d'un patient, sans autre exploration. Cette interprétation "
          'est-elle conforme aux limitations documentées de l\'indice ?',
      options: [
        "Non — QUICKI est un indice indirect d'insulinosensibilité, non une mesure directe "
            '(référence : clamp euglycémique hyperinsulinémique)',
        'Oui, QUICKI est équivalent au clamp euglycémique hyperinsulinémique',
        'Oui, QUICKI remplace toute exploration complémentaire',
        "Non, car QUICKI ne mesure jamais l'insulinosensibilité",
      ],
      correctIndex: 0,
      explanation:
          "La limitation documentée de QUICKI (Katz 2000) précise qu'il s'agit d'un indice "
          'indirect d\'insulinosensibilité, non une mesure directe ; la référence reste le clamp '
          'euglycémique hyperinsulinémique.',
    ),
    const QuizQuestion(
      id: 'metabolic_34',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un HOMA-IR élevé est présenté dans un dossier comme équivalent à un clamp '
          'euglycémique hyperinsulinémique normal. Cette assimilation est-elle correcte au '
          'regard des limitations documentées ?',
      options: [
        "Non — HOMA-IR est un indice indirect d'insulinorésistance, la référence directe restant "
            'le clamp euglycémique hyperinsulinémique',
        'Oui, les deux méthodes sont rigoureusement équivalentes',
        'Oui, HOMA-IR est plus précis que le clamp',
        "Non, car HOMA-IR ne concerne pas l'insulinorésistance",
      ],
      correctIndex: 0,
      explanation:
          'Comme QUICKI, HOMA-IR (Matthews 1985) est qualifié d\'indice indirect '
          "d'insulinorésistance dont la référence est le clamp euglycémique hyperinsulinémique — "
          'jamais une mesure équivalente à ce dernier.',
    ),
    const QuizQuestion(
      id: 'metabolic_35',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient est connu porteur d\'une dysbêtalipoprotéinémie de type III (maladie à '
          'large bande bêta). Un LDL calculé (Friedewald ou Sampson) est-il fiable dans ce '
          'contexte ?',
      options: [
        'Non — le panel lipidique calculé (Friedewald ou Sampson) n\'est pas valide en cas de '
            'dysbêtalipoprotéinémie de type III',
        'Oui, les deux équations restent valides dans tous les cas',
        'Oui, à condition d\'utiliser uniquement Sampson',
        'Non, mais uniquement si les triglycérides sont normaux',
      ],
      correctIndex: 0,
      explanation:
          'Il est documenté que le panel lipidique calculé n\'est pas valide en cas de '
          'dysbêtalipoprotéinémie de type III (ni de chylomicronémie), une situation non '
          'détectable à partir des seules valeurs saisies.',
    ),
    const QuizQuestion(
      id: 'metabolic_36',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un sérum manifestement lactescent (aspect évocateur de chylomicronémie) est reçu '
          'au laboratoire pour un bilan lipidique complet incluant un LDL calculé. Le résultat '
          'calculé peut-il être rendu sans réserve ?',
      options: [
        'Non — le LDL calculé (Friedewald ou Sampson) n\'est pas valide en cas de '
            'chylomicronémie',
        "Oui, l'aspect du sérum n'a aucune incidence sur la validité du calcul",
        "Oui, à condition de centrifuger deux fois l'échantillon",
        'Non, mais uniquement si le patient est à jeun',
      ],
      correctIndex: 0,
      explanation:
          'La chylomicronémie fait partie des situations documentées où le panel lipidique '
          'calculé n\'est pas valide, une situation qui n\'est pas détectable à partir des '
          'seules valeurs numériques saisies.',
    ),
    const QuizQuestion(
      id: 'metabolic_37',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un clinicien demande pourquoi BioSigma ne propose pas l\'équation de '
          'Martin-Hopkins pour le LDL calculé, réputée plus précise en cas d\'hypertriglycéridémie '
          'modérée. Quelle est la justification documentée ?',
      options: [
        'Elle n\'est pas implémentée dans cette version : le risque de transcription d\'une '
            'table à 180 cellules a été jugé trop élevé sans validation externe formelle ; '
            'Friedewald et Sampson couvrent la majorité des cas d\'usage',
        'Martin-Hopkins est en réalité identique à Friedewald, donc redondante',
        "Martin-Hopkins n'existe pas dans la littérature scientifique",
        'Martin-Hopkins est réservée aux laboratoires vétérinaires',
      ],
      correctIndex: 0,
      explanation:
          'La documentation précise explicitement que l\'équation Martin-Hopkins (table de '
          'facteurs ajustés) n\'est pas implémentée, en raison du risque de transcription d\'une '
          'table à 180 cellules sans validation externe formelle.',
    ),
    const QuizQuestion(
      id: 'metabolic_38',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Pour un dosage de QUICKI, l\'insulinémie a été réalisée avec une méthode de '
          'dosage non standardisée et mal contrôlée en interne. Cela respecte-t-il les '
          'conditions analytiques documentées de QUICKI ?',
      options: [
        'Non — les conditions analytiques de QUICKI exigent un prélèvement à jeun (≥ 8 h) et un '
            'dosage d\'insuline standardisé',
        "Oui, la standardisation du dosage d'insuline n'est pas une condition de QUICKI",
        'Oui, seule la glycémie doit être standardisée',
        'Non, mais uniquement si le patient est un enfant',
      ],
      correctIndex: 0,
      explanation:
          'Les conditions analytiques documentées de QUICKI (Katz 2000) précisent un '
          'prélèvement à jeun (≥ 8 h) ET un dosage d\'insuline standardisé.',
    ),
    const QuizQuestion(
      id: 'metabolic_39',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Chez un patient dont les triglycérides bloquent le calcul du LDL par Friedewald '
          '(≥ 400 mg/dL) et pour lequel l\'équation de Sampson n\'a pas été sélectionnée, le '
          'cholestérol résiduel peut-il être rendu ?',
      options: [
        'Non — le cholestérol résiduel est défini comme non-HDL − LDL et ne peut être calculé si '
            'le LDL ne l\'est pas',
        'Oui, le cholestérol résiduel ne dépend jamais du LDL',
        'Oui, en utilisant directement les triglycérides à la place du LDL',
        "Non, car le cholestérol résiduel n'existe pas dans le panel lipidique",
      ],
      correctIndex: 0,
      explanation:
          'Le cholestérol résiduel est défini par la formule non-HDL − LDL ; si le LDL n\'est '
          'pas calculé (triglycérides hors domaine de validité), le cholestérol résiduel ne peut '
          'pas non plus être obtenu.',
    ),
    const QuizQuestion(
      id: 'metabolic_40',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Dans le panel lipidique de BioSigma, comment le cholestérol résiduel est-il '
          'défini par rapport aux autres valeurs du panel ?',
      options: [
        'Cholestérol résiduel = Cholestérol non-HDL − LDL calculé',
        'Cholestérol résiduel = Triglycérides / 5',
        'Cholestérol résiduel = HDL − LDL',
        'Cholestérol résiduel = Cholestérol total / HDL',
      ],
      correctIndex: 0,
      explanation:
          'Le panel lipidique documente explicitement : Cholestérol résiduel = non-HDL − LDL.',
    ),
    const QuizQuestion(
      id: 'metabolic_41',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un patient a des triglycérides à 5,5 mmol/L (~490 mg/dL), bloquant le LDL par '
          'Friedewald. Le cholestérol non-HDL peut-il malgré tout être rapporté dans le '
          'compte-rendu ?',
      options: [
        'Oui — non-HDL = CT − HDL, une formule qui ne dépend pas des triglycérides ni du calcul '
            'du LDL',
        'Non, non-HDL nécessite obligatoirement un LDL calculé au préalable',
        'Non, non-HDL est bloqué dans les mêmes conditions que Friedewald',
        'Oui, mais uniquement en divisant par les triglycérides',
      ],
      correctIndex: 0,
      explanation:
          'Le cholestérol non-HDL est défini comme CT − HDL, une formule indépendante des '
          'triglycérides et du calcul du LDL ; il reste donc disponible même quand Friedewald '
          'est bloqué.',
    ),
    const QuizQuestion(
      id: 'metabolic_42',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Chez un patient présentant une hypertriglycéridémie sévère empêchant tout calcul '
          'de LDL (Friedewald et Sampson tous deux hors domaine), quelles valeurs du panel '
          'lipidique restent tout de même calculables ?',
      options: [
        'Le cholestérol non-HDL et le ratio CT/HDL, qui ne dépendent pas du LDL calculé',
        'Aucune valeur du panel ne peut plus être rendue',
        'Seul le cholestérol résiduel reste calculable',
        'Seul le ratio TG/HDL en mmol/L reste calculable',
      ],
      correctIndex: 0,
      explanation:
          'Non-HDL (CT − HDL) et le ratio CT/HDL sont calculés indépendamment du LDL ; en '
          'revanche le cholestérol résiduel (non-HDL − LDL) nécessite le LDL et ne peut donc pas '
          'être rendu dans ce cas.',
    ),
    const QuizQuestion(
      id: 'metabolic_43',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un clinicien souhaite recevoir le résultat de l\'eAG (glycémie moyenne estimée) à '
          'la fois en mg/dL, unité de l\'équation d\'origine, et en mmol/L, unité qu\'il utilise '
          'en pratique courante. Est-ce possible avec le calculateur documenté ?',
      options: [
        "Oui — le calcul de l'eAG restitue le résultat à la fois en mg/dL et en mmol/L",
        "Non, l'eAG n'est disponible qu'en mg/dL",
        "Non, l'eAG n'est disponible qu'en mmol/L",
        "Non, il faut reconvertir manuellement l'HbA1c avant chaque calcul",
      ],
      correctIndex: 0,
      explanation:
          "L'équation ADAG (Nathan 2008) donne l'eAG en mg/dL (28,7 × HbA1c% − 46,7), et le "
          'calculateur restitue également la conversion correspondante en mmol/L.',
    ),
    const QuizQuestion(
      id: 'metabolic_44',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Pour vérifier manuellement un calcul de QUICKI, un interne veut recalculer 1 / '
          '[log10(insuline) + log10(glycémie)]. Dans quelles unités les deux valeurs doivent-elles '
          'être exprimées avant application des log10, selon la formule documentée ?',
      options: [
        'Insulinémie à jeun en µU/mL et glycémie à jeun en mg/dL',
        'Insulinémie à jeun en mUI/L et glycémie à jeun en mmol/L',
        'Insulinémie et glycémie toutes deux en mmol/L',
        'Insulinémie et glycémie toutes deux en g/L',
      ],
      correctIndex: 0,
      explanation:
          'L\'équation documentée de QUICKI est : 1 / [log10(Insulinémie à jeun, µU/mL) + '
          'log10(Glycémie à jeun, mg/dL)].',
    ),
    const QuizQuestion(
      id: 'metabolic_45',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un étudiant recalcule manuellement l\'indice TyG d\'un patient et utilise par '
          'erreur un logarithme décimal (log10) au lieu de l\'opération documentée. Quelle est '
          "l'erreur commise ?",
      options: [
        'Le TyG documenté utilise le logarithme népérien (ln), pas le logarithme décimal (log10)',
        'Aucune erreur, log10 et ln donnent le même résultat pour le TyG',
        "Le TyG documenté n'utilise aucun logarithme",
        'Le TyG documenté utilise le log10, l\'étudiant a raison',
      ],
      correctIndex: 0,
      explanation:
          'La formule documentée du TyG est TyG = ln[(Triglycérides à jeun mg/dL × Glycémie à '
          'jeun mg/dL) / 2], soit un logarithme népérien, non un logarithme décimal.',
    ),
    const QuizQuestion(
      id: 'metabolic_46',
      type: QuizQuestionType.scientificSource,
      prompt: 'L\'équation de Sampson pour le LDL calculé (dite « NIH équation 2 ») a été '
          'publiée dans quelle revue, en 2020 ?',
      options: [
        'JAMA Cardiology',
        'Diabetes Care',
        'Clinical Chemistry',
        'Diabetologia',
      ],
      correctIndex: 0,
      explanation: 'Sampson M, Ling C, Sun Q, et al. JAMA Cardiol. 2020;5(5):540-548.',
    ),
    const QuizQuestion(
      id: 'metabolic_47',
      type: QuizQuestionType.scientificSource,
      prompt: "L'étude princeps ayant établi la formule du TyG (produit glycémie × triglycérides "
          'à jeun) a été publiée par Simental-Mendía et al. dans :',
      options: [
        'Metabolic Syndrome and Related Disorders (2008)',
        'Diabetologia (1985)',
        'JAMA Cardiology (2020)',
        'Clinical Biochemistry (2001)',
      ],
      correctIndex: 0,
      explanation:
          'Simental-Mendía LE, Rodríguez-Morán M, Guerrero-Romero F. Metab Syndr Relat Disord. '
          '2008;6(4):299-304.',
    ),
    const QuizQuestion(
      id: 'metabolic_48',
      type: QuizQuestionType.scientificSource,
      prompt: "L'indice athérogène du plasma (AIP), log(TG/HDL-C), a été proposé par Dobiásová "
          'et Frohlich dans quelle revue, en 2001 ?',
      options: [
        'Clinical Biochemistry',
        'Journal of Clinical Endocrinology & Metabolism',
        'Diabetes Care',
        'JAMA Cardiology',
      ],
      correctIndex: 0,
      explanation: 'Dobiásová M, Frohlich J. Clin Biochem. 2001;34(7):583-588.',
    ),
    const QuizQuestion(
      id: 'metabolic_49',
      type: QuizQuestionType.vocabulary,
      prompt: 'Que signifie l\'acronyme « TyG » utilisé pour l\'indice éponyme ?',
      options: [
        'Triglyceride-Glucose Index',
        'Type Glycémique',
        'Thyroid-Glucose Index',
        'Total Glucose',
      ],
      correctIndex: 0,
      explanation: 'TyG = Triglyceride-Glucose Index (Simental-Mendía et al., 2008).',
    ),
    const QuizQuestion(
      id: 'metabolic_50',
      type: QuizQuestionType.vocabulary,
      prompt: 'Que signifie l\'acronyme « eAG » ?',
      options: [
        'Estimated Average Glucose (glycémie moyenne estimée)',
        'Extended Albumin Glycation',
        'Erythrocyte Aging Gradient',
        'Enzymatic Assay for Glucose',
      ],
      correctIndex: 0,
      explanation:
          "eAG = Estimated Average Glucose, calculée à partir de l'HbA1c selon l'équation ADAG "
          '(Nathan 2008).',
    ),
    const QuizQuestion(
      id: 'metabolic_51',
      type: QuizQuestionType.vocabulary,
      prompt: 'Dans l\'étude ADAG, qui fonde l\'équation de l\'eAG, que signifie l\'acronyme '
          '« ADAG » ?',
      options: [
        'A1c-Derived Average Glucose',
        'American Diabetes Advisory Group',
        'Average Diabetic Assessment Guideline',
        'Analytical Determination of A1c and Glucose',
      ],
      correctIndex: 0,
      explanation:
          'ADAG = A1c-Derived Average Glucose Study Group (Nathan DM et al., Diabetes Care '
          '2008).',
    ),
    const QuizQuestion(
      id: 'metabolic_52',
      type: QuizQuestionType.scientificSource,
      prompt: "L'article de Matthews DR et al. ayant introduit le HOMA (Homeostasis Model "
          'Assessment) a été publié en 1985 dans :',
      options: [
        'Diabetologia',
        'Clinical Chemistry',
        'JAMA Cardiology',
        'Metabolic Syndrome and Related Disorders',
      ],
      correctIndex: 0,
      explanation:
          'Matthews DR, Hosker JP, Rudenski AS, Naylor BA, Treacher DF, Turner RC. Diabetologia. '
          '1985;28(7):412-419.',
    ),
    const QuizQuestion(
      id: 'metabolic_53',
      type: QuizQuestionType.vocabulary,
      prompt: 'Dans la documentation de BioSigma, l\'équation de Sampson pour le LDL calculé est '
          'aussi désignée par quel autre nom ?',
      options: [
        'Équation NIH équation 2',
        'Équation de Martin-Hopkins',
        'Équation de Dobiásová',
        'Équation ADAG',
      ],
      correctIndex: 0,
      explanation:
          'La documentation cite : « Sampson 2020 (équation NIH 2) », note associée à la '
          'référence Sampson et al., JAMA Cardiol. 2020.',
    ),
    const QuizQuestion(
      id: 'metabolic_54',
      type: QuizQuestionType.scientificSource,
      prompt: "L'article original de Katz A et al. décrivant le QUICKI a été publié en 2000 dans "
          'quelle revue ?',
      options: [
        'Journal of Clinical Endocrinology & Metabolism',
        'Diabetologia',
        'Diabetes Care',
        'Clinical Biochemistry',
      ],
      correctIndex: 0,
      explanation:
          'Katz A, Nambi SS, Mather K, et al. J Clin Endocrinol Metab. 2000;85(7):2402-2410.',
    ),
    const QuizQuestion(
      id: 'metabolic_55',
      type: QuizQuestionType.vocabulary,
      prompt: 'Que signifie l\'acronyme « QUICKI » ?',
      options: [
        'Quantitative Insulin Sensitivity Check Index',
        'Quick Insulin Correction Index',
        'Qualitative Index of Cardiometabolic Insulin',
        'Quantitative Interpretation of Clinical Ketone Index',
      ],
      correctIndex: 0,
      explanation: 'QUICKI = Quantitative Insulin Sensitivity Check Index (Katz et al., 2000).',
    ),
  ],
);
