#!/usr/bin/env bash
set -euo pipefail

# Build script for MOpenKey macOS
# Produces Universal 2 (arm64 + x86_64) signed application, zip, and dmg.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_PATH="${ROOT_DIR}/Sources/OpenKey/macOS/OpenKey.xcodeproj"
BUILD_DIR="${ROOT_DIR}/build"
DIST_DIR="${ROOT_DIR}/dist"

echo "==> Building MOpenKey (Universal: arm64 + x86_64)..."
rm -rf "${BUILD_DIR}" "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

xcodebuild \
  -project "${PROJECT_PATH}" \
  -scheme OpenKey \
  -configuration Release \
  -derivedDataPath "${BUILD_DIR}" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="${BUILD_DIR}/Build/Products/Release/MOpenKey.app"

if [[ ! -d "${APP_PATH}" ]]; then
  echo "Error: ${APP_PATH} not found!"
  exit 1
fi

echo "==> Stripping filesystem extended attributes..."
xattr -cr "${APP_PATH}"

echo "==> Ad-hoc code signing MOpenKey.app..."
codesign --force --deep --sign - "${APP_PATH}"

echo "==> Verifying binary architectures..."
file "${APP_PATH}/Contents/MacOS/MOpenKey"

echo "==> Packaging ZIP..."
ditto -c -k --keepParent "${APP_PATH}" "${DIST_DIR}/MOpenKey-macOS-Universal.zip"

echo "==> Packaging DMG..."
DMG_PATH="${DIST_DIR}/MOpenKey-macOS-Universal.dmg"
DMG_TMP="${BUILD_DIR}/dmg_tmp"
mkdir -p "${DMG_TMP}"
cp -R "${APP_PATH}" "${DMG_TMP}/"
ln -s /Applications "${DMG_TMP}/Applications"

if hdiutil create -volname "MOpenKey" \
  -srcfolder "${DMG_TMP}" \
  -ov -format UDZO \
  "${DMG_PATH}"; then
  echo "==> DMG successfully created at ${DMG_PATH}"
else
  echo "==> Warning: hdiutil could not create DMG in current environment. ZIP distribution is ready."
fi

echo "==> Generating SHA256 checksums..."
cd "${DIST_DIR}"
shasum -a 256 *.zip $(ls *.dmg 2>/dev/null || true) > checksums.txt 2>/dev/null || shasum -a 256 *.zip > checksums.txt

echo "==> Build and Packaging Complete!"
cat "${DIST_DIR}/checksums.txt"
