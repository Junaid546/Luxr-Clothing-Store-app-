// Client-side rate limiting to prevent abuse.
// This is a SECONDARY protection — primary is server rules.
// Prevents rapid-fire button taps and API spam.

class RateLimiter {
  RateLimiter._();

  // Track last operation times per operation key
  static final _lastOperations = <String, DateTime>{};
  static final _operationCounts = <String, int>{};

  // ── Check if operation is allowed ─────────────────
  // Returns true if operation can proceed.
  // Returns false if rate limit exceeded.
  static bool canProceed(
    String operationKey, {
    Duration minInterval = const Duration(seconds: 1),
    int maxPerMinute = 10,
  }) {
    final now = DateTime.now();
    final lastOp = _lastOperations[operationKey];

    // Check minimum interval between calls
    if (lastOp != null) {
      final elapsed = now.difference(lastOp);
      if (elapsed < minInterval) {
        return false;
      }
    }

    // Check max per minute
    final countKey = '${operationKey}_${now.minute}';
    final count = _operationCounts[countKey] ?? 0;
    if (count >= maxPerMinute) {
      return false;
    }

    // Update tracking
    _lastOperations[operationKey] = now;
    _operationCounts[countKey] = count + 1;

    // Clean up old entries (> 2 minutes old)
    final keysToRemove = _operationCounts.keys.where((k) {
      if (!k.contains('_')) return false;
      final minute = int.tryParse(
            k.split('_').last,
          ) ??
          -1;
      return (now.minute - minute).abs() > 1;
    }).toList();
    keysToRemove.forEach(_operationCounts.remove);

    return true;
  }

  // ── Specific rate limits ───────────────────────────

  // Login attempts: max 5 per minute
  static bool canAttemptLogin(String email) => canProceed(
        'login_${email.hashCode}',
        minInterval: const Duration(seconds: 3),
        maxPerMinute: 5,
      );

  // Registration: max 3 per 10 minutes
  static bool canAttemptRegistration() => canProceed(
        'registration',
        minInterval: const Duration(seconds: 5),
        maxPerMinute: 3,
      );

  // Search: max 20 per minute (debounced in UI anyway)
  static bool canSearch() => canProceed(
        'search',
        minInterval: const Duration(milliseconds: 100),
        maxPerMinute: 20,
      );

  // Add to cart: max 10 per minute
  static bool canAddToCart() => canProceed(
        'add_to_cart',
        minInterval: const Duration(milliseconds: 500),
      );

  // Order placement: max 3 per 10 minutes
  static bool canPlaceOrder() => canProceed(
        'place_order',
        minInterval: const Duration(seconds: 5),
        maxPerMinute: 3,
      );

  // Password reset: max 3 per hour
  static bool canRequestPasswordReset(String email) => canProceed(
        'password_reset_${email.hashCode}',
        minInterval: const Duration(minutes: 5),
        maxPerMinute: 1,
      );

  // Clear all limits (for testing or logout)
  static void reset() {
    _lastOperations.clear();
    _operationCounts.clear();
  }
}
