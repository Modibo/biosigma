/// Version affichée de l'application, à incrémenter à chaque livraison en
/// même temps que `pubspec.yaml` (`version:`) et `web/version.json` publié
/// sur le site (voir `lib/widgets/update_checker.dart`).
const String kAppVersion = '1.7.0';

/// Compare deux versions « X.Y.Z » (partie numérique uniquement, un
/// éventuel « +build » est ignoré). Renvoie `true` si [remote] est
/// strictement plus récente que [current].
bool isNewerVersion(String remote, String current) {
  List<int> parts(String v) => v
      .split('+')
      .first
      .split('.')
      .map((p) => int.tryParse(p.trim()) ?? 0)
      .toList(growable: false);

  final r = parts(remote);
  final c = parts(current);
  final length = r.length > c.length ? r.length : c.length;
  for (var i = 0; i < length; i++) {
    final rv = i < r.length ? r[i] : 0;
    final cv = i < c.length ? c[i] : 0;
    if (rv != cv) return rv > cv;
  }
  return false;
}
