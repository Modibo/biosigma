import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

/// Icône associée à chaque catégorie clinique, utilisée dans les sections
/// repliables de l'accueil et des références pour un repérage visuel rapide
/// parmi les nombreux calculs du catalogue.
IconData categoryIcon(CalculatorCategory category) => switch (category) {
      CalculatorCategory.renal => Icons.water_drop_outlined,
      CalculatorCategory.metabolic => Icons.monitor_heart_outlined,
      CalculatorCategory.ionogram => Icons.science_outlined,
      CalculatorCategory.hemostasis => Icons.bloodtype_outlined,
      CalculatorCategory.hematology => Icons.biotech_outlined,
    };
