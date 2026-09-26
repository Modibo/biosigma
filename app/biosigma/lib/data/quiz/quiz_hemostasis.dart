import 'package:biosigma_core/biosigma_core.dart';

import '../../models/quiz_question.dart';

final QuizModule quizHemostasis = QuizModule(
  id: 'quiz_hemostasis',
  title: 'Hémostase',
  category: CalculatorCategory.hemostasis,
  questions: [
    const QuizQuestion(
      id: 'hemostasis_1',
      type: QuizQuestionType.scientificSource,
      prompt: 'L\'indice de mélange à l\'origine de l\'indice de Rosner a été décrit en 1987 par :',
      options: ['Rosner E et al.', 'Kirkwood TB', 'Taylor FB Jr et al.', 'Lo GK et al.'],
      correctIndex: 0,
      explanation:
          'Rosner E, Pauzner R, Lusky A, Modan M, Many A. Thromb Haemost. 1987;57(2):144-147.',
    ),
    const QuizQuestion(
      id: 'hemostasis_2',
      type: QuizQuestionType.scientificSource,
      prompt: 'Le score ISTH de CIVD a été proposé en 2001 par :',
      options: [
        'Le sous-comité scientifique CIVD de l\'ISTH (Taylor FB Jr et al.)',
        'Warkentin TE seul',
        'Le comité OMS des thromboplastines',
        'De Ritis F et al.',
      ],
      correctIndex: 0,
      explanation:
          'Taylor FB Jr, Toh CH, Hoots WK, Wada H, Levi M ; sous-comité scientifique CIVD de '
          'l\'ISTH. Thromb Haemost. 2001;86(5):1327-1330.',
    ),
    const QuizQuestion(
      id: 'hemostasis_3',
      type: QuizQuestionType.scientificSource,
      prompt: 'Le score 4Ts pour la thrombopénie induite par l\'héparine (2006) est associé à '
          'quel auteur principal ?',
      options: ['Warkentin TE (Lo GK et al.)', 'Rosner E', 'Kirkwood TB', 'Figge J'],
      correctIndex: 0,
      explanation:
          'Lo GK, Juhl D, Warkentin TE, Sigouin CS, Eichler P, Greinacher A. J Thromb Haemost. '
          '2006;4(4):759-765.',
    ),
    const QuizQuestion(
      id: 'hemostasis_4',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un indice de Rosner élevé est retrouvé lors d\'un bilan d\'allongement du TCA. '
          'Permet-il à lui seul de conclure à un anticoagulant circulant de type lupique ?',
      options: [
        'Non — il ne permet pas non plus d\'exclure un déficit en facteur de coagulation',
        'Oui, c\'est suffisant pour poser le diagnostic',
        'Oui, à condition que le TCA soit normal',
        'Non, cet indice ne sert qu\'au suivi du fibrinogène',
      ],
      correctIndex: 0,
      explanation:
          'L\'interprétation et les seuils dépendent du réactif, du protocole (immédiat ou après '
          'incubation) et de la validation locale du laboratoire.',
    ),
    const QuizQuestion(
      id: 'hemostasis_5',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Peut-on appliquer le score ISTH de CIVD chez un patient sans pathologie associée à '
          'un risque de CIVD ?',
      options: [
        'Non — ce prérequis clinique est une condition préalable obligatoire',
        'Oui, le score reste valide dans tous les contextes',
        'Oui, à condition que les plaquettes soient normales',
        'Cela dépend uniquement du taux de fibrinogène',
      ],
      correctIndex: 0,
      explanation:
          'Sans ce contexte clinique évocateur préalable, il n\'est pas recommandé d\'appliquer ce '
          'score (Taylor et al., 2001).',
    ),
    const QuizQuestion(
      id: 'hemostasis_6',
      type: QuizQuestionType.clinicalCase,
      prompt: 'Un des quatre critères du score 4Ts est manquant. Peut-on estimer un score partiel '
          'en supposant la valeur la plus probable ?',
      options: [
        'Non — le score doit être affiché comme incomplet, jamais inféré',
        'Oui, en prenant la moyenne des trois autres critères',
        'Oui, à condition de le signaler en petit caractère',
        'Le score 4Ts ne comporte que trois critères de toute façon',
      ],
      correctIndex: 0,
      explanation:
          'Comme pour le score ISTH-CIVD, aucune donnée absente n\'est jamais inférée : le score '
          'reste incomplet tant que les quatre critères ne sont pas renseignés.',
    ),
    const QuizQuestion(
      id: 'hemostasis_7',
      type: QuizQuestionType.vocabulary,
      prompt: 'Que signifie ISI, utilisé dans le calcul de l\'INR ?',
      options: [
        'Indice de Sensibilité International (International Sensitivity Index)',
        'Indice Standard International des ISTH',
        'International Serum Index',
        'Indice Sanguin Individuel',
      ],
      correctIndex: 0,
      explanation:
          'INR = (TP patient / TP moyen normal du laboratoire) ^ ISI. L\'ISI est spécifique au '
          'couple réactif/analyseur du laboratoire.',
    ),
    const QuizQuestion(
      id: 'hemostasis_8',
      type: QuizQuestionType.vocabulary,
      prompt: 'Que signifie TIH ?',
      options: [
        'Thrombopénie induite par l\'héparine',
        'Temps d\'Incubation de l\'Hémostase',
        'Trouble International de l\'Hémoglobine',
        'Taux d\'Inhibition Hépatique',
      ],
      correctIndex: 0,
      explanation:
          'Le score 4Ts est un score de probabilité clinique pré-test de TIH ; il ne remplace pas '
          'la recherche biologique d\'anticorps anti-PF4/héparine quand celle-ci est indiquée.',
    ),
    const QuizQuestion(
      id: 'hemostasis_9',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Dans le cadre d\'un bilan d\'allongement inexpliqué du TCA, le biologiste réalise un '
          'test de mélange 1:1 et mesure trois temps de coagulation (mélange, plasma témoin '
          'normal, plasma patient) pour calculer l\'indice de Rosner. Quelle est la formule '
          'exacte utilisée ?',
      options: [
        '[(TCA mélange 1:1 − TCA plasma témoin normal) / TCA plasma patient] × 100',
        '[(TCA plasma patient − TCA plasma témoin normal) / TCA mélange 1:1] × 100',
        '[TCA mélange 1:1 / (TCA plasma témoin normal + TCA plasma patient)] × 100',
        '(TCA mélange 1:1 − TCA plasma patient) / TCA plasma témoin normal',
      ],
      correctIndex: 0,
      explanation:
          'Formule documentée de l\'indice de Rosner (Rosner E et al., Thromb Haemost. '
          '1987;57(2):144-147).',
    ),
    const QuizQuestion(
      id: 'hemostasis_10',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un laboratoire calcule l\'indice de Rosner à partir d\'un TCA mélange 1:1 réalisé sur '
          'l\'automate A, d\'un TCA plasma témoin normal réalisé sur l\'automate B avec un '
          'réactif différent, et d\'un TCA plasma patient réalisé sur l\'automate A. Cette '
          'pratique est-elle conforme aux conditions analytiques documentées ?',
      options: [
        'Non — les trois temps doivent être mesurés avec le même réactif et le même analyseur, '
            'dans les mêmes conditions de prélèvement',
        'Oui, car seul le temps du mélange compte pour le calcul',
        'Oui, à condition que les trois prélèvements datent du même jour',
        'Non, mais uniquement si le patient est sous anticoagulant',
      ],
      correctIndex: 0,
      explanation:
          'Condition analytique documentée pour l\'indice de Rosner : mêmes réactif, analyseur et '
          'conditions de prélèvement pour les trois temps.',
    ),
    const QuizQuestion(
      id: 'hemostasis_11',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Le protocole du laboratoire prévoit de refaire le test de mélange TCA 1:1 après une '
          'phase d\'incubation avant de recalculer l\'indice de Rosner, à la recherche d\'un '
          'anticoagulant circulant temps-dépendant. Quelle durée d\'incubation typique est '
          'mentionnée pour cette phase dans la fiche technique ?',
      options: [
        '1 à 2 heures à 37°C',
        '5 minutes à température ambiante',
        '24 heures à 4°C',
        '30 secondes à 37°C',
      ],
      correctIndex: 0,
      explanation:
          'La phase « Après incubation » de l\'indice de Rosner est documentée comme typiquement '
          '1-2 h à 37°C.',
    ),
    const QuizQuestion(
      id: 'hemostasis_12',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un patient présente un TCA strictement normal lors d\'un bilan préopératoire '
          'systématique, sans allongement ni contexte évocateur. Le calcul de l\'indice de '
          'Rosner est-il indiqué dans cette situation d\'après la population d\'application '
          'documentée pour cet indice ?',
      options: [
        'Non — cet indice s\'applique au bilan d\'un allongement inexpliqué du TCA, absent ici',
        'Oui, il doit être calculé systématiquement en bilan préopératoire',
        'Oui, mais seulement si le patient a plus de 65 ans',
        'Non, cet indice ne s\'applique qu\'au suivi du fibrinogène',
      ],
      correctIndex: 0,
      explanation:
          'La population d\'application documentée de l\'indice de Rosner est le bilan d\'un '
          'allongement inexpliqué du TCA.',
    ),
    const QuizQuestion(
      id: 'hemostasis_13',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez une patiente enceinte présentant un allongement isolé du TCA en bilan '
          'préopératoire de césarienne, l\'indice de Rosner calculé après test de mélange est '
          'élevé. Cela suffit-il, à lui seul, à exclure un déficit en facteur de la coagulation ?',
      options: [
        'Non — un indice élevé ne permet pas d\'exclure un déficit en facteur de coagulation',
        'Oui, un indice élevé exclut formellement tout déficit en facteur',
        'Oui, si le TCA mélange se corrige totalement après incubation',
        'Cela dépend uniquement du taux de fibrinogène de la patiente',
      ],
      correctIndex: 0,
      explanation:
          'Limite documentée : un indice de Rosner élevé ne permet pas de conclure à un '
          'anticoagulant circulant lupique, ni d\'exclure un déficit en facteur de coagulation.',
    ),
    const QuizQuestion(
      id: 'hemostasis_14',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un patient sous AVK a un temps de prothrombine (TP) mesuré, comparé au TP moyen '
          'normal du laboratoire, avec un ISI propre au couple réactif/analyseur utilisé. '
          'Quelle formule permet de calculer son INR ?',
      options: [
        'INR = (TP patient / TP moyen normal du laboratoire) ^ ISI',
        'INR = (TP moyen normal du laboratoire / TP patient) ^ ISI',
        'INR = TP patient × ISI / TP moyen normal du laboratoire',
        'INR = (TP patient − TP moyen normal du laboratoire) / ISI',
      ],
      correctIndex: 0,
      explanation:
          'Formule documentée du système OMS INR/ISI : INR = (TP patient / TP moyen normal du '
          'laboratoire) ^ ISI.',
    ),
    const QuizQuestion(
      id: 'hemostasis_15',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un patient hospitalisé n\'est pas sous anticoagulant et son bilan d\'hémostase est '
          'demandé uniquement pour un dépistage d\'un trouble constitutionnel de la coagulation, '
          'en dehors de toute surveillance thérapeutique. D\'après la population d\'application '
          'documentée, l\'INR est-il l\'outil pertinent pour ce contexte ?',
      options: [
        'Non — l\'INR est destiné au patient sous surveillance du temps de prothrombine '
            '(typiquement un traitement par AVK)',
        'Oui, l\'INR est indiqué dans tous les bilans d\'hémostase sans exception',
        'Oui, car l\'INR remplace le dépistage constitutionnel de la coagulation',
        'Non, l\'INR ne s\'applique qu\'aux patients sous héparine',
      ],
      correctIndex: 0,
      explanation:
          'Population d\'application documentée de l\'INR : patient sous surveillance du temps '
          'de prothrombine.',
    ),
    const QuizQuestion(
      id: 'hemostasis_16',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Le clinicien demande au laboratoire de lui indiquer directement l\'ajustement de dose '
          'd\'AVK à partir du seul INR calculé, sans autre élément clinique. Que doit répondre le '
          'biologiste au regard des limites documentées de ce calcul ?',
      options: [
        'L\'INR ne fournit aucune recommandation de dose d\'anticoagulant ; il doit être '
            'interprété avec le contexte clinique et l\'indication du traitement',
        'Le laboratoire peut proposer une dose précise, car l\'INR seul suffit',
        'L\'INR permet de calculer directement la dose selon une formule intégrée',
        'Seul un INR supérieur à 4 nécessite une interprétation clinique complémentaire',
      ],
      correctIndex: 0,
      explanation:
          'Limite documentée de l\'INR : aucune recommandation de dose d\'anticoagulant ; '
          'interprétation à faire avec le contexte clinique et l\'indication du traitement.',
    ),
    const QuizQuestion(
      id: 'hemostasis_17',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Deux laboratoires obtiennent un TP patient identique mais utilisent des réactifs '
          'différents pour le temps de prothrombine. Peuvent-ils appliquer le même ISI pour '
          'calculer l\'INR de ce patient ?',
      options: [
        'Non — l\'ISI est spécifique au couple réactif/analyseur du laboratoire',
        'Oui, l\'ISI est une constante universelle indépendante du réactif',
        'Oui, à condition que les deux laboratoires soient accrédités',
        'Non, l\'ISI dépend uniquement de l\'âge du patient',
      ],
      correctIndex: 0,
      explanation:
          'Condition analytique documentée : l\'ISI est spécifique au couple réactif/analyseur du '
          'laboratoire.',
    ),
    const QuizQuestion(
      id: 'hemostasis_18',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Pour surveiller un traitement par héparine non fractionnée, le laboratoire mesure le '
          'TCA du patient et le TCA du témoin. Quelle formule donne le ratio TCA à interpréter ?',
      options: [
        'Ratio TCA = TCA patient / TCA témoin',
        'Ratio TCA = TCA témoin / TCA patient',
        'Ratio TCA = TCA patient − TCA témoin',
        'Ratio TCA = (TCA patient + TCA témoin) / 2',
      ],
      correctIndex: 0,
      explanation:
          'Formule documentée du ratio TCA patient/témoin (calcul standard, rapport de temps).',
    ),
    const QuizQuestion(
      id: 'hemostasis_19',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un patient reçoit une héparine non fractionnée en perfusion continue et un contrôle '
          'de TCA est demandé pour la surveillance thérapeutique. Le calcul du ratio TCA '
          'patient/témoin correspond-il à une population d\'application documentée pour ce '
          'calcul ?',
      options: [
        'Oui — ce ratio s\'applique au bilan d\'hémostase et à la surveillance d\'un traitement '
            'héparinique non fractionné',
        'Non, ce ratio ne s\'applique qu\'aux patients sous AVK',
        'Non, ce ratio est réservé au diagnostic de la CIVD',
        'Oui, mais uniquement en contexte pédiatrique',
      ],
      correctIndex: 0,
      explanation:
          'Population d\'application documentée du ratio TCA : bilan d\'hémostase, surveillance '
          'd\'un traitement héparinique non fractionné.',
    ),
    const QuizQuestion(
      id: 'hemostasis_20',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Le TCA patient est mesuré avec un réactif donné sur un analyseur donné, tandis que le '
          'TCA témoin utilisé pour le calcul du ratio provient d\'un autre lot de réactif testé '
          'sur un analyseur différent. Cette pratique respecte-t-elle les conditions analytiques '
          'documentées pour ce calcul ?',
      options: [
        'Non — le TCA patient et le TCA témoin doivent être mesurés avec le même réactif et le '
            'même analyseur',
        'Oui, seul le résultat final chiffré compte',
        'Oui, à condition que les deux analyseurs soient du même fabricant',
        'Non, mais uniquement si le patient est sous AVK',
      ],
      correctIndex: 0,
      explanation:
          'Condition analytique documentée du ratio TCA : patient et témoin mesurés avec le même '
          'réactif et le même analyseur.',
    ),
    const QuizQuestion(
      id: 'hemostasis_21',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un fibrinogène à 1,2 g/L est mesuré chez un patient, contre 1,8 g/L lors du '
          'prélèvement précédent. Quelle formule permet de calculer la variation relative entre '
          'les deux mesures ?',
      options: [
        'Variation relative (%) = (Valeur actuelle − Valeur précédente) / Valeur précédente × 100',
        'Variation relative (%) = (Valeur précédente − Valeur actuelle) / Valeur actuelle × 100',
        'Variation relative (%) = Valeur actuelle / Valeur précédente',
        'Variation relative (%) = (Valeur actuelle − Valeur précédente) × 100',
      ],
      correctIndex: 0,
      explanation:
          'Formule documentée du suivi de valeurs sériées pour la variation relative entre deux '
          'mesures successives.',
    ),
    const QuizQuestion(
      id: 'hemostasis_22',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Le laboratoire souhaite suivre l\'évolution de la numération plaquettaire d\'un '
          'patient entre deux prélèvements successifs. Le calcul de suivi de valeurs sériées '
          '(variation absolue et relative) est-il applicable à ce type d\'analyte d\'après sa '
          'population d\'application documentée ?',
      options: [
        'Oui — ce calcul s\'applique au suivi biologique sérié de tout analyte numérique',
        'Non, il est réservé exclusivement à l\'INR',
        'Non, il ne s\'applique qu\'aux marqueurs de fibrine',
        'Oui, mais seulement pour les analytes exprimés en g/L',
      ],
      correctIndex: 0,
      explanation:
          'Population d\'application documentée du suivi de valeurs sériées : suivi biologique '
          'sérié, tout analyte numérique.',
    ),
    const QuizQuestion(
      id: 'hemostasis_23',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un patient sous AVK, l\'INR passe de 2,1 à 3,4 entre deux prélèvements. Le '
          'biologiste calcule la variation absolue et relative avec le module de suivi sérié. '
          'Cette variation calculée constitue-t-elle, à elle seule, une recommandation de dose '
          'd\'anticoagulant ?',
      options: [
        'Non — ce calcul ne constitue pas une recommandation de dose d\'anticoagulant ni de '
            'conduite à tenir ; à interpréter selon le contexte clinique',
        'Oui, la variation relative indique directement l\'ajustement de dose nécessaire',
        'Oui, à condition que la variation dépasse 50 %',
        'Non, ce calcul de suivi sérié ne s\'applique pas à l\'INR',
      ],
      correctIndex: 0,
      explanation:
          'Limite documentée du suivi de valeurs sériées : ne constitue pas une recommandation de '
          'dose d\'anticoagulant ni de conduite à tenir.',
    ),
    const QuizQuestion(
      id: 'hemostasis_24',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un patient est admis en réanimation pour un choc septique sévère, contexte reconnu '
          'comme à risque de CIVD, et un bilan de coagulation complet est prélevé. Le score '
          'ISTH de CIVD peut-il être calculé dans ce contexte d\'après le prérequis clinique '
          'documenté ?',
      options: [
        'Oui — le patient présente une pathologie associée à un risque de CIVD, condition '
            'préalable requise',
        'Non, le score ISTH-CIVD ne s\'applique qu\'en contexte chirurgical',
        'Non, il faut d\'abord un dosage des D-dimères supérieur à un seuil fixe',
        'Oui, mais uniquement si les plaquettes sont déjà abaissées',
      ],
      correctIndex: 0,
      explanation:
          'Population d\'application documentée du score ISTH-CIVD : patient présentant une '
          'pathologie associée à un risque de CIVD (Taylor et al., 2001).',
    ),
    const QuizQuestion(
      id: 'hemostasis_25',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un patient consulte pour un bilan de coagulation de routine avant un geste '
          'ambulatoire mineur, sans pathologie sous-jacente évocatrice de CIVD ni contexte à '
          'risque. Peut-on appliquer le score ISTH de CIVD à ce bilan ?',
      options: [
        'Non — ce prérequis clinique (pathologie associée à un risque de CIVD) est une condition '
            'préalable obligatoire',
        'Oui, le score peut être calculé sur tout bilan de coagulation',
        'Oui, à condition que le TP soit normal',
        'Non, uniquement si le patient a plus de 60 ans',
      ],
      correctIndex: 0,
      explanation:
          'Sans ce contexte clinique évocateur préalable, il n\'est pas recommandé d\'appliquer ce '
          'score (Taylor et al., 2001).',
    ),
    const QuizQuestion(
      id: 'hemostasis_26',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un patient en choc septique remplissant le prérequis clinique du score '
          'ISTH-CIVD, la numération plaquettaire est de 42 G/L. Combien de points ce critère '
          '« plaquettes » rapporte-t-il au score ?',
      options: ['2 points', '1 point', '0 point', '3 points'],
      correctIndex: 0,
      explanation:
          'Barème documenté du score ISTH-CIVD : plaquettes < 50 G/L → 2 points.',
    ),
    const QuizQuestion(
      id: 'hemostasis_27',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Toujours chez un patient répondant au prérequis clinique du score ISTH-CIVD, la '
          'numération plaquettaire est de 75 G/L. Combien de points ce critère rapporte-t-il ?',
      options: ['1 point', '2 points', '0 point', '4 points'],
      correctIndex: 0,
      explanation:
          'Barème documenté du score ISTH-CIVD : plaquettes entre 50 et 99 G/L → 1 point.',
    ),
    const QuizQuestion(
      id: 'hemostasis_28',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un patient éligible au score ISTH-CIVD, le taux de D-dimères est interprété par '
          'le biologiste comme une augmentation forte du marqueur de fibrine. Combien de points '
          'cette catégorie rapporte-t-elle ?',
      options: ['3 points', '2 points', '1 point', '0 point'],
      correctIndex: 0,
      explanation:
          'Barème documenté du score ISTH-CIVD pour le marqueur de fibrine : augmentation forte '
          '→ 3 points.',
    ),
    const QuizQuestion(
      id: 'hemostasis_29',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un autre patient éligible au score ISTH-CIVD, le marqueur de fibrine (D-dimères '
          'ou PDF) est jugé sans augmentation. Quelle est la valeur en points attribuée à cette '
          'catégorie du score ?',
      options: ['0 point', '1 point', '2 points', '3 points'],
      correctIndex: 0,
      explanation:
          'Barème documenté du score ISTH-CIVD pour le marqueur de fibrine : pas d\'augmentation '
          '→ 0 point.',
    ),
    const QuizQuestion(
      id: 'hemostasis_30',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un patient éligible au score ISTH-CIVD, l\'allongement du TP par rapport au '
          'témoin est de 1,5 seconde. Combien de points ce critère rapporte-t-il ?',
      options: ['0 point', '1 point', '2 points', '3 points'],
      correctIndex: 0,
      explanation:
          'Barème documenté du score ISTH-CIVD : allongement du TP < 3 s → 0 point.',
    ),
    const QuizQuestion(
      id: 'hemostasis_31',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un patient éligible au score ISTH-CIVD, l\'allongement du TP est de 4,5 secondes '
          'par rapport au témoin. Combien de points ce critère apporte-t-il au score ?',
      options: ['1 point', '0 point', '2 points', '3 points'],
      correctIndex: 0,
      explanation:
          'Barème documenté du score ISTH-CIVD : allongement du TP entre 3 et 6 s → 1 point.',
    ),
    const QuizQuestion(
      id: 'hemostasis_32',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un patient éligible au score ISTH-CIVD, l\'allongement du TP par rapport au '
          'témoin atteint 8 secondes. Combien de points ce critère rapporte-t-il au score ?',
      options: ['2 points', '1 point', '0 point', '3 points'],
      correctIndex: 0,
      explanation:
          'Barème documenté du score ISTH-CIVD : allongement du TP ≥ 6 s → 2 points.',
    ),
    const QuizQuestion(
      id: 'hemostasis_33',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un patient éligible au score ISTH-CIVD, le fibrinogène mesuré, une fois converti '
          'en unité canonique, est de 0,8 g/L, soit une valeur inférieure ou égale à 1,0 g/L. '
          'Combien de points ce critère fibrinogène rapporte-t-il au score total ?',
      options: ['1 point', '0 point', '2 points', '3 points'],
      correctIndex: 0,
      explanation:
          'Barème documenté du score ISTH-CIVD : fibrinogène ≤ 1,0 g/L → 1 point.',
    ),
    const QuizQuestion(
      id: 'hemostasis_34',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un patient éligible au score ISTH-CIVD obtient un score total de 6 points après '
          'addition des quatre critères. D\'après l\'interprétation documentée, que signifie ce '
          'résultat ?',
      options: [
        'Compatible avec une CIVD manifeste (décompensée), score à répéter quotidiennement',
        'Évocateur d\'une CIVD non manifeste, score à répéter dans 1 à 2 jours',
        'Le score ISTH-CIVD n\'a pas d\'interprétation associée à un total chiffré',
        'Un score de 6 exclut formellement toute CIVD',
      ],
      correctIndex: 0,
      explanation:
          'Interprétation documentée : score ≥ 5 = compatible avec une CIVD manifeste '
          '(décompensée), à répéter quotidiennement.',
    ),
    const QuizQuestion(
      id: 'hemostasis_35',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un autre patient éligible obtient un score ISTH-CIVD total de 3 points. Que signifie '
          'ce résultat d\'après l\'interprétation documentée ?',
      options: [
        'Évocateur d\'une CIVD non manifeste (non décompensée), à répéter dans les 1 à 2 jours '
            'suivants',
        'Compatible avec une CIVD manifeste, à répéter quotidiennement',
        'Un score de 3 confirme l\'absence totale de risque hémorragique',
        'Le score doit être immédiatement annulé car incomplet',
      ],
      correctIndex: 0,
      explanation:
          'Interprétation documentée : score < 5 = évocateur d\'une CIVD non manifeste, à '
          'répéter dans les 1 à 2 jours suivants.',
    ),
    const QuizQuestion(
      id: 'hemostasis_36',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Deux laboratoires évaluent le marqueur de fibrine du score ISTH-CIVD : l\'un utilise '
          'les D-dimères, l\'autre les PDF, chacun chez un patient différent. Le seuil définissant '
          'une augmentation « modérée » ou « forte » est-il identique et transférable d\'un '
          'laboratoire à l\'autre d\'après les limites documentées ?',
      options: [
        'Non — ce seuil dépend du test utilisé (D-dimères ou PDF) et du laboratoire',
        'Oui, ce seuil est fixé de façon universelle par l\'ISTH',
        'Oui, à condition que les deux patients aient le même âge',
        'Non, ce seuil ne dépend que de la numération plaquettaire',
      ],
      correctIndex: 0,
      explanation:
          'Limite documentée du score ISTH-CIVD : le seuil « augmentation modérée/forte » du '
          'marqueur de fibrine dépend du test utilisé et du laboratoire.',
    ),
    const QuizQuestion(
      id: 'hemostasis_37',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un technicien calcule un score ISTH-CIVD à 5 points et souhaite l\'utiliser '
          'directement pour orienter la prise en charge sans relecture. Que recommandent les '
          'limites documentées de ce score ?',
      options: [
        'L\'interprétation clinique de ce score doit être validée localement par le biologiste '
            'responsable avant toute utilisation en pratique',
        'Le score peut être appliqué directement sans validation, car son calcul est automatisé',
        'Seul un score supérieur à 7 nécessite une validation par le biologiste',
        'La validation n\'est nécessaire que pour les scores inférieurs à 5',
      ],
      correctIndex: 0,
      explanation:
          'Limite documentée du score ISTH-CIVD : interprétation clinique à valider localement '
          'par le biologiste responsable avant toute utilisation en pratique.',
    ),
    const QuizQuestion(
      id: 'hemostasis_38',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un patient sous héparine, les plaquettes chutent de plus de 50 % avec un nadir '
          'mesuré à 25 G/L. D\'après la description documentée du critère « Thrombopénie » du '
          'score 4Ts, combien de points ce constat rapporte-t-il ?',
      options: [
        '2 points — chute des plaquettes > 50 % ET nadir ≥ 20 G/L',
        '1 point — chute des plaquettes 30-50 % OU nadir 10-19 G/L',
        '0 point — chute des plaquettes < 30 % OU nadir < 10 G/L',
        '3 points, le maximum possible pour ce critère',
      ],
      correctIndex: 0,
      explanation:
          'Description documentée du critère « Thrombopénie » du score 4Ts : chute > 50 % ET '
          'nadir ≥ 20 G/L → 2 points.',
    ),
    const QuizQuestion(
      id: 'hemostasis_39',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un patient hospitalisé reçoit de l\'héparine non fractionnée pour la première fois. '
          'La numération plaquettaire chute nettement entre le 7e et le 8e jour de traitement. '
          'D\'après la description documentée du critère « Chronologie » du score 4Ts, combien '
          'de points cette chronologie rapporte-t-elle ?',
      options: [
        '2 points — début net entre le 5e et le 10e jour',
        '1 point — chute compatible avec le 5e-10e jour mais mal documentée',
        '0 point — chute récente (< 4 jours) sans exposition récente à l\'héparine',
        'Le critère « Chronologie » ne s\'applique qu\'en cas de ré-exposition',
      ],
      correctIndex: 0,
      explanation:
          'Description documentée du critère « Chronologie » du score 4Ts : début net entre le '
          '5e et le 10e jour → 2 points.',
    ),
    const QuizQuestion(
      id: 'hemostasis_40',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un patient déjà exposé à l\'héparine il y a 15 jours reçoit une nouvelle dose '
          'd\'héparine ; ses plaquettes chutent brutalement en moins d\'un jour. D\'après la '
          'description documentée du critère « Chronologie » du score 4Ts, combien de points '
          'cette situation rapporte-t-elle ?',
      options: [
        '2 points — chute ≤ 1 jour en cas d\'exposition à l\'héparine dans les 30 derniers jours',
        '1 point — chute ≤ 1 jour si exposition 30-100 jours auparavant',
        '0 point — chute récente sans exposition à l\'héparine',
        'Ce critère n\'est jamais coté en cas de ré-exposition',
      ],
      correctIndex: 0,
      explanation:
          'Description documentée du critère « Chronologie » du score 4Ts : chute ≤ 1 jour si '
          'exposition à l\'héparine dans les 30 derniers jours → 2 points.',
    ),
    const QuizQuestion(
      id: 'hemostasis_41',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un patient sous héparine, une thrombose veineuse profonde de novo est confirmée '
          'par écho-Doppler pendant le traitement. D\'après la description documentée du '
          'critère « Thrombose/séquelles » du score 4Ts, combien de points cet événement '
          'rapporte-t-il ?',
      options: [
        '2 points — nouvelle thrombose confirmée, nécrose cutanée, ou réaction systémique aiguë '
            'après bolus IV d\'héparine',
        '1 point — thrombose suspectée non confirmée',
        '0 point — aucun signe de thrombose ou de séquelle',
        'Ce critère ne prend en compte que les nécroses cutanées',
      ],
      correctIndex: 0,
      explanation:
          'Description documentée du critère « Thrombose/séquelles » du score 4Ts : nouvelle '
          'thrombose confirmée → 2 points.',
    ),
    const QuizQuestion(
      id: 'hemostasis_42',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Chez un patient thrombopénique sous héparine, le bilan étiologique retrouve une cause '
          'alternative bien définie et documentée à la thrombopénie (par exemple une '
          'chimiothérapie myélosuppressive récente). D\'après la description documentée du '
          'critère « Autres causes » du score 4Ts, combien de points ce constat rapporte-t-il ?',
      options: [
        '0 point — autre cause définie et documentée',
        '2 points — aucune autre cause apparente',
        '1 point — autre cause possible',
        'Ce critère n\'intervient pas dans le calcul du score total',
      ],
      correctIndex: 0,
      explanation:
          'Description documentée du critère « Autres causes » du score 4Ts : autre cause '
          'définie et documentée → 0 point.',
    ),
    const QuizQuestion(
      id: 'hemostasis_43',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un patient obtient un score 4Ts total de 7 points après addition des quatre '
          'critères. D\'après l\'interprétation documentée de ce score, quelle probabilité '
          'clinique pré-test de TIH cela représente-t-il ?',
      options: [
        'Probabilité clinique élevée de thrombopénie induite par l\'héparine',
        'Probabilité clinique intermédiaire',
        'Probabilité clinique faible',
        'Le score 4Ts ne va pas jusqu\'à 7 points',
      ],
      correctIndex: 0,
      explanation:
          'Interprétation documentée du score 4Ts : 6-8 points = probabilité clinique élevée de '
          'TIH.',
    ),
    const QuizQuestion(
      id: 'hemostasis_44',
      type: QuizQuestionType.clinicalCase,
      prompt:
          'Un score 4Ts calculé à 6 points chez un patient sous héparine est jugé par l\'interne '
          'comme suffisant pour écarter toute confirmation biologique de la TIH. Cette attitude '
          'est-elle conforme aux limites documentées du score ?',
      options: [
        'Non — ce score de probabilité clinique pré-test ne remplace pas la recherche biologique '
            'd\'anticorps anti-PF4/héparine quand celle-ci est indiquée',
        'Oui, un score ≥ 6 dispense totalement de confirmation biologique',
        'Oui, à condition que le patient soit asymptomatique',
        'Non, uniquement si le patient a moins de 18 ans',
      ],
      correctIndex: 0,
      explanation:
          'Limite documentée du score 4Ts : ne remplace pas la recherche biologique d\'anticorps '
          'anti-PF4/héparine quand celle-ci est indiquée.',
    ),
    const QuizQuestion(
      id: 'hemostasis_45',
      type: QuizQuestionType.vocabulary,
      prompt: 'Que signifie l\'acronyme CIVD, présent dans le nom complet du score ISTH ?',
      options: [
        'Coagulation Intravasculaire Disséminée',
        'Coagulation Intra-Veineuse Diffuse',
        'Complexe Immun Vasculaire Disséminé',
        'Circulation Intra-Vasculaire Directe',
      ],
      correctIndex: 0,
      explanation:
          'Nom complet documenté : « Score ISTH de CIVD (coagulation intravasculaire '
          'disséminée) ».',
    ),
    const QuizQuestion(
      id: 'hemostasis_46',
      type: QuizQuestionType.vocabulary,
      prompt:
          'Que signifie INR, nom complet du calcul utilisé pour la surveillance d\'un traitement '
          'par AVK ?',
      options: [
        'International Normalized Ratio',
        'Indice Normalisé de Référence',
        'International Normal Range',
        'Indice National de Référence',
      ],
      correctIndex: 0,
      explanation: 'Nom complet documenté : « INR (International Normalized Ratio) ».',
    ),
    const QuizQuestion(
      id: 'hemostasis_47',
      type: QuizQuestionType.vocabulary,
      prompt:
          'Quels sont les quatre critères évalués par le score 4Ts, tels que nommés dans son '
          'barème documenté ?',
      options: [
        'Thrombopénie, Chronologie, Thrombose/séquelles, Autres causes',
        'Thrombopénie, Température, Thrombose, Traitement',
        'Temps de saignement, Chronologie, Thrombose, Autres causes',
        'Thrombopénie, Chronologie, Transfusion, Autres causes',
      ],
      correctIndex: 0,
      explanation:
          'Les quatre critères documentés du score 4Ts sont Thrombopénie, Chronologie, '
          'Thrombose/séquelles et Autres causes.',
    ),
    const QuizQuestion(
      id: 'hemostasis_48',
      type: QuizQuestionType.vocabulary,
      prompt: 'Quel est le nom complet documenté de l\'indice de Rosner ?',
      options: [
        'Indice de Rosner (indice d\'anticoagulant circulant, test de mélange)',
        'Indice de Rosner (indice de thrombopénie induite)',
        'Indice de Rosner (indice de fibrinolyse)',
        'Indice de Rosner (indice de résistance à la protéine C activée)',
      ],
      correctIndex: 0,
      explanation:
          'Nom complet documenté : « Indice de Rosner (indice d\'anticoagulant circulant, test '
          'de mélange) ».',
    ),
    const QuizQuestion(
      id: 'hemostasis_49',
      type: QuizQuestionType.scientificSource,
      prompt:
          'Dans quelle revue scientifique et en quelle année l\'indice de Rosner a-t-il été '
          'publié, d\'après la référence documentée ?',
      options: [
        'Thrombosis and Haemostasis, 1987',
        'Journal of Thrombosis and Haemostasis, 2006',
        'Blood, 1987',
        'The Lancet, 1983',
      ],
      correctIndex: 0,
      explanation:
          'Rosner E, Pauzner R, Lusky A, Modan M, Many A. Thromb Haemost. 1987;57(2):144-147.',
    ),
    const QuizQuestion(
      id: 'hemostasis_50',
      type: QuizQuestionType.scientificSource,
      prompt:
          'En quelle année et dans quelle revue le score ISTH de CIVD (Taylor et al.) a-t-il été '
          'publié, d\'après la référence documentée ?',
      options: [
        'Thrombosis and Haemostasis, 2001',
        'Journal of Thrombosis and Haemostasis, 2006',
        'Thrombosis and Haemostasis, 1987',
        'Blood, 2001',
      ],
      correctIndex: 0,
      explanation:
          'Taylor FB Jr, Toh CH, Hoots WK, Wada H, Levi M. Thromb Haemost. 2001;86(5):1327-1330.',
    ),
    const QuizQuestion(
      id: 'hemostasis_51',
      type: QuizQuestionType.scientificSource,
      prompt:
          'Le score 4Ts (Lo et al., 2006) et le score ISTH de CIVD (Taylor et al., 2001) '
          'ont-ils été publiés dans la même revue, d\'après les références documentées ?',
      options: [
        'Non — le score 4Ts a été publié dans Journal of Thrombosis and Haemostasis, et le score '
            'ISTH-CIVD dans Thrombosis and Haemostasis',
        'Oui, les deux ont été publiés dans Thrombosis and Haemostasis',
        'Oui, les deux ont été publiés dans Journal of Thrombosis and Haemostasis',
        'Non, le score 4Ts a été publié dans Blood',
      ],
      correctIndex: 0,
      explanation:
          'Lo GK et al. J Thromb Haemost. 2006;4(4):759-765 (score 4Ts) ; Taylor FB Jr et al. '
          'Thromb Haemost. 2001;86(5):1327-1330 (score ISTH-CIVD) : deux revues distinctes.',
    ),
    const QuizQuestion(
      id: 'hemostasis_52',
      type: QuizQuestionType.scientificSource,
      prompt:
          'Quel auteur a proposé, en 1983, la méthode de calibration des thromboplastines pour '
          'l\'usage international à l\'origine du système INR/ISI ?',
      options: ['Kirkwood TB', 'Rosner E', 'Taylor FB Jr', 'Warkentin TE'],
      correctIndex: 0,
      explanation:
          'Kirkwood TB. Calibration of Clinical Thromboplastins for International Use. Thromb '
          'Haemost. 1983;49:238-244.',
    ),
    const QuizQuestion(
      id: 'hemostasis_53',
      type: QuizQuestionType.scientificSource,
      prompt:
          'Quel score porte, d\'après sa fiche technique, la version documentée « Lo et al. 2006 '
          '(Warkentin) » ?',
      options: [
        'Le score 4Ts (thrombopénie induite par l\'héparine)',
        'Le score ISTH de CIVD',
        'L\'indice de Rosner',
        'L\'INR',
      ],
      correctIndex: 0,
      explanation:
          'Version documentée du score 4Ts : « Lo et al. 2006 (Warkentin) ».',
    ),
    const QuizQuestion(
      id: 'hemostasis_54',
      type: QuizQuestionType.scientificSource,
      prompt:
          'Quel score porte la version documentée « ISTH 2001 (Taylor et al.) » dans sa fiche '
          'technique ?',
      options: [
        'Le score ISTH de CIVD',
        'Le score 4Ts',
        'L\'indice de Rosner',
        'Le ratio TCA patient/témoin',
      ],
      correctIndex: 0,
      explanation: 'Version documentée du score ISTH-CIVD : « ISTH 2001 (Taylor et al.) ».',
    ),
  ],
);
