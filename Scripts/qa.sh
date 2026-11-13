#!/bin/bash
set -euo pipefail
cd /Users/belzephyrus/Documents/gambling_factory
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
OUT="$PWD/output/FanPulse-implementation"
xcrun simctl boot "$GF_SIMULATOR_UDID" || true
xcrun simctl bootstatus "$GF_SIMULATOR_UDID" -b
export FANPULSE_DB="$OUT/qa-server-$(date +%s).sqlite"
PORT=18766 .venv/bin/python ios/apps/FanPulse/backend/server.py > "$OUT/qa-server.log" 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2>/dev/null || true' EXIT
.venv/bin/python ios/apps/FanPulse/Scripts/test_build.py
xcrun simctl launch "$GF_SIMULATOR_UDID" app.fanpulse.local
xcrun simctl io "$GF_SIMULATOR_UDID" screenshot "$OUT/home.png"
xcrun simctl get_app_container "$GF_SIMULATOR_UDID" app.fanpulse.local data > "$OUT/container.txt"
