// Le champ numérique refuse une saisie ambiguë au lieu de la calculer
// avec un facteur 10 (backlog P0-04, T-SAI-001).
import 'package:biosigma/models/app_settings.dart';
import 'package:biosigma/widgets/numeric_unit_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<double?>> _type(WidgetTester tester, String text, DecimalSeparator sep) async {
  final received = <double?>[];
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: NumericUnitField(
        label: 'Créatinine',
        helpText: null,
        value: null,
        unit: 'mg/dL',
        units: const ['mg/dL'],
        decimalSeparator: sep,
        onValueChanged: received.add,
        onUnitChanged: (_) {},
      ),
    ),
  ));
  await tester.enterText(find.byType(TextFormField), text);
  await tester.pump();
  return received;
}

void main() {
  testWidgets('« 1.5 » en mode virgule : message affiché, aucune valeur transmise', (tester) async {
    final received = await _type(tester, '1.5', DecimalSeparator.comma);
    expect(find.textContaining('Séparateur ambigu'), findsOneWidget);
    expect(received.last, isNull);
  });

  testWidgets('« 1,5 » en mode virgule : pas de message, valeur 1,5', (tester) async {
    final received = await _type(tester, '1,5', DecimalSeparator.comma);
    expect(find.textContaining('Séparateur ambigu'), findsNothing);
    expect(received.last, 1.5);
  });

  testWidgets('« 1,5 » en mode point : message affiché, aucune valeur transmise', (tester) async {
    final received = await _type(tester, '1,5', DecimalSeparator.dot);
    expect(find.textContaining('Séparateur ambigu'), findsOneWidget);
    expect(received.last, isNull);
  });
}
