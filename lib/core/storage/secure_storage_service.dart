import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'secure_storage_service.g.dart';

// Wraps both SharedPreferences (non-sensitive) and
// FlutterSecureStorage (sensitive) with a unified API.

class SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  const SecureStorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  // ── Sensitive data (encrypted) ─────────────────────
  // Use for: auth tokens, user IDs, payment info

  Future<void> writeSecure(String key, String value) => _secureStorage.write(key: key, value: value);

  Future<String?> readSecure(String key) => _secureStorage.read(key: key);

  Future<void> deleteSecure(String key) => _secureStorage.delete(key: key);

  Future<void> clearAllSecure() => _secureStorage.deleteAll();

  // ── Non-sensitive data (plain) ─────────────────────
  // Use for: UI preferences, feature flags,
  //          notification permission asked

  Future<void> writeBool(String key, bool value) => _prefs.setBool(key, value);

  bool readBool(String key, {bool defaultValue = false}) => _prefs.getBool(key) ?? defaultValue;

  Future<void> writeString(String key, String value) => _prefs.setString(key, value);

  String? readString(String key) => _prefs.getString(key);

  Future<void> writeInt(String key, int value) => _prefs.setInt(key, value);

  int readInt(String key, {int defaultValue = 0}) => _prefs.getInt(key) ?? defaultValue;

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clearAll() => _prefs.clear();

  // ── Storage key constants ──────────────────────────
  static const String keyNotificationAsked = 'notification_permission_asked';
  static const String keyThemeMode = 'theme_mode';
  static const String keyRecentSearches = 'recent_searches';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyLastSyncTime = 'last_sync_time';
}

@riverpod
Future<SecureStorageService> secureStorageService(SecureStorageServiceRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SecureStorageService(
    secureStorage: const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        // Use Android Keystore for encryption
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
    prefs: prefs,
  );
}
