import Foundation
import WatchConnectivity

/// Abgleich mit der Uhr-App (watchOS, Ziel „Watch“).
///
/// Die Uhr bekommt denselben Stand wie das Android-Widget — keine
/// Telefonnummern, im diskreten Modus nur Initialen. Übertragen wird nur per
/// WatchConnectivity direkt an die gekoppelte Apple Watch und nur, wenn die
/// Uhr-App dort installiert ist; ohne Uhr-App verlässt nichts das Telefon.
final class WatchSync: NSObject, WCSessionDelegate {
  static let shared = WatchSync()

  private let queue = DispatchQueue(label: "space.mai.watch-sync")
  private var lastSnapshot: String?

  func activate() {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }

  func update(snapshot: String) {
    queue.async {
      self.lastSnapshot = snapshot
      self.push()
    }
  }

  private func push() {
    guard WCSession.isSupported(), let snapshot = lastSnapshot else { return }
    let session = WCSession.default
    guard session.activationState == .activated, session.isPaired, session.isWatchAppInstalled
    else { return }
    // Anwendungskontext: das System behält nur den neuesten Stand und stellt
    // ihn zu, sobald die Uhr erreichbar ist.
    try? session.updateApplicationContext([
      "snapshot": snapshot,
      "sentAt": Date().timeIntervalSince1970,
    ])
  }

  // MARK: - WCSessionDelegate

  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    queue.async { self.push() }
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    // Uhr gewechselt: neu aktivieren, damit die neue Uhr den Stand bekommt.
    session.activate()
  }

  func sessionWatchStateDidChange(_ session: WCSession) {
    queue.async { self.push() }
  }
}
