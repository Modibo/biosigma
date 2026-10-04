// Fichier chargé uniquement sur le web via l'import conditionnel de
// export_dialog.dart (`if (dart.library.html)`) — jamais compilé pour
// Android/iOS/bureau.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Imprime [html] avec la boîte d'impression du navigateur (décision D-11 :
/// pas de dépendance PDF ; « Enregistrer au format PDF » est proposé par le
/// navigateur lui-même). Le document est placé dans un cadre invisible, imprimé,
/// puis retiré : la page de l'application n'est pas modifiée.
bool printHtmlDocument(String html) {
  try {
    final document = globalContext['document'] as JSObject;
    final iframe = document.callMethod('createElement'.toJS, 'iframe'.toJS) as JSObject;
    iframe.callMethod('setAttribute'.toJS, 'style'.toJS,
        'position:fixed;right:0;bottom:0;width:0;height:0;border:0;visibility:hidden'.toJS);
    iframe.callMethod('setAttribute'.toJS, 'aria-hidden'.toJS, 'true'.toJS);
    iframe.setProperty('srcdoc'.toJS, html.toJS);
    void onLoad() {
      final window = iframe['contentWindow'] as JSObject?;
      window?.callMethod('focus'.toJS);
      window?.callMethod('print'.toJS);
      // retire le cadre après l'impression (ou l'annulation)
      globalContext.callMethod(
        'setTimeout'.toJS,
        (() => iframe.callMethod('remove'.toJS)).toJS,
        60000.toJS,
      );
    }

    iframe.setProperty('onload'.toJS, onLoad.toJS);
    (document['body'] as JSObject).callMethod('appendChild'.toJS, iframe);
    return true;
  } catch (_) {
    return false;
  }
}

const bool canPrintHtml = true;
