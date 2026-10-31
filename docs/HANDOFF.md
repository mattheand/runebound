# Coordinator handoff — M2 Core Gameplay Systems

## Status

- **M0 and M1: complete and explicitly user-approved**, including the current movement implementation.
- **M2: implemented, playable and verified.** All five requested core systems are present.
- **M3/M4: not started.** Training targets are stationary damage fixtures, not enemy AI. Production art is being developed separately; current presentation remains temporary.
- Work branch: `feat/m2-core-gameplay`, based on M0/M1 commit `819069c` in `mattheand/runebound`.

The source of truth remains `specs.md`. The supplied art direction lives at `docs/design/RUNEBOUND_Visual_References/ART_DIRECTION.md`.

## M2 implementation

### Health and player lifecycle

`scripts/components/health_component.gd` is reusable and actor-independent. It starts with three hearts by default and exposes:

- `take_damage(amount: int, impulse: Vector2 = Vector2.ZERO) -> bool`: accepts a hit only while alive and vulnerable; clamps health at zero.
- `heal(amount: int)`: clamps to maximum, rejects nonpositive amounts and does not revive dead actors.
- `kill()`: one-shot death, bypassing invulnerability for falls/kill planes.
- `reset_health(grace_seconds: float = 0.0)`: explicit revive/restore.
- Signals: `health_changed(current, maximum)`, `damaged(amount, impulse)`, `died`.

The player applies damage knockback and a 180 ms steering/jump stun, cancels combat and clears buffered jump state. Default damage invulnerability is 800 ms. Death freezes input/motion and plays brief rotation/fade feedback. Respawn restores all three hearts with 800 ms grace and clears movement, jump, stun, attack and visual death state.

### Sword combat

`scenes/player/sword_combat.*` uses a single physics clock for temporary slash presentation and hitbox activity. `scripts/resources/combat_tuning.gd` defaults to **80 ms wind-up / 100 ms active / 220 ms recovery**, one damage and directional knockback.

`HitboxComponent` queries `HurtboxComponent` Areas on layer 4. Team IDs exclude self/friendly hits. Each swing records **health-owner IDs**, preventing repeated damage from sustained overlaps or multiple hurtboxes on one target. Facing locks at swing start. Holding J does not auto-repeat; wind-up/recovery cannot deal damage, and hurt/death/reset cancel the attack.

Stationary training dummies demonstrate health, knockback, hit flash, defeat and reset. Spike Areas demonstrate repeated contact damage gated by player invulnerability. Slash/impact flashes, hurt flicker, death feedback and short original synthesized SFX provide temporary feedback.

### Checkpoints and respawning

Reusable checkpoint Areas activate on contact with a living player and show an activation pulse/active marker. `LevelProgress` stores the latest checkpoint ID and global spawn point. The level waits **650 ms** after death, then restores the player there. Falling follows the same lifecycle; **R** returns immediately to the latest checkpoint.

Respawning resets training targets and player state while preserving the active checkpoint and collected runes. Safe spawn offsets keep checkpoint returns clear of hazards. No asynchronous scene callback survives a menu transition.

### Rune collection and HUD

`scenes/collectibles/rune.*` provides floating/glowing pickups with explicit IDs, bound to the level-local `LevelProgress` node. Only registered, uncollected IDs increment the counter. Duplicate IDs cannot inflate totals; duplicate instances of a collected ID remain hidden. Collection persists through death and R. Starting a new session from the menu recreates progress.

`scenes/ui/gameplay_hud.gd` subscribes to health/progress signals, showing hearts plus numeric health, runes, active checkpoint and short status messages. Heart icons are drawn polygons, so Web rendering does not depend on OS fallback fonts.

### Playable area

`scenes/levels/gameplay_test.tscn` is a 1,920-pixel training course containing **five runes, two checkpoints, two dummies, two spike patches, a gap and raised platforms**. The menu opens this scene by default and retains the approved M1 movement playground as a separate option.

## Verified evidence

`bash tools/check.sh` imports the project, checks main-scene startup and runs:

| Suite | Checks at each rate | Rates |
|---|---:|---|
| Movement regression (`tests/run_tests.gd`) | 36 | 30 / 60 / 120 Hz |
| M2 systems/lifecycle (`tests/test_gameplay.gd`) | 62 | 30 / 60 / 120 Hz |
| Full M2 route (`tests/test_traversal.gd`) | 22 | 30 / 60 / 120 Hz |

**360 passing assertions; zero failures, engine errors or warnings in the final run.** Tests use actual Godot input, scene instances and collisions.

The complete route uses input actions only—no teleports, hazard disabling or health cheats—to collect all five runes and reach both checkpoints with three hearts intact. The systems suite additionally verifies damage/death, sword timing/deduplication, real pickup/checkpoint overlaps, HUD updates, respawn persistence and fresh-session reset.

Native macOS rendering was captured and inspected. The single-threaded Web export builds successfully and passes the Chrome smoke test with no runtime/resource/HTTP errors. Inspected browser captures show sword damage, 2/3 hearts after spikes, restored 3/3 health and a persistent 1/5 rune count after R. Missing Unicode heart glyphs discovered during Web inspection were fixed using drawn icons.

Read-only review found no actionable M2 functional issues and independently ran the 62-check systems suite at 60 Hz. Final HUD/traversal changes were subsequently validated in the complete suite and browser checks.

## Play / reproduce

```bash
bash tools/godot.sh                 # Play; select Start gameplay
bash tools/godot.sh --editor        # Edit
bash tools/check.sh                 # Full validation
bash tools/godot.sh --script tools/capture_preview.gd
```

Controls: **A/D or arrows** move; **Space** jump/double-jump; **J** sword; **R** return to checkpoint; **Escape** menu. Gamepad mappings: stick/D-pad, A, X, LB, Start respectively.

Browser preview: **http://localhost:8765** while the local server runs. Regenerate/serve with:

```bash
mkdir -p build/web
bash tools/godot.sh --headless --editor --export-release Web build/web/index.html
python3.13 -m http.server 8765 --bind 127.0.0.1 --directory build/web
```

Godot **4.7.2 stable** is installed locally at `~/Applications/Godot.app` with matching single-threaded Web export templates. Launcher also supports PATH or `GODOT`. On other machines, use an installed Python 3 executable for serving.

Builds: `build/web/`. Captures: `build/screenshots/`, including `browser-m2-sword.png`, `browser-m2-damage.png`, `browser-m2-respawn.png` and `native-gameplay.png`. Test logs: `build/test-results/`. These outputs are regenerable and excluded from Git.

## Remaining checks and next direction

- **Outstanding compatibility:** physical gamepads, Firefox/Safari, Windows/Linux, additional window sizes and sustained performance profiling. Native macOS and Chrome WebGL 2 have been checked.
- **M2 hands-on follow-up:** sword feel, hurt/respawn pacing and temporary sound balance. Automated tests do not claim subjective audio quality.
- Rune/checkpoint progress is session-local, not saved to disk; this matches M2 scope.
- No known critical or progression-blocking issue remains in the verified scope.
- Keep temporary artwork until separately produced assets arrive. Swap presentation using the existing signals and sword timing contract.
- **Await M2 feedback. Do not begin M3 or M4 without further direction.**

See `README.md`, `docs/architecture.md`, `docs/testing.md`, `docs/asset-pipeline.md` and `docs/roadmap.md` for additional detail.
