#!/bin/bash

###############################################################################
# ABB Robot Reader - IPA Build Script
# This script builds the iOS app and creates an IPA file.
#
# Notes:
# - Must be run on macOS with Xcode command line tools installed.
# - Uses ad-hoc signing disabled (CODE_SIGNING_ALLOWED=NO) for local archives.
# - Exports to build/ipa/ABBRobotReader.ipa by default.
###############################################################################

set -euo pipefail

PROJECT_NAME="ABBRobotReader"
SCHEME_NAME="ABBRobotReader"
CONFIGURATION="Release"
ARCHIVE_PATH="build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="build/ipa"
IPA_NAME="${PROJECT_NAME}.ipa"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "❌ 此脚本需要在 macOS 上运行（当前为 $(uname -s)）。"
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "❌ 未找到 xcodebuild，请先安装 Xcode 命令行工具：xcode-select --install"
  exit 1
fi

if [[ ! -d "${PROJECT_FILE}" ]]; then
  echo "❌ 未找到 ${PROJECT_FILE}，请从项目根目录运行此脚本。"
  exit 1
fi

echo "🏗️  Building ABB Robot Reader iOS App..."
echo "=================================="

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build

# Create build directory
mkdir -p "${EXPORT_PATH}"

# Build for iOS device (generic)
echo "📦 Building archive..."
xcodebuild archive \
    -project ${PROJECT_NAME}.xcodeproj \
    -scheme ${SCHEME_NAME} \
    -configuration ${CONFIGURATION} \
    -archivePath ${ARCHIVE_PATH} \
    -destination 'generic/platform=iOS' \
    -sdk iphoneos \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

APP_PATH="${ARCHIVE_PATH}/Products/Applications/${PROJECT_NAME}.app"
PAYLOAD_PATH="${EXPORT_PATH}/Payload"
FINAL_IPA="${EXPORT_PATH}/${IPA_NAME}"

echo "📦 Packaging IPA without re-signing..."
if [[ ! -d "${APP_PATH}" ]]; then
  echo "❌ 未找到生成的 .app，Archive 可能失败。"
  exit 1
fi

rm -rf "${PAYLOAD_PATH}" "${FINAL_IPA}"
mkdir -p "${PAYLOAD_PATH}"
cp -R "${APP_PATH}" "${PAYLOAD_PATH}/"

pushd "${EXPORT_PATH}" >/dev/null
zip -r "${IPA_NAME}" Payload >/dev/null
popd >/dev/null

if [[ ! -f "${FINAL_IPA}" ]]; then
  echo "⚠️  未能生成 IPA，请查看上方日志。"
  exit 1
fi

echo ""
echo "✅ Build completed successfully!"
echo "📍 IPA file location: ${FINAL_IPA}"
echo ""
echo "To install on device:"
echo "  1. Open Xcode"
echo "  2. Go to Window > Devices and Simulators"
echo "  3. Select your device"
echo "  4. Drag and drop the IPA file to install"
echo ""
