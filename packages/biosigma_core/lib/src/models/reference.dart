/// Une source scientifique primaire (publication, organisme officiel).
///
/// Consultable hors connexion : le texte de la citation est embarqué dans
/// l'application, aucun accès réseau n'est nécessaire pour l'afficher.
class Reference {
  const Reference({required this.citation, this.note});

  /// Citation complète (auteurs, revue, année, volume, pages).
  final String citation;

  /// Précision optionnelle (ex. "équation 2021, sans coefficient racial").
  final String? note;

  @override
  String toString() => note == null ? citation : '$citation ($note)';
}
