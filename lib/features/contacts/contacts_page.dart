import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/services.dart';
import '../../data/repositories/people_repository.dart';
import '../../domain/days.dart';
import '../../domain/importance.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common.dart';
import '../../widgets/labels.dart';
import 'contact_detail_page.dart';
import 'contact_form.dart';
import 'import_page.dart';
import 'triage_page.dart';

/// Alle Kontakte mit Suche und Filter nach Wichtigkeit.
class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

/// Filter: alle, eine Wichtigkeit oder „nicht eingeordnet“.
sealed class _Filter {
  const _Filter();
}

class _All extends _Filter {
  const _All();
}

class _Level extends _Filter {
  const _Level(this.importance);

  final Importance? importance;

  @override
  bool operator ==(Object other) =>
      other is _Level && other.importance == importance;

  @override
  int get hashCode => importance.hashCode;
}

class _ContactsPageState extends State<ContactsPage> {
  final _search = TextEditingController();
  _Filter _filter = const _All();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = context.services;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabContacts),
        actions: [
          IconButton(
            tooltip: l10n.triageTitle,
            icon: const Icon(Icons.sort),
            onPressed: () => openTriage(context),
          ),
          IconButton(
            tooltip: l10n.contactsImport,
            icon: const Icon(Icons.download_outlined),
            onPressed: () => openImport(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => addContact(context),
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.contactsAdd),
      ),
      body: StreamBuilder<List<PersonView>>(
        stream: s.people.watchAll(),
        builder: (context, snapshot) {
          final all = snapshot.data;
          if (all == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.contacts_outlined,
              title: l10n.contactsEmptyTitle,
              message: l10n.contactsEmptyText,
              action: FilledButton.icon(
                onPressed: () => openImport(context),
                icon: const Icon(Icons.download),
                label: Text(l10n.contactsImport),
              ),
            );
          }
          final counts = <Importance?, int>{};
          for (final v in all) {
            counts[v.person.importance] = (counts[v.person.importance] ?? 0) + 1;
          }
          final q = _query.toLowerCase();
          final shown = all.where((v) {
            final f = _filter;
            if (f is _Level && v.person.importance != f.importance) return false;
            if (q.isEmpty) return true;
            return v.person.name.toLowerCase().contains(q) ||
                (v.person.phone ?? '').contains(q);
          }).toList();
          final levels = <Importance?>[
            ...Importance.ranked,
            null,
          ].where((i) => (counts[i] ?? 0) > 0);
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v.trim()),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.commonSearch,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('${l10n.contactsFilterAll} · ${all.length}'),
                      selected: _filter is _All,
                      onSelected: (_) => setState(() => _filter = const _All()),
                    ),
                    for (final i in levels) ...[
                      const SizedBox(width: 6),
                      ChoiceChip(
                        avatar: Icon(importanceIcon(i), size: 18),
                        label: Text('${l10n.importanceName(i)} · ${counts[i]}'),
                        selected: _filter == _Level(i),
                        onSelected: (_) => setState(() => _filter = _Level(i)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l10n.contactsNoMatch, textAlign: TextAlign.center),
                ),
              for (final v in shown) _PersonTile(view: v),
            ],
          );
        },
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.view});

  final PersonView view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = view.person;
    final paused =
        p.pausedUntil != null && Days.between(DateTime.now(), p.pausedUntil!) >= 0;
    final subtitle = [
      l10n.importanceName(p.importance),
      paused
          ? l10n.contactsPausedUntil(DateFormat.MMMd(l10n.localeName).format(p.pausedUntil!))
          : l10n.lastContact(view.lastContact),
    ].join(' · ');
    return ListTile(
      leading: PersonAvatar(p.name),
      title: Text(p.name),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(
        paused ? Icons.pause_circle_outline : importanceIcon(p.importance),
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => openPerson(context, p.id),
    );
  }
}

Future<void> openPerson(BuildContext context, String id) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ContactDetailPage(personId: id)),
    );

Future<void> openTriage(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute<void>(builder: (_) => const TriagePage()),
);

/// Import öffnen; danach (falls neue) direkt einordnen.
Future<void> openImport(BuildContext context) async {
  final added = await Navigator.of(
    context,
  ).push<int>(MaterialPageRoute(builder: (_) => const ImportPage()));
  if ((added ?? 0) > 0 && context.mounted) await openTriage(context);
}
