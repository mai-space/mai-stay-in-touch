import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../data/repositories/people_repository.dart';
import '../../l10n/l10n.dart';
import '../../services/device_contacts.dart';
import '../../widgets/common.dart';
import '../../widgets/labels.dart';

/// Kontakte aus dem Adressbuch auswählen und übernehmen. Gibt die Zahl der
/// neu übernommenen Kontakte zurück.
class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

enum _State { loading, denied, permanentlyDenied, unsupported, ready }

class _ImportPageState extends State<ImportPage> {
  _State _state = _State.loading;
  List<DeviceContact> _contacts = const [];
  Set<String> _known = const {};
  final _selected = <String>{};
  String _query = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final s = context.services;
    setState(() => _state = _State.loading);
    final permission = await s.contacts.requestPermission();
    if (!mounted) return;
    switch (permission) {
      case ContactsPermission.denied:
        setState(() => _state = _State.denied);
        return;
      case ContactsPermission.permanentlyDenied:
        setState(() => _state = _State.permanentlyDenied);
        return;
      case ContactsPermission.unsupported:
        setState(() => _state = _State.unsupported);
        return;
      case ContactsPermission.granted:
        break;
    }
    try {
      final contacts = await s.contacts.load();
      final known = await s.people.knownSystemIds();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _known = known;
        // Vorauswahl: alle, die noch nicht in der App sind.
        _selected
          ..clear()
          ..addAll(contacts.map((c) => c.systemId).where((id) => !known.contains(id)));
        _state = _State.ready;
      });
    } catch (e) {
      debugPrint('Kontakte nicht lesbar: $e');
      if (mounted) setState(() => _state = _State.denied);
    }
  }

  Future<void> _import() async {
    final l10n = context.l10n;
    final s = context.services;
    setState(() => _busy = true);
    try {
      // Bekannte immer mit abgleichen (Name/Nummer aktualisieren).
      final chosen = _contacts
          .where((c) => _selected.contains(c.systemId) || _known.contains(c.systemId))
          .toList();
      final result = await s.people.import(chosen);
      if (!mounted) return;
      showSnack(context, l10n.importResult(result.added));
      Navigator.pop(context, result.added);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fresh = _contacts.where((c) => !_known.contains(c.systemId)).toList();
    final q = _query.toLowerCase();
    final shown = _contacts
        .where((c) => q.isEmpty || c.name.toLowerCase().contains(q))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importTitle),
        actions: [
          if (_state == _State.ready && fresh.isNotEmpty)
            TextButton(
              onPressed: () => setState(() {
                if (_selected.length == fresh.length) {
                  _selected.clear();
                } else {
                  _selected
                    ..clear()
                    ..addAll(fresh.map((c) => c.systemId));
                }
              }),
              child: Text(
                _selected.length == fresh.length
                    ? l10n.importSelectNone
                    : l10n.importSelectAll,
              ),
            ),
        ],
      ),
      bottomNavigationBar: _state == _State.ready
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton.icon(
                  onPressed: _busy || (_selected.isEmpty && _known.isEmpty)
                      ? null
                      : _import,
                  icon: const Icon(Icons.download_done),
                  label: Text(l10n.importButton(_selected.length)),
                ),
              ),
            )
          : null,
      body: switch (_state) {
        _State.loading => const Center(child: CircularProgressIndicator()),
        _State.unsupported => EmptyState(
          icon: Icons.contacts_outlined,
          title: l10n.importTitle,
          message: l10n.importUnsupported,
        ),
        _State.denied || _State.permanentlyDenied => EmptyState(
          icon: Icons.lock_outline,
          title: l10n.importTitle,
          message: l10n.importDenied,
          action: _state == _State.permanentlyDenied
              ? FilledButton(
                  onPressed: () => context.services.contacts.openSettings(),
                  child: Text(l10n.importOpenSettings),
                )
              : FilledButton(onPressed: _load, child: Text(l10n.commonRetry)),
        ),
        _State.ready when _contacts.isEmpty => EmptyState(
          icon: Icons.contacts_outlined,
          title: l10n.importTitle,
          message: l10n.importNone,
        ),
        _State.ready => ListView.builder(
          itemCount: shown.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.importIntro),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (v) => setState(() => _query = v.trim()),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l10n.commonSearch,
                      ),
                    ),
                  ],
                ),
              );
            }
            final c = shown[i - 1];
            final known = _known.contains(c.systemId);
            return CheckboxListTile(
              secondary: PersonAvatar(c.name),
              title: Text(c.name),
              subtitle: Text(known ? l10n.importAlready : c.phones.first),
              value: known || _selected.contains(c.systemId),
              onChanged: known
                  ? null
                  : (v) => setState(() {
                      v == true
                          ? _selected.add(c.systemId)
                          : _selected.remove(c.systemId);
                    }),
            );
          },
        ),
      },
    );
  }
}
