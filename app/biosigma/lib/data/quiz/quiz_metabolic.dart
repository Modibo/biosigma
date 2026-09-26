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
  ],
);
