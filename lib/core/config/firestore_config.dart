import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreConfig {
  FirestoreConfig._();

  static Future<void> configure() async {
    final firestore = FirebaseFirestore.instance;

    // ── Enable offline persistence ─────────────────
    // Firestore caches data locally (SQLite on mobile).
    // App works offline; syncs when back online.
    // Cache size: UNLIMITED as requested
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      sslEnabled: true,
    );

    // ── Enable network when app starts ─────────────
    // If device was offline previously, explicitly
    // enable network to start syncing
    try {
      await firestore.enableNetwork();
    } catch (_) {
      // Already enabled — ignore
    }

    debugPrint(
      '✓ Firestore configured: persistence enabled',
    );
  }

  // ── Disable network (for offline mode / testing) ──
  static Future<void> goOffline() async {
    await FirebaseFirestore.instance.disableNetwork();
  }

  // ── Re-enable network ──────────────────────────────
  static Future<void> goOnline() async {
    await FirebaseFirestore.instance.enableNetwork();
  }

  // ── Clear local cache ──────────────────────────────
  // Call when user logs out to prevent data leakage
  static Future<void> clearCache() async {
    await FirebaseFirestore.instance.clearPersistence();
  }
}
