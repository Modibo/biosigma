/// Entrée d'historique local, entièrement anonyme : aucune identité de
/// patient n'est jamais demandée ni stockée. Facultatif (désactivé par
/// défaut) et effaçable intégralement à tout moment depuis les réglages.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.calculatorId,
    required this.calculatorName,
    required this.timestamp,
    required this.echoedInputs,
    required this.resultSummary,
  });

  final String id;
  final String calculatorId;
  final String calculatorName;
  final DateTime timestamp;

  /// Entrées telles qu'utilisées par le calcul (déjà anonymes par
  /// construction : aucun champ d'identité n'existe dans le moteur).
  final Map<String, String> echoedInputs;

  /// Libellés "Résultat : valeur unité" prêts à l'affichage.
  final List<String> resultSummary;

  Map<String, dynamic> toJson() => {
        'id': id,
        'calculatorId': calculatorId,
        'calculatorName': calculatorName,
        'timestamp': timestamp.toIso8601String(),
        'echoedInputs': echoedInputs,
        'resultSummary': resultSummary,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String,
        calculatorId: json['calculatorId'] as String,
        calculatorName: json['calculatorName'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        echoedInputs: Map<String, String>.from(json['echoedInputs'] as Map),
        resultSummary: List<String>.from(json['resultSummary'] as List),
      );
}
