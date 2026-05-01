import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sakinah_flow/features/auth/providers/auth_provider.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/sync/services/sync_service.dart';

part 'sync_provider.g.dart';

/// Owns the lifecycle of the [SyncService] for the currently signed-in user.
///
/// When a user signs in, this starts sync. When they sign out, it stops.
/// Switching users (rare — would need to sign out then sign in as someone
/// else on the same device) tears down the old service and starts a new
/// one for the new uid.
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  SyncService? _service;
  String? _activeUid;

  @override
  Future<void> build() async {
    final authAsync = ref.watch(authStateChangesProvider);
    final user = authAsync.valueOrNull;
    final newUid = user?.uid;

    // No-op if uid hasn't actually changed.
    if (newUid == _activeUid) return;

    // Tear down previous service.
    if (_service != null) {
      await _service!.stop();
      _service = null;
    }
    _activeUid = newUid;

    if (newUid == null) {
      // Signed out — sync stays off. Local data continues to work as guest.
      return;
    }

    final db = ref.read(habitsDatabaseProvider);
    final service = SyncService(database: db, uid: newUid);
    _service = service;

    ref.onDispose(() async {
      await service.stop();
    });

    try {
      await service.start();
    } catch (e) {
      debugPrint('SyncController: failed to start sync: $e');
    }
  }

  /// Force a remote re-sync. Useful after a network outage clears, or after
  /// returning to the foreground.
  Future<void> resync() async {
    if (_service == null) return;
    await _service!.stop();
    await _service!.start();
  }

  /// Permanently delete the user's cloud data. Caller is responsible for
  /// then deleting the FirebaseAuth account and signing out.
  Future<void> deleteAllRemoteData() async {
    await _service?.deleteAllRemoteData();
  }
}
