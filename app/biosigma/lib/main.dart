import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/app_storage_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await AppStorageService.create();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(storage),
      child: const BioSigmaApp(),
    ),
  );
}
