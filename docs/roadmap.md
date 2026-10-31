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

**Acceptance:** user approved M2, subject to hands-on feedback. `feat/m2-core-gameplay` was fast-forward merged into `main` at `856a666`, the 360-check suite passed on the merged result, and main was pushed.

## M3 — Enemies and boss: implemented and verified, awaiting review

- Draugr: bounded patrol, sight-based detection/chase, telegraphed melee, hurt/knockback and death.
- Raven: flight patrol, fixed-aim warning/dive, recovery/route return, hurt and death.
- Bridge Troll: introduction/health bar, predictable slam/club/charged-smash cycle, recovery, damage, bounded bridge breakage and defeat/exit sequence.
- Shared enemy lifecycle, existing health/hurtbox/hitbox ownership, exported tuning and attack profiles.
- Selectable combat room with 1/2/3 opponent selection, R retry and automatic death reset. Previous M1/M2 scenes remain selectable.
- Verification: 700 assertions pass, covering prior gameplay, art contracts and M3 at 30/60/120 physics Hz. Standard-input tests defeat every type with default health/sword/jumps and no retries. Chrome/native captures and a recorded Troll victory provide runtime evidence.

**Next action:** user hands-on M3 review and balance/telegraph feedback. M4/M5 stay blocked until M3 is reviewed and accepted.

## M5 — Visual polish: deferred, mandatory visual acceptance gate

The first art handoff is extracted and available for later incremental integration. It is provisional, not a final production art release. Intake details and caveats: `handoff/ART_HANDOFF_INTEGRATION.md`; metadata: `../asset_manifest.json`; authoritative gate: `handoff/M5_VISUAL_GATE_AGENT_PROMPT.md` and M5 in `../specs.md`.

M5 must demonstrate an actual playable Godot level, screenshots and a short gameplay-resolution recording. Provide a pass/fail table and side-by-side reference/runtime comparisons covering:

1. Approved blond Viking identity, blue tunic, red cape, shield/seax, expressive animation and stable foot anchor/collision.
2. Consistent pixel grid, scale, palette and shading across all game assets/UI.
3. Rich Norwegian fjords, steep mountains, pine/spruce forests, waterfalls, bridges and Norse architecture.
4. Independent background/foreground layers with parallax verified in motion, without seams or camera jitter.
5. Real frame-based hero/enemy/boss animations and readable rune/checkpoint interactions.
6. Clear foreground terrain, hazards, enemies and interactive elements against detailed scenery.
7. Welcoming Nordic atmosphere and mythic rune accents consistent with references.
8. Documented creator/source/license provenance for external assets.
9. Actual in-game comparison evidence and resolution of significant visual gaps.
10. Passing established Godot tests, browser checks and gameplay traversal, with exact environments and unsupported checks recorded.

**PASS requires all ten evidenced criteria, no significant unresolved visual gap, and human visual acceptance.** Otherwise report **NEEDS ART ITERATION** and resolve prioritized differences before requesting approval. No fidelity percentages and no completion claim based solely on placeholder replacement. Preserve gameplay throughout; provisional art may be replaced/refined without changing accepted mechanics.

M4 (complete Troll Bridge level) and M6 (public demo) remain as defined in `../specs.md`.

## First playable artifacts

- Source: `project.godot`, `scenes/`, `scripts/`, `tests/`, `tools/`.
- Browser files: `build/web/` (regenerable, not tracked).
- Captures: `build/screenshots/` (regenerable, not tracked).
- Test evidence: `build/test-results/` after `bash tools/check.sh`.
- Startup and controls: `../README.md`.
