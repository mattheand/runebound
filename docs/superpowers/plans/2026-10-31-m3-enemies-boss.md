# M3 Enemies and Boss Implementation Plan

> **For agentic workers:** Execute inline with test-driven-development. M0–M2 are accepted; M2 was fast-forward merged and its 360 assertions rerun successfully on main before this branch.

**Goal:** A runnable combat-testing room with a Draugr, Raven and defeatable Bridge Troll, preserving M0–M2.

**Architecture:** Reuse HealthComponent and hitbox/hurtbox ownership. A shared enemy actor handles target validation, hurt/death/reset and state signals. A profile-driven attack component handles telegraph/active/recovery timing. Separate enemy controllers own ground patrol/chase, locked-direction flight dives and the boss's three-pattern encounter. The test room owns selection, arena bounds, bridge damage/reset, player respawn and trial completion.

**Tech Stack:** Godot 4.7.2, GDScript, native physics, Compatibility renderer, temporary programmatic presentation.

**Spec:** `specs.md` enemy phase and M3 milestone; user's ordered implementation request. M4/M5 excluded.

## Decisions

- Draugr: idle/patrol/chase/attack/hurt/dead; bounded patrol, line-of-sight detection, ledge avoidance, interruptible telegraphed melee.
- Raven: patrol/telegraph/dive/recovery/return/hurt/dead; capture aim at warning start, no mid-dive homing, one hit per dive, recovery before returning to the route.
- Troll: dormant/intro/chase/attack/dead; visible intro, health bar, predictable slam → club → charged smash cycle. Each attack has wind-up, active and recovery phases. Ground slam can be jumped; directional attacks can also be avoided by retreating/crossing behind. Boss remains damageable during combat, with brief hit flash instead of stun-lock.
- Charged smash breaks a bounded bridge patch in the test room; retries restore it. Boss defeat stops all damage, plays a short sequence, unlocks the exit and completes the combat trial.
- Test room selector: 1/Draugr, 2/Raven, 3/Troll. R retries current encounter, Escape returns to menu. M1/M2 remain selectable from main menu.
- Run tests at 30/60/120 physics Hz, including a real-input standard-sword boss win. Add browser/native captures and a Chrome smoke check.

## Task 1 — Draugr and shared enemy foundation

- [x] Write/run failing state, detection, attack, hurt/death and reset tests.
- [x] Add `EnemyActor`, `EnemyAttack`, `EnemyAttackProfile`, Draugr tuning/controller/scene and temporary enemy visual.
- [x] Verify patrol boundaries, chase/LOS, melee timing, interruptions and death.

## Task 2 — Raven

- [x] Write/run failing flight patrol, telegraph, locked dive, recovery and hurt/death tests.
- [x] Add configurable flight controller/scene using shared health and timed attack.
- [x] Verify attack cancellation, return to route and no repeated dive damage.

## Task 3 — Bridge Troll

- [x] Write/run failing intro, three attacks, recovery, damage, bridge event and defeat tests.
- [x] Add boss tuning/controller/scene, clear telegraphs and phase-driven feedback.
- [x] Verify no attacks before intro/after death, health accounting and bounded bridge damage.

## Task 4 — Combat room and handoff

- [x] Add selection/retry room, arena collision bounds, bridge patch, boss HUD and completion/exit flow.
- [x] Add actual input-driven enemy defeats and a standard-ability boss victory test.
- [x] Rerun M0–M2 and new suites, validate export and rendered Chrome/native gameplay, request read-only review.
- [x] Update README/architecture/testing/roadmap and `docs/HANDOFF.md`. Stop before M4/M5.
- [ ] Commit/publish M3 branch for user review.

## Outcome

700 assertions pass across prior regressions, 43 provisional asset contracts and M3's three tested physics rates. Every input-only fight wins using the default three-heart player without retries. A 573-frame native Troll-victory movie and inspected Chrome/native captures demonstrate the actual runtime. Read-only review independently passed all 99 M3 checks at 60 Hz with no actionable findings. Art Handoff v1 was separately imported/committed and its future M5 gate documented without replacing current gameplay presentation.
