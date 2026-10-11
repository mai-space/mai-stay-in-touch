import Foundation

/// Ein Vorschlag (siehe `widget_snapshot.dart`).
struct WatchPick: Identifiable {
  /// Tag als „JJJJ-MM-TT“.
  let day: String
  let name: String
  let detail: String?
  /// „open“, „called“, „messaged“, „declined“, „noted“.
  let status: String

  var id: String { day }
  var open: Bool { status == "open" }
  var declined: Bool { status == "declined" }
}

/// Inhalt der Uhr-App — derselbe Stand wie für das Android-Widget. Keine
/// Telefonnummern; im diskreten Modus nur Initialen.
struct WatchData {
  let stored: WatchPick?
  let upcoming: [WatchPick]

  /// Heutiger Vorschlag — selbst bestimmt, damit es nach Mitternacht ohne
  /// iPhone stimmt: Ist der gespeicherte Tag vorbei, gilt die Vorschau.
  func today(_ now: Date) -> WatchPick? {
    let key = WatchData.key(now)
    if let s = stored, s.day == key { return s }
    return upcoming.first { $0.day == key }
  }

  func next(_ now: Date) -> [WatchPick] {
    let key = WatchData.key(now)
    return upcoming.filter { $0.day > key }
  }

  /// Noch niemand eingeordnet.
  var empty: Bool { stored == nil && upcoming.isEmpty }

  /// Liest den Stand tolerant: unbekannte Felder werden ignoriert,
  /// fehlerhafte Einträge übersprungen.
  static func parse(_ raw: String) -> WatchData? {
    guard let bytes = raw.data(using: .utf8),
      let json = (try? JSONSerialization.jsonObject(with: bytes)) as? [String: Any]
    else { return nil }
    let upcoming = ((json["upcoming"] as? [Any]) ?? []).compactMap { pick($0) }
    return WatchData(stored: pick(json["today"]), upcoming: upcoming.sorted { $0.day < $1.day })
  }

  private static func pick(_ value: Any?) -> WatchPick? {
    guard let j = value as? [String: Any],
      let day = j["day"] as? String, date(day) != nil,
      let name = j["name"] as? String, !name.isEmpty
    else { return nil }
    let detail = (j["detail"] as? String).flatMap { $0.isEmpty ? nil : $0 }
    return WatchPick(day: day, name: name, detail: detail, status: (j["status"] as? String) ?? "open")
  }

  private static let formatter: DateFormatter = {
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = .current
    f.dateFormat = "yyyy-MM-dd"
    return f
  }()

  static func key(_ date: Date) -> String { formatter.string(from: date) }

  static func date(_ key: String) -> Date? { formatter.date(from: key) }
}
