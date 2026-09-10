#!/bin/bash
#
# Packages Pomofocus into a proper macOS .app bundle without Xcode.
#
# Why this exists: `swift run` works, but it runs a bare executable — it shows
# up in the Dock and can't post notifications. A real .app bundle (with an
# Info.plist marking LSUIElement) behaves like a true menu bar utility.
#
# Usage: ./Scripts/build_app.sh   (run from the project root)

set -euo pipefail

APP_NAME="Pomofocus"
BUILD_CONFIG="release"
BUILD_DIR=".build/${BUILD_CONFIG}"
APP_BUNDLE="build/${APP_NAME}.app"

echo "==> Building ${APP_NAME} (${BUILD_CONFIG})"
swift build -c "${BUILD_CONFIG}"

echo "==> Assembling ${APP_BUNDLE}"
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp "${APP_NAME}/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"

if [ -f "${APP_NAME}/AppIcon.icns" ]; then
  cp "${APP_NAME}/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
fi

# Ad-hoc code signature so macOS will run and let it post notifications.
echo "==> Signing (ad-hoc)"
codesign --force --deep --sign - "${APP_BUNDLE}" >/dev/null 2>&1 || \
  echo "   (ad-hoc signing skipped)"

echo "==> Done: ${APP_BUNDLE}"
echo "    Launch it with:  open \"${APP_BUNDLE}\""
