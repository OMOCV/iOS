#!/bin/bash

# ABB Robot Reader - IPA Build Script
# Builds a signed IPA using manual code signing settings.

set -eo pipefail

PROJECT_NAME=${PROJECT_NAME:-"ABBRobotReader"}
SCHEME_NAME=${SCHEME_NAME:-"ABBRobotReader"}
CONFIGURATION=${CONFIGURATION:-"Release"}
APP_BUNDLE_ID=${APP_BUNDLE_ID:-"com.omocv.ABBRobotReader"}
EXPORT_METHOD=${EXPORT_METHOD:-"ad-hoc"}
DEVELOPMENT_TEAM=${DEVELOPMENT_TEAM:-""}
CODE_SIGN_IDENTITY=${CODE_SIGN_IDENTITY:-"Apple Distribution"}
PROVISIONING_PROFILE_SPECIFIER=${PROVISIONING_PROFILE_SPECIFIER:-""}

ARCHIVE_PATH="build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="build/ipa"
IPA_NAME="${PROJECT_NAME}.ipa"
PROFILE_DEST="${HOME}/Library/MobileDevice/Provisioning Profiles/${PROJECT_NAME}.mobileprovision"

if [[ -z "${DEVELOPMENT_TEAM}" || -z "${PROVISIONING_PROFILE_SPECIFIER}" ]]; then
  echo "❌ DEVELOPMENT_TEAM and PROVISIONING_PROFILE_SPECIFIER must be set for a signed build."
  exit 1
fi

install_provisioning_profile() {
  mkdir -p "$(dirname "${PROFILE_DEST}")"

  if [[ -n "${PROVISIONING_PROFILE_BASE64}" ]]; then
    echo "📄 Installing provisioning profile from base64 payload..."
    echo "${PROVISIONING_PROFILE_BASE64}" | base64 --decode > "${PROFILE_DEST}"
  elif [[ -n "${PROVISIONING_PROFILE_PATH}" && -f "${PROVISIONING_PROFILE_PATH}" ]]; then
    echo "📄 Installing provisioning profile from ${PROVISIONING_PROFILE_PATH}..."
    cp "${PROVISIONING_PROFILE_PATH}" "${PROFILE_DEST}"
  else
    echo "⚠️  No provisioning profile provided. Ensure the required profile is already installed."
  fi

  if [[ -f "${PROFILE_DEST}" ]]; then
    echo "✅ Provisioning profile installed at ${PROFILE_DEST}"
  fi
}

create_export_options() {
  cat > build/ExportOptions.plist <<EOF_OPTIONS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>${EXPORT_METHOD}</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>teamID</key>
  <string>${DEVELOPMENT_TEAM}</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>${APP_BUNDLE_ID}</key>
    <string>${PROVISIONING_PROFILE_SPECIFIER}</string>
  </dict>
  <key>compileBitcode</key>
  <false/>
  <key>stripSwiftSymbols</key>
  <true/>
</dict>
</plist>
EOF_OPTIONS

  plutil -lint build/ExportOptions.plist
}

clean_build_artifacts() {
  echo "🧹 Cleaning previous builds..."
  rm -rf build
  mkdir -p build
}

archive_project() {
  echo "📦 Creating archive..."
  xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
    DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM}" \
    PROVISIONING_PROFILE_SPECIFIER="${PROVISIONING_PROFILE_SPECIFIER}" \
    PRODUCT_BUNDLE_IDENTIFIER="${APP_BUNDLE_ID}"

  if [[ ! -d "${ARCHIVE_PATH}" ]]; then
    echo "❌ Archive was not created."
    exit 1
  fi

  echo "✅ Archive created at ${ARCHIVE_PATH}"
}

export_ipa() {
  echo "📤 Exporting IPA..."
  xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${EXPORT_PATH}" \
    -exportOptionsPlist build/ExportOptions.plist \
    -allowProvisioningUpdates

  if [[ ! -f "${EXPORT_PATH}/${IPA_NAME}" ]]; then
    echo "❌ IPA export failed."
    ls -la "${EXPORT_PATH}" || true
    exit 1
  fi

  echo "✅ IPA exported to ${EXPORT_PATH}/${IPA_NAME}"
}

main() {
  echo "🏗️  Building ${PROJECT_NAME} iOS App..."
  echo "=================================="

  clean_build_artifacts
  install_provisioning_profile
  create_export_options
  archive_project
  export_ipa

  echo ""
  echo "📍 IPA file location: ${EXPORT_PATH}/${IPA_NAME}"
  echo ""
  echo "To install on device:"
  echo "  1. Open Xcode"
  echo "  2. Go to Window > Devices and Simulators"
  echo "  3. Select your device"
  echo "  4. Drag and drop the IPA file to install"
  echo ""
}

main "$@"
