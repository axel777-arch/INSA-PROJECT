import 'dart:async';

class SyncTracker {
  DateTime? lastSyncedTime;
  final Function(String) onDisplayUrlChanged;
  Timer? _timer;

  SyncTracker({required this.onDisplayUrlChanged});

  void initialize() {
    lastSyncedTime = DateTime.now();
    updateSyncString();

    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      updateSyncString();
    });
  }

  void updateSyncString() {
    if (lastSyncedTime == null) {
      onDisplayUrlChanged('Never');
      return;
    }

    final difference = DateTime.now().difference(lastSyncedTime!);
    
    if (difference.inSeconds < 60) {
      onDisplayUrlChanged('Just now');
    } else if (difference.inMinutes < 60) {
      onDisplayUrlChanged('${difference.inMinutes}m ago');
    } else if (difference.inHours < 24) {
      onDisplayUrlChanged('${difference.inHours}h ago');
    } else {
      onDisplayUrlChanged('${difference.inDays}d ago');
    }
  }

  void recordSync() {
    lastSyncedTime = DateTime.now();
    updateSyncString();
  }

  void dispose() {
    _timer?.cancel();
  }
}
