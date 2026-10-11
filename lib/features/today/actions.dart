import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../data/repositories/suggestion_repository.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common.dart';

/// Reaktion auf einen Vorschlag aus der Oberfläche (mit Hinweis bei Fehlern).
Future<void> runSuggestionAction(
  BuildContext context,
  DateTime day,
  String personId,
  SuggestionAction action,
) async {
  final l10n = context.l10n;
  final outcome = await context.services.act(day, personId, action);
  if (!context.mounted) return;
  _report(context, l10n, outcome, action);
}

/// Direkt anrufen/schreiben (Kontaktseite).
Future<void> runReach(
  BuildContext context,
  String personId,
  SuggestionAction action,
) async {
  final l10n = context.l10n;
  final outcome = await context.services.reach(personId, action);
  if (!context.mounted) return;
  _report(context, l10n, outcome, action);
}

void _report(
  BuildContext context,
  AppLocalizations l10n,
  ActionOutcome outcome,
  SuggestionAction action,
) {
  switch (outcome) {
    case ActionOutcome.done:
      break;
    case ActionOutcome.noNumber:
      showSnack(context, l10n.noNumber);
    case ActionOutcome.launchFailed:
      showSnack(
        context,
        action == SuggestionAction.whatsapp ? l10n.whatsAppFailed : l10n.launchFailed,
      );
  }
}
