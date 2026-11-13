<!-- gf-brief source=f7c423b71ec90310efa0b504cd1ba62837f4c0c1b5ec8c99cf8da2e50af8c563 written=2026-11-14T01:47:06+03:00 -->
# Fan Pulse

## What it is

Fan Pulse is a football prediction app for people who want to practise picking match outcomes and scores. It offers an offline training season and optional friends’ leagues on a server supplied by the user; its training fixtures and results are simulated, with no live sports feed.

## Launch and onboarding

On a first cold launch, the app opens directly to “Home”; there is no onboarding or account requirement. It creates a local training season with five demo fixtures and no saved answers.

The screen shows “FAN / PULSE”, “LOCAL TRAINING”, “SEASON 01”, “MATCHDAY CHALLENGE”, “Your club. Your instinct.” and “Build your round. Raise your accuracy.” The “Make your picks” button opens “Round”. The first fixture and “My personal league” also lead directly to an answer screen and the personal leaderboard respectively.

On later launches, the saved local season is restored.

## Screens

### “Home”

“Home” shows “Season points”, “Answers saved”, “Match of the round”, the first fixture and “My personal league”. Fixture cards show “TRAINING LEAGUE”, team names, kick-off in the device’s time zone and a status such as “Answer”, “Answer saved”, “Finished” or “Cancelled”.

- “Make your picks” opens “Round”.
- The first fixture opens “Your answer”.
- “My personal league” opens “Leaderboard”.

The footer identifies the fixtures as demo content, gives their generation time and says “No live sports feed. Works offline.”

### “Round” / “This round”

“This round” shows “ROUND 01 · LOCAL SEASON”, “Make every answer count.”, the number of unanswered open fixtures and “3 points for the outcome + 2 for an exact score”. It lists all five fixture cards.

- Tap a fixture to open “Your answer”.
- “Round results” opens the results screen.
- The bottom bar shows “My answers: [number]/5”; “Review answers” also opens “Round results”.

### “Your answer”

The screen shows the fixture, “Who will win?” and either “Closes [date and time] · your time” or “Answers closed”.

- Tap the home team, “Draw” or the away team to select an outcome.
- “Add an exact score” reveals score controls for each named team, from 0 to 20.
- “Save answer” saves a new answer and returns to the previous screen. For an existing answer, “Update answer” saves changes and returns.
- Answers can be edited until kick-off. The screen explains that wrong answers and cancelled matches score zero, and that a postponed match reopens when its new kick-off is confirmed while existing answers are kept.

### “Round results”

“Round results” shows “ROUND 01”, “The final whistle.”, “Round points” and “Correct outcomes”. Each fixture shows the saved “Your answer”, any “Exact score”, or “No answer saved”, followed by “Result pending” or the points awarded.

- “Finish training round” opens “Finish this local round? Answers will close.” Confirming with “Finish training round” supplies simulated scores and closes the answers.
- The screen explains: “Training results are simulated. Scores are always recalculated from the latest result, never added twice.”

### “Leaderboard”

“Leaderboard” shows “PERSONAL LEAGUE”, “Set your standard.”, the local display name, first place and points. It explains that only the user plays in the local league and that a server can be connected in “Leagues” to compete with friends.

“How points work” states “Correct outcome: 3 points”, “Exact score: 2 extra points” and “Incorrect or cancelled: 0 points”. “See every point” opens “Round results”.

### “Leagues”

“Leagues” shows “Better together.” and “My personal league”, which opens “Leaderboard”. Under “Friends' leagues”, it explains that the local season stays on the device and server leagues use separate fixtures and scores.

When disconnected, the screen shows “LOCAL MODE” and these fields and controls:

- “Server URL”, “Username” and “Password (at least 10 characters)” collect the server address and credentials.
- “Create account” registers with the configured server.
- “Sign in” signs in to it.

When connected, it shows “CONNECTED SERVER”:

- “New league name” and “Create league” create a friends’ league.
- “Invitation code” and “Join with code” join one.
- Each league row shows its name and invitation code; tapping it opens the league.
- “Sign out” leaves the connected view.

A league opens as a sheet showing its name, standings and “Server training round”:

- “Invite: [code]” opens the system sharing controls for the invitation code.
- For an open fixture, tap a team name or “Draw” to save an outcome; it can be changed until kick-off.
- “Optional exact score” opens “Home: [number]” and “Away: [number]” score controls. “Save exact score” saves the score and its implied outcome.
- For a closed fixture, “View members' answers” displays members’ answers or “No answers saved.”
- “Refresh round and ranking” reloads the fixtures and standings.
- “Done” closes the league.

