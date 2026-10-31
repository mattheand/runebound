# RUNEBOUND — The Nine Realms

**First playable: M0 / M1 movement playground.** Built and tested with Godot **4.7.2 stable**, GDScript and the Compatibility renderer.

Run, jump, double-jump and explore a 2,560-pixel collision course with steps, gaps, a low ceiling and a high ledge. The blond hero, blue tunic, red cape and fjord colors are original placeholders based on the supplied visual direction.

## Play locally

From this folder:

```bash
bash tools/godot.sh
```

Select **Start movement test**, or press Enter. The launcher finds `godot`/`godot4` on PATH or Godot in `~/Applications` or `/Applications`. On this machine, Godot 4.7.2 is installed at `~/Applications/Godot.app`.

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
| Restart playground | R | Left shoulder |
| Return to menu | Escape | Start |

Hold jump for more height; tap for less. A cyan ring marks the air jump. Leaving a ledge gives 100 ms of coyote time; an exhausted jump pressed within 120 ms of landing is buffered. Falling out of the course returns you to the start.

Gamepad bindings are configured; a physical controller still needs hands-on testing. `attack`, `ability` and `interact` are reserved input actions for later milestones.

## Browser preview

The generated first build is in `build/web/`. Serve it over HTTP, then visit **http://localhost:8765**:

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

This imports the project, starts the main scene, and runs real input/collision tests at 30, 60 and 120 physics ticks per second. Logs are written under `build/test-results/`. See [testing](docs/testing.md) for browser checks and the hands-on checklist.

## Project map

- `scenes/main/`: menu and scene entry.
- `scenes/player/`: reusable controller, collision body, camera and placeholder presentation.
- `scripts/resources/player_tuning.gd`: editable movement parameters.
- `scenes/levels/`: tiled movement course and quiet placeholder scenery.
- `tests/`: headless physics suite and optional browser smoke test.
- `docs/design/`: supplied concept references, preserved as reference-only artwork.
- `docs/roadmap.md`: milestone status and remaining work.

See [architecture](docs/architecture.md) and [asset pipeline](docs/asset-pipeline.md) for implementation details.

## Current scope and remaining checks

M0 is validated. M1's movement and collision implementation is validated automatically and is ready for hands-on feel feedback. The course is an early prototype with temporary art. Combat, enemies, collectibles, checkpoints, sound and the Troll Bridge level belong to subsequent milestones.

Chrome and native macOS rendering have been checked. Firefox, Safari, Windows, Linux, physical gamepads and sustained performance measurements remain untested. No project-wide distribution license has been selected; supplied concept references are not included in the game export.
