import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_settings.dart';
import '../../state/app_state.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/lab_widgets.dart';

/// Quality : CV, biais, récupération, erreur totale, Sigma. L'ETa et le
/// coefficient k sont saisis ; aucun verdict d'interprétation n'est donné.
class QualityScreen extends StatefulWidget {
  const QualityScreen({super.key});

  @override
  State<QualityScreen> createState() => _QualityScreenState();
}

class _QualityScreenState extends State<QualityScreen> with LabFormMixin<QualityScreen> {
  String _valuesText = '';
  double? _mean, _sd, _target, _tea, _k;

  void _calculate(DecimalSeparator sep) {
    if (_valuesText.trim().isNotEmpty) {
      final list = parseNumberList(_valuesText, sep);
      if (list.any((v) => v == null)) {
        setState(() {
          errors = {'values': 'Valeur illisible : séparez-les par « ; » ou un retour à la ligne (la virgule est décimale).'};
          result = null;
        });
        return;
      }
      runCalc(() => calculateQuality(
          values: list.cast<double>(), target: _target, tea: _tea, k: _k));
    } else {
      runCalc(() => calculateQuality(mean: _mean, sd: _sd, target: _target, tea: _tea, k: _k));
    }
  }

  void _reset() => setState(() {
        _valuesText = '';
        _mean = _sd = _target = _tea = _k = null;
        clearResult();
        generation++;
      });

  @override
  Widget build(BuildContext context) {
    final sep = context.watch<AppState>().settings.decimalSeparator;
    return Scaffold(
      appBar: AppBar(title: const Text('Quality')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            Text(
              'L\'ETa (erreur totale admissible) et le coefficient k sont à saisir selon la source '
              'de votre laboratoire : BioSigma n\'en fournit aucun et ne donne aucune interprétation.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextFormField(
                key: ValueKey('values-$generation'),
                initialValue: _valuesText,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Valeurs mesurées (séparées par « ; » ou une ligne chacune)',
                  helperText: 'Ou laissez vide et saisissez la moyenne et l\'écart-type ci-dessous.',
                  errorText: errors['values'],
                  errorMaxLines: 3,
                ),
                onChanged: (v) => setState(() => _valuesText = v),
              ),
            ),
            numberField(id: 'mean', label: 'Moyenne (si pas de liste)', value: _mean,
                set: (v) => _mean = v, separator: sep),
            numberField(id: 'sd', label: 'Écart-type (si pas de liste)', value: _sd,
                set: (v) => _sd = v, separator: sep),
            numberField(id: 'target', label: 'Valeur cible — facultatif', value: _target,
                set: (v) => _target = v, separator: sep, help: 'Pour le biais et la récupération.'),
            numberField(id: 'tea', label: 'ETa (%) — facultatif', value: _tea,
                set: (v) => _tea = v, separator: sep, help: 'Pour la métrique Sigma (la cible est requise).'),
            numberField(id: 'k', label: 'Coefficient k — facultatif', value: _k,
                set: (v) => _k = v, separator: sep, help: 'Pour l\'erreur totale (la cible est requise).'),
            otherErrors({'values', 'mean', 'sd', 'target', 'tea', 'k'}),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                  onPressed: () => _calculate(sep),
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculer')),
              OutlinedButton.icon(
                  onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('Nouvelle saisie')),
            ]),
            if (result != null) ...[
              const SizedBox(height: 16),
              LabResultCard(result: result!, decimalSeparator: sep),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
