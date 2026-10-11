import 'dart:async';

import 'package:flutter/material.dart';

import '../app/services.dart';
import '../features/contacts/contacts_page.dart';
import '../features/history/history_page.dart';
import '../features/today/actions.dart';
import '../features/today/today_page.dart';
import '../home_widgets/home_widgets.dart';
import '../l10n/l10n.dart';
import '../services/daily_notifications.dart';

/// Drei Bereiche: Heute · Kontakte · Verlauf.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;
  StreamSubscription<WidgetLink>? _links;
  StreamSubscription<NotificationTap>? _taps;

  /// Übernimmt „Heute nicht“ aus der Benachrichtigung auch, während die App
  /// offen ist (die Aktion läuft im Hintergrund-Isolat).
  Timer? _pendingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final s = context.services;
      _links = s.widgets.links.stream.listen(_openLink);
      _taps = s.notifications.taps.stream.listen(_openTap);
      await _refresh();
      s.notifications.init().catchError((Object _) {});
      s.widgets.start().catchError((Object _) {});
      s.watchForNotifications();
      s.scheduleNotifications();
      _startPendingTimer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _links?.cancel();
    _taps?.cancel();
    _pendingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final s = context.services;
    switch (state) {
      case AppLifecycleState.resumed:
        _refresh();
        _startPendingTimer();
      case AppLifecycleState.paused:
        _pendingTimer?.cancel();
        // „Heute/Morgen“ aktuell halten.
        s.widgets.publish().catchError((_) {});
      default:
        break;
    }
  }

  void _startPendingTimer() {
    _pendingTimer?.cancel();
    _pendingTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => context.services.applyPending().catchError((Object _) => 0),
    );
  }

  /// Warteschlange übernehmen und den heutigen Vorschlag festhalten.
  Future<void> _refresh() async {
    final s = context.services;
    try {
      await s.applyPending();
      await s.suggestions.ensureToday();
    } catch (e) {
      debugPrint('Aktualisieren fehlgeschlagen: $e');
    }
  }

  void _openLink(WidgetLink link) {
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    setState(() => _index = 0);
    final action = link.action;
    if (action != null && link.day != null && link.personId != null) {
      runSuggestionAction(context, link.day!, link.personId!, action);
    }
  }

  void _openTap(NotificationTap tap) {
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    setState(() => _index = 0);
    final action = tap.action;
    if (action == null) return;
    runSuggestionAction(context, tap.payload.day, tap.payload.personId, action);
  }

  void _open(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [TodayPage(), ContactsPage(), HistoryPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _open,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.tabToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.tabContacts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.tabHistory,
          ),
        ],
      ),
    );
  }
}
