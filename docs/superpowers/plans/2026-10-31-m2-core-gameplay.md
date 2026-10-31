# M2 Core Gameplay Implementation Plan

> **For agentic workers:** Execute inline with executing-plans and test-driven-development. The user explicitly approved M0/M1 and instructed autonomous M2 implementation.

**Goal:** A playable M2 test area demonstrating damage, sword attacks, checkpoints, rune collection and HUD state.

**Architecture:** Compose reusable HealthComponent, HurtboxComponent and HitboxComponent with the existing player. SwordCombat owns physics-timed attack phases. A level-local progress component owns unique rune IDs and checkpoint state, with signals driving pickups and HUD. The level owns delayed respawn and resets training props; movement remains independent.

**Tech Stack:** Godot 4.7.2 stable, GDScript, Compatibility, native 2D physics.

**Spec:** `specs.md` milestone M2 and the user's five ordered priorities. M0/M1 accepted. Temporary art only; M3/M4 excluded.

## Global constraints and decisions

- Three hearts; accepted damage emits knockback and starts invulnerability. Death emits once, stops input/combat, plays brief feedback, then restores full health at latest checkpoint.
- Sword: 80 ms wind-up, 100 ms active window, 220 ms recovery, one damage per health owner per swing. Facing is locked for that swing. Movement remains usable outside brief damage stun.
- Checkpoints activate on touch; active marker is visually distinct. R returns to latest checkpoint. Rune progress persists across respawn/R but resets when starting a new session.
- Rune IDs are unique within the scene; registering/collecting a duplicate cannot inflate totals. Hidden collected instances remain consumed. Five demonstration runes, not a Troll Bridge level.
- Stationary knockback-enabled training dummies and spike hazards demonstrate combat/damage without enemy AI.
- HUD listens to state signals, displays three hearts, rune count, checkpoint and death/recovery feedback.
- Keep movement scene accessible. Validate both suites at 30/60/120 physics Hz and the Web export in Chrome.

## Task 1 — Health and player lifecycle

Files: `scripts/components/health_component.gd`, player scene/controller/visual, `tests/test_gameplay.gd`.

- [x] Red: three-heart damage, rejection during invulnerability, healing clamp, one death event, no post-death damage/heal, restore; player knockback/stun/death input suppression.
- [x] Implement HealthComponent with `take_damage(amount, impulse) -> bool`, `heal(amount)`, `kill()`, `reset_health(grace_seconds)`; signals `health_changed`, `damaged`, `died`.
- [x] Connect player damage/death feedback while retaining movement regression behavior.
- [x] Run tests before moving on.

## Task 2 — Sword and damage fixtures

Files: `scripts/components/{hurtbox_component,hitbox_component}.gd`, `scenes/player/sword_combat.gd`, `scripts/resources/combat_tuning.gd`, `scenes/interactables/{training_dummy,damage_hazard}.*`.

- [x] Red: no wind-up/recovery damage; active overlap damage; no repeated hits per swing (including multiple hurtboxes); cooldown, facing/self exclusion, death cancellation and real player damage from hazards.
- [x] Implement physics-timed sword phases, reusable damage areas, knockback-capable dummy and continuous-contact hazard.
- [x] Add synchronized temporary slash/impact/hurt/death feedback and short original synthesized SFX.
- [x] Run tests before integration.

## Task 3 — Checkpoints, runes and playable HUD

Files: `scripts/components/level_progress.gd`, `scenes/interactables/checkpoint.*`, `scenes/collectibles/rune.*`, `scenes/ui/gameplay_hud.gd`, `scenes/levels/gameplay_test.*`, main menu.

- [x] Red: checkpoint idempotence and switching, safe respawn clears health/momentum/combat, unique collection and persistent count, HUD updates; new session resets state.
- [x] Implement reusable marker/pickup scenes and signal-driven HUD; assemble a small training area with safe checkpoint locations.
- [x] Add a menu entry for gameplay and retain movement-test access.
- [x] Verify real overlap activation/collection, damage/death/respawn, hazard i-frames, directional targets, exported scene navigation and screenshots.

## Task 4 — Handoff

- [x] Run import/startup, both Godot suites plus a full input-driven route at 30/60/120 Hz, export and Chrome smoke checks.
- [x] Request read-only review, address real findings and rerun affected checks.
- [x] Update README, architecture, testing, roadmap and `docs/HANDOFF.md` with details, commands and outstanding compatibility checks.
- [ ] Commit verified M2 source; publish the feature branch to the personal repository for coordination.

## Verification outcome

360 passing assertions across three suites and three tick rates; clean import/startup and Web export. Native and Chrome captures inspected. Browser-only missing heart glyphs were replaced with drawn icons. Full traversal collects every rune and reaches both checkpoints using real input without damage. Review found no actionable gameplay issues. M3/M4 remain out of scope.
