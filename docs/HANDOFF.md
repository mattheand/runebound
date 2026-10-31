# Coordinator handoff — M3 Enemies and Boss

## Status and source control

- **M0–M2 approved.** As requested, `feat/m2-core-gameplay` was fast-forward merged into `main` at **`856a666`**. The existing **360 assertions passed on merged main**, then main was pushed to `mattheand/runebound`.
- **M3 implemented, playable and verified; awaiting user hands-on review/acceptance.** Work branch: `feat/m3-enemies-boss`.
- **M4/M5 have not started.** Current art remains temporary. The additional art package was extracted/imported and its M5 gate documented during M3, without replacing accepted gameplay presentation.
- Art intake commit: **`e95e5fb`**. Source package, extracted assets, metadata, producer scripts and gate documentation are preserved.

## Play M3

```bash
bash tools/godot.sh
```

Choose **Combat trials (M3)** or press Enter. **Gameplay training (M2)** and **Movement playground (M1)** retain the previous scenes.

| Action | Input |
|---|---|
| Move | A/D or arrows; gamepad stick/D-pad |
| Jump / double-jump | Space; gamepad A |
| Sword | J; gamepad X |
| Select Draugr / Raven / Troll | 1 / 2 / 3, or click the three buttons |
| Retry selected encounter | R; gamepad LB |
| Return to menu | Escape; gamepad Start |

For the Troll, walk past the yellow banner to start its introduction. Amber rectangles indicate the exact warned attack region; red indicates active damage. The Raven aim line is locked at warning start. Jump low attacks, retreat or cross behind directional swings, and use recovery windows to attack. The charged smash can break the marked bridge patch. Defeating the Troll unlocks the exit and triggers combat-trial completion.

**Browser:** refresh **http://localhost:8765** while the local preview server runs. To regenerate/serve:

```bash
mkdir -p build/web
bash tools/godot.sh --headless --editor --export-release Web build/web/index.html
python3.13 -m http.server 8765 --bind 127.0.0.1 --directory build/web
```

Godot 4.7.2 stable is installed at `~/Applications/Godot.app`; the launcher also accepts PATH or `GODOT`. Use another installed Python 3 executable when appropriate. The Web preset is single-threaded Compatibility/WebGL 2.

## Implemented systems

### Shared enemy foundation

`scenes/enemies/enemy_actor.gd` handles home/target state, living-target validation, world-layer line-of-sight/ground probes, hurt/knockback, death/reset and `state_changed(previous, current)` / `defeated(actor)` signals. Enemy bodies use world collision and existing team-2 hurtboxes. The accepted player controller and M2 damage rules remain unchanged.

`scripts/components/enemy_attack.gd` uses exported `EnemyAttackProfile` resources for wind-up/active/recovery timing, geometry, damage and knockback. `start(profile, facing)`, `cancel()`, `begin_recovery()` and phase/active/finished signals let each controller own movement independently. Facing locks at attack start; the existing hitbox records health-owner IDs, preventing repeated or multi-hurtbox damage within an attack. Dead enemies cancel all damage immediately.

### Draugr

`scenes/enemies/draugr.*`, `scripts/resources/draugr_tuning.gd`:

- Three health; idle/patrol/chase/attack/hurt/dead state machine.
- Patrol stays within home bounds and reverses at walls or unsupported ledges.
- Nearby living players are detected through clear sight; a larger forget radius prevents range-edge flicker while chasing.
- Interruptible melee with **350 ms warning / 120 ms active / 650 ms recovery** by default.
- Player hits apply knockback/hurt interruption; death freezes movement, disables collisions/hurtbox and fades the placeholder.

### Raven

`scenes/enemies/raven.*`, `raven_tuning.gd`, `raven_dive.tres`:

- Two health; patrol/telegraph/dive/recovery/return/hurt/dead states.
- Patrols a bounded flight route. Detection captures a fixed aim point/vector, shown before the dive; it does not home on subsequent player movement.
- **550 ms warning / up to 750 ms active dive / 650 ms recovery**. World impact or passing the aim point ends active damage early.
- At most one hit per dive, followed by return to the original patrol altitude/route. Hurt/death cancel attack activity.

### Bridge Troll

`scenes/bosses/bridge_troll.*`, `troll_tuning.gd`, three `troll_*.tres` profiles:

- Twelve health; dormant → 1.2-second introduction → bounded approach/attacks → defeat.
- `start_encounter() -> bool` is idempotent. Dormant/intro protection prevents damage or attacks before introduction completes.
- A visible health bar responds to health/state signals. Combat hits produce feedback without normal-enemy knockback/stun-lock.
- Predictable repeating attack order:

| Attack | Wind-up | Active | Recovery | Counterplay |
|---|---:|---:|---:|---|
| Ground slam | 0.80 s | 0.12 s | 1.00 s | Jump the low two-sided impact region |
| Club swing | 0.65 s | 0.16 s | 1.10 s | Back off, cross behind or jump above the sweep |
| Charged smash | 1.10 s | 0.15 s | 1.35 s | Leave/jump the marked front region; watch bridge damage |

