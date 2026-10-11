import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../data/app_database.dart';
import '../../l10n/l10n.dart';
import 'contacts_page.dart';

/// Neuen Kontakt von Hand anlegen; öffnet danach die Kontaktseite.
Future<void> addContact(BuildContext context) async {
  final result = await showDialog<(String, String)>(
    context: context,
    builder: (_) => const _ContactDialog(),
  );
  if (result == null || !context.mounted) return;
  final id = await context.services.people.add(
    name: result.$1,
    phone: result.$2,
  );
  if (context.mounted) await openPerson(context, id);
}

/// Name und Nummer ändern.
Future<void> editContact(BuildContext context, Person person) async {
  final result = await showDialog<(String, String)>(
    context: context,
    builder: (_) => _ContactDialog(person: person),
  );
  if (result == null || !context.mounted) return;
  await context.services.people.update(
    person.id,
    name: Value(result.$1),
    phone: Value(result.$2),
  );
}

class _ContactDialog extends StatefulWidget {
  const _ContactDialog({this.person});

  final Person? person;

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.person?.name);
  late final _phone = TextEditingController(text: widget.person?.phone);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context, (_name.text.trim(), _phone.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.person == null ? l10n.contactsAdd : l10n.contactEdit),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: widget.person == null,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.contactName),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? l10n.contactNameRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.contactPhone),
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}
