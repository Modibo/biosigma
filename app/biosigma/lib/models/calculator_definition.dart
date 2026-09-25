import 'package:biosigma_core/biosigma_core.dart';

import 'calculator_field.dart';

/// Lie une [FormulaMeta] du moteur de calcul pur à un formulaire déclaratif
/// et à la fonction de calcul réelle, pour l'écran calculateur générique.
///
/// C'est la seule couche « glue » entre l'UI et `biosigma_core` : chaque
/// calculateur du catalogue a une instance de cette classe. Le formulaire
/// (champs, unités, aide contextuelle) est entièrement décrit par
/// [fields] ; [compute] ne fait qu'extraire les valeurs saisies (par id de
/// champ) et appeler la fonction pure correspondante.
class CalculatorDefinition {
  const CalculatorDefinition({
    required this.meta,
    required this.fields,
    required this.compute,
  });

  final FormulaMeta meta;
  final List<CalculatorFieldSpec> fields;

  /// [values] est indexé par [CalculatorFieldSpec.id] ; chaque entrée est
  /// un [NumericEntry], un `bool`, ou la valeur d'un [EnumFieldOption]
  /// selon [CalculatorFieldSpec.kind]. Peut lever [CalculationInputException].
  final CalculationResult Function(Map<String, dynamic> values) compute;
}
