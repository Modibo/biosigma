import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import 'lab/convert_screen.dart';
import 'lab/count_screen.dart';
import 'lab/dilute_screen.dart';
import 'lab/microbiology_screen.dart';
import 'lab/prepare_screen.dart';
import 'lab/quality_screen.dart';
import 'lab/smart_solver_screen.dart';

/// Écran d'un module Lab (utilisé par l'onglet Lab et par la recherche).
Widget labModuleScreen(LabModule m) => switch (m) {
      LabModule.convert => const ConvertScreen(),
      LabModule.dilute => const DiluteScreen(),
      LabModule.prepare => const PrepareScreen(),
      LabModule.count => const CountScreen(),
      LabModule.microbiology => const MicrobiologyScreen(),
      LabModule.quality => const QualityScreen(),
    };

/// Onglet « Lab » : accueil des modules de laboratoire (décision D-13 :
/// l'accueil enveloppe les domaines existants sans rien remplacer).
/// Seuls les modules réellement disponibles ouvrent un écran ; les autres
/// affichent honnêtement pourquoi ils ne le sont pas encore.
class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void open(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
    void goToCalcul() => DefaultTabController.of(context).animateTo(0);
    void openModule(LabModule m) => open(labModuleScreen(m));

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const _Header('Disponibles'),
          _Tile(
            icon: Icons.swap_horiz,
            title: 'Convert',
            subtitle: 'Conversion d\'unités et de grandeurs (masse, quantité, équivalents), '
                'analytes cliniques.',
            onTap: () => open(const ConvertScreen()),
          ),
          _Tile(
            icon: Icons.opacity,
            title: 'Dilute',
            subtitle: 'Dilution simple (C1·V1 = C2·V2), dilutions en série, résultat après '
                'dilution (hors linéarité).',
            onTap: () => open(const DiluteScreen()),
          ),
          _Tile(
            icon: Icons.science_outlined,
            title: 'Prepare',
            subtitle: 'Masse à peser, solutions en pourcentage, tampons. Masse molaire, pureté et pKa '
                'sont saisis par vous.',
            onTap: () => openModule(LabModule.prepare),
          ),
          _Tile(
            icon: Icons.grid_on,
            title: 'Count',
            subtitle: 'Numération en chambre, formule leucocytaire (compteur tactile), nombre total, '
                'comptages en double. La géométrie de la chambre est saisie par vous.',
            onTap: () => openModule(LabModule.count),
          ),
          _Tile(
            icon: Icons.coronavirus_outlined,
            title: 'Microbiology',
            subtitle: 'UFC/mL à partir de boîtes dénombrées. L\'intervalle de colonies est saisi par vous ; '
                'aucune équivalence McFarland.',
            onTap: () => openModule(LabModule.microbiology),
          ),
          _Tile(
            icon: Icons.rule,
            title: 'Quality',
            subtitle: 'CV, biais, récupération, erreur totale, Sigma. L\'ETa et le coefficient k sont '
                'saisis par vous ; aucun verdict.',
            onTap: () => openModule(LabModule.quality),
          ),
          _Tile(
            icon: Icons.lightbulb_outline,
            title: 'Smart Solver',
            subtitle: 'Décrivez votre besoin en une phrase : un module vous est proposé, à confirmer. '
                'Analyse locale, aucun calcul automatique.',
            onTap: () => open(SmartSolverScreen(openModule: openModule)),
          ),
          const _Header('Domaines de calcul existants (onglet Calcul)'),
          _Tile(
            icon: Icons.biotech_outlined,
            title: 'Hématologie',
            subtitle: 'Indices microcytaires, réticulocytes, SII, SIRI.',
            onTap: goToCalcul,
          ),
          _Tile(
            icon: Icons.bloodtype_outlined,
            title: 'Hémostase',
            subtitle: 'INR, ratio TCA, Rosner, ISTH-CIVD, 4Ts, scores de risque.',
            onTap: goToCalcul,
          ),
          _Tile(
            icon: Icons.monitor_heart_outlined,
            title: 'Clinique',
            subtitle: 'Fonction rénale, cardiométabolique, ionogramme.',
            onTap: goToCalcul,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Card(
      child: ListTile(
        enabled: enabled,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: enabled ? const Icon(Icons.chevron_right) : const Icon(Icons.lock_clock),
        onTap: onTap,
      ),
    );
  }
}
