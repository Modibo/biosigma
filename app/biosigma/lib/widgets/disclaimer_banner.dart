import 'package:flutter/material.dart';

/// Rappel permanent : BioSigma est un outil d'aide au calcul, jamais un
/// diagnostic. Affiché sur chaque écran de calcul, conformément au
/// cahier des charges.
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: theme.colorScheme.primaryContainer,
      child: Semantics(
        liveRegion: true,
        child: Text(
          "Outil d'aide au calcul : résultat à confronter aux données analytiques et "
          'cliniques, et à valider par un professionnel compétent.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
        ),
      ),
    );
  }
}
