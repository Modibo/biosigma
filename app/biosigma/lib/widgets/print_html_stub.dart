// Plates-formes sans navigateur (Android, iOS, bureau) : l'impression par le
// navigateur n'existe pas ; l'appelant se rabat sur la copie du texte.

/// Renvoie `false` : rien n'a été imprimé.
bool printHtmlDocument(String html) => false;

/// Indique si l'impression est disponible sur cette plateforme.
const bool canPrintHtml = false;
