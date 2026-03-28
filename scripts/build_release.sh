#!/bin/bash

# Luxr Production Build Script
echo "Starting production build for Luxr..."

# 1. Clean
echo "Cleaning project..."
flutter clean

# 2. Get dependencies
echo "Getting dependencies..."
flutter pub get

# 3. Generate code
echo "Generating code..."
dart run build_runner build --delete-conflicting-outputs

# 4. Analyze
echo "Running analysis..."
flutter analyze

# 5. Build App Bundle
echo "Building App Bundle (.aab)..."
flutter build appbundle --release --obfuscate --split-debug-info=./build/debug_info/android

# 6. Build APKs
echo "Building APKs..."
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=./build/debug_info/apk

echo "Build complete!"
echo "AAB: build/app/outputs/bundle/release/app-release.aab"
echo "APKs: build/app/outputs/flutter-apk/"
