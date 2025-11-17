#!/bin/bash

# ABB Robot Reader - IPA Build Script
# This script builds the iOS app and creates an IPA file

set -e

PROJECT_NAME="ABBRobotReader"
SCHEME_NAME="ABBRobotReader"
CONFIGURATION="Release"
ARCHIVE_PATH="build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="build/ipa"
IPA_NAME="${PROJECT_NAME}.ipa"

echo "🏗️  Building ABB Robot Reader iOS App..."
echo "=================================="

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build

# Create build directory
mkdir -p build

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

echo ""
echo "✅ Build completed successfully!"
echo "📍 IPA file location: ${EXPORT_PATH}/${IPA_NAME}"
echo ""
echo "To install on device:"
echo "  1. Open Xcode"
echo "  2. Go to Window > Devices and Simulators"
echo "  3. Select your device"
echo "  4. Drag and drop the IPA file to install"
echo ""
