#!/bin/bash

# Production Build Script for ConfessNepal
# This script builds a secure, optimized release APK

echo "🚀 Building ConfessNepal Production Release..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation if needed
# flutter pub run build_runner build --delete-conflicting-outputs

# Build release APK with obfuscation
echo "🔨 Building release APK with obfuscation..."
flutter build apk \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols \
  --target-platform android-arm,android-arm64,android-x64 \
  --split-per-abi

echo "✅ Build complete!"
echo "📱 APK files are in: build/app/outputs/flutter-apk/"
echo "🔐 Debug symbols saved to: build/app/outputs/symbols/"
echo ""
echo "⚠️  IMPORTANT: Keep the symbols directory for crash reporting!"
