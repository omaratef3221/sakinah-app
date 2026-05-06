import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sakinah_flow/features/auth/providers/auth_provider.dart';
import 'package:sakinah_flow/features/habits/providers/habits_database_provider.dart';
import 'package:sakinah_flow/features/sync/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sync_provider.g.dart';

const kLastSignedInUidKey = 'auth_last_signed_in_uid';

/// Owns the lifecycle of the [SyncService] for the currently signed-in user.
///
/// When a user signs in, this starts sync. When they sign out, it stops.
/// Switching users tears down the old service, wipes local data so the new
/// user doesn't inherit the old user's habits, and starts a fresh sync.
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

    final wasSignedIn = _activeUid != null;

    // Tear down previous service.
    if (_service != null) {
      await _service!.stop();
      _service = null;
    }
    _activeUid = newUid;

    final db = ref.read(habitsDatabaseProvider);
    final prefs = await SharedPreferences.getInstance();

    if (newUid == null) {
      // Signed out. Wipe local data and clear the last-uid marker so the
      // next sign-in (whoever it is) starts clean. The cloud copy remains
      // intact — the user can sign back in on this or any other device to
      // restore their data.
      if (wasSignedIn) {
        await db.wipeAllLocalData();
        await prefs.remove(kLastSignedInUidKey);
      }
      return;
    }

    // If the previous signed-in user on this device was someone else, wipe
    // local data so user B doesn't inherit user A's local rows. Guest data
    // (no previous uid recorded) is preserved on first sign-in so it can
    // migrate to the new account.
    final previousUid = prefs.getString(kLastSignedInUidKey);
    if (previousUid != null && previousUid != newUid) {
      await db.wipeAllLocalData();
    }
    await prefs.setString(kLastSignedInUidKey, newUid);

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
