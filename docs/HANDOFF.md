# Coordinator handoff — M0 / M1 first playable

## Status

The actual Godot project and first playable movement course are implemented. M0 is validated. M1 is implemented and passes automated physics validation; detailed human movement-feel acceptance remains. The user saw the first version and said **“yes it looks good.”**

The workspace originally contained only `specs.md`, agent instructions and concept references. No reusable prototype was available. Work followed `specs.md` and the visual direction in `docs/design/RUNEBOUND_Visual_References/ART_DIRECTION.md`.

## Implemented

- Godot **4.7.2 stable**, GDScript, Compatibility renderer, 640 × 360 logical resolution.
- Main menu → movement course → return to menu.
- Reusable CharacterBody2D controller with configurable Resource tuning.
- Acceleration/braking, air steering, gravity, variable-height jumping and one air jump.
- 100 ms coyote time, 120 ms jump buffering, landing reset and unlimited-jump prevention.
- Collision against solid terrain, smooth bounded Camera2D follow.
- 2,560-pixel TileMapLayer course with steps, gaps, low ceiling and double-jump ledge.
- Restart and fall reset, controls/diagnostics HUD, keyboard and gamepad mappings.
- Original temporary hero/scenery visuals retaining blond hair, blue tunic, red cape and fjord colors. Cyan air-jump feedback.
- Single-threaded browser export with development files excluded.

## Verified

- Project import and headless startup: no errors.
- **36 checks at each of 30, 60 and 120 physics ticks/s: 108 passing assertions, zero failures.** Tests exercise real input and engine collisions.
- Native macOS rendered gameplay captured and inspected.
- Chrome WebGL 2 smoke test exercises menu, movement/double-jump, restart and menu return; captures inspected; no runtime/resource/HTTP errors.
- Read-only code review found no Critical/Important issues. One minor zero-buffer setting bug was reproduced and fixed with regression tests.
- Export initially omitted the preloaded tuning script; the preset now includes all runtime resources with explicit docs/tests/tools/build exclusions.

## Play / test

```bash
bash tools/godot.sh                 # Play
bash tools/godot.sh --editor        # Edit
bash tools/check.sh                 # Import + startup + physics suite
```

Browser preview: **http://localhost:8765** while the local server is running. To restart it:

```bash
python3.13 -m http.server 8765 --bind 127.0.0.1 --directory build/web
```

Controls: A/D or arrows; Space for jump/double-jump; R restart; Escape menu.

Engine installed locally at `~/Applications/Godot.app`; launcher also supports PATH or `GODOT`. Builds and screenshots are under `build/web/` and `build/screenshots/`; logs under `build/test-results/`. Build outputs are regenerable and excluded from Git.

## Read next

- `README.md`: launch, controls, export.
- `docs/architecture.md`: scene boundaries and controller behavior.
- `docs/testing.md`: commands, evidence and remaining acceptance checks.
- `docs/asset-pipeline.md`: placeholder conventions and source references.
- `docs/roadmap.md`: milestone status.
- `scenes/player/player.gd`, `scripts/resources/player_tuning.gd`: movement implementation/tuning.
- `scenes/levels/movement_test.gd`: course geometry and reset flow.

## Remaining / next

Obtain detailed movement-feel feedback and a full hands-on course traversal. Physical gamepad, Firefox/Safari, Windows/Linux and sustained performance testing remain unverified. The user approved the initial appearance, not every acceptance check.

After closing the M1 feel gate, proceed to **M2: health, sword combat, checkpoints, runes and basic gameplay UI**. These systems have not been implemented. Keep visual polish incremental and preserve the reference identity. No known critical blocker remains.
