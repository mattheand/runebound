# Verification — M0 through M3 and provisional art intake

## Environment

- Godot `4.7.2.stable.official.ed1daf0bf`.
- macOS, Apple M4 Max, native OpenGL Compatibility renderer.
- Google Chrome `156.0.8078.79` / WebGL 2, single-threaded Emscripten export.
- Official Godot release binary and matching export templates from GitHub.
- Homebrew and Apple's Python shim were blocked by the local Xcode license state. The official engine download and existing Homebrew Python 3.13 worked without changing Xcode settings.

## Headless suite

```bash
bash tools/check.sh
```

The wrapper runs import, 43 art-contract checks and startup, then seven suites at 30 / 60 / 120 physics ticks per second with matching fixed render rates. It fails for a nonzero process exit **or** Godot script/error diagnostics. Logs go to `build/test-results/`.

| Suite | Checks per rate | Verified result |
|---|---:|---|
| `tests/run_tests.gd` — movement regression | 36 | Pass at 30/60/120 Hz |
| `tests/test_gameplay.gd` — M2 components and lifecycle | 62 | Pass at 30/60/120 Hz |
| `tests/test_traversal.gd` — complete input-driven M2 route | 22 | Pass at 30/60/120 Hz |
| `tests/test_enemies.gd` — Draugr/Raven | 34 | Pass at 30/60/120 Hz |
| `tests/test_boss.gd` — Troll mechanics | 38 | Pass at 30/60/120 Hz |
| `tests/test_combat_room.gd` — selection/intro/retry/completion | 17 | Pass at 30/60/120 Hz |
| `tests/test_combat_victory.gd` — standard-input victories | 10 | Pass at 30/60/120 Hz |

**Total: 700 passing assertions** (219 × 3 tick rates + 43 art-contract checks), zero failures. Import/startup and suite logs contain no engine/script errors or warnings. M0–M2 were explicitly accepted by the user. Before M3 work, M2 was fast-forward merged into `main` at `856a666` and all 360 pre-art/pre-M3 assertions were rerun green on main.

### Movement regression

The suite uses the shipped player scene, real StaticBody2D fixtures, actual `Input.action_press/release` calls and physics frames. The course test loads the shipped TileMapLayer scene through the actual menu Start signal. It checks:

- Gravity and spawn contact.
- Running distance/speed bounds, braking and air steering.
- Held vs tapped apex; holding cannot auto-repeat.
- One distinct air jump, rejection of a third jump, landing reset and signal.
- Fresh ground and air jumps still work when buffering is configured to zero.
- Coyote jump preserving the air jump; expired coyote consuming it.
- Buffered held jump and buffered released tap on landing; buffer expiry.
- Collision against floor, wall and ceiling.
- Menu-to-game flow, course collision, restart, fall reset, camera following/bounds and Escape-to-menu flow.

Initial red runs: missing M0 scene failed; before controller implementation, 20 movement assertions failed; before course wiring, six course-flow assertions failed. Review identified that a zero-duration buffer disabled jumping; two regression checks reproduced it, and fresh presses now work independently of buffer duration. The final suite contains 36 checks per tick rate.

Measured held / tapped apex (logical pixels), with current defaults:

| Physics ticks/s | Held | Tapped |
|---|---:|---:|
| 30 | 98.46 | 26.24 |
| 60 | 94.03 | 24.63 |
| 120 | 91.90 | 27.67 |

These measurements include discrete input sampling; they demonstrate bounded movement across tick rates, not identical trajectories. Production uses 60 physics ticks/s.

### M2 components and lifecycle

`test_gameplay.gd` checks real HealthComponent, player, sword, target, hazard, pickup, checkpoint and HUD instances:

- Three-heart damage, invulnerability expiry, healing/invalid input, one-shot death, dead-state rejection and explicit revival/grace.
- Knockback resisting held movement input, steering recovery, death input suppression and reset.
- No idle/wind-up/recovery sword damage; active-window hits; one hit per health owner with duplicate hurtboxes; self exclusion, directional knockback, cooldown and no held-button auto-repeat.
- Later swings damage again; targets die and reset; facing locks per swing; death cancels pending hits.
- Real continuous hazard overlap respects i-frames and can damage again after expiry.
- Rune registration/collection rejects empty, unknown and duplicate IDs without increasing totals.
- Actual menu → M2 scene flow, real overlap pickup/checkpoint activation, duplicate pickup instances, HUD health/count updates, delayed death, checkpoint switching, R/reset, fall death and fresh-session reset.

The suite started with failing checks before each implementation stage. Fixed-FPS tests can finish before the audio mixer releases its stopped playbacks; the gameplay/traversal test runners allow a final 100 ms real-time drain before engine shutdown. This is test teardown only; production code has no test-specific audio paths.

### Full course traversal

`test_traversal.gd` steers the shipped player through the actual M2 scene using named input actions only. It does not teleport, disable hazards or change health. It crosses the gap and both spike patches, collects all five runes, activates both checkpoints and finishes with all three hearts. Bounded waypoint checks allow normal air braking; collection/checkpoint/health assertions verify the actual route outcome.

Read-only code review found no actionable M2 functional issues and independently reran the 62-check gameplay suite at 60 Hz. Final presentation corrections were subsequently covered by the complete test run and browser inspection.

### M3 enemy and boss mechanics

- Draugr: bounded patrol, detection/chase, physical line-of-sight occlusion, ledge avoidance, wind-up/active/recovery melee, hurt interruption/knockback, dead-target rejection, death/reset.
- Raven: level patrol, warned attack, fixed aim without homing, recovery damage shutdown, route/altitude return, contact damage once per dive, hurt/death/reset.
- Troll: dormant/intro protections, idempotent encounter start, activation, normal sword damage without stun-lock, all three predictable patterns and their no-early-damage/active/recovery windows, charged-smash event, death and reset.
- Combat room: actual menu and selector inputs, safe spawn, real intro trigger and boss bar, health updates, charged-smash removal of bridge collision, restored bridge/health/intro on retry, exit unlock/trial completion, fall retry and menu return.

