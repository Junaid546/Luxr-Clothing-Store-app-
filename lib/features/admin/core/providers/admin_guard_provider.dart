import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/features/auth/data/providers/auth_providers.dart';

part 'admin_guard_provider.g.dart';

@riverpod
AsyncValue<bool> adminGuard(AdminGuardRef ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return const AsyncValue.data(false);
      // 🔥 TEMPORARY: Allow all logged-in users to access admin for TESTING
      // Revert this to: (user.isAdmin) after testing
      return const AsyncValue.data(true); 
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
}

mixin AdminGuardMixin on ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardStatus = ref.watch(adminGuardProvider);
    
    return guardStatus.when(
      data: (isAdmin) {
        if (!isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(RouteNames.home);
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return buildAdmin(context, ref);
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget buildAdmin(BuildContext context, WidgetRef ref);
}