Charged smash emits `bridge_smashed(at)` on its active frame. The room removes a **32-pixel-wide bridge collision patch** only when the attack reaches it; repeat smashes do not expand destruction. Retry restores those tiles.

### Combat room / lifecycle

`scenes/levels/combat_test.*` is a bounded test room, not the M4 Troll Bridge level. One selected enemy is active at a time. R or player death reconstructs the current opponent and restores player health, bridge, intro, boss bar and victory/exit state. A brief enemy death sequence leads to trial completion; Troll defeat unlocks the exit. `CombatHUD` shows hearts, opponent health/state/phase, selector buttons and boss bar.

## Test evidence

```bash
bash tools/check.sh
```

| Suite | Checks per run | Runs |
|---|---:|---|
| Movement regression | 36 | 30/60/120 Hz |
| M2 systems/lifecycle | 62 | 30/60/120 Hz |
| Full M2 input-driven route | 22 | 30/60/120 Hz |
| Draugr/Raven states and damage | 34 | 30/60/120 Hz |
| Troll mechanics/patterns | 38 | 30/60/120 Hz |
| M3 selection/intro/bridge/retry/completion | 17 | 30/60/120 Hz |
| Input-only combat victories | 10 | 30/60/120 Hz |
| Provisional art import contracts | 43 | Once |

**700 passing assertions**, zero failures. Project import/startup and suite logs have no engine/script errors or warnings. Tests use real Godot scenes, input and collisions. The winning test fighter defeats **all three enemies with 3/3 hearts and no retries** at all three rates, using unchanged player health, movement, jump and sword rules. It does not teleport, apply damage directly or grant abilities. The Troll is demonstrably beatable with standard abilities; human difficulty/balance review remains pending.

Read-only code review found no actionable M3 functional issues and independently passed the 99 M3 checks at 60 Hz. Render inspection identified and corrected a boss-bar theme sizing overlap; its visibility is signal-driven from the actual intro/death state.

Native macOS (Apple M4 Max) rendering and Chrome **156.0.8078.79**, WebGL 2, were checked. Both `tests/browser_combat.cjs` (M3) and `tests/browser_smoke.cjs` (M2 regression) passed with no runtime/resource/HTTP errors. Browser captures demonstrate a hurt Draugr, the Raven warning, Troll intro/damage/slam, retry and the three-entry menu.

## Runtime captures and recording

```bash
bash tools/godot.sh --script tools/capture_preview.gd -- --opponent=troll
bash tools/godot.sh --write-movie build/m3-troll-victory.avi --fixed-fps 60 --script tools/capture_combat_victory.gd
```

The native input-only victory recording contains **573 frames at 60 FPS (~9.6 seconds)**, with a standard three-heart win, completed trial and unlocked exit. Screenshot: `build/screenshots/native-m3-victory.png`. Browser captures: `build/screenshots/browser-m3-*.png`. Logs: `build/test-results/m3-all.log` and per-suite files. Builds/recordings/captures are regenerable and ignored by Git. Capture speed is not a sustained-FPS benchmark.

## Art handoff and deferred M5 gate

The supplied `RUNEBOUND_Art_Handoff_v1.zip` was inspected and extracted without replacing existing implementation files. Its README is preserved at `docs/handoff/ART_HANDOFF_V1_README.md`; intake mapping, SHA-256, validation and integration caveats are in `docs/handoff/ART_HANDOFF_INTEGRATION.md`.

The provisional hero strips, terrain, rune/checkpoint sprites and independent backdrop layers are imported under `assets/`, with `asset_manifest.json` and hero animation metadata. The producer scripts are provenance snapshots, not executed. The hero's feet reference is `[16,46]`; the first-pass 600 ms attack strip must eventually be adapted to the accepted 400 ms sword clock rather than changing combat. Layers are not guaranteed seamless. These imported assets do not claim final illustrated quality and have not been wired over active gameplay presentation during M3.

The authoritative **ten-criterion M5 visual gate** is now in `specs.md` and `docs/roadmap.md`, linked to `docs/handoff/M5_VISUAL_GATE_AGENT_PROMPT.md`. It requires approved hero identity/expressive animation, consistent pixels/palette, rich Norwegian scenery, layered parallax, readable interactions, atmosphere, provenance, actual runtime screenshots/recording and side-by-side comparisons, resolved significant gaps and passing gameplay regressions. Completion requires human visual acceptance; unresolved gaps mean **NEEDS ART ITERATION**, not an invented fidelity percentage.

## Outstanding checks / next action

- **Await M3 hands-on review:** difficulty, telegraph readability, Raven counterplay, boss recovery/pacing and temporary sound balance.
- **Compatibility still untested:** physical gamepads, Firefox/Safari, Windows/Linux, additional window sizes and sustained performance profiling.
- Prior rune/checkpoint persistence remains session-local as defined in M2.
- No known critical or progression-blocking issue remains in the verified scope.
- **Do not start M4 or M5 until M3 is reviewed and accepted.** Keep the build playable and preserve accepted mechanics during any follow-up or later art integration.

Further detail: `README.md`, `docs/architecture.md`, `docs/testing.md`, `docs/asset-pipeline.md`, `docs/roadmap.md`.
