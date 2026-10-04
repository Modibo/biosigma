@TestOn('browser')
library;

// Impression par le navigateur (exécuté seulement avec --platform chrome) :
// vérifie que le document est placé dans un cadre invisible avec le bon contenu.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:biosigma/widgets/print_html_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('printHtmlDocument ajoute un cadre invisible portant le document', () {
    final ok = printHtmlDocument('<!doctype html><html><body><p id="x">Rapport BioSigma</p></body></html>');
    expect(ok, isTrue);
    final document = globalContext['document'] as JSObject;
    final frames = document.callMethod('querySelectorAll'.toJS, 'iframe[aria-hidden="true"]'.toJS) as JSObject;
    final count = (frames['length'] as JSNumber).toDartInt;
    expect(count, greaterThanOrEqualTo(1));
    final first = frames.callMethod('item'.toJS, 0.toJS) as JSObject;
    final srcdoc = (first['srcdoc'] as JSString).toDart;
    expect(srcdoc, contains('Rapport BioSigma'));
    final style = (first.callMethod('getAttribute'.toJS, 'style'.toJS) as JSString).toDart;
    expect(style, contains('visibility:hidden'));
  });
}
