// Pipettes simulées (jeu de test), saisies dans le test : aucune plage
// n'est embarquée dans le code (T-PIP-001, T-PIP-002).
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

final now = DateTime.utc(2026, 10, 4);

// Pipette de test : fiche 1–10 µL, recommandé à partir de 2 µL.
Pipette p10({DateTime? verifiedOn, int? days}) => Pipette(
    name: 'P10 (test)', minUl: 1, maxUl: 10, recommendedMinUl: 2, verifiedOn: verifiedOn, verificationValidDays: days);
const p20 = Pipette(name: 'P20 (test)', minUl: 2, maxUl: 20, recommendedMinUl: 4);
const p100 = Pipette(name: 'P100 (test)', minUl: 10, maxUl: 100, recommendedMinUl: 20);
const p200 = Pipette(name: 'P200 (test)', minUl: 20, maxUl: 200, recommendedMinUl: 40);
const p1000 = Pipette(name: 'P1000 (test)', minUl: 100, maxUl: 1000, recommendedMinUl: 200);
final all = [p10(), p20, p100, p200, p1000];

void main() {
  group('T-PIP-001 — 0,7 µL', () {
    test('aucune pipette du jeu de test ne convient : volume non pipetable', () {
      expect(suggestPipettes(0.7, all, now: now), isEmpty);
      for (final p in all) {
        expect(checkPipetability(0.7, p, now: now).fit, PipetteFit.impossible, reason: p.name);
      }
    });
  });

  group('T-PIP-002 — classes aux seuils (P10 : 1 / 2 / 10 µL)', () {
    test('frontières', () {
      PipetteFit fit(double v) => checkPipetability(v, p10(), now: now).fit;
      expect(fit(0.999), PipetteFit.impossible);
      expect(fit(1), PipetteFit.possible); // minimum de la fiche inclus
      expect(fit(1.999), PipetteFit.possible);
      expect(fit(2), PipetteFit.recommended); // seuil recommandé inclus
      expect(fit(10), PipetteFit.recommended); // maximum inclus
      expect(fit(10.001), PipetteFit.impossible);
    });

    test('validé seulement si la vérification est à jour', () {
      final current = p10(verifiedOn: DateTime.utc(2026, 9, 1), days: 365);
      expect(checkPipetability(5, current, now: now).fit, PipetteFit.validated);

      final expired = p10(verifiedOn: DateTime.utc(2025, 1, 1), days: 365);
      final c = checkPipetability(5, expired, now: now);
      expect(c.fit, PipetteFit.recommended);
      expect(c.notes.single, contains('périmée'));

      final unknown = checkPipetability(5, p10(), now: now);
      expect(unknown.fit, PipetteFit.recommended);
      expect(unknown.notes.single, contains('non renseignée'));
    });

    test('dernier jour de validité inclus, lendemain périmé', () {
      final base = DateTime.utc(2026, 1, 1);
      final p = p10(verifiedOn: base, days: 10);
      expect(p.verificationCurrent(DateTime.utc(2026, 1, 11)), isTrue);
      expect(p.verificationCurrent(DateTime.utc(2026, 1, 12)), isFalse);
    });

    test('sans seuil recommandé : toute la plage de la fiche est « recommandée »', () {
      const p = Pipette(name: 'x', minUl: 5, maxUl: 50);
      expect(checkPipetability(5, p, now: now).fit, PipetteFit.recommended);
    });

    test('volumes non valides', () {
      expect(checkPipetability(0, p20, now: now).fit, PipetteFit.impossible);
      expect(checkPipetability(-1, p20, now: now).fit, PipetteFit.impossible);
      expect(checkPipetability(double.nan, p20, now: now).fit, PipetteFit.impossible);
    });
  });

  group('suggestions', () {
    test('50 µL : P100 (recommandé) et P200 (recommandé) ; la plus petite plage d\'abord', () {
      final s = suggestPipettes(50, all, now: now);
      expect(s.map((c) => c.pipette.name), ['P100 (test)', 'P200 (test)']);
      expect(s.every((c) => c.fit == PipetteFit.recommended), isTrue);
    });

    test('la meilleure classe passe avant la plage : 30 µL — P100 recommandé avant P200 « possible »', () {
      final s = suggestPipettes(30, all, now: now);
      expect(s.first.pipette.name, 'P100 (test)');
      expect(s.first.fit, PipetteFit.recommended);
      expect(s.last.pipette.name, 'P200 (test)');
      expect(s.last.fit, PipetteFit.possible);
    });

    test('une pipette validée passe avant une recommandée', () {
      final validated = p10(verifiedOn: DateTime.utc(2026, 9, 1), days: 365);
      const other = Pipette(name: 'P20b', minUl: 2, maxUl: 20, recommendedMinUl: 4);
      final s = suggestPipettes(6, [other, validated], now: now);
      expect(s.first.pipette.name, 'P10 (test)');
      expect(s.first.fit, PipetteFit.validated);
    });

    test('aucune pipette enregistrée : liste vide', () {
      expect(suggestPipettes(10, const [], now: now), isEmpty);
    });
  });

  test('sérialisation JSON aller-retour', () {
    final p = p10(verifiedOn: DateTime.utc(2026, 9, 1), days: 180);
    final back = Pipette.fromJson(p.toJson());
    expect(back.name, p.name);
    expect(back.minUl, 1);
    expect(back.maxUl, 10);
    expect(back.recommendedMinUl, 2);
    expect(back.verifiedOn, p.verifiedOn);
    expect(back.verificationValidDays, 180);
    final minimal = Pipette.fromJson(const Pipette(name: 'm', minUl: 1, maxUl: 2).toJson());
    expect(minimal.verifiedOn, isNull);
  });
}
