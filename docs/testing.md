# M0 / M1 verification

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

The wrapper runs import and startup, then `tests/run_tests.gd` at 30 / 60 / 120 physics ticks per second with matching fixed render rates. It fails for a nonzero process exit **or** Godot script/error diagnostics. Logs go to `build/test-results/`.

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

## Native rendering

```bash
bash tools/godot.sh --script tools/capture_preview.gd
```

This opens a real rendering window, waits for physics and drawing, then saves `build/screenshots/native-gameplay.png`. Verified native renderer startup and inspected the captured terrain, hero, HUD and scenery.

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

The browser test checks that the loader completes, collects runtime/resource/HTTP errors and sends Enter, D, Space twice, R and Escape. It verifies that movement changes the rendered image. Inspect the menu/gameplay/double-jump/restart/return-menu captures in `build/screenshots/`; pixel changes alone are not proof of each mechanic. All five captures were inspected for this first version. The double-jump capture shows an airborne player, cyan burst, speed 220 and air jump used. The reset capture shows the spawn with zero speed and a restored jump.

The first browser run caught a missing exported `player_tuning.gd`; exporting all runtime resources with explicit development exclusions fixed it. The final Chrome smoke run reported no runtime/resource/HTTP errors.

## Hands-on acceptance still needed

1. Play the whole course and judge acceleration, stopping, jump height and camera comfort.
2. Try a tap, a held jump, a second jump near the apex and repeated third presses.
3. Walk off an edge and jump immediately; try buffering just before landing after using both jumps.
4. Test the low ceiling, high ledge, gaps, restart while moving and falling out.
5. Test a physical gamepad and other browser/window sizes.

Firefox, Safari, Windows, Linux, hardware gamepads and sustained 60 FPS performance have not been tested. A full human feel/playthrough assessment remains the M1 acceptance follow-up; automated validation does not substitute for that judgment.
