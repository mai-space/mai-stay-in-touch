import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/repositories/suggestion_repository.dart';
import '../domain/days.dart';

/// Reaktion, die ohne geöffnete App kam („Heute nicht“ in der
/// Benachrichtigung). Die App übernimmt sie beim nächsten Start.
class PendingAction {
  const PendingAction({
    required this.day,
    required this.personId,
    required this.action,
    required this.at,
  });

  final DateTime day;
  final String personId;
  final SuggestionAction action;
  final DateTime at;

  Map<String, Object?> toJson() => {
    'd': Days.key(day),
    'c': personId,
    'a': action.name,
    'ts': at.millisecondsSinceEpoch,
  };

  static PendingAction? fromJson(Object? json) {
    if (json is! Map) return null;
    final day = Days.parse(json['d'] as String?);
    final person = json['c'];
    final a = json['a'];
    final action = SuggestionAction.parse(a is String ? a : null);
    final ts = json['ts'];
    if (day == null || person is! String || action == null || ts is! int) {
      return null;
    }
    return PendingAction(
      day: day,
      personId: person,
      action: action,
      at: DateTime.fromMillisecondsSinceEpoch(ts),
    );
  }
}

/// Warteschlange als Datei (eine JSON-Zeile je Reaktion) im privaten
/// App-Ordner. Enthält nur Tag, interne Kontakt-ID und Aktion — keine
/// Namen oder Nummern. Kommt ohne Plugins aus, damit sie auch im
/// Hintergrund-Isolat der Benachrichtigungen funktioniert.
class PendingActions {
  const PendingActions(this.path);

  /// Dateiname im App-Ordner (Application Support).
  static const fileName = 'pending_actions.jsonl';

  final String path;

  Future<void> add(PendingAction action) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      '${jsonEncode(action.toJson())}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  /// Liest alle Einträge und leert die Warteschlange.
  Future<List<PendingAction>> take() async {
    final file = File(path);
    if (!await file.exists()) return const [];
    final List<String> lines;
    try {
      lines = await file.readAsLines();
      await file.delete();
    } catch (e) {
      debugPrint('Warteschlange nicht lesbar: $e');
      return const [];
    }
    final out = <PendingAction>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final a = PendingAction.fromJson(jsonDecode(line));
        if (a != null) out.add(a);
      } catch (_) {
        // Kaputte Zeile überspringen.
      }
    }
    return out;
  }
}
