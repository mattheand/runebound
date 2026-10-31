# Milestone status

## M0 — Project initialization: validated

- Created the Godot project, input actions and repository structure.
- Main menu launches the movement scene.
- Compatibility renderer, 640 × 360 logical viewport, nearest filtering and integer scaling.
- Godot 4.7.2 imports and starts without errors.
- Native rendering capture and Chrome Web export verified.

## M1 — Player movement: implemented and automatically validated

- Acceleration, braking, air control, gravity and solid platform collision.
- Variable-height jump, one air jump, coyote time and landing buffer.
- Landing reset, direction-facing placeholder presentation and double-jump feedback.
- Scrolling bounded camera and modular collision course.
- Restart/fall reset and menu return for repeated testing.
- Automated suite covers 36 assertions at each of 30, 60 and 120 physics ticks/s, including a zero-buffer tuning regression.

**User feedback:** the initial visual presentation was reviewed and approved ("yes it looks good").

**Acceptance follow-up:** detailed movement-feel feedback, full hands-on course traversal and physical gamepad validation. Placeholder art remains intentionally early-stage. No known progression-blocking issue has been observed in the automated or browser smoke checks.

## Next milestone — M2

After M1 feel feedback is addressed: player health, sword combat, checkpoints, runes and basic gameplay UI. No M2 gameplay systems have been added yet.

Later gates remain as defined in `../specs.md`: enemies/boss (M3), complete Troll Bridge level (M4), visual/audio polish (M5), public demo validation/distribution (M6).

## First playable artifacts

- Source: `project.godot`, `scenes/`, `scripts/`, `tests/`, `tools/`.
- Browser files: `build/web/` (regenerable, not tracked).
- Captures: `build/screenshots/` (regenerable, not tracked).
- Test evidence: `build/test-results/` after `bash tools/check.sh`.
- Startup and controls: `../README.md`.
