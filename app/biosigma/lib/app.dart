import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/root_tab_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/update_checker.dart';

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
      // Texte agrandi jusqu'à 200 % (WCAG 1.4.4) : les écrans principaux sont
      // testés à 200 % sans débordement (test/accessibility/text_scale_test.dart).
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(mq.textScaler.scale(1.0).clamp(0.85, 2.0)),
          ),
          child: child!,
        );
      },
      home: const UpdateChecker(child: RootTabScreen()),
    );
  }
}
