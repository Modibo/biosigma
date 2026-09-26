import '../models/calculator_definition.dart';
import 'calculator_registry_afib_risk.dart';
import 'calculator_registry_caprini.dart';
import 'calculator_registry_cardiovascular_risk.dart';
import 'calculator_registry_hematology.dart';
import 'calculator_registry_hemostasis.dart';
import 'calculator_registry_hemostasis_additions.dart';
import 'calculator_registry_hospitalized_vte_risk.dart';
import 'calculator_registry_hepatic_acidbase.dart';
import 'calculator_registry_ionogram.dart';
import 'calculator_registry_metabolic.dart';
import 'calculator_registry_metabolic_additions.dart';
import 'calculator_registry_renal.dart';

/// Registre complet des calculateurs pilotés par l'écran générique
/// [CalculatorScreen] (n'inclut pas les scores guidés ISTH-CIVD et 4Ts,
/// qui ont leurs propres écrans dédiés — voir `screens/isth_dic_screen.dart`
/// et `screens/four_ts_screen.dart`, référencés directement via leur
/// [FormulaMeta] dans le catalogue de `biosigma_core`).
final List<CalculatorDefinition> allCalculators = [
  ...renalCalculators,
  ...metabolicCalculators,
  ...metabolicAdditionsCalculators,
  ...cardiovascularRiskCalculators,
  ...ionogramCalculators,
  ...hepaticAcidBaseCalculators,
  ...hemostasisCalculators,
  ...hemostasisAdditionsCalculators,
  ...afibRiskCalculators,
  ...hospitalizedVteRiskCalculators,
  ...capriniCalculators,
  ...hematologyCalculators,
];

CalculatorDefinition? findCalculatorDefinition(String id) {
  for (final def in allCalculators) {
    if (def.meta.id == id) return def;
  }
  return null;
}
