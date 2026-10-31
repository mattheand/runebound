# M4 Complete Troll Bridge Level Implementation Plan

> **For agentic workers:** Execute inline with test-driven development and runtime verification. M3 was accepted, merged into main at `410b3ba`, and all 700 existing assertions passed on merged main before this branch.

**Goal:** One continuous, completable Troll Bridge adventure with the five specified sections, existing combat/enemies/checkpoints/runes, an optional cave and a boss-led completion flow.

**Architecture:** A fixed authored layout assembles reusable TileMap platforming beats and existing actors/pickups. AdventureProgress extends session-local LevelProgress with death/time/world flags. Small reusable interaction zones, breakable stone and gates handle the cave and progression. The adventure controller owns routing, checkpoint retries, arena locks and completion; the HUD owns presentation only.

**Tech Stack:** Godot 4.7.2, GDScript, Compatibility, existing CharacterBody2D and damage components, provisional programmatic scenery.

**Spec:** `specs.md` sections 5, 6 and M4; user authorization. M5 is blocked pending M4 acceptance.

## Scope and design decisions

- Fixed authored sequence of 38 1,024px platforming beats, then the existing-style 640px boss arena and exit; this is not procedural world generation.
- Starting Forest introduces jumps/runes; Forest Cliffs adds gaps, high routes and enemies; an optional lower Hidden Cave has a sword-opened entrance and E-activated rune switch; Stave Church Vista supplies scenery, recovery and foreshadowing; a long wooden bridge leads to the Troll.
- Seven runes: five on the main route and two in the optional cave. Any five open the bridge gate; all seven are shown on the completion screen. Players can backtrack, and the cave cannot lock the main route.
- Checkpoints heal on first activation; death/R restores the latest checkpoint, ordinary enemies and breakable boss bridge. Collected runes, cave entrance/switch and boss defeat persist within the session. New game resets all progress.
- The cave uses explicit E-operated passage zones within the same level scene. Travel preserves health/rune state and relocates presentation/physics safely. A cave checkpoint restores cave camera/kill-plane context.
- Boss arena reuses the accepted Troll profiles/health. Intro closes the back gate, defeat unlocks the exit; completion displays runes, deaths and time with restart/menu actions.
- M4 adds pause/resume that freezes gameplay/time; earlier trials retain their own Escape behavior.
- Layout targets 5–10 minutes for first play through route length, vertical platforming, encounters and exploration. Measure the efficient input-driven route and document that first-player timing needs review; do not invent a human playtest duration or add artificial waits.
- Keep M1/M2/M3 test scenes selectable. Keep imported art provisional; M5 fidelity work is not started.

## Task 1 — Progress and reusable level interactions

- [x] Write failing tests for world-flag persistence, gates, switch/portal triggers, breakable entrance, completion idempotence and fresh-session reset.
- [x] Implement AdventureProgress, rune gate, breakable stone and interaction zone scenes with existing health/hurtbox components.
- [x] Verify component behavior before assembly.

## Task 2 — Authored five-section route

- [x] Add layout data, terrain beats, authored runes/checkpoints/enemies, cave interior and provisional landmarks.
- [x] Add level controller/HUD with objectives, section tracking, camera context, retries and persistent progression.
- [x] Add locked boss arena, bridge destruction/repair and victory/exit/completion UI.
- [x] Preserve existing menu entries and add The Troll Bridge as the main entry.

## Task 3 — Full-level verification

- [x] Add real-input route through the full level, including cave interactions, all seven runes, gate, normal-sword boss victory and exit.
- [x] Verify bypassing the optional cave remains completable with the five main-route runes and no permanent progression lock.
- [x] Test death/respawn in main route, cave and boss arena; persistent runes/flags and completion restart/menu.
- [x] Rerun old suites and new checks, validate Chrome/native rendering, measure route duration and request read-only review.

## Task 4 — Handoff

- [x] Update README, roadmap, testing/architecture and `docs/HANDOFF.md` with instructions, evidence, known issues and deferred M5 gate.
- [ ] Commit/publish M4 branch for user review; do not start M5.

## Verified outcome

1,087 assertions pass. Both input-only level routes complete without deaths (7/7 through the cave, 5/7 on the main route) in about 203.5 seconds. Native captures cover all five sections and completion; M4/M3/M2 Chrome smoke checks pass. Review found a cave-roof fall trap and a gate visual/collision height mismatch; both are fixed, with a failing-then-passing fall regression. First-time 5–10-minute pacing remains a human review target, not a measured claim. Handoff 2 was preserved separately in `eee7fc2`, with 15 passing source checks and no combat changes. M5 remains blocked pending M4 acceptance.
