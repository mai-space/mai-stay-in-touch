import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/services.dart';
import '../../data/app_database.dart';
import '../../data/repositories/suggestion_repository.dart';
import '../../domain/days.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common.dart';
import '../../widgets/labels.dart';
import '../contacts/contacts_page.dart';

/// Verlauf: Anrufe, Nachrichten, „Heute nicht“ und eingetragene Kontakte,
/// mit kleiner Statistik. Einträge lassen sich wegwischen (Rückgängig).
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = context.services;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabHistory)),
      body: StreamBuilder<List<HistoryEntry>>(
        stream: s.suggestions.watchHistory(limit: 500),
        builder: (context, snapshot) {
          final items = snapshot.data;
          if (items == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.history,
              title: l10n.historyEmptyTitle,
              message: l10n.historyEmptyText,
            );
          }
          final today = Days.of(DateTime.now());
          bool reached(HistoryEntry h, int days) =>
              h.event.kind != EventKind.declined &&
              !h.event.at.isBefore(Days.add(today, -(days - 1)));
          final week = items.where((h) => reached(h, 7)).length;
          final month = items.where((h) => reached(h, 30)).toList();
          final people = month.map((h) => h.event.personId).toSet().length;

          final rows = <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: PaddedCard(
                child: Row(
                  children: [
                    Expanded(child: StatTile(value: '$week', label: l10n.statsWeek)),
                    Expanded(
                      child: StatTile(value: '${month.length}', label: l10n.statsMonth),
                    ),
                    Expanded(child: StatTile(value: '$people', label: l10n.statsPeople)),
                  ],
                ),
              ),
            ),
          ];
          DateTime? lastDay;
          final dayFormat = DateFormat.yMMMMEEEEd(l10n.localeName);
          final time = DateFormat.Hm(l10n.localeName);
          for (final h in items) {
            final day = Days.of(h.event.at);
            if (day != lastDay) {
              lastDay = day;
              rows.add(
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    Days.between(day, today) <= 1
                        ? l10n.dayName(day)
                        : dayFormat.format(day),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              );
            }
            final name = h.person?.name ?? l10n.historyRemovedPerson;
            rows.add(
              Dismissible(
                key: ValueKey(h.event.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.delete_outline),
                ),
                onDismissed: (_) {
                  s.suggestions.deleteEvent(h.event.id);
                  showSnack(context, l10n.historyDeleted);
                },
                child: ListTile(
                  leading: PersonAvatar(name),
                  title: Text(name),
                  subtitle: Row(
                    children: [
                      Icon(eventIcon(h.event.kind), size: 16),
                      const SizedBox(width: 4),
                      Text(l10n.eventName(h.event.kind)),
                    ],
                  ),
                  trailing: Text(time.format(h.event.at)),
                  onTap: h.person == null || h.person!.archived
                      ? null
                      : () => openPerson(context, h.person!.id),
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: rows,
          );
        },
      ),
    );
  }
}
