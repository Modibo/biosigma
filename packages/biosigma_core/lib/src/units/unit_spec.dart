/// Définition affine d'une unité par rapport à l'unité canonique de son
/// analyte : `canonique = valeur × facteur + décalage`.
///
/// La quasi-totalité des conversions cliniques utilisées ici sont de
/// simples facteurs multiplicatifs (décalage = 0) ; l'HbA1c NGSP(%) ↔
/// IFCC(mmol/mol) est le seul cas avec un décalage non nul.
class UnitSpec {
  const UnitSpec(this.symbol, this.factorToCanonical, {this.offset = 0});

  final String symbol;
  final double factorToCanonical;
  final double offset;

  double toCanonical(double value) => value * factorToCanonical + offset;

  double fromCanonical(double canonicalValue) =>
      (canonicalValue - offset) / factorToCanonical;
}
