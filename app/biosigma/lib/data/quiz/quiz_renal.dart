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
  ],
);
