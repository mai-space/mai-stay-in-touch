import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../data/repositories/people_repository.dart';
import '../../data/settings.dart';
import '../../l10n/l10n.dart';
import '../../services/daily_notifications.dart';
import '../contacts/contacts_page.dart';
import '../settings/settings_page.dart';

/// Einrichtung beim ersten Start: Idee, Kontakte holen, Uhrzeit.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pages = PageController();
  int _page = 0;
  bool _notify = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() => _pages.nextPage(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );

  Future<void> _finish() async {
    final s = context.services;
    await s.settings.setFlag(SettingKeys.notificationsEnabled, _notify);
    await s.settings.set(SettingKeys.onboarded, '1');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final last = _page == 2;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _Step(
                    icon: Icons.phone_in_talk_outlined,
                    title: l10n.onboardingWelcomeTitle,
                    texts: [l10n.onboardingWelcomeText, l10n.onboardingPrivacyText],
                  ),
                  _Step(
                    icon: Icons.contacts_outlined,
                    title: l10n.onboardingImportTitle,
                    texts: [l10n.onboardingImportText],
                    child: StreamBuilder<List<PersonView>>(
                      stream: context.services.people.watchAll(),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return Column(
                          children: [
                            FilledButton.icon(
                              onPressed: () => openImport(context),
                              icon: const Icon(Icons.download),
                              label: Text(l10n.todayImport),
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.onboardingImported(count)),
                          ],
                        );
                      },
                    ),
                  ),
                  _Step(
                    icon: Icons.notifications_active_outlined,
                    title: l10n.onboardingNotifyTitle,
                    texts: [l10n.onboardingNotifyText],
                    child: StreamBuilder<String?>(
                      stream: context.services.settings.watch(
                        SettingKeys.notificationMinutes,
                      ),
                      builder: (context, snapshot) {
                        final minutes =
                            int.tryParse(snapshot.data ?? '') ??
                            Settings.defaultNotificationMinutes;
                        return Column(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => pickNotificationTime(context, minutes),
                              icon: const Icon(Icons.schedule),
                              label: Text(formatMinutes(context, minutes)),
                            ),
                            const SizedBox(height: 12),
                            if (_notify)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline),
                                  const SizedBox(width: 8),
                                  Text(l10n.onboardingNotifyOn),
                                ],
                              )
                            else
                              FilledButton.icon(
                                onPressed: !DailyNotifications.supported
                                    ? null
                                    : () async {
                                        final ok = await context.services
                                            .notifications
                                            .requestPermission();
                                        if (mounted) setState(() => _notify = ok);
                                      },
                                icon: const Icon(Icons.notifications_outlined),
                                label: Text(l10n.onboardingNotifyButton),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: last ? _finish : _next,
                    child: Text(last ? l10n.onboardingStart : l10n.commonContinue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.title,
    required this.texts,
    this.child,
  });

  final IconData icon;
  final String title;
  final List<String> texts;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      children: [
        Icon(icon, size: 72, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        for (final t in texts) ...[
          const SizedBox(height: 16),
          Text(t, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
        ],
        if (child != null) ...[const SizedBox(height: 32), child!],
      ],
    );
  }
}
