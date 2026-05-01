import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sakinah_flow/features/auth/data/auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository();

/// Stream of FirebaseAuth state changes.
@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

/// The current signed-in user, or null. Convenient sync accessor when you
/// already know the auth state stream has emitted at least once.
@riverpod
User? currentUser(Ref ref) {
  return ref.watch(authStateChangesProvider).valueOrNull;
}

/// True when the user has explicitly chosen to continue without signing in.
/// Stored in SharedPreferences so it survives app restarts.
@riverpod
class GuestMode extends _$GuestMode {
  @override
  Future<bool> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return repo.isGuestMode();
  }

  Future<void> set(bool value) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.setGuestMode(value);
    state = AsyncData(value);
  }
}
