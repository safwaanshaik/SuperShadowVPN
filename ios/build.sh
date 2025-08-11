#!/bin/bash

echo "Building SuperShadowVPN for iOS..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "Xcode is required to build iOS app"
    exit 1
fi

# Create Xcode project
cd SuperShadowVPN
swift package generate-xcodeproj

echo "iOS project generated!"
echo "Open SuperShadowVPN.xcodeproj in Xcode"
echo "Connect your iPhone and select it as target"
echo "Build and run to install on your device"
echo ""
echo "Required steps in Xcode:"
echo "1. Set your Apple Developer Team in Signing & Capabilities"
echo "2. Enable 'Personal VPN' capability"
echo "3. Change bundle identifier to unique value"
echo "4. Build and install on your iPhone"