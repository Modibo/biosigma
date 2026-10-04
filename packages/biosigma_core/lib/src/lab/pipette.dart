/// Pipette de l'utilisateur, décrite à partir de SA fiche et de SA
/// vérification (backlog P2-01, règle `PIP_CHECK_001`). Aucune pipette ni
/// plage n'est embarquée : tout seuil vient de la saisie de l'utilisateur.
class Pipette {
  const Pipette({
    required this.name,
    required this.minUl,
    required this.maxUl,
    this.recommendedMinUl,
    this.verifiedOn,
    this.verificationValidDays,
  });

  /// Libellé libre (modèle, numéro d'inventaire).
  final String name;

  /// Plus petit volume que la fiche du fabricant autorise (µL).
  final double minUl;

  /// Volume nominal maximal (µL).
  final double maxUl;

  /// Volume minimal à partir duquel le laboratoire juge l'emploi
  /// « recommandé » (µL) ; en dessous, entre [minUl] et ce seuil : « possible ».
  /// Absent : tout volume de [minUl] à [maxUl] est « recommandé ».
  final double? recommendedMinUl;

  /// Date de la dernière vérification (métrologique) saisie par l'utilisateur.
  final DateTime? verifiedOn;

  /// Durée de validité de la vérification (jours), fixée par le laboratoire.
  final int? verificationValidDays;

  /// Vérification connue ET non périmée à la date [now].
  bool verificationCurrent(DateTime now) {
    if (verifiedOn == null || verificationValidDays == null) return false;
    return !now.isAfter(verifiedOn!.add(Duration(days: verificationValidDays!)));
  }

  /// Vérification renseignée mais périmée.
  bool verificationExpired(DateTime now) =>
      verifiedOn != null && verificationValidDays != null && !verificationCurrent(now);

  Map<String, dynamic> toJson() => {
        'name': name,
        'minUl': minUl,
        'maxUl': maxUl,
        'recommendedMinUl': recommendedMinUl,
        'verifiedOn': verifiedOn?.toIso8601String(),
        'verificationValidDays': verificationValidDays,
      };

  factory Pipette.fromJson(Map<String, dynamic> json) => Pipette(
        name: json['name'] as String,
        minUl: (json['minUl'] as num).toDouble(),
        maxUl: (json['maxUl'] as num).toDouble(),
        recommendedMinUl: (json['recommendedMinUl'] as num?)?.toDouble(),
        verifiedOn: json['verifiedOn'] == null ? null : DateTime.parse(json['verifiedOn'] as String),
        verificationValidDays: json['verificationValidDays'] as int?,
      );
}

/// Classe de pipetabilité d'un volume pour une pipette donnée.
enum PipetteFit {
  /// Hors de la plage de la fiche : ne pas utiliser cette pipette.
  impossible('impossible'),

  /// Dans la plage de la fiche mais sous le seuil « recommandé » du laboratoire.
  possible('possible (déconseillé)'),

  /// Dans la plage recommandée par le laboratoire.
  recommended('recommandé'),

  /// Recommandé ET vérification de la pipette à jour.
  validated('validé');

  const PipetteFit(this.label);
  final String label;
}

class PipetteCheck {
  const PipetteCheck({required this.pipette, required this.fit, required this.notes});
  final Pipette pipette;
  final PipetteFit fit;
  final List<String> notes;
  bool get usable => fit != PipetteFit.impossible;
}

/// Classe un volume (µL) pour une pipette. `PIP_CHECK_001`.
PipetteCheck checkPipetability(double volumeUl, Pipette pipette, {required DateTime now}) {
  final notes = <String>[];
  if (!volumeUl.isFinite || volumeUl <= 0) {
    return PipetteCheck(
        pipette: pipette, fit: PipetteFit.impossible, notes: const ['Volume non valide.']);
  }
  if (volumeUl > pipette.maxUl) {
    return PipetteCheck(
        pipette: pipette,
        fit: PipetteFit.impossible,
        notes: ['Volume supérieur au volume nominal (${pipette.maxUl} µL).']);
  }
  if (volumeUl < pipette.minUl) {
    return PipetteCheck(
        pipette: pipette,
        fit: PipetteFit.impossible,
        notes: ['Volume inférieur au minimum de la fiche (${pipette.minUl} µL).']);
  }
  final recommendedMin = pipette.recommendedMinUl ?? pipette.minUl;
  if (volumeUl < recommendedMin) {
    return PipetteCheck(
        pipette: pipette,
        fit: PipetteFit.possible,
        notes: ['Sous le seuil recommandé par votre laboratoire ($recommendedMin µL).']);
  }
  if (pipette.verificationExpired(now)) {
    notes.add('Vérification de la pipette périmée : refaire la vérification.');
  } else if (pipette.verifiedOn == null || pipette.verificationValidDays == null) {
    notes.add('Vérification de la pipette non renseignée.');
  }
  final validated = pipette.verificationCurrent(now);
  return PipetteCheck(
      pipette: pipette,
      fit: validated ? PipetteFit.validated : PipetteFit.recommended,
      notes: notes);
}

/// Pipettes utilisables pour [volumeUl], de la meilleure classe à la moins
/// bonne, puis de la plus petite plage à la plus grande (plus précis).
/// Liste vide : volume non pipetable directement avec ces pipettes.
List<PipetteCheck> suggestPipettes(double volumeUl, List<Pipette> pipettes, {required DateTime now}) {
  final checks = [for (final p in pipettes) checkPipetability(volumeUl, p, now: now)]
      .where((c) => c.usable)
      .toList();
  checks.sort((a, b) {
    final byFit = b.fit.index.compareTo(a.fit.index);
    return byFit != 0 ? byFit : a.pipette.maxUl.compareTo(b.pipette.maxUl);
  });
  return checks;
}
