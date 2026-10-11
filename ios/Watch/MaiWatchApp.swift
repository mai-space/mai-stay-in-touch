import SwiftUI

/// Uhr-App „Ruf durch“ (watchOS): heutiger Vorschlag und die nächsten Tage;
/// die Komplikation liegt in der Widget-Erweiterung „WatchWidgets“.
@main
struct MaiWatchApp: App {
  @StateObject private var model = WatchModel.shared

  var body: some Scene {
    WindowGroup {
      OverviewView()
        .environmentObject(model)
    }
  }
}
