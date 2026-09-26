import 'package:biosigma_core/src/calculators/hemostasis/lupus_and_sepsis_coagulopathy.dart';
import 'package:biosigma_core/src/models/errors.dart';
import 'package:test/test.dart';

void main() {
  group('calculateDrvvtNormalizedRatio', () {
    test('patient dépistage=45 s, normal dépistage=35 s, patient '
        'confirmation=38 s, normal confirmation=33 s', () {
      // Calcul indépendant :
      // ratio dépistage = 45/35 = 9/7 = 1.2857142857142858
      // ratio confirmation = 38/33 = 1.1515151515151516
      // ratio normalisé = (9/7)/(38/33) = 297/266 = 1.1165413533834586
      // % correction = (31/231)/(9/7)*100 = 31/297*100 = 10.437710437710438
      final result = calculateDrvvtNormalizedRatio(
        patientScreenSeconds: 45,
        normalScreenSeconds: 35,
        patientConfirmSeconds: 38,
        normalConfirmSeconds: 33,
      );
      expect(result.values[0].value, closeTo(1.2857142857142858, 1e-9));
      expect(result.values[1].value, closeTo(1.1515151515151516, 1e-9));
      expect(result.values[2].value, closeTo(1.1165413533834586, 1e-9));
      expect(result.values[3].value, closeTo(10.437710437710438, 1e-9));
    });

    test('patient dépistage=50 s, normal dépistage=30 s, patient '
        'confirmation=40 s, normal confirmation=32 s (nombres ronds)', () {
      // Calcul indépendant :
      // ratio dépistage = 50/30 = 5/3 = 1.6666666666666667
      // ratio confirmation = 40/32 = 5/4 = 1.25
      // ratio normalisé = (5/3)/(5/4) = 4/3 = 1.3333333333333333
      // % correction = (5/12)/(5/3)*100 = 25.0
      final result = calculateDrvvtNormalizedRatio(
        patientScreenSeconds: 50,
        normalScreenSeconds: 30,
        patientConfirmSeconds: 40,
        normalConfirmSeconds: 32,
      );
      expect(result.values[0].value, closeTo(1.6666666666666667, 1e-9));
      expect(result.values[1].value, closeTo(1.25, 1e-9));
      expect(result.values[2].value, closeTo(1.3333333333333333, 1e-9));
      expect(result.values[3].value, closeTo(25.0, 1e-9));
    });

    test('temps non positif -> CalculationInputException', () {
      expect(
        () => calculateDrvvtNormalizedRatio(
          patientScreenSeconds: 0,
          normalScreenSeconds: 35,
          patientConfirmSeconds: 38,
          normalConfirmSeconds: 33,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('calculateSicScore', () {
    test('bornes basses : plaquettes=150, INR=1.2, SOFA=0 -> total=0', () {
      final result = calculateSicScore(
        plateletCountGL: 150,
        inr: 1.2,
        sofaRespiratoryCardiovascularSubscore: 0,
      );
      expect(result.values.single.value, closeTo(0, 1e-9));
      expect(result.echoedInputs['Plaquettes'], contains('0 points'));
      expect(result.echoedInputs['INR'], contains('0 points'));
    });

    test('bornes intermédiaires : plaquettes=100, INR=1.4, SOFA=1 -> total=3', () {
      final result = calculateSicScore(
        plateletCountGL: 100,
        inr: 1.4,
        sofaRespiratoryCardiovascularSubscore: 1,
      );
      expect(result.values.single.value, closeTo(3, 1e-9));
    });

    test('bornes hautes : plaquettes=90, INR=1.5, SOFA=2 -> total=6', () {
      final result = calculateSicScore(
        plateletCountGL: 90,
        inr: 1.5,
        sofaRespiratoryCardiovascularSubscore: 2,
      );
      expect(result.values.single.value, closeTo(6, 1e-9));
      expect(result.echoedInputs['Plaquettes'], contains('2 points'));
      expect(result.echoedInputs['INR'], contains('2 points'));
      expect(
        result.echoedInputs['Sous-score SOFA respiratoire + cardiovasculaire'],
        contains('2 points'),
      );
    });

    test('sous-score SOFA hors plage (5) -> CalculationInputException', () {
      expect(
        () => calculateSicScore(
          plateletCountGL: 90,
          inr: 1.5,
          sofaRespiratoryCardiovascularSubscore: 5,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });
}
