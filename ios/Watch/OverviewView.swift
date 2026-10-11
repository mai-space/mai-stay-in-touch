import SwiftUI

/// Übersicht: heutiger Vorschlag (mit Status) und die nächsten Tage.
struct OverviewView: View {
  @EnvironmentObject private var model: WatchModel

  var body: some View {
    TimelineView(.everyMinute) { context in
      List {
        if let data = model.data {
          today(data, now: context.date)
          let next = data.next(context.date)
          if !next.isEmpty {
            Section(WatchText.upcoming) {
              ForEach(next) { pick in
                VStack(alignment: .leading, spacing: 2) {
                  Text(WatchText.day(pick.day, now: context.date))
                    .font(.footnote)
                    .foregroundStyle(.tint)
                  Text(pick.name).font(.headline).lineLimit(1)
                }
              }
            }
          }
        } else {
          Text(WatchText.openPhone).foregroundStyle(.secondary)
        }
      }
    }
    .onAppear { model.reload() }
  }

  @ViewBuilder
  private func today(_ data: WatchData, now: Date) -> some View {
    Section(WatchText.title) {
      if let pick = data.today(now) {
        VStack(alignment: .leading, spacing: 4) {
          Text(pick.name).font(.title3.weight(.semibold)).lineLimit(2)
          if let status = WatchText.status(pick) {
            Label(status, systemImage: pick.declined ? "moon.zzz" : "checkmark.circle.fill")
              .foregroundStyle(.tint)
          } else {
            if let detail = pick.detail {
              Text(detail).font(.footnote).foregroundStyle(.secondary)
            }
            Text(WatchText.callOnPhone).font(.footnote).foregroundStyle(.secondary)
          }
        }
      } else {
        Text(data.empty ? WatchText.empty : WatchText.free).foregroundStyle(.secondary)
      }
    }
  }
}
