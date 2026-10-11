import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_database.dart';
import '../domain/days.dart';
import '../domain/importance.dart';
import '../domain/phone.dart';
import '../l10n/l10n.dart';

extension LabelStrings on AppLocalizations {
  String importanceName(Importance? i) => switch (i) {
    null => importanceUnrated,
    Importance.never => importanceNever,
    Importance.rarely => importanceRarely,
    Importance.sometimes => importanceSometimes,
    Importance.often => importanceOften,
    Importance.veryOften => importanceVeryOften,
  };

  String importanceHint(Importance i) => switch (i) {
    Importance.never => importanceHintNever,
    Importance.rarely => importanceHintRarely,
    Importance.sometimes => importanceHintSometimes,
    Importance.often => importanceHintOften,
    Importance.veryOften => importanceHintVeryOften,
  };

  String eventName(EventKind k) => switch (k) {
    EventKind.called => eventCalled,
    EventKind.messaged => eventMessaged,
    EventKind.declined => eventDeclined,
    EventKind.noted => eventNoted,
  };

  /// „Heute“, „Morgen“, sonst „Mi., 14.10.“.
  String dayName(DateTime day, {DateTime? now}) {
    final today = Days.of(now ?? DateTime.now());
    final diff = Days.between(today, day);
    if (diff == 0) return commonToday;
    if (diff == 1) return commonTomorrow;
    return DateFormat.MMMEd(localeName).format(day);
  }

  String lastContact(DateTime? at, {DateTime? now}) => at == null
      ? lastContactNever
      : lastContactDays(Days.between(at, now ?? DateTime.now()).clamp(0, 99999));

  /// Mo … So (1 = Montag).
  String weekdayShort(int weekday) =>
      DateFormat.E(localeName).format(DateTime(2024, 1, weekday));
}

IconData importanceIcon(Importance? i) => switch (i) {
  null => Icons.help_outline,
  Importance.never => Icons.do_not_disturb_on_outlined,
  Importance.rarely => Icons.signal_cellular_alt_1_bar,
  Importance.sometimes => Icons.signal_cellular_alt_2_bar,
  Importance.often => Icons.signal_cellular_alt,
  Importance.veryOften => Icons.favorite,
};

IconData eventIcon(EventKind k) => switch (k) {
  EventKind.called => Icons.call,
  EventKind.messaged => Icons.chat_bubble_outline,
  EventKind.declined => Icons.snooze,
  EventKind.noted => Icons.check_circle_outline,
};

/// Rund mit Initialen; Farbe aus dem Namen (stabil, ohne Foto).
class PersonAvatar extends StatelessWidget {
  const PersonAvatar(this.name, {super.key, this.radius = 20});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = [
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
    ];
    final hash = name.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0xffff);
    final (bg, fg) = palette[hash % palette.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        Phone.initials(name),
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}
