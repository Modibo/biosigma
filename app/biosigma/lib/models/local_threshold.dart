/// Un seuil interprétatif défini localement par le laboratoire pour un
/// calcul donné (ex. HOMA-IR, TyG, indice de Rosner). BioSigma ne fournit
/// jamais de seuil clinique universel codé en dur : quand un seuil est
/// affiché, il provient soit de cette structure (saisie et validée
/// localement), soit d'un exemple de littérature explicitement marqué
/// comme tel et non appliqué automatiquement.
class LocalThreshold {
  const LocalThreshold({
    required this.calculatorId,
    required this.label,
    required this.value,
    required this.unit,
    required this.method,
    required this.validatedOn,
    required this.validatedBy,
  });

  final String calculatorId;

  /// Ex. "Seuil d'insulinorésistance".
  final String label;

  final double value;
  final String unit;

  /// Méthode/réactif concerné (ex. "Dosage insuline électrochimiluminescence, Roche Cobas").
  final String method;

  final DateTime validatedOn;

  /// Nom ou fonction du biologiste responsable ayant validé ce seuil.
  final String validatedBy;

  Map<String, dynamic> toJson() => {
        'calculatorId': calculatorId,
        'label': label,
        'value': value,
        'unit': unit,
        'method': method,
        'validatedOn': validatedOn.toIso8601String(),
        'validatedBy': validatedBy,
      };

  factory LocalThreshold.fromJson(Map<String, dynamic> json) => LocalThreshold(
        calculatorId: json['calculatorId'] as String,
        label: json['label'] as String,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        method: json['method'] as String,
        validatedOn: DateTime.parse(json['validatedOn'] as String),
        validatedBy: json['validatedBy'] as String,
      );
}
