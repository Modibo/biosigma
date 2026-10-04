// P3-02 : l'ISI de l'INR est une saisie explicite, sans valeur présélectionnée ;
// sans lui, aucun INR n'est calculé.
import 'package:biosigma/data/calculator_registry_hemostasis.dart';
import 'package:biosigma/models/calculator_field.dart';
import 'package:biosigma/screens/calculator_screen.dart';
import 'package:biosigma/services/app_storage_service.dart';
import 'package:biosigma/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test("la déclaration du champ ISI n'a aucune valeur par défaut et est obligatoire", () {
    final isi = inrDefinition.fields.firstWhere((f) => f.id == 'isi');
    expect(isi.required, isTrue);
    expect(isi.defaultText, isNull);
    expect(isi.kind, FieldKind.numberFixedUnit);
  });

  testWidgets('sans ISI saisi, « Calculer » ne produit pas d\'INR', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final state = AppState(await AppStorageService.create());
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(home: CalculatorScreen(definition: inrDefinition)),
    ));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(tester.widget<TextFormField>(fields.at(2)).controller?.text ?? '', isEmpty,
        reason: "l'ISI ne doit pas être prérempli");
    await tester.enterText(fields.at(0), '28');
    await tester.enterText(fields.at(1), '12');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2,33'), findsNothing);
    expect(find.textContaining('2.33'), findsNothing);

    await tester.enterText(fields.at(2), '1');
    await tester.tap(find.text('Calculer'));
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r'2[.,]33')), findsWidgets);
  });
}
