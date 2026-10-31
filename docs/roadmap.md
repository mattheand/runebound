# Milestone status

## M0 — Project initialization: complete

- Created the Godot project, input actions and repository structure.
- Main menu launches the movement scene.
- Compatibility renderer, 640 × 360 logical viewport, nearest filtering and integer scaling.
- Godot 4.7.2 imports and starts without errors.
- Native rendering capture and Chrome Web export verified.

## M1 — Player movement: complete

- Acceleration, braking, air control, gravity and solid platform collision.
- Variable-height jump, one air jump, coyote time and landing buffer.
- Landing reset, direction-facing placeholder presentation and double-jump feedback.
- Scrolling bounded camera and modular collision course.
- Restart/fall reset and menu return for repeated testing.
- Automated suite covers 36 assertions at each of 30, 60 and 120 physics ticks/s, including a zero-buffer tuning regression.

**User acceptance:** the initial appearance and current movement implementation have been explicitly approved. M0 and M1 are complete.

**Outstanding compatibility checks:** physical gamepad, Firefox/Safari, Windows/Linux, additional window sizes and sustained performance measurements. These remain documented follow-ups, not an open M1 movement gate. Placeholder art remains intentionally early-stage.

## M2 — Core Gameplay Systems: complete

- Reusable three-heart health, damage/knockback, invulnerability, healing and one-shot death.
- Timed directional sword combat, per-target hit deduplication, recovery and damage feedback.
- Reusable checkpoint markers and safe delayed respawn; training props reset per attempt.
- Five uniquely identified runes persist through death/R, with duplicate-safe counters.
- Signal-driven heart/rune/checkpoint HUD and temporary visual/audio cues.
- Separate M2 training area; original M1 playground remains selectable.
- Validation: 36 movement + 62 gameplay + 22 complete-route checks at each of 30/60/120 Hz (360 passes). Native rendering and Chrome export/smoke verified.

**Gate evidence:** the complete input-driven route collects every rune and reaches both checkpoints without damage; integration tests verify sword interactions, damage/death, pickup persistence and HUD updates.

**Next action:** collect M2 hands-on feedback. Production art is developed separately. Do not start M3 or M4 without further direction.

Later gates remain as defined in `../specs.md`: enemies/boss (M3), complete Troll Bridge level (M4), visual/audio polish (M5), public demo validation/distribution (M6).

## First playable artifacts

- Source: `project.godot`, `scenes/`, `scripts/`, `tests/`, `tools/`.
- Browser files: `build/web/` (regenerable, not tracked).
- Captures: `build/screenshots/` (regenerable, not tracked).
- Test evidence: `build/test-results/` after `bash tools/check.sh`.
- Startup and controls: `../README.md`.
