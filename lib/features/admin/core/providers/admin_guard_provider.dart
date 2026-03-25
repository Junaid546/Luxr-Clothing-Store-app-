import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:style_cart/app/router/route_names.dart';
import 'package:style_cart/features/auth/data/providers/auth_providers.dart';

part 'admin_guard_provider.g.dart';

@riverpod
bool adminGuard(AdminGuardRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
}

mixin AdminGuardMixin on ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(adminGuardProvider);
    
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(RouteNames.home);
        }
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return buildAdmin(context, ref);
  }

  Widget buildAdmin(BuildContext context, WidgetRef ref);
}
