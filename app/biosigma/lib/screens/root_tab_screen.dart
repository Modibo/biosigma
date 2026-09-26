import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'entrainement_screen.dart';
import 'home_screen.dart';
import 'references_screen.dart';
import 'settings_screen.dart';

/// Écran racine de BioSigma : cinq onglets (Calcul, Entraînement,
/// Références, Réglages, À propos). Chaque onglet garde son propre
/// `Scaffold`/`AppBar` ; seule la barre de navigation du bas est commune.
class RootTabScreen extends StatefulWidget {
  const RootTabScreen({super.key});

  @override
  State<RootTabScreen> createState() => _RootTabScreenState();
}

class _RootTabScreenState extends State<RootTabScreen> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    EntrainementScreen(),
    ReferencesScreen(),
    SettingsScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'Calcul'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Entraînement'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Références'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Réglages'),
          NavigationDestination(icon: Icon(Icons.info_outline), label: 'À propos'),
        ],
      ),
    );
  }
}
