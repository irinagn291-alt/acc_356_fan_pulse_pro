#!/bin/bash
set -euo pipefail
cd /Users/belzephyrus/Documents/gambling_factory
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
OUT="$PWD/output/FanPulse-implementation"
xcrun simctl boot "$GF_SIMULATOR_UDID" || true
xcrun simctl bootstatus "$GF_SIMULATOR_UDID" -b
.venv/bin/python ios/apps/FanPulse/Scripts/build.py > "$OUT/ipad-build.log" 2>&1
xcrun simctl install "$GF_SIMULATOR_UDID" "$OUT/DerivedData/Build/Products/Debug-iphonesimulator/FanPulse.app"
xcrun simctl launch "$GF_SIMULATOR_UDID" app.fanpulse.local
sleep 3
xcrun simctl io "$GF_SIMULATOR_UDID" screenshot "$OUT/ipad.png"