Server fixtures are described as “Demo fixtures on your server · updated when refreshed”. The sheet says “Server league · points from server fixtures only”.

### “Profile”

“Profile” shows “YOUR FAN ID”, “Keep the pulse.”, “Local season”, “Outcome accuracy” and “Achievements”.

- “Display name” edits the local name; submit the field to save it.
- “First answer · not yet unlocked” changes to “First answer · unlocked” after a saved answer.
- “Full house · answer all 5 matches” changes to “Full house · unlocked” after all five answers are saved.
- “Enable match reminders” requests notification permission and schedules reminders. After permission is granted during the session, the button reads “Refresh match reminders”.
- “Season results” opens “Round results”.
- “Start a fresh training season” opens “Archive this season and start again?”; “Start new season” confirms it. Earlier seasons with answers appear below as dated points and accuracy records.

### “Round progress” widget

The small and medium home-screen widget is described as “Your training picks and earned points.” It shows “Your training round”, picks saved, points and correct predictions. Tapping it opens “Round”.

Before widget data is available, it shows “Open the app to begin”, “Save your matchday picks.” and “Your progress will appear here”.

## Features

- Five-fixture “LOCAL TRAINING” season with outcome and optional exact-score answers.
- “Round results” with simulated scores, points and correct outcomes.
- “My personal league” and its scoring explanation.
- Friends’ leagues with accounts, invitation codes, standings and separate server fixtures.
- “Achievements”, “Outcome accuracy” and archived season results.
- Match reminders and the “Round progress” widget.

## Behaviours that can look like bugs

- “Save answer” is disabled until an outcome is selected. Select a team or “Draw” first.
- An exact score must match the selected outcome. Otherwise “Something needs attention” appears with “The exact score must agree with your selected outcome.” Adjust the score or outcome and save again.
- At kick-off, or when a match is finished or cancelled, “Answers closed” appears and answer controls are disabled. Existing answers remain visible; start a fresh training season for new open fixtures.
- “Finish training round” closes all answers, even if some have “No answer saved”. Confirm it only when ready to see simulated results.
- Before scoring, results show “Result pending”; before any answers, they show “No answer saved”. Save answers and finish the training round to populate them.
- A newly connected account with no leagues shows “Your team starts here” and “Create a league or enter a friend's code.” Create or join a league to populate the list.
- While “Contacting your server…” appears, the league screen is disabled. If a request fails, the screen says “Check the server address and connection, then try again. Your local season is available offline.”
- If notifications are denied, the alert says “Notifications are off. You can enable them in Settings.” Enable them in device settings, then use the reminder control again.
- Starting a fresh season resets the current fixtures and answers. A season is added to the history only if it had at least one saved answer; the history grows as eligible seasons are archived.
- If saved data cannot be read, the alert says “Your saved season could not be read. The file is preserved; restart to try again.” A failed save says “Your changes could not be saved. Please try again.”

## Starter content and resume

A new local season starts with “North London” versus “Merseyside”, “Manchester” versus “West London”, “Brighton” versus “Newcastle”, “Birmingham” versus “Nottingham”, and “Bournemouth” versus “Leeds”. Their kick-offs are generated two to six hours after the season is created. The default display name is “You”.

Saved local answers, results and season history can be resumed after reopening the app. Answers remain editable until their fixture closes. Friends’ league data belongs to the configured server; the app’s connected session is not retained after a restart, so the user must sign in again.

## Permissions

- **Notifications:** requested when the user taps “Enable match reminders”. The app requests alert and sound permission. There is no separate usage-description string.
- **Local network:** the system may ask when the app attempts to contact a local league server. The usage-description string is “Connect to your local Fan Pulse league server.”

## Absent

In-app purchases, ads, analytics, an account deletion flow and an App Tracking Transparency prompt are absent.

Login and accounts are present for optional friends’ leagues. User-generated content is present in the form of display names, league names and prediction answers.

## Data and support

The local season, answers, display name and season history stay on the device. Friends’ account and league activity is sent to the server the user configures; local season points are not uploaded to that server.

There is no on-screen Contact or Support control.

## Scanning and health

None. The app does not scan barcodes or QR codes and does not show health, medical or product-health information.

## Platform

The app uses English with an English (UK) development region. Match dates and times follow the device’s time zone. It supports iPhone and iPad, portrait and both landscape orientations, and requires iOS 17.0 or later.

## Category

Sports.
