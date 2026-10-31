# RUNEBOUND architecture — through M3

## Scene flow

`main.tscn` → Combat trials (M3) → `combat_test.tscn` → Escape → `main.tscn`.

The separate Gameplay training and Movement playground buttons load `gameplay_test.tscn` and `movement_test.tscn`.

There are no autoloads. Scene ownership handles cleanup. The M1 playground owns its simple restart/fall reset; the M2 course owns delayed death respawn and training-prop resets. The player owns movement and damage reactions. Session progress is a level-local node, preserved through M2 respawns and recreated on a fresh session.

## Player

`player.tscn` is reusable: CharacterBody2D, an 18 × 32 solid collision rectangle anchored at the feet, a presentation node and Camera2D. World terrain uses layer 1; the player uses layer 2 and collides with layer 1.

`player.gd` reads named input actions during physics ticks. Horizontal acceleration and deceleration use delta-scaled `move_toward`; gravity has a terminal-velocity cap. Jump release caps remaining upward speed. Physics uses `move_and_slide`, not positional integration or manual collision tests.

- Ground contact restores one air jump.
- Walking off a platform starts the coyote window.
- Jumping during that window preserves the air jump.
- A later jump consumes the air jump.
- Further input can only wait in the short landing buffer.
- Holding a button cannot repeatedly jump.
- `jumped(is_double)` drives visual feedback; `landed` reports contact.
- A buffered jump can fire immediately on contact, even if already released. The next tick checks upward velocity as well as Godot's floor flag to avoid re-granting ground grace.

Movement parameters live in `PlayerTuning`, an exported Resource. Select Player → Tuning in the inspector to adjust speeds and timing. The runtime HUD shows grounded/airborne state, speed and the remaining air jump.

The hero visual is intentionally separate from controller logic. It draws an original grid-aligned placeholder, flips its local draw transform and varies its stride with movement. Production sprite/animation assets are a later art milestone.

## Course and camera

`test_terrain.gd` generates two 16 × 16 moss/stone tiles and attaches solid collision polygons via a TileSet atlas. `movement_test.gd` builds the deterministic course from tile rectangles. Geometry is expressed in tile coordinates, with a safe spawn, low steps, gaps, ceiling test, 128-pixel raised ledge and final lookout.

Camera2D follows the player on both axes with smoothing, bounded to 2,560 × 720. Nearest-neighbor filtering and transform pixel snapping keep the game art sharp. UI uses a CanvasLayer; background scenery uses a separate fixed CanvasLayer.

## Export

All runtime resources are exported, with docs/tests/tools/build excluded. Selecting only scenes was insufficient to include the script-preloaded tuning Resource; the browser test caught that missing dependency. `.gdignore` in docs and build prevents concept art and generated screenshots from being imported into the game.

Single-threaded Compatibility/WebGL 2 export uses matching `web_nothreads` templates. No external runtime packages, C#, GDExtensions or network services are used.

## M2 health and combat composition

- `HealthComponent` owns current/max health, damage acceptance, invulnerability and one-shot death emission. `take_damage(amount, impulse) -> bool` rejects dead, invulnerable or nonpositive hits; accepted damage emits `health_changed` and `damaged`. `heal` clamps to the maximum and does not revive dead actors. `kill` bypasses grace for kill planes. `reset_health(grace_seconds)` is the explicit revive path.
- Player damage reaction applies the impulse, suppresses steering/jumping for 180 ms, clears buffered input and cancels sword attacks. Death freezes control/momentum and triggers temporary rotation/fade feedback. `reset_to` restores health with 800 ms grace and clears motion, stun, jump grace, visual death state and attack state.
- `HurtboxComponent` routes hits to its configured `health_path` and declares a team ID. Hurtboxes use layer 4; the sword queries that layer and excludes its own team. Player team is 1; dummy team is 2.
- `HitboxComponent` keeps overlap tracking enabled but applies damage only when active. It records health-owner IDs per swing, so multiple hurtboxes, persistent overlaps and temporary invulnerability cannot produce duplicate hits within one swing.
- `SwordCombat` uses one physics clock for both collision activity and temporary slash presentation. Defaults: 80 ms wind-up, 100 ms active, 220 ms recovery. `CombatTuning` holds timings, damage and knockback. Facing is locked at attack start; damage/death/reset cancel the attack immediately.
- Training dummies are stationary CharacterBody2D damage fixtures with knockback and reset behavior. Spike hazards demonstrate incoming damage on continuous overlap. Neither implements enemy AI.

## M2 checkpoint/rune lifecycle

`LevelProgress` stores the active checkpoint ID/position, registered rune IDs and collected IDs. It emits `checkpoint_changed` and `runes_changed`; it does not own nodes or reload scenes.

