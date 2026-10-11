import 'dart:async';

import 'package:flutter/material.dart';

/// Lädt [load] neu, sobald [changes] feuert (z. B. Datenbankänderungen).
class LiveBuilder<T> extends StatefulWidget {
  const LiveBuilder({
    super.key,
    required this.load,
    required this.changes,
    required this.builder,
  });

  final Future<T> Function() load;
  final Stream<void> changes;
  final Widget Function(BuildContext context, T value) builder;

  @override
  State<LiveBuilder<T>> createState() => _LiveBuilderState<T>();
}

class _LiveBuilderState<T> extends State<LiveBuilder<T>> {
  T? _value;
  bool _loaded = false;
  StreamSubscription<void>? _sub;
  Timer? _debounce;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _reload();
    _sub = widget.changes.listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 50), _reload);
    });
  }

  Future<void> _reload() async {
    final generation = ++_generation;
    final value = await widget.load();
    if (!mounted || generation != _generation) return;
    setState(() {
      _value = value;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());
    return widget.builder(context, _value as T);
  }
}
