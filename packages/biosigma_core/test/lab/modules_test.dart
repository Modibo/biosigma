// Valeurs attendues calculées à la main (masses molaires, pKa, géométries :
// saisies dans le test, jamais lues dans le code).
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void expectFieldError(void Function() body, String fieldId) {
  try {
    body();
    fail('une CalculationInputException était attendue');
  } on CalculationInputException catch (e) {
    expect(e.errors.map((x) => x.fieldId), contains(fieldId), reason: e.toString());
  }
}

ResultValue v(CalculationResult r, String start) =>
    r.values.firstWhere((x) => x.label.startsWith(start), orElse: () => fail('« $start » absent : ${r.values.map((x) => x.label)}'));

void main() {
  group('Prepare — masse à peser', () {
    test('concentration massique 9 g/L dans 500 mL → 4,5 g (aucune masse molaire requise)', () {
      final r = calculateSolutionPreparation(
          targetConcentration: 9, concentrationUnit: 'g/L', finalVolume: 500, volumeUnit: 'mL');
      expect(r.values.first.value, closeTo(4.5, 1e-12));
      expect(r.values.first.unit, 'g');
    });

    test('0,1 mol/L, M saisie 58,44 g/mol, 1 L → 5,844 g', () {
      final r = calculateSolutionPreparation(
          targetConcentration: 0.1, concentrationUnit: 'mol/L', finalVolume: 1, volumeUnit: 'L',
          molarMassGPerMol: 58.44);
      expect(r.values.first.value, closeTo(5.844, 1e-9));
    });

    test('pureté 99 % : 5,844 / 0,99 = 5,90303 g, et la masse pure est aussi donnée', () {
      final r = calculateSolutionPreparation(
          targetConcentration: 0.1, concentrationUnit: 'mol/L', finalVolume: 1, volumeUnit: 'L',
          molarMassGPerMol: 58.44, purityPercent: 99);
      expect(r.values.first.value, closeTo(5.844 / 0.99, 1e-9));
      expect(v(r, 'Masse de soluté pur').value, closeTo(5.844, 1e-9));
    });

    test('petites masses affichées en mg : 10 mmol/L, M 121,14, 100 mL → 121,14 mg', () {
      final r = calculateSolutionPreparation(
          targetConcentration: 10, concentrationUnit: 'mmol/L', finalVolume: 100, volumeUnit: 'mL',
          molarMassGPerMol: 121.14);
      expect(r.values.first.unit, 'mg');
      expect(r.values.first.value, closeTo(121.14, 1e-9));
    });

    test('refus : molaire sans masse molaire, valeurs nulles, unités fausses, pureté > 100', () {
      expectFieldError(
          () => calculateSolutionPreparation(
              targetConcentration: 1, concentrationUnit: 'mol/L', finalVolume: 1, volumeUnit: 'L'),
          'molarMass');
      expectFieldError(
          () => calculateSolutionPreparation(
              targetConcentration: 0, concentrationUnit: 'g/L', finalVolume: 1, volumeUnit: 'L'),
          'targetConcentration');
      expectFieldError(
          () => calculateSolutionPreparation(
              targetConcentration: 1, concentrationUnit: 'mg', finalVolume: 1, volumeUnit: 'L'),
          'targetConcentration');
      expectFieldError(
          () => calculateSolutionPreparation(
              targetConcentration: 1, concentrationUnit: 'g/L', finalVolume: 1, volumeUnit: 'g'),
          'finalVolume');
      expectFieldError(
          () => calculateSolutionPreparation(
              targetConcentration: 1, concentrationUnit: 'g/L', finalVolume: 1, volumeUnit: 'L',
              purityPercent: 101),
          'purity');
    });

    test('pureté absente : avertissement « 100 % supposé »', () {
      final r = calculateSolutionPreparation(
          targetConcentration: 1, concentrationUnit: 'g/L', finalVolume: 1, volumeUnit: 'L');
      expect(r.warnings.any((w) => w.message.contains('100 %')), isTrue);
    });
  });

  group('Prepare — pourcentage', () {
    test('0,9 % m/v dans 500 mL → 4,5 g', () {
      final r = calculatePercentSolution(percent: 0.9, kind: 'mv', finalVolume: 500, volumeUnit: 'mL');
      expect(r.values.single.value, closeTo(4.5, 1e-12));
      expect(r.values.single.unit, 'g');
    });

    test('70 % v/v dans 100 mL → 70 mL ; 0,5 % dans 100 mL → 500 µL', () {
      expect(calculatePercentSolution(percent: 70, kind: 'vv', finalVolume: 100, volumeUnit: 'mL').values.single.value,
          closeTo(70, 1e-12));
      final small = calculatePercentSolution(percent: 0.5, kind: 'vv', finalVolume: 100, volumeUnit: 'mL');
      expect(small.values.single.unit, 'µL');
      expect(small.values.single.value, closeTo(500, 1e-9));
    });

    test('refus : pourcentage hors ]0 ; 100], type inconnu', () {
      expectFieldError(() => calculatePercentSolution(percent: 0, kind: 'mv', finalVolume: 1, volumeUnit: 'L'), 'percent');
      expectFieldError(() => calculatePercentSolution(percent: 101, kind: 'mv', finalVolume: 1, volumeUnit: 'L'), 'percent');
      expectFieldError(() => calculatePercentSolution(percent: 1, kind: 'mm', finalVolume: 1, volumeUnit: 'L'), 'kind');
    });
  });

  group('Prepare — tampon', () {
    test('pH = pKa : rapport 1, 50 % de chaque forme', () {
      final r = calculateBuffer(
          targetPh: 7, pKa: 7, totalConcentration: 0.1, concentrationUnit: 'mol/L',
          finalVolume: 1, volumeUnit: 'L');
      expect(v(r, 'Rapport').value, closeTo(1, 1e-12));
      expect(v(r, 'Quantité de forme basique').value, closeTo(50, 1e-9)); // mmol
    });

    test('pH 7,4, pKa 7,2 : rapport 10^0,2 = 1,58489 ; 61,3137 mmol base et 38,6863 mmol acide (r/(1+r) = 1,58489/2,58489 = 0,61314)', () {
      final r = calculateBuffer(
          targetPh: 7.4, pKa: 7.2, totalConcentration: 0.1, concentrationUnit: 'mol/L',
          finalVolume: 1, volumeUnit: 'L');
      expect(v(r, 'Rapport').value, closeTo(1.5848932, 1e-6));
      expect(v(r, 'Quantité de forme basique').value, closeTo(61.3137, 1e-3));
      expect(v(r, 'Quantité de forme acide').value, closeTo(38.6863, 1e-3));
      expect(r.warnings.any((w) => w.message.contains('pH-mètre')), isTrue);
    });

    test('pH éloigné du pKa de plus d\'une unité : avertissement', () {
      final r = calculateBuffer(
          targetPh: 9, pKa: 7, totalConcentration: 1, concentrationUnit: 'mmol/L',
          finalVolume: 1, volumeUnit: 'L');
      expect(r.warnings.any((w) => w.message.contains('pouvoir tampon')), isTrue);
    });

    test('refus : pH hors 0-14, concentration non molaire, pKa absent', () {
      expectFieldError(
          () => calculateBuffer(targetPh: 15, pKa: 7, totalConcentration: 1, concentrationUnit: 'mol/L', finalVolume: 1, volumeUnit: 'L'),
          'targetPh');
      expectFieldError(
          () => calculateBuffer(targetPh: 7, pKa: 7, totalConcentration: 1, concentrationUnit: 'g/L', finalVolume: 1, volumeUnit: 'L'),
          'totalConcentration');
      expectFieldError(
          () => calculateBuffer(targetPh: 7, pKa: null, totalConcentration: 1, concentrationUnit: 'mol/L', finalVolume: 1, volumeUnit: 'L'),
          'pKa');
    });
  });

  group('Count', () {
    test('100 cellules, 1 mm² × 0,1 mm = 0,1 µL, sans dilution → 1000 cellules/µL = 1 G/L', () {
      final r = calculateCellCount(counted: 100, countedAreaMm2: 1, depthMm: 0.1, dilutionFactor: 1);
      expect(r.values[0].value, closeTo(1000, 1e-9));
      expect(r.values[1].value, closeTo(1, 1e-12));
      expect(r.values[2].value, closeTo(0.001, 1e-15));
      expect(r.warnings.first.message, contains('10.0 %')); // 100/√100
    });

    test('50 cellules, 4 mm² × 0,1 mm = 0,4 µL, dilution 10 → 1250 /µL = 1,25 G/L', () {
      final r = calculateCellCount(counted: 50, countedAreaMm2: 4, depthMm: 0.1, dilutionFactor: 10);
      expect(r.values[0].value, closeTo(1250, 1e-9));
      expect(r.values[1].value, closeTo(1.25, 1e-12));
    });

    test('zéro cellule : concentration 0 avec avertissement « limite de détection »', () {
      final r = calculateCellCount(counted: 0, countedAreaMm2: 1, depthMm: 0.1, dilutionFactor: 1);
      expect(r.warnings.any((w) => w.message.contains('limite de détection')), isTrue);
    });

    test('refus : nombre négatif, surface nulle, dilution < 1', () {
      expectFieldError(() => calculateCellCount(counted: -1, countedAreaMm2: 1, depthMm: 0.1, dilutionFactor: 1), 'counted');
      expectFieldError(() => calculateCellCount(counted: 1, countedAreaMm2: 0, depthMm: 0.1, dilutionFactor: 1), 'countedArea');
      expectFieldError(() => calculateCellCount(counted: 1, countedAreaMm2: 1, depthMm: 0.1, dilutionFactor: 0.5), 'dilution');
      expectFieldError(() => calculateCellCount(counted: null, countedAreaMm2: 1, depthMm: 0.1, dilutionFactor: 1), 'counted');
    });

    test('nombre total : 60 ×10⁶/mL × 2,5 mL = 150 ×10⁶', () {
      final r = calculateTotalCount(concentrationE6PerMl: 60, volumeMl: 2.5);
      expect(r.values.single.value, closeTo(150, 1e-12));
    });

    test('comptages en double : A 60, B 40 → moyenne 50, écart 20, écart relatif 40 %, sans seuil', () {
      final r = calculateDuplicateCounts(concentrationA: 60, concentrationB: 40, unit: '×10⁶/mL');
      expect(v(r, 'Moyenne').value, closeTo(50, 1e-12));
      expect(v(r, 'Écart A').value, closeTo(20, 1e-12));
      expect(v(r, 'Écart relatif').value, closeTo(40, 1e-9));
      expect(r.warnings.single.message, contains('n\'en applique aucun'));
    });

    test('formule : 60/30/6/3/1 sur 100 cellules ; leucocytes 8 G/L → neutrophiles 4,8 G/L', () {
      final r = calculateDifferential(
          counts: {'Neutrophiles': 60, 'Lymphocytes': 30, 'Monocytes': 6, 'Éosinophiles': 3, 'Basophiles': 1},
          wbcGL: 8);
      expect(v(r, 'Neutrophiles').value, closeTo(60, 1e-12));
      expect(v(r, 'Neutrophiles — valeur absolue').value, closeTo(4.8, 1e-12));
      expect(v(r, 'Basophiles — valeur absolue').value, closeTo(0.08, 1e-12));
    });

    test('érythroblastes 10/100 : leucocytes corrigés 8 × 100/110 = 7,2727 ; neutrophiles 4,3636', () {
      final r = calculateDifferential(counts: {'Neutrophiles': 60, 'Lymphocytes': 40}, wbcGL: 8, nrbcPer100Wbc: 10);
      expect(v(r, 'Neutrophiles — valeur absolue').value, closeTo(0.6 * 8 * 100 / 110, 1e-12));
    });

    test('sans leucocytes : pourcentages seulement ; total ≠ 100 normalisé', () {
      final r = calculateDifferential(counts: {'A': 30, 'B': 20});
      expect(r.values.length, 2);
      expect(v(r, 'A').value, closeTo(60, 1e-12));
    });

    test('refus : total nul, comptage négatif, leucocytes nuls', () {
      expectFieldError(() => calculateDifferential(counts: {'A': 0, 'B': 0}), 'counts');
      expectFieldError(() => calculateDifferential(counts: {'A': -1, 'B': 5}), 'A');
      expectFieldError(() => calculateDifferential(counts: {'A': 1}, wbcGL: 0), 'wbc');
    });
  });

  group('Microbiology', () {
    test('150 colonies, 10^-3, 0,1 mL → 1,5 × 10⁶ UFC/mL', () {
      final r = calculateCfu(plates: [const PlateCount(colonies: 150, dilutionExponent: 3, platedVolumeMl: 0.1)]);
      expect(r.values.first.value, closeTo(1.5e6, 1e-3));
    });

    test('intervalle saisi 30-300 : 120 et 150 retenues (moyenne 1,35 × 10⁶), 5 colonies exclue', () {
      final r = calculateCfu(
        plates: const [
          PlateCount(colonies: 120, dilutionExponent: 3, platedVolumeMl: 0.1),
          PlateCount(colonies: 150, dilutionExponent: 3, platedVolumeMl: 0.1),
          PlateCount(colonies: 5, dilutionExponent: 4, platedVolumeMl: 0.1),
        ],
        countMin: 30,
        countMax: 300,
      );
      expect(v(r, 'Moyenne').value, closeTo(1.35e6, 1e-3));
      expect(v(r, 'log10').value, closeTo(6.130334, 1e-6));
      expect(r.values.any((x) => x.label.contains('hors intervalle')), isTrue);
      expect(r.isComplete, isTrue);
    });

    test('aucune colonie : « < limite de détection », jamais zéro', () {
      final r = calculateCfu(
        plates: const [PlateCount(colonies: 0, dilutionExponent: 2, platedVolumeMl: 0.1)],
      );
      expect(r.values.first.value, isNull);
      expect(r.warnings.any((w) => w.message.contains('limite de détection')), isTrue);
      expect(r.isComplete, isFalse);
      expect(r.hasBlockingWarning, isTrue);
    });

    test('toutes les boîtes hors intervalle : aucun résultat, avertissement bloquant', () {
      final r = calculateCfu(
        plates: const [PlateCount(colonies: 500, dilutionExponent: 3, platedVolumeMl: 0.1)],
        countMin: 30,
        countMax: 300,
      );
      expect(r.isComplete, isFalse);
      expect(r.hasBlockingWarning, isTrue);
      expect(r.values.any((x) => x.label.startsWith('Moyenne')), isFalse);
    });

    test('sans intervalle saisi : avertissement', () {
      final r = calculateCfu(plates: const [PlateCount(colonies: 10, dilutionExponent: 0, platedVolumeMl: 1)]);
      expect(r.warnings.any((w) => w.message.contains('Intervalle de dénombrement non précisé')), isTrue);
    });

    test('refus : aucune boîte, exposant 13, volume nul, bornes inversées', () {
      expectFieldError(() => calculateCfu(plates: const []), 'plates');
      expectFieldError(
          () => calculateCfu(plates: const [PlateCount(colonies: 1, dilutionExponent: 13, platedVolumeMl: 1)]), 'exponent0');
      expectFieldError(
          () => calculateCfu(plates: const [PlateCount(colonies: 1, dilutionExponent: 1, platedVolumeMl: 0)]), 'volume0');
      expectFieldError(
          () => calculateCfu(
              plates: const [PlateCount(colonies: 1, dilutionExponent: 1, platedVolumeMl: 1)],
              countMin: 300,
              countMax: 30),
          'countMax');
    });

    test('aucune équivalence McFarland ↔ UFC n\'est proposée', () {
      expect(cfuMeta.limitations.join(' '), contains('McFarland'));
    });
  });

  group('Quality', () {
    final series = [98.0, 100.0, 102.0, 100.0, 100.0]; // moyenne 100, s = √2

    test('série : moyenne 100, écart-type 1,41421, CV 1,41421 %', () {
      final r = calculateQuality(values: series);
      expect(v(r, 'Moyenne').value, closeTo(100, 1e-12));
      expect(v(r, 'Écart-type').value, closeTo(1.4142136, 1e-6));
      expect(v(r, 'CV').value, closeTo(1.4142136, 1e-6));
    });

    test('cible 98 : biais 2,0408 %, récupération 102,0408 %', () {
      final r = calculateQuality(values: series, target: 98);
      expect(v(r, 'Biais').value, closeTo(2.0408163, 1e-6));
      expect(v(r, 'Récupération').value, closeTo(102.0408163, 1e-6));
    });

    test('ETa 10 % saisie : Sigma = (10 − 2,0408) / 1,41421 = 5,628', () {
      final r = calculateQuality(values: series, target: 98, tea: 10);
      expect(v(r, 'Sigma').value, closeTo(5.628, 1e-3));
      expect(r.warnings.any((w) => w.message.contains('aucune interprétation')), isTrue);
    });

    test('k = 2 saisi : erreur totale = 2,0408 + 2 × 1,41421 = 4,86924 %', () {
      final r = calculateQuality(values: series, target: 98, k: 2);
      expect(v(r, 'Erreur totale').value, closeTo(4.8692435, 1e-6));
    });

    test('moyenne et écart-type saisis : CV = 5 %', () {
      final r = calculateQuality(mean: 100, sd: 5);
      expect(v(r, 'CV').value, closeTo(5, 1e-12));
    });

    test('Sigma ou erreur totale sans cible : résultat non calculé et incomplet', () {
      final r = calculateQuality(values: series, tea: 10);
      expect(r.values.last.value, isNull);
      expect(r.isComplete, isFalse);
    });

    test('aucun verdict « acceptable / excellent » dans les messages', () {
      final r = calculateQuality(values: series, target: 98, tea: 10);
      final text = r.warnings.map((w) => w.message.toLowerCase()).join(' ');
      for (final verdict in ['excellent', 'acceptable', 'world class', 'inacceptable']) {
        expect(text.contains(verdict), isFalse, reason: verdict);
      }
    });

    test('refus : une seule valeur, moyenne nulle, cible ≤ 0, valeur non finie, ETa ≤ 0', () {
      expectFieldError(() => calculateQuality(values: [1]), 'values');
      expectFieldError(() => calculateQuality(mean: 0, sd: 1), 'mean');
      expectFieldError(() => calculateQuality(values: series, target: 0), 'target');
      expectFieldError(() => calculateQuality(values: [1, double.nan]), 'values');
      expectFieldError(() => calculateQuality(values: series, target: 98, tea: 0), 'tea');
      expectFieldError(() => calculateQuality(), 'mean');
    });
  });

  group('Smart Solver — propose, ne calcule pas', () {
    test('conversion', () {
      final s = analyzeLabQuestion('Je veux convertir 5 mg/dL de créatinine en µmol/L');
      expect(s.candidates.first, LabModule.convert);
      expect(s.quantities.map((q) => q.raw), contains('5 mg/dL'));
    });

    test('dilution : repère les deux volumes', () {
      final s = analyzeLabQuestion('Diluer 100 µL de sérum dans 900 µL de diluant');
      expect(s.candidates.first, LabModule.dilute);
      expect(s.quantities.map((q) => q.raw), containsAll(['100 µL', '900 µL']));
    });

    test('préparation avec pourcentage', () {
      final s = analyzeLabQuestion('préparer 500 mL de NaCl 0,9 %');
      expect(s.candidates.first, LabModule.prepare);
      expect(s.quantities.map((q) => q.raw), containsAll(['500 mL', '0,9 %']));
    });

    test('microbiologie, numération, qualité', () {
      expect(analyzeLabQuestion('120 colonies sur gélose, UFC/mL ?').candidates.first, LabModule.microbiology);
      expect(analyzeLabQuestion('numération en chambre de Neubauer').candidates.first, LabModule.count);
      expect(analyzeLabQuestion('CV et biais de ma méthode, métrique sigma').candidates.first, LabModule.quality);
    });

    test('phrase non reconnue : aucune proposition', () {
      final s = analyzeLabQuestion('bonjour');
      expect(s.recognized, isFalse);
      expect(s.candidates, isEmpty);
    });

    test('plusieurs modules aussi probables : ambigu, l\'utilisateur choisit', () {
      final s = analyzeLabQuestion('diluer puis préparer');
      expect(s.ambiguous, isTrue);
      expect(s.candidates, containsAll([LabModule.dilute, LabModule.prepare]));
    });

    test('un nombre sans unité reconnue n\'est pas une quantité', () {
      expect(analyzeLabQuestion('dilution 1/10 avec 3 fois').quantities, isEmpty);
    });
  });
}
