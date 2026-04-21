#!/usr/bin/env bash
set -euo pipefail

OWNER="${1:-bthien235}"
REPO="${2:-Tool_IECS}"
INSTALL_DIR="${3:-$HOME/Applications}"

ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  ASSET_NAME="ZaloTool-macos-arm.zip"
else
  ASSET_NAME="ZaloTool-macos-intel.zip"
fi

API_URL="https://api.github.com/repos/${OWNER}/${REPO}/releases/latest"
TMP_DIR="$(mktemp -d)"
ZIP_PATH="$TMP_DIR/$ASSET_NAME"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Fetching latest release metadata..."
JSON="$(curl -fsSL -H "User-Agent: ZaloToolInstaller" "$API_URL")"
URL="$(printf '%s' "$JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); n='$ASSET_NAME'; print(next((a['browser_download_url'] for a in d.get('assets',[]) if a.get('name')==n), ''))")"

if [[ -z "$URL" ]]; then
  echo "Asset not found: $ASSET_NAME"
  exit 1
fi

mkdir -p "$INSTALL_DIR"

echo "Downloading $ASSET_NAME..."
curl -fL -H "User-Agent: ZaloToolInstaller" "$URL" -o "$ZIP_PATH"

echo "Extracting..."
ditto -x -k "$ZIP_PATH" "$TMP_DIR/unzip"

APP_PATH="$(find "$TMP_DIR/unzip" -maxdepth 2 -type d -name "ZaloTool.app" | head -n 1 || true)"
if [[ -z "$APP_PATH" ]]; then
  echo "ZaloTool.app not found in archive"
  exit 1
fi

TARGET_APP="$INSTALL_DIR/ZaloTool.app"
rm -rf "$TARGET_APP"
cp -R "$APP_PATH" "$TARGET_APP"
xattr -dr com.apple.quarantine "$TARGET_APP" || true

echo "Installed to: $TARGET_APP"
echo "Launching app..."
open "$TARGET_APP"
