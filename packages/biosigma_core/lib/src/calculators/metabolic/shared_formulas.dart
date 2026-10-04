import 'dart:math' as math;

// Formules cardiométaboliques utilisées par plusieurs calculs (backlog P3-03,
// duplication A-18). Une seule définition : une modification se répercute sur
// tous les calculs qui s'en servent, au lieu de diverger en silence.

/// Indice TyG = ln[(triglycérides mg/dL × glycémie mg/dL) / 2] (convention de
/// Simental-Mendía). Utilisé par `calculateTyg` et `calculateTygBmi`.
double tygIndexFromMgDl(double triglyceridesMgDl, double glucoseMgDl) =>
    math.log((triglyceridesMgDl * glucoseMgDl) / 2);

/// Rapport cholestérol total / HDL-cholestérol, les deux en mmol/L. Utilisé
/// par `calculateCtHdlRatio` et par le panel lipidique.
double totalToHdlCholesterolRatio(double totalMmolL, double hdlMmolL) =>
    totalMmolL / hdlMmolL;
