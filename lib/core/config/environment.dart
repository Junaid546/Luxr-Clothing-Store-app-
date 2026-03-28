import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _current = Environment.development;

  static Environment get current => _current;

  static void setEnvironment(Environment env) {
    _current = env;
  }

  static bool get isDev => _current == Environment.development;
  static bool get isStaging => _current == Environment.staging;
  static bool get isProd => _current == Environment.production;

  // Determine from build mode
  static Environment fromBuildMode() {
    if (kReleaseMode) return Environment.production;
    if (kProfileMode) return Environment.staging;
    return Environment.development;
  }
}
