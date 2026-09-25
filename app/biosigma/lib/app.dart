import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class BioSigmaApp extends StatelessWidget {
  const BioSigmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioSigma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Empêche la coupure du texte agrandi (accessibilité) tout en
      // gardant l'app utilisable sur petit écran : borne raisonnable.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(mq.textScaler.scale(1.0).clamp(0.85, 1.6)),
          ),
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
