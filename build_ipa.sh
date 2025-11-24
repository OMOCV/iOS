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
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Create export options plist
echo "📝 Creating export options..."
cat > build/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF

# Export IPA
echo "📤 Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath ${ARCHIVE_PATH} \
    -exportPath ${EXPORT_PATH} \
    -exportOptionsPlist build/ExportOptions.plist

EXPORTED_IPA=$(find "${EXPORT_PATH}" -maxdepth 1 -name "*.ipa" | head -n 1 || true)
FINAL_IPA="${EXPORT_PATH}/${IPA_NAME}"
if [[ -n "${EXPORTED_IPA}" && "${EXPORTED_IPA}" != "${FINAL_IPA}" ]]; then
  mv "${EXPORTED_IPA}" "${FINAL_IPA}"
elif [[ -z "${EXPORTED_IPA}" ]]; then
  echo "⚠️  未找到导出的 IPA，请检查 xcodebuild 输出。"
  exit 1
fi

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
