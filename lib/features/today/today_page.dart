import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../data/app_database.dart';
import '../../data/repositories/suggestion_repository.dart';
import '../../domain/days.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common.dart';
import '../../widgets/labels.dart';
import '../../widgets/live.dart';
import '../contacts/contacts_page.dart';
import '../settings/settings_page.dart';
import 'actions.dart';

/// Alles für die Startseite auf einmal.
class _TodayData {
  const _TodayData(this.plan, this.last, this.unrated, this.week, this.total);

  final Plan plan;
  final Map<String, (DateTime, EventKind)> last;
  final int unrated;
  final int week;

  /// Kontakte in der App (aktiv).
  final int total;
}

/// Heute: Vorschlag mit „Anrufen“, „WhatsApp“, „Heute nicht“ und die
/// Vorschau der nächsten Tage.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  Future<_TodayData> _load(AppServices s) async {
    final now = DateTime.now();
    final plan = await s.suggestions.plan(now: now);
    final people = await s.people.active();
    return _TodayData(
      plan,
      await s.people.lastContacts(),
      people.where((p) => p.importance == null).length,
      await s.suggestions.contactsSince(Days.add(Days.of(now), -6)),
      people.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: LiveBuilder<_TodayData>(
        load: () => _load(s),
        changes: s.suggestions.changes(),
        builder: (context, data) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            if (data.total == 0)
              EmptyState(
                icon: Icons.contacts_outlined,
                title: l10n.todayEmptyTitle,
                message: l10n.todayEmptyText,
                action: FilledButton.icon(
                  onPressed: () => openImport(context),
                  icon: const Icon(Icons.download),
                  label: Text(l10n.todayImport),
                ),
              )
            else ...[
              const SizedBox(height: 8),
              _TodayCard(data: data),
              if (data.unrated > 0) ...[
                const SizedBox(height: 12),
                _UnratedBanner(count: data.unrated),
              ],
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l10n.todayWeek(data.week),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SectionTitle(l10n.upcomingTitle),
              _Upcoming(data: data),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.data});

  final _TodayData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pick = data.plan.today;
    final person = pick == null ? null : data.plan.people[pick.personId];

    if (pick == null || person == null) {
      final noOneDue = data.plan.isSuggestionDay;
      return PaddedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              noOneDue ? Icons.sentiment_satisfied_alt : Icons.weekend_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              noOneDue ? l10n.todayNobody : l10n.todayFree,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _another(context),
              icon: const Icon(Icons.casino_outlined),
              label: Text(l10n.todayFreeAction),
            ),
          ],
        ),
      );
    }

    final last = data.last[person.id]?.$1;
    final done = pick.status.accepted;
    final declined = pick.status == SuggestionStatus.declined;
    return Card(
      color: theme.colorScheme.primaryContainer,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.todaySuggestion,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => openPerson(context, person.id),
              child: Row(
                children: [
                  PersonAvatar(person.name, radius: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.lastContact(last),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          l10n.importanceName(person.importance),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (done || declined) ...[
              Row(
                children: [
                  Icon(
                    done ? Icons.check_circle : Icons.snooze,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      done ? l10n.todayDone : l10n.todayDeclined,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _another(context),
                  icon: const Icon(Icons.casino_outlined),
                  label: Text(l10n.actionAnother),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: person.phone == null
                          ? null
                          : () => runSuggestionAction(
                              context,
                              pick.day,
                              person.id,
                              SuggestionAction.call,
                            ),
                      icon: const Icon(Icons.call),
                      label: Text(l10n.actionCall),
                    ),
                  ),
                  if (person.whatsapp) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: person.phone == null
                            ? null
                            : () => runSuggestionAction(
                                context,
                                pick.day,
                                person.id,
                                SuggestionAction.whatsapp,
                              ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: Text(l10n.actionWhatsApp),
                      ),
                    ),
                  ],
                ],
              ),
              if (person.phone == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.noNumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => runSuggestionAction(
                      context,
                      pick.day,
                      person.id,
                      SuggestionAction.later,
                    ),
                    icon: const Icon(Icons.snooze),
                    label: Text(l10n.actionLater),
                  ),
                  TextButton.icon(
                    onPressed: () => _another(context),
                    icon: const Icon(Icons.casino_outlined),
                    label: Text(l10n.actionAnother),
                  ),
                  TextButton.icon(
                    onPressed: () => runSuggestionAction(
                      context,
                      pick.day,
                      person.id,
                      SuggestionAction.noted,
                    ),
                    icon: const Icon(Icons.check),
                    label: Text(l10n.actionNoted),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _another(BuildContext context) async {
    final l10n = context.l10n;
    final id = await context.services.suggestions.another();
    if (id == null && context.mounted) showSnack(context, l10n.todayAnotherNone);
  }
}

class _UnratedBanner extends StatelessWidget {
  const _UnratedBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return PaddedCard(
      color: theme.colorScheme.secondaryContainer,
      onTap: () => openTriage(context),
      child: Row(
        children: [
          Icon(Icons.sort, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.todayUnrated(count),
              style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
            ),
          ),
          Text(
            l10n.todaySort,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSecondaryContainer),
        ],
      ),
    );
  }
}

class _Upcoming extends StatelessWidget {
  const _Upcoming({required this.data});

  final _TodayData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = data.plan.upcoming;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.upcomingEmpty),
                )
              : Column(
                  children: [
                    for (final u in items)
                      if (data.plan.people[u.contactId] case final p?)
                        ListTile(
                          leading: PersonAvatar(p.name),
                          title: Text(p.name),
                          subtitle: Text(l10n.importanceName(p.importance)),
                          trailing: Text(
                            l10n.dayName(u.day),
                            style: theme.textTheme.labelLarge,
                          ),
                          onTap: () => openPerson(context, p.id),
                        ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(
            l10n.upcomingHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
