import 'package:flutter/material.dart';

import '../data/calculator_registry.dart';
import 'calculator_screen.dart';
import 'ckd_epi_panel_screen.dart';
import 'four_ts_screen.dart';
import 'isth_dic_screen.dart';

const _guidedScoreIds = {'isth_dic_score', 'four_ts_score'};
const _ckdEpiIds = {
  'ckd_epi_creatinine_2021',
  'ckd_epi_cystatin_c_2012',
  'ckd_epi_creatinine_cystatin_c_2021',
};

/// Ouvre l'écran adapté à un calculateur donné : écran générique pour la
/// majorité, écrans dédiés pour les scores guidés (ISTH-CIVD, 4Ts). Les
/// trois équations CKD-EPI restent aussi accessibles individuellement via
/// l'écran générique (recherche, favoris) — le panel composite a sa
/// propre entrée dans l'accueil.
void openCalculator(BuildContext context, String calculatorId) {
  if (_guidedScoreIds.contains(calculatorId)) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => calculatorId == 'isth_dic_score' ? const IsthDicScreen() : const FourTsScreen(),
    ));
    return;
  }
  final definition = findCalculatorDefinition(calculatorId);
  if (definition == null) return;
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => CalculatorScreen(definition: definition),
  ));
}

void openCkdEpiPanel(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CkdEpiPanelScreen()));
}

bool isCkdEpiIndividualId(String id) => _ckdEpiIds.contains(id);
