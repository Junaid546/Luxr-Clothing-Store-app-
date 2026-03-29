import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/core/providers/repository_providers.dart';
import 'package:style_cart/features/auth/domain/entities/user_entity.dart';
import 'package:style_cart/features/auth/presentation/providers/auth_state_notifier.dart';

part 'shared_providers.g.dart';

// Cart item count for badge - real-time updates from Firestore
@riverpod
Stream<int> cartItemCount(CartItemCountRef ref) {
  final authState = ref.watch(authNotifierProvider);
  final userId = authState is AuthAuthenticated ? authState.user.uid : null;

  if (userId == null) return Stream.value(0);

  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(userId)
      .collection('cart')
      .snapshots()
      .map((snap) => snap.docs.length);
}

// Current authenticated user — convenience provider
@riverpod
UserEntity? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState is AuthAuthenticated ? authState.user : null;
}

// Is user admin — for conditional UI
@riverpod
bool isAdmin(IsAdminRef ref) {
  return ref.watch(currentUserProvider)?.isAdmin ?? false;
}
