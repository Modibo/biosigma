import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/number_format_service.dart';

/// Affichage d'une stratégie de dilution : une carte par étape, avec le
/// prélèvement, le diluant, les pipettes à utiliser et leur classe.
class DilutionPlanView extends StatelessWidget {
  const DilutionPlanView({super.key, required this.plan, required this.separator, this.title});

  final DilutionPlan plan;
  final DecimalSeparator separator;
  final String? title;

  String _vol(double v) {
    final decimals = v >= 100 ? 0 : (v >= 10 ? 1 : 2);
    return '${NumberFormatService.format(v, separator, precision: decimals)} µL';
  }

  String _factor(double f) =>
      (f - f.roundToDouble()).abs() < 1e-9 ? f.toStringAsFixed(0) : NumberFormatService.format(f, separator, precision: 2);

  String _pipette(PlanOperation o) {
    final b = o.best;
    if (b == null) return 'aucune pipette';
    return '${b.pipette.name} (${b.fit.label})';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(title!, style: theme.textTheme.titleSmall),
          ),
        for (final s in plan.steps)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Étape ${s.index} — dilution 1/${_factor(s.factor)} (cumulée 1/${_factor(s.cumulativeFactor)})',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  '• Prélever ${_vol(s.transfer.volumeUl)} '
                  '${s.index == 1 ? 'de la solution mère' : 'du tube ${s.index - 1}'} '
                  'avec ${_pipette(s.transfer)}.',
                ),
                Text('• Ajouter ${_vol(s.diluent.volumeUl)} de diluant avec ${_pipette(s.diluent)}.'),
                Text('• Mélanger. Volume du tube ${s.index} : ${_vol(s.tubeVolumeUl)}.',
                    style: theme.textTheme.bodySmall),
              ]),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Facteur total 1/${_factor(plan.steps.fold<double>(1, (a, s) => a * s.factor))} · '
            'diluant total ${_vol(plan.totalDiluentUl)}.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// Stratégies alternatives et stratégies écartées (avec les raisons).
class DilutionPlanDetails extends StatelessWidget {
  const DilutionPlanDetails({super.key, required this.result, required this.separator});

  final DilutionPlanResult result;
  final DecimalSeparator separator;

  @override
  Widget build(BuildContext context) {
    final alternatives = result.plans.length > 1 ? result.plans.sublist(1) : const <DilutionPlan>[];
    return Column(children: [
      if (alternatives.isNotEmpty)
        Card(
          child: ExpansionTile(
            title: Text('Autres stratégies réalisables (${alternatives.length})'),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: [
              for (var i = 0; i < alternatives.length; i++)
                DilutionPlanView(
                  plan: alternatives[i],
                  separator: separator,
                  title:
                      'Variante ${i + 2} — ${alternatives[i].stepCount} étape${alternatives[i].stepCount > 1 ? 's' : ''}',
                ),
            ],
          ),
        ),
      if (result.rejected.isNotEmpty)
        Card(
          child: ExpansionTile(
            initiallyExpanded: result.plans.isEmpty,
            title: Text('Stratégies écartées et pourquoi (${result.rejected.length})'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final r in result.rejected) ...[
                Text(r.description, style: Theme.of(context).textTheme.labelLarge),
                for (final reason in r.reasons) Text('• $reason'),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
    ]);
  }
}
