#!/bin/bash

set -e

cd "$(dirname "$0")"

APPLICATION_NAME=Erosion

echo "[*] $APPLICATION_NAME Build Script"

rm -rf build

if ls *.ipa 1> /dev/null 2>&1; then
    rm -rf *.ipa
fi

WORKING_LOCATION="$(pwd)"

if [ ! -d "build" ]; then
    mkdir build
fi

cd build

echo "[*] Building..."
if [[ $* == *--debug* ]]; then
xcodebuild -project "$WORKING_LOCATION/$APPLICATION_NAME.xcodeproj" \
    -scheme "$APPLICATION_NAME" \
    -configuration Debug \
    -derivedDataPath "$WORKING_LOCATION/build/DerivedDataApp" \
    -destination 'generic/platform=iOS' \
    clean build \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO"

DD_APP_PATH="$WORKING_LOCATION/build/DerivedDataApp/Build/Products/Debug-iphoneos/$APPLICATION_NAME.app"
TARGET_APP="$WORKING_LOCATION/build/$APPLICATION_NAME.app"
cp -r "$DD_APP_PATH" "$TARGET_APP"
else
xcodebuild -project "$WORKING_LOCATION/$APPLICATION_NAME.xcodeproj" \
    -scheme "$APPLICATION_NAME" \
    -configuration Release \
    -derivedDataPath "$WORKING_LOCATION/build/DerivedDataApp" \
    -destination 'generic/platform=iOS' \
    clean build \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO"

DD_APP_PATH="$WORKING_LOCATION/build/DerivedDataApp/Build/Products/Release-iphoneos/$APPLICATION_NAME.app"
TARGET_APP="$WORKING_LOCATION/build/$APPLICATION_NAME.app"
cp -r "$DD_APP_PATH" "$TARGET_APP"
fi

echo "[*] Stripping signature..."
codesign --remove "$TARGET_APP"
if [ -e "$TARGET_APP/_CodeSignature" ]; then
    rm -rf "$TARGET_APP/_CodeSignature"
fi
if [ -e "$TARGET_APP/embedded.mobileprovision" ]; then
    rm -rf "$TARGET_APP/embedded.mobileprovision"
fi

echo "[*] Packaging..."
mkdir Payload
cp -r $APPLICATION_NAME.app Payload/$APPLICATION_NAME.app
zip -vr $APPLICATION_NAME.ipa Payload

echo "[*] All done, cleaning up..."
rm -rf Payload

cd ..
if [[ $* == *--debug* ]]; then
mv "$WORKING_LOCATION/build/$APPLICATION_NAME.ipa" ./$APPLICATION_NAME.debug.ipa
else
mv "$WORKING_LOCATION/build/$APPLICATION_NAME.ipa" .
fi
rm -rf "$WORKING_LOCATION/build/"
