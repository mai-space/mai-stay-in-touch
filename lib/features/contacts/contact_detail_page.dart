import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/services.dart';
import '../../data/app_database.dart';
import '../../data/repositories/suggestion_repository.dart';
import '../../domain/days.dart';
import '../../domain/importance.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common.dart';
import '../../widgets/labels.dart';
import '../today/actions.dart';
import 'contact_form.dart';

/// Ein Kontakt: Einordnung, Pause, Anrufen/WhatsApp, Notiz und Verlauf.
class ContactDetailPage extends StatelessWidget {
  const ContactDetailPage({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    final l10n = context.l10n;
    return StreamBuilder<Person?>(
      stream: s.people.watch(personId),
      builder: (context, snapshot) {
        final p = snapshot.data;
        if (p == null) {
          return Scaffold(
            appBar: AppBar(),
            body: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                tooltip: l10n.contactEdit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => editContact(context, p),
              ),
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v != 'remove') return;
                  final ok = await confirm(
                    context,
                    title: l10n.contactRemoveTitle(p.name),
                    message: l10n.contactRemoveText,
                    confirmLabel: l10n.contactRemove,
                    cancelLabel: l10n.commonCancel,
                    destructive: true,
                  );
                  if (!ok || !context.mounted) return;
                  await s.people.archive(p.id);
                  if (context.mounted) Navigator.pop(context);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'remove', child: Text(l10n.contactRemove)),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              _Header(person: p),
              const SizedBox(height: 16),
              _ReachButtons(person: p),
              SectionTitle(l10n.contactImportance),
              _ImportancePicker(person: p),
              SectionTitle(l10n.contactPause),
              _PauseCard(person: p),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.chat_bubble_outline),
                  title: Text(l10n.contactWhatsApp),
                  value: p.whatsapp,
                  onChanged: (v) => s.people.update(p.id, whatsapp: Value(v)),
                ),
              ),
              SectionTitle(l10n.contactNote),
              _NoteField(person: p),
              SectionTitle(l10n.contactHistory),
              _History(personId: p.id),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Row(
      children: [
        PersonAvatar(person.name, radius: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.name, style: theme.textTheme.headlineSmall),
              if (person.phone != null)
                Text(person.phone!, style: theme.textTheme.bodyMedium)
              else
                Text(
                  l10n.noNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReachButtons extends StatelessWidget {
  const _ReachButtons({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasPhone = person.phone != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: hasPhone
                    ? () => runReach(context, person.id, SuggestionAction.call)
                    : null,
                icon: const Icon(Icons.call),
                label: Text(l10n.actionCall),
              ),
            ),
            if (person.whatsapp) ...[
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: hasPhone
                      ? () => runReach(
                          context,
                          person.id,
                          SuggestionAction.whatsapp,
                        )
                      : null,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(l10n.actionWhatsApp),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final s = context.services;
            final today = Days.of(DateTime.now());
            final current = await s.suggestions.current(today);
            if (current != null && current.personId == person.id) {
              await s.suggestions.act(today, person.id, SuggestionAction.noted);
            } else {
              await s.suggestions.note(person.id);
            }
            if (context.mounted) showSnack(context, l10n.contactNotedDone);
          },
          icon: const Icon(Icons.check),
          label: Text(l10n.actionNoted),
        ),
      ],
    );
  }
}

class _ImportancePicker extends StatelessWidget {
  const _ImportancePicker({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: RadioGroup<Importance>(
        groupValue: person.importance,
        onChanged: (v) {
          if (v != null) context.services.people.setImportance(person.id, v);
        },
        child: Column(
          children: [
            for (final i in Importance.ranked)
              RadioListTile<Importance>(
                value: i,
                secondary: Icon(importanceIcon(i)),
                title: Text(l10n.importanceName(i)),
                subtitle: Text(l10n.importanceHint(i)),
              ),
          ],
        ),
      ),
    );
  }
}

class _PauseCard extends StatelessWidget {
  const _PauseCard({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = context.services;
    final until = person.pausedUntil;
    final paused = until != null && Days.between(DateTime.now(), until) >= 0;
    return PaddedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paused
                ? l10n.contactsPausedUntil(
                    DateFormat.yMMMd(l10n.localeName).format(until),
                  )
                : l10n.contactPauseText,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (paused)
                FilledButton.tonalIcon(
                  onPressed: () => s.people.pause(person.id, null),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.contactResume),
                ),
              for (final (days, label) in [
                (7, l10n.contactPauseWeek),
                (30, l10n.contactPauseMonth),
                (90, l10n.contactPauseQuarter),
              ])
                OutlinedButton(
                  onPressed: () => s.people.pause(person.id, days),
                  child: Text(label),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteField extends StatefulWidget {
  const _NoteField({required this.person});

  final Person person;

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  late final _controller = TextEditingController(text: widget.person.note);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _save();
    });
  }

  void _save() {
    final text = _controller.text.trim();
    if (text == (widget.person.note ?? '')) return;
    context.services.people.update(
      widget.person.id,
      note: Value(text.isEmpty ? null : text),
    );
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    focusNode: _focus,
    minLines: 2,
    maxLines: 6,
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(hintText: context.l10n.contactNoteHint),
    onTapOutside: (_) => _focus.unfocus(),
  );
}

class _History extends StatelessWidget {
  const _History({required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = DateFormat.yMMMEd(l10n.localeName).add_Hm();
    return StreamBuilder<List<HistoryEntry>>(
      stream: context.services.suggestions.watchHistory(
        personId: personId,
        limit: 50,
      ),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return PaddedCard(child: Text(l10n.contactNoHistory));
        }
        return Card(
          child: Column(
            children: [
              for (final h in items)
                ListTile(
                  dense: true,
                  leading: Icon(eventIcon(h.event.kind)),
                  title: Text(l10n.eventName(h.event.kind)),
                  subtitle: Text(format.format(h.event.at)),
                ),
            ],
          ),
        );
      },
    );
  }
}
