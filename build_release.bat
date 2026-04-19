@echo off
REM Production Build Script for ConfessNepal (Windows)

echo Building ConfessNepal Production Release...

echo Cleaning previous builds...
call flutter clean

echo Getting dependencies...
call flutter pub get

echo Building release APK with obfuscation...
call flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols --target-platform android-arm,android-arm64,android-x64 --split-per-abi

echo Build complete!
echo APK files are in: build\app\outputs\flutter-apk\
echo Debug symbols saved to: build\app\outputs\symbols\
echo.
echo IMPORTANT: Keep the symbols directory for crash reporting!
pause
