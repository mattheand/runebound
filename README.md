# RUNEBOUND — The Nine Realms

**Current playable: M2 — Core Gameplay Systems.** M0 and M1 are complete and user-approved. Built and tested with Godot **4.7.2 stable**, GDScript and the Compatibility renderer.

Run, jump, swing a sword at training targets, collect five runes and activate two checkpoints in a small gameplay course. You have three hearts, damage knockback, brief invulnerability and checkpoint respawns. The original 2,560-pixel movement playground is also available. Artwork and sound effects are temporary; production art is being developed separately.

## Play locally

From this folder:

```bash
bash tools/godot.sh
```

Select **Start gameplay**, or press Enter. Choose **Movement playground (M1)** for the original course. The launcher finds `godot`/`godot4` on PATH or Godot in `~/Applications` or `/Applications`. On this machine, Godot 4.7.2 is installed at `~/Applications/Godot.app`.

To edit the project:

```bash
bash tools/godot.sh --editor
```

On other platforms, install [Godot 4.7 or newer stable Godot 4](https://godotengine.org/download/), import `project.godot`, and press **F6** for the open scene or **F5** for the main menu. You can also set `GODOT=/path/to/executable` when using the launcher.

### Controls

| Action | Keyboard | Gamepad mapping |
|---|---|---|
| Move | A / D or Left / Right | Left stick or D-pad |
| Jump / double-jump | Space | A / bottom face button |
| Sword attack | J | X / left face button |
| Return to checkpoint | R | Left shoulder |
| Return to menu | Escape | Start |

Hold jump for more height; tap for less. A cyan ring marks the air jump. Leaving a ledge gives 100 ms of coyote time; an exhausted jump pressed within 120 ms of landing is buffered.

Touch a checkpoint stone to activate it. Fatal damage or falling plays brief death feedback and returns you there with full health. R also returns to the latest checkpoint, resetting training targets while keeping collected runes. Returning to the menu and starting again begins a fresh session. In the M1 playground, R/falling return to its original spawn.

Each fresh J press starts a timed sword swing; holding J does not auto-attack. One swing damages each target at most once, even if it has multiple hurtboxes. Gamepad bindings are configured; physical hardware testing is outstanding. `ability` and `interact` remain reserved.

## Browser preview

The generated Web build is in `build/web/`. Serve it over HTTP, then visit **http://localhost:8765**:

```bash
python3.13 -m http.server 8765 --bind 127.0.0.1 --directory build/web
```

Use `python3` instead on machines where that is the installed Python executable. The local preview server was started during implementation; this command is for restarting it. Opening `index.html` directly is unsupported.

To rebuild, install export templates matching your Godot version via **Editor → Manage Export Templates**, then:

```bash
mkdir -p build/web
bash tools/godot.sh --headless --editor --export-release Web build/web/index.html
```

The Web preset is single-threaded, WebGL 2 compatible, and excludes documentation, tests and build outputs. Deploy the complete `build/web/` directory to an HTTP(S) static host. Builds are intentionally excluded from Git; regenerate from source after cloning.

## Verify

```bash
bash tools/check.sh
```

This imports the project, starts the main scene, and runs movement, gameplay-system and full-route input tests at 30, 60 and 120 physics ticks per second: **360 passing assertions** in the verified M2 version. Logs are written under `build/test-results/`. See [testing](docs/testing.md) for browser checks and the hands-on checklist.

## Project map

- `scenes/main/`: menu and scene entry.
- `scenes/player/`: reusable controller, collision body, camera and placeholder presentation.
- `scripts/resources/`: editable movement and combat parameters.
- `scripts/components/`: health, hitbox/hurtbox, level progress and temporary sound cues.
- `scenes/interactables/`, `scenes/collectibles/`: reusable checkpoints, training targets, hazards and runes.
- `scenes/ui/`: signal-driven HUD and font-independent heart icons.
- `scenes/levels/`: M2 gameplay area, M1 movement course and placeholder scenery.
- `tests/`: movement/gameplay/traversal suites and optional browser smoke test.
- `docs/design/`: supplied concept references, preserved as reference-only artwork.
- `docs/roadmap.md`: milestone status and remaining work.

See [architecture](docs/architecture.md) and [asset pipeline](docs/asset-pipeline.md) for implementation details.

## Current scope and remaining checks

M0/M1 are complete and approved. M2 is implemented and validated, with reusable health, sword combat, checkpoints, runes and HUD. M3 enemy AI/bosses and the M4 Troll Bridge level have not been started. See [the coordinator handoff](docs/HANDOFF.md) for exact interfaces, lifecycle behavior and verification.

Chrome and native macOS rendering have been checked. Firefox, Safari, Windows, Linux, physical gamepads and sustained performance measurements remain untested. No project-wide distribution license has been selected; supplied concept references are not included in the game export.
