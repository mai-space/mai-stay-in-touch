import Foundation

/// Letzter Stand vom iPhone. Liegt in der App-Gruppe, damit die
/// Komplikationen (Widget-Erweiterung) ihn lesen können; im diskreten Modus
/// stehen statt Namen nur Initialen drin.
struct SnapshotStore {
  static let appGroup = "group.space.mai.maiStayInTouch"
  private static let keySnapshot = "snapshot"
  private static let keyReceivedAt = "receivedAt"

  private let defaults: UserDefaults

  init() {
    // Ohne App-Gruppe (z. B. unsignierter Build) wenigstens die App selbst.
    defaults = UserDefaults(suiteName: SnapshotStore.appGroup) ?? .standard
  }

  /// `nil` = noch kein Stand vom iPhone.
  func load() -> WatchData? {
    guard let raw = defaults.string(forKey: SnapshotStore.keySnapshot) else { return nil }
    return WatchData.parse(raw)
  }

  var receivedAt: Date? {
    defaults.object(forKey: SnapshotStore.keyReceivedAt) as? Date
  }

  func save(_ snapshot: String) {
    guard WatchData.parse(snapshot) != nil else { return }
    defaults.set(snapshot, forKey: SnapshotStore.keySnapshot)
    defaults.set(Date(), forKey: SnapshotStore.keyReceivedAt)
  }
}
