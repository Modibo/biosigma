/// Grandeurs biologiques pour lesquelles BioSigma sait convertir des unités.
///
/// Chaque analyte a une unité canonique unique, utilisée en interne pour
/// tous les calculs : les conversions n'ont lieu qu'aux frontières
/// (saisie utilisateur → canonique, canonique → affichage). On ne convertit
/// jamais entre deux analytes différents (ex. impossible de convertir une
/// créatinine en cystatine C).
enum Analyte {
  creatinine,
  cystatinC,
  glucose,
  triglycerides,
  proteinuria,
  volume,
  duration,
  albumin,
  calcium,
  fibrinogen,
  insulin,
  hba1c,
  cholesterol,
}
