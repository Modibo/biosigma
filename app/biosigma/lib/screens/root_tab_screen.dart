import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'entrainement_screen.dart';
import 'home_screen.dart';
import 'references_screen.dart';
import 'settings_screen.dart';

/// Écran racine de BioSigma : cinq onglets en haut de l'écran (Calcul,
/// Entraînement, Références, Réglages, À propos), sous une AppBar commune
/// qui affiche le logo — visible en permanence, y compris à l'ouverture de
/// chaque onglet, puisque l'AppBar ne se reconstruit pas au changement
/// d'onglet.
class RootTabScreen extends StatelessWidget {
  const RootTabScreen({super.key});

  static const _tabs = [
    Tab(icon: Icon(Icons.calculate_outlined), text: 'Calcul'),
    Tab(icon: Icon(Icons.school_outlined), text: 'Entraînement'),
    Tab(icon: Icon(Icons.menu_book_outlined), text: 'Références'),
    Tab(icon: Icon(Icons.settings_outlined), text: 'Réglages'),
    Tab(icon: Icon(Icons.info_outline), text: 'À propos'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/icon.png', width: 28, height: 28),
              ),
              const SizedBox(width: 10),
              const Text('BioSigma'),
            ],
          ),
          bottom: const TabBar(isScrollable: true, tabs: _tabs),
        ),
        body: const TabBarView(
          children: [
            _KeepAlive(child: HomeScreen()),
            _KeepAlive(child: EntrainementScreen()),
            _KeepAlive(child: ReferencesScreen()),
            _KeepAlive(child: SettingsScreen()),
            _KeepAlive(child: AboutScreen()),
          ],
        ),
      ),
    );
  }
}

/// `TabBarView` reconstruit ses enfants au fil du défilement (contrairement
/// à `IndexedStack`) : sans ce wrapper, la recherche en cours ou la
/// position de défilement d'un onglet seraient perdues en changeant
/// d'onglet puis en y revenant.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});
  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
