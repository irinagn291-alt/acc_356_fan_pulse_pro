# Fan Pulse

Open `FanPulse.xcodeproj` with Xcode 27.2 or a Swift 6-capable Xcode. Deployment target iOS 17. All screens are in English.

From the factory root:

```sh
.venv/bin/python ios/apps/FanPulse/Scripts/build.py
.venv/bin/python -m unittest discover -s ios/apps/FanPulse/backend -v
.venv/bin/python ios/apps/FanPulse/backend/server.py
```

Server defaults to `http://127.0.0.1:8765` and stores `backend/fanpulse.sqlite`. Open Leagues in the simulator, create an account with a 10+ character password, create a league, share the invitation code, then sign in as another account to join. The URL is editable. Sessions expire after 24 hours; app restart requires sign-in. No password is persisted by the app.

Use the same Python interpreter for `backend/manage.py result 1 --home 2 --away 1`, `cancel 1`, or `postpone 1 --kickoff 2026-12-01T18:00:00+00:00`. Corrections replace results and standings are recomputed on every request. Postponement preserves answers. `FANPULSE_DB` and `PORT` isolate parallel server instances. The bundled server is for local validation; a phone cannot reach the Mac using its own loopback address. Password hashing uses PBKDF2-HMAC-SHA256 with 600,000 iterations and a random per-user salt. Production requires HTTPS, deployment, rate limiting and account recovery.

Run the entire `Scripts/qa.sh` under the factory `gf/genesis/simulator_pool.py TEMPLATE_UDID bash …` helper. It uses `GF_SIMULATOR_UDID`, disables parallel testing, and preserves the xcresult/screenshots in `output/FanPulse-implementation`. No shipping is invoked.
