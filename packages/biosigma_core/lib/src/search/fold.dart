/// Minuscules sans accents (« Éosinophiles » → « eosinophiles »), pour des
/// recherches et des reconnaissances de mots-clés insensibles à la casse et
/// aux accents.
const Map<String, String> _accents = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'ç': 'c', 'é': 'e', 'è': 'e', 'ê': 'e',
  'ë': 'e', 'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', 'ñ': 'n', 'ó': 'o', 'ò': 'o', 'ô': 'o',
  'ö': 'o', 'õ': 'o', 'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ý': 'y', 'ÿ': 'y', 'œ': 'oe',
  'æ': 'ae', 'µ': 'u', 'μ': 'u', 'α': 'a', 'β': 'b', 'γ': 'g', 'δ': 'd',
  '₂': '2', '₃': '3', '⁺': '+', '⁻': '-',
};

String foldText(String s) {
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    b.write(_accents[ch] ?? ch);
  }
  return b.toString();
}
