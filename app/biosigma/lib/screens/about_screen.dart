import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Écran « À propos » : ce que BioSigma apporte, ses avertissements
/// d'usage, l'auteur et un contact pour les remarques, corrections de
/// seuils et demandes de formation.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _contactEmail = 'coulibalymodibom@gmail.com';

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _contactEmail));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Adresse copiée dans le presse-papiers.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset('assets/icon.png', width: 96, height: 96),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text('BioSigma', style: theme.textTheme.headlineSmall),
            ),
            Center(
              child: Text(
                "Biochimie clinique et hémostase, hors connexion",
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
            const SizedBox(height: 28),
            _Section(
              title: 'Ce que BioSigma apporte',
              child: Text(
                "BioSigma calcule, sur l'appareil et sans connexion, les indices et équations de "
                'biochimie clinique et d\'hémostase les plus utiles en pratique courante : DFG '
                'estimés (CKD-EPI, Schwartz), indices d\'insulinorésistance (QUICKI, HOMA-IR, TyG), '
                'bilan lipidique, ionogramme et biochimie générale, hémostase (indice de Rosner, '
                'INR, scores ISTH-CIVD et 4Ts).\n\n'
                "Conçu à l'origine pour les laboratoires qui interprètent sans automate, il rend "
                "accessibles des calculs habituellement réservés aux systèmes experts des grands "
                "analyseurs — avec, pour chaque résultat, la formule exacte, les unités utilisées, "
                "la version de l'équation, la source scientifique et les limites d'emploi. Jamais "
                'un chiffre isolé sans son contexte.\n\n'
                "L'onglet Entraînement complète l'application pour l'auto-évaluation : des séries "
                'de 20 questions, essentiellement des cas cliniques et des questions '
                "d'interprétation, tirées au hasard dans une banque qui s'enrichit "
                'progressivement.',
              ),
            ),
            _Section(
              title: 'Avertissements',
              child: Text(
                "BioSigma est un outil d'aide au calcul, pas un dispositif de diagnostic. Chaque "
                'résultat doit être confronté aux données analytiques et cliniques du patient, puis '
                'validé par un professionnel compétent avant toute décision.\n\n'
                "Aucun seuil interprétatif clinique n'est imposé par l'application : les seuils "
                'rapportés dans la littérature sont indicatifs, à valider et documenter localement '
                'par le biologiste responsable (Réglages, section Seuils locaux). Les scores ISTH-CIVD et '
                '4Ts se calculent toujours, mais leur texte d\'interprétation reste masqué tant '
                "qu'il n'a pas été validé localement.\n\n"
                'BioSigma ne collecte aucune donnée nominative, ne nécessite aucune connexion pour '
                "calculer, et n'envoie rien en dehors de l'appareil.",
              ),
            ),
            _Section(
              title: 'Auteur',
              child: const Text(
                'Conçu et développé par le Dr Modibo Mouctar Coulibaly, PharmD, CLMS, PhD, Maître '
                'de recherche à l\'Hôpital Sominé Dolo de Mopti (Mali).',
              ),
            ),
            _Section(
              title: 'Remarques et contact',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remarques, corrections de seuils et demandes de formation sont les bienvenues.',
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _copyEmail(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.email_outlined, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(_contactEmail,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: theme.colorScheme.primary)),
                          const SizedBox(width: 6),
                          Icon(Icons.copy, size: 16, color: theme.colorScheme.outline),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text('BioSigma 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
