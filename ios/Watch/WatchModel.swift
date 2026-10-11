import Foundation
import WatchConnectivity
import WidgetKit

/// Stand der Uhr-App: Snapshot vom iPhone (WatchConnectivity). Die Uhr
/// zeigt nur an — angerufen wird übers iPhone.
final class WatchModel: NSObject, ObservableObject, WCSessionDelegate {
  static let shared = WatchModel()

  @Published private(set) var data: WatchData?

  private let store = SnapshotStore()

  override init() {
    super.init()
    reload()
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }
  }

  func reload() {
    data = store.load()
  }

  private func receive(_ context: [String: Any]) {
    guard let snapshot = context["snapshot"] as? String else { return }
    store.save(snapshot)
    WidgetCenter.shared.reloadAllTimelines()
    DispatchQueue.main.async { self.reload() }
  }

  // MARK: - WCSessionDelegate

  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    receive(session.receivedApplicationContext)
  }

  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    receive(applicationContext)
  }
}
