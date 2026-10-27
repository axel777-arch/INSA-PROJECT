import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Turns a past time into a short label such as "Just now", "45s ago",
/// "5 min ago", "2 h ago" or "3 d ago". Returns "Never" when [time] is null.
String formatSyncAge(DateTime? time, {DateTime? now}) {
  if (time == null) return 'Never';
  final diff = (now ?? DateTime.now()).difference(time);
  if (diff.isNegative || diff.inSeconds < 10) return 'Just now';
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  return '${diff.inDays} d ago';
}

/// Keeps a dashboard "live".
///
/// * Refreshes silently every [interval] while the screen is visible and the
///   app is in the foreground (polling stops while the app is in background).
/// * When the app comes back to the foreground it syncs straight away if the
///   last successful sync is older than [staleAfter].
/// * Remembers the last successful sync time (per [storageKey]) so the
///   "Last synced" label is real, survives app restarts, and keeps counting
///   up ("Just now" -> "40s ago" -> "3 min ago" ...).
///
/// [refresh] must load the data and return `true` on success or `false` on
/// failure. Only a successful refresh updates "last synced".
class LiveSyncController with WidgetsBindingObserver {
  LiveSyncController({
    required this.storageKey,
    required this.refresh,
    required this.onChanged,
    this.interval = const Duration(seconds: 15),
    this.staleAfter = const Duration(seconds: 15),
  });

  final String storageKey;
  final Future<bool> Function() refresh;
  final VoidCallback onChanged;
  final Duration interval;
  final Duration staleAfter;

  DateTime? lastSyncedAt;
  bool isSyncing = false;

  bool _busy = false;
  bool _disposed = false;
  Timer? _pollTimer;
  Timer? _labelTimer;

  /// Text for the "Last synced" label.
  String get label => formatSyncAge(lastSyncedAt);

  String get _prefsKey => 'last_synced_$storageKey';

  /// Call from initState. Syncs immediately by default.
  Future<void> start({bool syncImmediately = true}) async {
    WidgetsBinding.instance.addObserver(this);
    _startTimers();
    try {
      final prefs = await SharedPreferences.getInstance();
      final ms = prefs.getInt(_prefsKey);
      if (ms != null && lastSyncedAt == null) {
        lastSyncedAt = DateTime.fromMillisecondsSinceEpoch(ms);
        _notify();
      }
    } catch (_) {}
    if (syncImmediately) await syncNow(silent: true);
  }

  /// Sync now. [silent] = true keeps the banner spinner off (used by polling).
  Future<void> syncNow({bool silent = false}) async {
    if (_busy || _disposed) return;
    _busy = true;
    if (!silent) {
      isSyncing = true;
      _notify();
    }
    var ok = false;
    try {
      ok = await refresh();
    } catch (_) {
      ok = false;
    }
    _busy = false;
    isSyncing = false;
    if (ok && !_disposed) {
      lastSyncedAt = DateTime.now();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_prefsKey, lastSyncedAt!.millisecondsSinceEpoch);
      } catch (_) {}
    }
    _notify();
  }

  void _startTimers() {
    _pollTimer?.cancel();
    _labelTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) => syncNow(silent: true));
    // Re-draw the label so "Just now" keeps counting up on its own.
    _labelTimer = Timer.periodic(const Duration(seconds: 10), (_) => _notify());
  }

  void _stopTimers() {
    _pollTimer?.cancel();
    _labelTimer?.cancel();
    _pollTimer = null;
    _labelTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;
    if (state == AppLifecycleState.resumed) {
      _startTimers();
      final last = lastSyncedAt;
      if (last == null || DateTime.now().difference(last) >= staleAfter) {
        syncNow(silent: true);
      } else {
        _notify();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _stopTimers();
    }
  }

  void _notify() {
    if (!_disposed) onChanged();
  }

  /// Call from dispose.
  void dispose() {
    _disposed = true;
    _stopTimers();
    WidgetsBinding.instance.removeObserver(this);
  }
}
