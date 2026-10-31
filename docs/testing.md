# Verification — M0, M1 and M2

## Environment

- Godot `4.7.2.stable.official.ed1daf0bf`.
- macOS, Apple M4 Max, native OpenGL Compatibility renderer.
- Chrome / WebGL 2, single-threaded Emscripten export.
- Official Godot release binary and matching export templates from GitHub.
- Homebrew and Apple's Python shim were blocked by the local Xcode license state. The official engine download and existing Homebrew Python 3.13 worked without changing Xcode settings.

## Headless suite

```bash
bash tools/check.sh
```

The wrapper runs import and startup, then three suites at 30 / 60 / 120 physics ticks per second with matching fixed render rates. It fails for a nonzero process exit **or** Godot script/error diagnostics. Logs go to `build/test-results/`.

| Suite | Checks per rate | Verified result |
|---|---:|---|
| `tests/run_tests.gd` — movement regression | 36 | Pass at 30/60/120 Hz |
| `tests/test_gameplay.gd` — M2 components and lifecycle | 62 | Pass at 30/60/120 Hz |
| `tests/test_traversal.gd` — complete input-driven M2 route | 22 | Pass at 30/60/120 Hz |

**Total: 360 passing assertions, zero failures.** Import/startup and final suite logs contain no engine/script errors or warnings. M0 and M1 were explicitly accepted by the user.

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

## Native rendering

```bash
bash tools/godot.sh --script tools/capture_preview.gd
```

This opens the M2 scene in a real rendering window, waits for physics and drawing, then saves `build/screenshots/native-gameplay.png`. Native macOS rendering was verified and the M2 terrain, hero, hearts, rune HUD and scenery inspected. Add `-- --movement` to capture the original M1 scene.

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

Alternatively omit `CHROME` when Playwright's Chromium is installed. `GAME_URL` overrides the default `http://127.0.0.1:8765`.

The browser test checks that the loader completes, collects runtime/resource/HTTP errors and sends Enter, D, Space twice, J, R and Escape. It verifies that movement changes the rendered image, approaches the first dummy, attacks and walks into spikes. Inspect captures in `build/screenshots/`; pixel changes alone are not proof of each mechanic.

The final M2 captures were inspected: `browser-m2-sword.png` shows the active slash, impact and a damaged dummy; `browser-m2-damage.png` shows 2/3 hearts and hurt/invulnerability feedback; `browser-m2-respawn.png` shows 3/3 hearts restored, the target reset and the rune counter still at 1/5. The menu exposes both M2 and M1 scenes. `browser-return-menu.png` records the return flow.

Browser inspection caught native-only fallback font support for Unicode hearts. Replacing the glyphs with drawn polygon icons fixed the missing-glyph boxes; native and final Chrome captures now render the same hearts.

The first browser run caught a missing exported `player_tuning.gd`; exporting all runtime resources with explicit development exclusions fixed it. The final Chrome smoke run reported no runtime/resource/HTTP errors.

## Remaining manual/compatibility checks

1. Judge M2 sword timing, damage feedback, respawn pacing and temporary sound mix by hand.
2. Use J against a dummy; repeated overlapping active frames should remove only one dummy health pip per swing.
3. Collect a rune, activate a checkpoint, take fatal damage or fall, and confirm full health and preserved runes at that checkpoint.
4. Verify gamepad stick/D-pad, A jump, X sword, LB checkpoint and Start menu on physical hardware.
5. Check Firefox/Safari, other browser/window sizes, and desktop targets as available.

Firefox, Safari, Windows, Linux, hardware gamepads and sustained 60 FPS performance remain untested. M0/M1 are accepted; these are outstanding compatibility checks, not an open movement acceptance gate. Audio playback paths ran without errors, but subjective sound quality/mix is not an automated test claim.
