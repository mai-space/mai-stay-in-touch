/// Telefonnummern für Wählen und WhatsApp aufbereiten.
abstract final class Phone {
  /// Für die Wähl-App: Ziffern, „+“, „*“, „#“ (Leerzeichen usw. raus).
  static String dialable(String raw) =>
      raw.trim().replaceAll(RegExp(r'[^0-9+*#]'), '');

  /// Internationale Nummer ohne „+“ für `wa.me/<nummer>`; `null`, wenn
  /// keine sinnvolle Nummer übrig bleibt. Nationale Nummern („0171 …“)
  /// bekommen die Ländervorwahl [countryCode] (z. B. „49“).
  static String? international(String raw, String countryCode) {
    var s = raw.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    if (s.isEmpty) return null;
    final cc = countryCode.replaceAll(RegExp(r'[^0-9]'), '');
    if (s.startsWith('+')) {
      s = s.substring(1).replaceAll('+', '');
    } else if (s.startsWith('00')) {
      s = s.substring(2);
    } else if (s.startsWith('0')) {
      if (cc.isEmpty) return null;
      s = '$cc${s.substring(1)}';
    } else if (cc.isNotEmpty && !s.startsWith(cc)) {
      // Ohne Präfix und ohne Vorwahl: wie eine nationale Nummer behandeln.
      s = '$cc$s';
    }
    s = s.replaceAll('+', '');
    // „+49 (0) 171 …“ → die „0“ nach der Ländervorwahl entfällt.
    if (cc.isNotEmpty && s.startsWith('${cc}0')) {
      s = '$cc${s.substring(cc.length + 1)}';
    }
    return s.length < 6 || s.length > 15 ? null : s;
  }

  /// Ländervorwahl aus der Region des Geräts („de_DE“ → „49“), sonst „49“.
  static String countryCodeFor(String? localeName) {
    final parts = (localeName ?? '').split(RegExp('[_-]'));
    final region = parts.length > 1 ? parts[1].toUpperCase() : '';
    return _codes[region] ?? '49';
  }

  static const _codes = {
    'DE': '49',
    'AT': '43',
    'CH': '41',
    'LI': '423',
    'LU': '352',
    'NL': '31',
    'BE': '32',
    'FR': '33',
    'IT': '39',
    'ES': '34',
    'PT': '351',
    'PL': '48',
    'CZ': '420',
    'DK': '45',
    'SE': '46',
    'NO': '47',
    'FI': '358',
    'GB': '44',
    'IE': '353',
    'US': '1',
    'CA': '1',
    'TR': '90',
    'GR': '30',
    'HR': '385',
    'HU': '36',
    'RO': '40',
  };

  /// Initialen für diskrete Anzeige („Anna Berger“ → „AB“).
  static String initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    String first(String w) => String.fromCharCodes(w.runes.take(1)).toUpperCase();
    if (words.length == 1) return first(words.single);
    return '${first(words.first)}${first(words.last)}';
  }
}
