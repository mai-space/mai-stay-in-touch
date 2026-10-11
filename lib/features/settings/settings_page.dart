import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../data/settings.dart';
import '../../domain/days.dart';
import '../../l10n/l10n.dart';
import '../../services/daily_notifications.dart';
import '../../widgets/common.dart';
import '../../widgets/labels.dart';
import '../contacts/contacts_page.dart';
import 'backup_section.dart';

/// Einstellungen: Benachrichtigung, Vorschlagstage, WhatsApp-Vorwahl,
/// Diskretion, Kontakte und Daten.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = context.services;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: StreamBuilder<Map<String, String>>(
        stream: s.settings.watchAll(),
        builder: (context, snapshot) {
          final map = snapshot.data;
          if (map == null) return const SizedBox.shrink();
          final enabled = map.flag(SettingKeys.notificationsEnabled);
          final minutes = map.number(
            SettingKeys.notificationMinutes,
            Settings.defaultNotificationMinutes,
          );
          final days = Days.parseWeekdays(map[SettingKeys.suggestionDays]);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              SectionTitle(l10n.settingsSuggestions),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: Text(l10n.settingsNotifications),
                      subtitle: Text(l10n.settingsNotificationsText),
                      value: enabled,
                      onChanged: !DailyNotifications.supported
                          ? null
                          : (v) async {
                              if (v) await s.notifications.requestPermission();
                              await s.settings.setFlag(
                                SettingKeys.notificationsEnabled,
                                v,
                              );
                            },
                    ),
                    ListTile(
                      enabled: enabled,
                      leading: const Icon(Icons.schedule),
                      title: Text(l10n.settingsTime),
                      trailing: Text(
                        formatMinutes(context, minutes),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onTap: () => pickNotificationTime(context, minutes),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsDays,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          WeekdayPicker(
                            selected: days,
                            onChanged: (d) => s.settings.set(
                              SettingKeys.suggestionDays,
                              Days.formatWeekdays(d),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.public),
                      title: Text(l10n.settingsCountryCode),
                      subtitle: Text(l10n.settingsCountryCodeText),
                      trailing: FutureBuilder<String>(
                        future: s.countryCode(),
                        builder: (context, cc) => Text(
                          '+${cc.data ?? ''}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      onTap: () => _editCountryCode(context),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.visibility_off_outlined),
                      title: Text(l10n.settingsDiscreet),
                      subtitle: Text(l10n.settingsDiscreetText),
                      value: map.flag(SettingKeys.discreet),
                      onChanged: (v) => s.settings.setFlag(SettingKeys.discreet, v),
                    ),
                  ],
                ),
              ),
              SectionTitle(l10n.settingsContacts),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: Text(l10n.contactsImport),
                      onTap: () => openImport(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.sort),
                      title: Text(l10n.triageTitle),
                      onTap: () => openTriage(context),
                    ),
                  ],
                ),
              ),
              SectionTitle(l10n.settingsData),
              const PaddedCard(child: BackupSection()),
              SectionTitle(l10n.settingsPrivacy),
              PaddedCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.settingsPrivacyText)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editCountryCode(BuildContext context) async {
    final s = context.services;
    final l10n = context.l10n;
    final controller = TextEditingController(text: await s.countryCode());
    if (!context.mounted) return;
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsCountryCode),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '+'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    final digits = value?.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits == null || digits.isEmpty || digits.length > 4) return;
    await s.settings.set(SettingKeys.countryCode, digits);
  }
}

String formatMinutes(BuildContext context, int minutes) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );

Future<void> pickNotificationTime(BuildContext context, int minutes) async {
  final s = context.services;
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
  );
  if (t == null) return;
  await s.settings.set(SettingKeys.notificationMinutes, '${t.hour * 60 + t.minute}');
}

/// Wochentage Mo … So zum An-/Abwählen (mindestens einer bleibt).
class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var d = 1; d <= 7; d++)
          FilterChip(
            showCheckmark: false,
            label: Text(l10n.weekdayShort(d)),
            selected: selected.contains(d),
            onSelected: (v) {
              final next = {...selected};
              v ? next.add(d) : next.remove(d);
              if (next.isNotEmpty) onChanged(next);
            },
          ),
      ],
    );
  }
}
