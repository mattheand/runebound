# RUNEBOUND — The Nine Realms

**Current playable: M4 — The Complete Troll Bridge Level.** M0–M3 are user-approved; M3 was merged into `main` and its full regression suite rerun green. Built with Godot **4.7.2 stable**, GDScript and the Compatibility renderer.

Explore Starting Forest, Forest Cliffs, an optional Hidden Cave, Stave Church Vista and the Troll Bridge in one adventure. Collect any five of seven runes, open the bridge gate, defeat the Troll and reach the exit. The authored route combines platforming, Draugr/Raven encounters, checkpoints, a cave switch puzzle and a final boss arena. Earlier M1–M3 test scenes remain available. All current presentation remains provisional; M5 has not started.

## Play locally

From this folder:

```bash
bash tools/godot.sh
```

Select **The Troll Bridge (M4)** or press Enter. The other buttons open the M3 combat trials, M2 gameplay training and M1 movement playground. The launcher finds `godot`/`godot4` on PATH or Godot in `~/Applications` or `/Applications`. On this machine, Godot 4.7.2 is installed at `~/Applications/Godot.app`.

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
| Interact with cave passage, switch or exit | E | B / right face button |
| Retry encounter / return to checkpoint | R | Left shoulder |
| Pause / resume in M4; menu in earlier trials | Escape | Start |
| Select opponent within M3 combat trials | 1 / 2 / 3 | Click the on-screen selector |

Hold jump for more height; tap for less. A cyan ring marks the air jump. Leaving a ledge gives 100 ms of coyote time; an exhausted jump pressed within 120 ms of landing is buffered.

**M4 progression:** checkpoints save your return point and restore hearts when activated. Death/R preserves runes, the opened cave entrance/switch and a defeated boss. Five runes open the gate at the end of the vista; all five needed runes are available on the main route. The optional cave offers two more, so you can also substitute those for missed main-route pickups.

Look for cyan cracks on the mossy ledge: use J to break the stone, then E to enter the cave. E also operates its rune switch and passages. After defeating the Troll, continue right and press E at the exit. The completion screen shows runes, deaths and time, with replay/menu controls. Esc pauses without losing the session; its menu offers resume, checkpoint retry and return to the main menu.

**Combat:** amber outlines show the impending attack region; red means active danger. Dodge the Raven's warned dive. Jump the Troll's slam, retreat or cross behind directional swings, and attack during recovery. Charged smash can break the marked bridge patch. Death/R repairs it and resets an undefeated boss.

**Pacing:** designed for 5–10 minutes on first play, pending hands-on validation. The efficient, known-route input tests finish in approximately **3:23**, both with and without the cave; that is not a measured first-time-player duration.

**M2:** touch a checkpoint stone to activate it. Fatal damage/falling or R returns you there with full health, resetting training targets while preserving runes. Starting again from the menu resets progress. In M1, R/falling return to the original spawn.

Each fresh J press starts a timed sword swing; holding J does not auto-attack. One swing damages each target at most once, even with multiple hurtboxes. Gamepad bindings are configured; physical hardware testing is outstanding. `ability` remains reserved.

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

This imports the project, validates both art handoffs, checks startup, runs the existing and M4 lifecycle suites at 30/60/120 physics Hz, and completes both full-level input routes at 60 Hz: **1,087 passing assertions**. Logs are written under `build/test-results/`. See [testing](docs/testing.md) for browser checks and native capture commands.

## Project map

- `scenes/main/`: menu and scene entry.
- `scenes/player/`: reusable controller, collision body, camera and placeholder presentation.
- `scenes/enemies/`, `scenes/bosses/`: shared enemy lifecycle, Draugr, Raven and Bridge Troll.
- `scripts/resources/`: editable movement and combat parameters.
- `scripts/components/`: health, hitboxes, enemy attacks, session/adventure progress and sound cues.
- `scenes/interactables/`, `scenes/collectibles/`: reusable checkpoints, training targets, hazards and runes.
- `scenes/ui/`: signal-driven HUD and font-independent heart icons.
- `scenes/levels/troll_bridge.*`: complete M4 adventure; authored layout is in `scripts/resources/troll_bridge_layout.gd`.
- `scenes/levels/`: earlier test scenes and provisional scenery.
- `tests/`: regression, enemy/boss, input-victory and art-contract suites; optional browser smoke tests.
- `assets/`, `asset_manifest.json`: provisional first handoff. Unprocessed enemy source sheets from handoff 2 are preserved in ignored source directories for later frame preparation.
- `docs/design/`: supplied concept references, preserved as reference-only artwork.
- `docs/roadmap.md`: milestone status and remaining work.

See [architecture](docs/architecture.md) and [asset pipeline](docs/asset-pipeline.md) for implementation details.

## Current scope and remaining checks

M0–M3 are approved. M4 is implemented and verified, awaiting hands-on level-flow/pacing acceptance. **M5 is deferred until M4 is tested and approved.** See [the coordinator handoff](docs/HANDOFF.md).

Both art handoffs are preserved. Handoff 2 needs frame separation, anchor alignment and validation before use; its sheets have not replaced combat presentation or changed M3 timings. The M5 gate in `specs.md` still requires runtime comparisons, all ten evidenced criteria, resolved significant visual gaps and human acceptance. See [handoff 1 intake](docs/handoff/ART_HANDOFF_INTEGRATION.md) and [handoff 2 intake](docs/handoff/ART_HANDOFF_2_INTAKE.md).

Chrome and native macOS rendering have been checked. Firefox, Safari, Windows, Linux, physical gamepads and sustained performance measurements remain untested. No project-wide distribution license has been selected; supplied concept references are not included in the game export.
