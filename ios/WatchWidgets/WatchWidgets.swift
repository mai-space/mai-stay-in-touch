import SwiftUI
import WidgetKit

/// Komplikation der Uhr-App (WidgetKit): heutiger Vorschlag. Daten aus der
/// App-Gruppe ([SnapshotStore]); Namen werden bei gesperrter Uhr bzw. im
/// Always-on-Modus ausgeblendet (`privacySensitive`).
@main
struct MaiWatchWidgets: WidgetBundle {
  var body: some Widget {
    TodayWidget()
  }
}

struct TodayEntry: TimelineEntry {
  let date: Date
  let data: WatchData?
}

struct TodayProvider: TimelineProvider {
  func placeholder(in context: Context) -> TodayEntry {
    TodayEntry(date: Date(), data: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
    completion(TodayEntry(date: Date(), data: SnapshotStore().load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
    let data = SnapshotStore().load()
    let now = Date()
    // Jetzt und kurz nach Mitternacht (der Vorschlag wechselt).
    var entries = [TodayEntry(date: now, data: data)]
    if let midnight = Calendar.current.nextDate(
      after: now, matching: DateComponents(hour: 0, minute: 1), matchingPolicy: .nextTime)
    {
      entries.append(TodayEntry(date: midnight, data: data))
    }
    completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(6 * 60 * 60))))
  }
}

struct TodayWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "space.mai.rufdurch.today", provider: TodayProvider()) { entry in
      TodayView(entry: entry)
        .containerBackground(.clear, for: .widget)
    }
    .configurationDisplayName(WatchText.title)
    .description(WatchText.description)
    .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
  }
}

struct TodayView: View {
  @Environment(\.widgetFamily) private var family
  let entry: TodayEntry

  var body: some View {
    let pick = entry.data?.today(entry.date)
    let status = pick.flatMap { WatchText.status($0) }
    let name = pick?.name ?? (entry.data == nil ? "–" : WatchText.free)
    let short = pick.map { status == nil ? String($0.name.split(separator: " ").first ?? "") : "✓" } ?? "–"
    switch family {
    case .accessoryCircular:
      VStack(spacing: 0) {
        Image(systemName: "phone.fill").font(.caption2)
        Text(short)
          .font(.system(.caption, design: .rounded).weight(.semibold))
          .minimumScaleFactor(0.5)
          .lineLimit(1)
          .privacySensitive()
      }
    case .accessoryInline:
      Label(name, systemImage: "phone.fill").privacySensitive()
    case .accessoryCorner:
      Image(systemName: "phone.fill")
        .widgetLabel { Text(short).privacySensitive() }
    default:
      VStack(alignment: .leading, spacing: 1) {
        Label(WatchText.title, systemImage: "phone.fill")
          .font(.caption2)
          .foregroundStyle(.secondary)
        Text(name).font(.headline).lineLimit(1).privacySensitive()
        Text(status ?? pick?.detail ?? "")
          .font(.caption2)
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