Initial failing scene/behavior checks preceded each implementation step. The real trigger test exposed a frame-late boss-bar visibility update; binding visibility to enemy state signals fixed it. Read-only review found no actionable M3 functional issues and independently passed all 99 M3 checks at 60 Hz.

### Standard-input victories

`test_combat_victory.gd` fights the actual opponents in the shipped room using only movement, jump and fresh sword input. Trial selection uses the same public selector as the UI. The fights do not teleport, alter health/tuning, disable collisions or invoke damage/death directly. The test fighter closes distance, faces its sword correctly after braking, jumps Raven attacks and times jumps against the Troll wind-up.

All three enemies were defeated with **3/3 hearts and no retries** at 30/60/120 Hz. Troll victories took approximately 7.4–7.6 simulated seconds of test-fighter input and completed the trial/unlocked the exit. This proves a standard-ability winning route; it is not a human difficulty or performance assessment.

### Art intake

`test_art_import.gd` verifies 43 metadata/dimension/transparency contracts for the supplied PNGs. It does not judge fidelity or seamless parallax. See `handoff/ART_HANDOFF_INTEGRATION.md`. M5 remains deferred behind its ten-criterion human visual gate.

## Native rendering

```bash
bash tools/godot.sh --script tools/capture_preview.gd
```

This opens the M3 scene in a real rendering window, waits for physics and drawing, then saves `build/screenshots/native-gameplay.png`. Add `-- --opponent=troll` or `-- --opponent=raven` for an approached opponent capture, `-- --gameplay` for M2, or `-- --movement` for M1.

To reproduce the rendered standard-input Troll victory and short native recording:

```bash
bash tools/godot.sh --write-movie build/m3-troll-victory.avi --fixed-fps 60 --script tools/capture_combat_victory.gd
```

The capture run defeated the Troll with 3/3 hearts and no retries, saved `build/screenshots/native-m3-victory.png` and recorded 573 frames at 60 FPS (about 9.6 seconds) of actual Godot gameplay. The recording's render speed is not a sustained gameplay-performance claim.

## Web export and smoke test

```bash
mkdir -p build/web
bash tools/godot.sh --headless --editor --export-release Web build/web/index.html
python3.13 -m http.server 8765 --bind 127.0.0.1 --directory build/web
```

Export templates must match the engine. Single-threaded export needs `web_nothreads_debug.zip` and `web_nothreads_release.zip`, not only the threaded `web_debug.zip` / `web_release.zip` files.

In another terminal, using an existing Playwright installation or a temporary tooling folder:

```bash
npm install --prefix "${TMPDIR%/}/runebound-browser" playwright
NODE_PATH="${TMPDIR%/}/runebound-browser/node_modules" \
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
node tests/browser_smoke.cjs
```

Run `tests/browser_combat.cjs` with the same environment for M3. The M2 smoke test explicitly selects the second menu entry; M3 remains the default.

Alternatively omit `CHROME` when Playwright's Chromium is installed. `GAME_URL` overrides the default `http://127.0.0.1:8765`.

The browser test checks that the loader completes, collects runtime/resource/HTTP errors and sends Enter, D, Space twice, J, R and Escape. It verifies that movement changes the rendered image, approaches the first dummy, attacks and walks into spikes. Inspect captures in `build/screenshots/`; pixel changes alone are not proof of each mechanic.

The final M2 captures were inspected: `browser-m2-sword.png` shows the active slash, impact and a damaged dummy; `browser-m2-damage.png` shows 2/3 hearts and hurt/invulnerability feedback; `browser-m2-respawn.png` shows 3/3 hearts restored, the target reset and the rune counter still at 1/5. The menu exposes both M2 and M1 scenes. `browser-return-menu.png` records the return flow.

Browser inspection caught native-only fallback font support for Unicode hearts. Replacing the glyphs with drawn polygon icons fixed the missing-glyph boxes; native and final Chrome captures now render the same hearts.

The first browser run caught a missing exported `player_tuning.gd`; exporting all runtime resources with explicit development exclusions fixed it. The final Chrome smoke run reported no runtime/resource/HTTP errors.

M3 Chrome smoke also passes with no runtime/resource/HTTP errors. Captures cover selector changes, a hurt Draugr after a sword hit, the Raven warning/aim line, Troll introduction and reduced boss health, slam/jump, retry and the three-entry menu. Inspect `browser-m3-*.png` under `build/screenshots/`. Boss-bar styling was adjusted after visual inspection so its default theme minimum size could not overlap the message row. Runtime state/damage correctness is asserted by the Godot suites, not inferred only from changing pixels.

## Remaining manual/compatibility checks

1. Review M3 difficulty, telegraph clarity, Raven counterplay, boss recovery windows and temporary sound balance.
2. Fight each type with normal inputs; retry during attacks/death and switch trials using the selector.
3. Check all Troll patterns, jumping the smash/slam, bridge damage/repair and the defeat/exit sequence.
4. Verify gamepad stick/D-pad, A jump, X sword, LB retry and Start menu on physical hardware.
5. Check Firefox/Safari, other browser/window sizes, and desktop targets as available.

Firefox, Safari, Windows, Linux, hardware gamepads and sustained 60 FPS performance remain untested. M0–M2 are accepted; M3 awaits human review. Audio playback paths ran without errors, but subjective sound quality/mix is not an automated test claim. M4/M5 stay deferred.
