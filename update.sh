#!/bin/bash
set -e

API_URL="https://webapi.lowiro.com/webapi/serve/static/bin/arcaea/apk/"

echo "Fetching APK metadata from API..."
RESPONSE=$(curl -s "$API_URL")

SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
if [ "$SUCCESS" != "true" ]; then
    echo "API request failed: $RESPONSE"
    exit 1
fi

APK_URL=$(echo "$RESPONSE" | jq -r '.value.url')
VERSION=$(echo "$RESPONSE" | jq -r '.value.version')
VERSION_NAME="${VERSION%c}"

if [ -n "$GITHUB_ENV" ]; then
    echo "ARCAEA_VERSION=$VERSION_NAME" >> "$GITHUB_ENV"
fi

echo "Latest version: $VERSION"

APK_PATH="arcaea_latest.apk"
echo "Downloading APK..."
curl -L -o "$APK_PATH" "$APK_URL"

echo "Extracting assets/app-data/..."
unzip -q "$APK_PATH" "assets/app-data/*"

echo "Moving extracted files..."
cp -R assets/app-data/* .

echo "Cleaning up APK file and temporary directories..."
rm -rf "$APK_PATH" assets

echo "Process completed successfully."
