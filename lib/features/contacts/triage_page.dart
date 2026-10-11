import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../data/app_database.dart';
import '../../domain/importance.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common.dart';
import '../../widgets/labels.dart';

/// Einordnen: noch nicht eingeordnete Kontakte nacheinander, mit einem
/// Tipp pro Person.
class TriagePage extends StatefulWidget {
  const TriagePage({super.key});

  @override
  State<TriagePage> createState() => _TriagePageState();
}

class _TriagePageState extends State<TriagePage> {
  List<Person>? _queue;
  int _index = 0;
  int _skipped = 0;

  /// Für „Rückgängig“: (Position, vorherige Einordnung).
  final _undo = <(int, Importance?)>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final list = await context.services.people.watchUnrated().first;
      if (mounted) setState(() => _queue = list);
    });
  }

  Future<void> _rate(Importance? importance) async {
    final queue = _queue!;
    final person = queue[_index];
    if (importance == null) {
      _skipped++;
    } else {
      await context.services.people.setImportance(person.id, importance);
    }
    _undo.add((_index, importance));
    if (mounted) setState(() => _index++);
  }

  Future<void> _back() async {
    if (_undo.isEmpty) return;
    final (index, importance) = _undo.removeLast();
    if (importance == null) {
      _skipped--;
    } else {
      await context.services.people.setImportance(_queue![index].id, null);
    }
    if (mounted) setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final queue = _queue;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.triageTitle),
        actions: [
          if (_undo.isNotEmpty)
            IconButton(
              tooltip: l10n.commonUndo,
              icon: const Icon(Icons.undo),
              onPressed: _back,
            ),
        ],
      ),
      body: queue == null
          ? const Center(child: CircularProgressIndicator())
          : queue.isEmpty
          ? EmptyState(
              icon: Icons.check_circle_outline,
              title: l10n.triageDoneTitle,
              message: l10n.triageEmpty,
            )
          : _index >= queue.length
          ? EmptyState(
              icon: Icons.celebration_outlined,
              title: l10n.triageDoneTitle,
              message: [
                l10n.triageDoneText,
                if (_skipped > 0) l10n.triageSkipped(_skipped),
              ].join('\n\n'),
              action: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonDone),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                LinearProgressIndicator(value: _index / queue.length),
                const SizedBox(height: 8),
                Text(
                  l10n.triageProgress(_index + 1, queue.length),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Center(child: PersonAvatar(queue[_index].name, radius: 40)),
                const SizedBox(height: 12),
                Text(
                  queue[_index].name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                if (queue[_index].phone != null)
                  Text(
                    queue[_index].phone!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  l10n.triageQuestion,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final i in Importance.ranked)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      color: i == Importance.never
                          ? null
                          : theme.colorScheme.primaryContainer.withValues(
                              alpha: 0.25 + 0.15 * i.index,
                            ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: Icon(importanceIcon(i)),
                        title: Text(l10n.importanceName(i)),
                        subtitle: Text(l10n.importanceHint(i)),
                        onTap: () => _rate(i),
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () => _rate(null),
                  child: Text(l10n.commonSkip),
                ),
              ],
            ),
    );
  }
}