Checkpoint Areas emit activation only for living players. The course records their global position plus a safe spawn offset and changes active marker visuals. Death waits 650 ms, then restores the player at that position and resets training targets. R uses the same reset function without the death delay. Both preserve rune and checkpoint progress.

Each rune scene has an explicit stable ID and is bound to the level's progress node. Duplicate registration cannot inflate totals, and collection only accepts registered, uncollected IDs. All instances sharing a collected ID hide and defer disabling their monitoring safely outside the physics callback. They remain consumed through respawns. A fresh menu-start reconstructs the entire level and clears progress.

`GameplayHUD` subscribes to health/progress signals and initializes itself from their current values. Hearts are drawn in `heart_display.gd` rather than relying on OS fallback font glyphs. The numeric health label and rune counter match the same source state. The HUD also shows the active checkpoint and short event messages.

Temporary sounds use AudioStreamPlayer nodes with short original WAV cues synthesized once in `_ready`. No external audio assets are required. Production presentation can replace the visual/sound nodes while preserving component signals and the shared sword timing contract.

## M3 enemy composition and state machines

`scenes/enemies/enemy_actor.gd` is a small CharacterBody2D base for shared sensing/lifecycle. It owns `state`, `state_time`, `target`, `home`, hurt flash, `state_changed(previous, current)` and one-shot `defeated(actor)` signals. It reuses HealthComponent, HurtboxComponent and enemy-team HitboxComponent. World-layer ray queries validate line of sight and ground support. Hurt cancels attacks and applies knockback for ordinary enemies; death cancels damage, disables collision/monitorability, freezes movement and fades the placeholder. `reset_enemy()` restores the home position and health.

`scripts/components/enemy_attack.gd` owns wind-up/active/recovery timing from `EnemyAttackProfile`. It exposes `start(profile, facing)`, `cancel()`, `begin_recovery()`, `is_running()` and phase/active/finished signals. Damage remains disabled during wind-up and recovery. A swing locks facing and deduplicates hits through the existing health-owner identity system. The exact profile rectangle is used for both collision and temporary warning overlays.

### Draugr

States: idle → patrol / chase → attack; hurt and dead override them. Configurable patrol bounds, speed, sight/forget radii and melee range live in `draugr_tuning.gd`; melee timings use an exported attack profile. Patrol reverses at bounds, walls and unsupported ledges. Detection requires a living player and clear world-layer sight. Melee is interrupted by hurt/death; recovery returns to idle before the next decision.

### Raven

States: patrol → telegraph → dive → recovery → return → patrol; hurt/dead interrupt. `raven_tuning.gd` holds speeds/radii and `raven_dive.tres` the phase timing/hit region. The player position and dive vector are captured at warning start, shown as an aim line and never homed during the dive. Reaching/passing that aim or colliding with the world ends active damage early. Recovery and return restore the home route/altitude before another dive.

### Bridge Troll

States: dormant → intro → chase → attack → chase; dead ends the encounter. `start_encounter() -> bool` is idempotent and required before combat. Health/hurtbox protection lasts through the intro; the boss is vulnerable in combat. Damage flashes without normal-enemy stagger to avoid player-driven stun-lock.

The boss approaches within configured arena bounds and cycles deterministically through ground slam, club swing and charged smash, using the three `troll_*.tres` profiles. Each has an independent telegraph and generous recovery. The slam is a low, two-sided region; club/smash face the target at wind-up start. `bridge_smashed(at)` fires only when charged smash becomes active.

### Combat-test room

`combat_test.tscn` is a bounded 640×360 room with one selected opponent. Keyboard 1/2/3 and HUD buttons select the trial. R or death reconstructs the current opponent, restores the player, repairs the bridge and clears intro/victory/exit flags. The room does not change M2 checkpoint/rune state because M2 remains a separate scene.

The Troll's real Area2D trigger begins its intro. Charged smash removes a two-tile-wide, four-tile-deep bridge patch only if its strike reaches the patch, and never expands that destruction on subsequent hits. The player can jump the gap; falls use the same encounter retry flow. Death signals unlock the Troll exit and start a short trial-completion sequence. `CombatHUD` binds boss health and state signals, with shared drawn heart icons and explicit danger/phase labels.

## Art handoff / future M5

The provisional sprite strips and background layers are imported under `assets/` but do not replace M3 presentation. `asset_manifest.json` and the hero manifest define dimensions, frames and anchor contracts. Producer scripts are preserved as provenance, not executed. Concept references stay outside runtime imports/exports. M5 acceptance is defined in `specs.md` and `docs/handoff/M5_VISUAL_GATE_AGENT_PROMPT.md`; package import is not visual acceptance.
