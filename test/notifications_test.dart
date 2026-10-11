import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mai_stay_in_touch/data/repositories/suggestion_repository.dart';
import 'package:mai_stay_in_touch/services/daily_notifications.dart';
import 'package:mai_stay_in_touch/services/pending_actions.dart';

void main() {
  late Directory tmp;
  setUp(() async => tmp = await Directory.systemTemp.createTemp('pending_'));
  tearDown(() => tmp.delete(recursive: true));

  test('Payload hin und zurück, Kaputtes wird ignoriert', () {
    final p = NotificationPayload(
      day: DateTime(2026, 10, 12),
      personId: 'p1',
      queuePath: '/x/q.jsonl',
    );
    final back = NotificationPayload.parse(p.encode())!;
    expect(back.day, DateTime(2026, 10, 12));
    expect(back.personId, 'p1');
    expect(back.queuePath, '/x/q.jsonl');
    expect(NotificationPayload.parse('{kaputt'), isNull);
    expect(NotificationPayload.parse('{"d":"2026-10-12"}'), isNull);
    expect(NotificationPayload.parse(null), isNull);
  });

  test('„Heute nicht“ im Hintergrund landet in der Warteschlange', () async {
    final path = '${tmp.path}/sub/${PendingActions.fileName}';
    final payload = NotificationPayload(
      day: DateTime(2026, 10, 12),
      personId: 'p1',
      queuePath: path,
    ).encode();
    await notificationBackgroundHandler(
      NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
        actionId: 'later',
        payload: payload,
      ),
    );
    // Unbekannte Aktion: nichts.
    await notificationBackgroundHandler(
      NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
        actionId: 'unbekannt',
        payload: payload,
      ),
    );
    File(path).writeAsStringSync('kaputt\n', mode: FileMode.append);
    final queue = PendingActions(path);
    final taken = await queue.take();
    expect(taken, hasLength(1));
    expect(taken.single.action, SuggestionAction.later);
    expect(taken.single.personId, 'p1');
    expect(taken.single.day, DateTime(2026, 10, 12));
    expect(await queue.take(), isEmpty);
  });

  test('geplant wird nur, was noch kommt', () {
    final now = DateTime(2026, 10, 12, 19);
    final planned = DailyNotifications.plannedTimes(
      picks: [
        (DateTime(2026, 10, 12), 'heute'),
        (DateTime(2026, 10, 13), 'morgen'),
      ],
      minutes: 18 * 60,
      now: now,
    );
    expect(planned, [(DateTime(2026, 10, 13, 18), 'morgen')]);
  });
}
