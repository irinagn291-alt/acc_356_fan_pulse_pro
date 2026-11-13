# Fan Pulse

Native SwiftUI football answer competition. Account label acc_356 maps to factory account ID 358; local bundle app.fanpulse.local. Reference: Superbet composition only. All UI is English, as explicitly requested; English (UK) is the development language. iOS 17+, Swift 6, iPhone and iPad.

## Product
Home, Round, Leagues and Profile preserve independent navigation. Home contains a red hero, season statistics and featured match. Each round has five offline training fixtures, answers, optional exact scores, deadlines, review and results. Personal ranking contains only the local player. Profile shows accuracy, achievement progress and opt-in local reminders. No fabricated live participants or live sports claims.

Outcome earns 3 points; exact score adds 2; incorrect and cancelled matches earn zero. Answers must agree with exact scores. Deadline comparison uses absolute Date values, displayed in the device timezone. Answers close at kickoff, not after. Confirmed postponement to a future kickoff reopens answers and preserves picks. Results are derived rather than incremented: retries and corrections cannot double-credit points. Training round completion is explicitly confirmed. Reset requires confirmation.

Local season and answers persist atomically as JSON in Documents. Failures are surfaced. Offline mode is the default; local play needs no network or key. The HTTPFixtureProvider adapter accepts ISO-8601 fixture JSON; it is not connected to a live provider. Images are original vector pitch artwork and system sport symbols. Palette #ED2939, #17191F, #252830, #FFD45A; 16pt gutters, 44pt or larger actions, adaptive scroll layout, semantic text, monospaced numbers and Reduce Motion-aware selection.

## Friends server
Isolated standard-library Python/SQLite server with registration/login, salted password hashing, random expiring bearer sessions, league creation, invitation codes, idempotent membership, membership-protected fixtures and ranking, private answers before kickoff and visible member answers afterwards. Server fixtures and local device fixtures are separate. Server standings never trust client points. Server data persists in its SQLite file. The iOS client supports server setup, account creation/login, creation/join/share, round answering and ranking. Server runs on loopback, with no production deployment. Local CLI alone manages results, corrections, cancellation and confirmed postponement.

## Validation
Swift domain assertions: scoring, idempotence, corrections, cancellation, closed deadlines including exact boundary, reopen, inconsistent score rejection and JSON round trip. Python tests: auth, access control, repeated invitation join, privacy, deadlines, correction/cancellation, and reopen. XCUITest: home, navigation, saved answer, relaunch persistence and main tabs. Factory simulator pool and build slots required for QA.

## External dependencies
Production hosting/TLS, operational hardening, real sports provider and Apple signing remain outside this local implementation. No purchases, advertising, money or shipping pipeline.
