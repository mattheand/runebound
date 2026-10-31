# RUNEBOUND — The Nine Realms

**Current playable: M3 — Enemies and Boss combat trials.** M0–M2 are user-approved; M2 has been merged into `main` and revalidated. Built and tested with Godot **4.7.2 stable**, GDScript and the Compatibility renderer.

Fight a patrolling Draugr, a diving Raven and the Bridge Troll in a selectable combat room. The boss has an introduction, health bar, three telegraphed attacks, a breakable bridge patch and a defeat/exit sequence. The M2 rune/checkpoint course and original M1 movement playground remain available. Artwork and sound effects are temporary; the first art handoff is imported as provisional integration material, not final production art.

## Play locally

From this folder:

```bash
bash tools/godot.sh
```

Select **Combat trials (M3)**, or press Enter. **Gameplay training (M2)** and **Movement playground (M1)** open the previous test scenes. The launcher finds `godot`/`godot4` on PATH or Godot in `~/Applications` or `/Applications`. On this machine, Godot 4.7.2 is installed at `~/Applications/Godot.app`.

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
| Retry encounter / return to checkpoint | R | Left shoulder |
| Return to menu | Escape | Start |
| Select Draugr / Raven / Troll trial | 1 / 2 / 3 | Click the on-screen selector |

Hold jump for more height; tap for less. A cyan ring marks the air jump. Leaving a ledge gives 100 ms of coyote time; an exhausted jump pressed within 120 ms of landing is buffered.

**M3:** amber outlines show the exact impending attack region; red means active danger. Dodge the Raven's warned dive. Jump the Troll's ground slam, retreat or cross behind directional swings, and attack during recovery. In the Troll trial, walk past the yellow banner to begin. Charged smash can break the marked bridge patch. R/death resets the encounter, player health, bridge, intro and exit state. Defeating the opponent completes that trial; defeating the Troll unlocks its exit.

**M2:** touch a checkpoint stone to activate it. Fatal damage/falling or R returns you there with full health, resetting training targets while preserving runes. Starting again from the menu resets progress. In M1, R/falling return to the original spawn.

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

This imports the project, validates the provisional assets, starts the main scene, and runs movement, gameplay, traversal, enemy, boss, arena and input-only victory tests at 30, 60 and 120 physics ticks per second: **700 passing assertions** in the verified M3 version. Logs are written under `build/test-results/`. See [testing](docs/testing.md) for browser checks, recording commands and the hands-on checklist.

## Project map

- `scenes/main/`: menu and scene entry.
- `scenes/player/`: reusable controller, collision body, camera and placeholder presentation.
- `scenes/enemies/`, `scenes/bosses/`: shared enemy lifecycle, Draugr, Raven and Bridge Troll.
- `scripts/resources/`: editable movement and combat parameters.
- `scripts/components/`: health, hitbox/hurtbox, profile-driven enemy attacks, level progress and temporary sound cues.
- `scenes/interactables/`, `scenes/collectibles/`: reusable checkpoints, training targets, hazards and runes.
- `scenes/ui/`: signal-driven HUD and font-independent heart icons.
- `scenes/levels/`: M3 combat room, M2 gameplay area, M1 movement course and placeholder scenery.
- `tests/`: regression, enemy/boss, input-victory and art-contract suites; optional browser smoke tests.
- `assets/`, `asset_manifest.json`: provisional Art Handoff v1; metadata defines later presentation integration.
- `docs/design/`: supplied concept references, preserved as reference-only artwork.
- `docs/roadmap.md`: milestone status and remaining work.

See [architecture](docs/architecture.md) and [asset pipeline](docs/asset-pipeline.md) for implementation details.

## Current scope and remaining checks

M0–M2 are approved. M3 is implemented and verified, awaiting hands-on review and acceptance. M4 and M5 have not begun. See [the coordinator handoff](docs/HANDOFF.md) for interfaces, lifecycle behavior and verification.

The first art package has been extracted, imported and contract-tested. Its assets remain provisional and are not wired over the accepted gameplay presentation during M3. The mandatory M5 gate in `specs.md` requires actual Godot screenshots/recording, side-by-side reference comparisons, ten evidenced criteria, resolved significant visual gaps and human visual acceptance. See [art intake](docs/handoff/ART_HANDOFF_INTEGRATION.md).

Chrome and native macOS rendering have been checked. Firefox, Safari, Windows, Linux, physical gamepads and sustained performance measurements remain untested. No project-wide distribution license has been selected; supplied concept references are not included in the game export.
