import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stylecart/app/router/route_names.dart';
import 'package:stylecart/features/auth/data/providers/auth_providers.dart';

part 'admin_guard_provider.g.dart';

@riverpod
AsyncValue<bool> adminGuard(AdminGuardRef ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (kDebugMode) return const AsyncValue.data(true);
      if (user == null) return const AsyncValue.data(false);
      return AsyncValue.data(user.isAdmin);
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
