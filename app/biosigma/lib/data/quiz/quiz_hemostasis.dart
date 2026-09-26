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
  ],
);
