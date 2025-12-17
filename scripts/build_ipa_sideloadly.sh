#!/usr/bin/env bash

# Quick build script to produce an .ipa for Sideloadly installation.
# Supports two modes:
#  - unsigned (fast): uses `flutter build ios --no-codesign` and packages the .app into an .ipa
#  - signed (requires signing assets): archives and exports a signed .ipa via xcodebuild
#
# Usage examples:
#  ./scripts/build_ipa_sideloadly.sh --mode unsigned --ipa-name SmartFactoryConnect
#  ./scripts/build_ipa_sideloadly.sh --mode signed --method ad-hoc --team TEAMID --ipa-name SmartFactoryConnect
#
# Notes:
#  - For `unsigned` mode: you can drop the produced .ipa into Sideloadly; Sideloadly will handle signing.
#  - For `signed` mode: you must provide a valid `--team` (development team id) and proper provisioning
#    profiles installed (or configure automatic signing in Xcode). Signed export may fail if signing
#    assets are incomplete.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT="${SCRIPT_DIR}/.."
cd "$PROJECT_ROOT"

MODE="unsigned"
EXPORT_METHOD="ad-hoc"
DEVELOPMENT_TEAM=""
IPA_NAME="App"
CLEAN=true

print_usage() {
  cat <<EOF
Usage: $0 [--mode unsigned|signed] [--method ad-hoc|development|app-store|enterprise] [--team TEAMID] [--ipa-name NAME] [--no-clean]

Examples:
  $0 --mode unsigned --ipa-name SmartFactoryConnect
  $0 --mode signed --method ad-hoc --team ABCDE12345 --ipa-name SmartFactoryConnect

EOF
}

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"; shift 2;;
    --method)
      EXPORT_METHOD="$2"; shift 2;;
    --team)
      DEVELOPMENT_TEAM="$2"; shift 2;;
    --ipa-name)
      IPA_NAME="$2"; shift 2;;
    --no-clean)
      CLEAN=false; shift 1;;
    -h|--help)
      print_usage; exit 0;;
    *)
      echo "Unknown arg: $1"; print_usage; exit 1;;
  esac
done

echo "📦 Building IPA (mode: $MODE) ..."

# check flutter
if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ Flutter not found in PATH. Install Flutter and try again." >&2
  exit 1
fi

if $CLEAN; then
  echo "🧹 flutter clean"
  flutter clean
fi

echo "📥 flutter pub get"
flutter pub get

# CocoaPods
if [ -d ios ]; then
  echo "📦 Running pod install (ios)
"
  (cd ios && pod install --repo-update)
fi

if [ "$MODE" = "unsigned" ]; then
  echo "🔨 Building iOS app (no codesign)"
  flutter build ios --release --no-codesign

  # find built .app
  APP_PATH="build/ios/iphoneos/Runner.app"
  if [ ! -d "$APP_PATH" ]; then
    echo "❌ Could not find built app at $APP_PATH" >&2
    exit 1
  fi

  IPA_DIR="build/ipa"
  mkdir -p "$IPA_DIR"
  TMP_DIR="$IPA_DIR/Payload"
  rm -rf "$TMP_DIR"
  mkdir -p "$TMP_DIR"

  echo "📂 Copying .app into Payload"
  cp -R "$APP_PATH" "$TMP_DIR/"

  pushd "$IPA_DIR" >/dev/null
  ZIP_NAME="${IPA_NAME}.ipa"
  echo "📦 Zipping Payload -> $ZIP_NAME"
  rm -f "$ZIP_NAME"
  zip -r "$ZIP_NAME" Payload >/dev/null
  mv -f "$ZIP_NAME" ../
  popd >/dev/null

  # cleanup
  rm -rf "$IPA_DIR"

  IPA_PATH="$(pwd)/${IPA_NAME}.ipa"
  echo "✅ Unsigned IPA created: $IPA_PATH"
  echo "ℹ️ You can now drag-and-drop this IPA into Sideloadly to install on your iPhone."
  exit 0

elif [ "$MODE" = "signed" ]; then
  echo "🔐 Building signed IPA (archive + export)"
  if [ -z "$DEVELOPMENT_TEAM" ]; then
    echo "❌ --team TEAMID is required for signed mode" >&2
    exit 1
  fi

  ARCHIVE_PATH="build/ios/archive/${IPA_NAME}.xcarchive"
  EXPORT_PATH="build/ios/export"
  mkdir -p "$(dirname "$ARCHIVE_PATH")"

  echo "📦 Running xcodebuild archive..."
  xcodebuild -workspace ios/Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    clean archive DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM"

  # generate exportOptions plist
  EXPORT_PLIST="$(mktemp /tmp/exportOptions.XXXX.plist)"
  cat > "$EXPORT_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>teamID</key>
  <string>${DEVELOPMENT_TEAM}</string>
  <key>method</key>
  <string>${EXPORT_METHOD}</string>
  <key>compileBitcode</key>
  <false/>
</dict>
</plist>
PLIST

  echo "📤 Exporting archive to IPA (method: $EXPORT_METHOD)"
  rm -rf "$EXPORT_PATH"
  mkdir -p "$EXPORT_PATH"

  xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportOptionsPlist "$EXPORT_PLIST" -exportPath "$EXPORT_PATH"

  # find ipa
  IPA_FOUND=$(ls "$EXPORT_PATH"/*.ipa 2>/dev/null || true)
  if [ -z "$IPA_FOUND" ]; then
    echo "❌ No .ipa found in $EXPORT_PATH. Export may have failed." >&2
    echo "📌 Check xcodebuild output for signing/provisioning errors." >&2
    exit 1
  fi

  # move ipa to project root and rename
  DEST_IPA="$(pwd)/${IPA_NAME}.ipa"
  mv -f "$IPA_FOUND" "$DEST_IPA"
  echo "✅ Signed IPA created: $DEST_IPA"
  rm -f "$EXPORT_PLIST"
  exit 0

else
  echo "Unknown mode: $MODE" >&2
  print_usage
  exit 1
fi
