import Foundation

/// Texte der Uhr-App (Deutsch/Englisch nach Systemsprache, wie die App).
enum WatchText {
  static let german = Locale.preferredLanguages.first?.hasPrefix("de") ?? false

  private static func t(_ de: String, _ en: String) -> String { german ? de : en }

  static var title: String { t("Heute anrufen", "Call today") }
  static var description: String {
    t("Wen du heute anrufen könntest", "Who you could call today")
  }
  static var upcoming: String { t("Als Nächstes", "Coming up") }
  static var openPhone: String {
    t("Öffne Ruf durch einmal am iPhone, um das zu laden",
      "Open Ruf durch on your iPhone once to load this")
  }
  static var empty: String {
    t("Ordne deine Kontakte in der App ein", "Sort your contacts in the app")
  }
  static var free: String { t("Heute kein Vorschlag", "No suggestion today") }
  static var done: String { t("Erledigt", "Done") }
  static var declined: String { t("Heute nicht", "Not today") }
  static var callOnPhone: String {
    t("Anrufen übers iPhone oder die Mitteilung", "Call from your iPhone or the notification")
  }
  static var today: String { t("Heute", "Today") }
  static var tomorrow: String { t("Morgen", "Tomorrow") }

  static func status(_ pick: WatchPick) -> String? {
    if pick.open { return nil }
    return pick.declined ? declined : done
  }

  /// „Heute“, „Morgen“ oder Wochentag.
  static func day(_ key: String, now: Date) -> String {
    guard let date = WatchData.date(key) else { return key }
    let calendar = Calendar.current
    let days = calendar.dateComponents(
      [.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)
    ).day ?? 0
    switch days {
    case 0: return today
    case 1: return tomorrow
    default: return date.formatted(.dateTime.weekday(.abbreviated))
    }
  }
}
