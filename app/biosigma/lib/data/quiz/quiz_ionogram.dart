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
  ],
);
