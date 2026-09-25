/// Sexe biologique requis par certaines équations (CKD-EPI, Schwartz,
/// CKD-EPI cystatine C). N'est jamais utilisé comme identité de patient :
/// c'est un paramètre d'équation saisi à chaque calcul, jamais stocké
/// nominativement.
enum Sex {
  male('Homme'),
  female('Femme');

  const Sex(this.label);
  final String label;
}
