# RUNEBOUND — Autonomous Game Development Specification

**Project:** RUNEBOUND — The Nine Realms  
**Initial playable level:** The Troll Bridge  
**Engine:** Godot 4.7 stable, GDScript  
**Primary distribution:** Browser (HTML5)  
**Secondary distribution:** Windows, macOS, Linux  
**Visual style:** High-quality 16-bit-inspired pixel art  
**Development priority:** Gameplay → Functional level → Visual quality → Polish

---

# 1. Your Mission

You are the lead game developer, game designer, and technical architect responsible for developing RUNEBOUND.

Your responsibility is to transform the supplied concept artwork and existing prototype into an actual, playable, well-structured 2D game.

You must write production-quality code, organize the project, implement gameplay systems, create or integrate assets, test the results, and deliver working builds.

Do not stop after producing documentation, architectural recommendations, concept illustrations, or sample code.

**Your primary goal is to deliver a playable game.**

Work incrementally, prioritize working software, and verify each milestone before proceeding.

## Autonomous working rules

1. Make reasonable implementation decisions without repeatedly requesting approval.
2. Maintain a runnable project throughout development.
3. Implement and test systems incrementally.
4. Run the Godot editor or headless validation tools wherever available.
5. Prefer simple, maintainable implementations over unnecessary abstractions.
6. Use placeholder assets temporarily when necessary, but replace them during the visual-polish phases.
7. Never claim a feature works without verifying it.
8. Commit working milestones to Git, if repository access is available.
9. Document blockers and unsupported operations instead of inventing test results.
10. Preserve the established artistic and gameplay direction.

If an external capability is unavailable, complete everything possible locally and provide the precise remaining manual steps.

---

# 2. Game Vision

## High-level concept

RUNЕBOUND is a 2D side-scrolling action platformer inspired by classic Mario and Donkey Kong Country games, combined with Norwegian landscapes, Scandinavian folklore, and Norse mythology.

The game should be:

- Accessible and enjoyable.
- Visually atmospheric.
- Responsive and satisfying to control.
- Rooted in recognizable Norwegian scenery.
- Rich in Nordic folklore and mythology.
- Suitable for exploration and discovery.
- Challenging without becoming excessively punishing.

## Story premise

The light of Baldr is disappearing, and a mysterious corruption is spreading between the Nine Realms.

The protagonist is a young Viking adventurer who discovers that ancient runes can restore connections between the realms.

As the adventure progresses, the player encounters Norse gods, explores mythological landscapes, and acquires divine abilities.

The broader narrative should draw from Norse mythology without requiring strict adherence to every historical detail.

Avoid reducing the game to generic Viking combat.

## Main character

The protagonist is a small, recognizable Viking adventurer.

Established appearance:

- Blond hair.
- Blue wool tunic.
- Distinctive flowing red cape.
- Brown leather boots.
- Small round shield.
- Short sword or seax.
- Friendly but courageous personality.

The red cape and blue tunic are essential visual identifiers.

The character must be immediately recognizable at gameplay resolution.

## Gameplay philosophy

The primary gameplay loop:

**Explore → Jump → Fight → Collect runes → Discover secrets → Overcome boss → Unlock next area.**

Movement must feel excellent before adding complex mechanics.

The game must remain fun even when played without visual effects or elaborate scenery.

---

# 3. Technical Requirements

## Engine

Use Godot 4.7 stable unless the installed environment provides a newer, verified stable Godot 4 release with equivalent web-export support.

Use:

- GDScript.
- Godot's native 2D physics.
- CharacterBody2D for the player.
- TileMapLayer for modular environments.
- Camera2D for camera behavior.
- AnimationPlayer and/or AnimatedSprite2D for animations.
- Area2D for triggers, collectibles, and hit detection.
- Signals for communication between components.
- Resources for configurable enemy/player parameters.
- AudioStreamPlayer nodes for sound effects and music.

## Renderer and exports

Use Godot's Compatibility renderer.

The initial implementation must support HTML5 export.

Do not rely on C# or browser-incompatible GDExtensions.

Prefer single-threaded browser exports unless there is a demonstrated need for threading.

Target Chromium-based browsers first, then validate Firefox and Safari.

## Resolution

Recommended initial settings:

- Logical gameplay resolution: 640 × 360.
- Aspect ratio: 16:9.
- Pixel-art-friendly scaling.
- Nearest-neighbor texture filtering for pixel-art assets.
- Controlled pixel snapping to avoid visual jitter.
- Consistent visual pixel density.

Avoid mixing sprites with substantially different pixel densities.

## Performance

Initial targets:

- 60 FPS on an ordinary desktop.
- No noticeable stuttering during gameplay.
- Fast scene transitions.
- No avoidable large allocations during gameplay.
- Efficient enemy activation and off-screen processing.

These are targets, not claims of tested performance.

---

# 4. Repository and Project Structure

Create a Git repository structured approximately as follows:

```text
runebound/
├── project.godot
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   ├── game-design.md
│   ├── architecture.md
│   ├── controls.md
│   ├── asset-pipeline.md
│   ├── testing.md
│   └── roadmap.md
├── assets/
│   ├── characters/
│   │   ├── hero/
│   │   ├── draugr/
│   │   ├── raven/
│   │   └── troll/
│   ├── environments/
│   │   ├── midgard/
│   │   └── shared/
│   ├── effects/
│   ├── ui/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── concept_art/
├── scenes/
│   ├── main/
│   ├── player/
│   ├── enemies/
│   ├── bosses/
│   ├── collectibles/
│   ├── interactables/
│   ├── levels/
│   └── ui/
├── scripts/
│   ├── components/
│   ├── systems/
│   └── resources/
├── tests/
├── build/
└── tools/
```

Adapt this layout if necessary, but keep a clear separation between reusable systems, game content, and assets.

Do not commit unnecessary generated caches or temporary build artifacts.

---

# 5. Development Phases

## Phase 0 — Audit and Setup

**Objective:** Establish a functional project and understand the existing work.

### Tasks

1. Inspect all supplied files.
2. Review the original HTML/JavaScript prototype, if available.
3. Examine the existing RUNEBOUND character and environment concept artwork.
4. Identify mechanics worth preserving from the prototype.
5. Create or initialize the Godot project.
6. Configure the renderer, resolution, and input mappings.
7. Set up repository structure.
8. Create a basic main menu and playable test scene.
9. Verify the project runs in the local Godot environment.
10. Document anything that could not be imported or reused.

The existing HTML prototype is a reference implementation, not a requirement to preserve its JavaScript architecture.

If the original files are not accessible, do not block development: reconstruct the core gameplay from this specification.

### Deliverables

- Valid Godot project.
- Working main scene.
- Player placeholder.
- Basic test environment.
- README with startup instructions.
- Initial Git commit.

### Acceptance criteria

- Godot opens the project without errors.
- Main scene starts correctly.
- No missing-resource errors.
- Player placeholder appears in the game window.

---

## Phase 1 — Player Controller

**Objective:** Create excellent platforming controls.

This is the most important mechanical milestone.

### Core movement

Implement:

- Walk left and right.
- Acceleration and deceleration.
- Jumping.
- Variable jump height.
- Double-jump.
- Air control.
- Gravity.
- Landing detection.
- Facing direction.
- Sprite flipping.
- Platform collision.

### Feel improvements

Implement:

**Coyote time**

Allow the player to jump briefly after leaving a platform.

Suggested initial value: 100 milliseconds.

**Jump buffering**

Allow jump input shortly before landing to trigger the jump when contact occurs.

Suggested initial value: 120 milliseconds.

**Variable jump height**

Holding jump should produce a higher jump than tapping it.

**Responsive acceleration**

Avoid excessively slow or slippery movement.

**Double-jump feedback**

Provide a visual or sound effect to distinguish the second jump.

All values must be configurable rather than hardcoded throughout the codebase.

### Initial controls

| Action | Keyboard |
|---|---|
| Move left | A / Left arrow |
| Move right | D / Right arrow |
| Jump / Double-jump | Space |
| Sword attack | J |
| Divine ability | K |
| Interact | E |
| Pause | Escape |

Use named Godot Input Map actions rather than direct key polling.

Provide gamepad support using Godot's input abstraction where practical.

### Acceptance criteria

- Player can move consistently.
- Jump height responds to button duration.
- Coyote time works.
- Jump buffering works.
- Double-jump resets appropriately on landing.
- Player cannot jump indefinitely.
- No collision clipping during ordinary movement.
- Gameplay remains stable at different frame rates.

### Deliverable

A playable movement-testing scene with platforms at different heights.

---

## Phase 2 — Camera and World Systems

**Objective:** Create the foundation for scrolling levels.

### Camera

Implement:

- Horizontal player following.
- Vertical follow behavior.
- Camera bounds.
- Optional camera look-ahead.
- Smooth but responsive camera movement.
- Camera behavior around large jumps and falls.

Avoid camera motion that introduces excessive pixel shimmer.

### Level construction

Use reusable modular elements:

- Ground platforms.
- Stone platforms.
- Wooden bridges.
- Collapsing platforms.
- Moving platforms.
- Cliffs.
- Small gaps.
- Large gaps.
- Walls.
- Secret passages.

### Checkpoints

Create a reusable checkpoint component.

When activated:

- Store the player's respawn position.
- Play an activation animation.
- Provide visual confirmation.
- Preserve appropriate level progress.

### Death and respawning

Implement:

- Falling into hazards.
- Taking fatal damage.
- Death animation.
- Respawning at the last checkpoint.
- Resetting relevant enemy and platform states.

### Acceptance criteria

- Camera never leaves intended level boundaries.
- Checkpoints activate reliably.
- Respawning does not break scene state.
- Moving platforms carry the player predictably.
- Collapsing platforms reset correctly after respawn.

---

## Phase 3 — Combat and Health

**Objective:** Establish a simple, satisfying combat system.

### Player health

Start with three hearts.

Implement:

- Current and maximum health.
- Damage handling.
- Temporary invulnerability after taking damage.
- Knockback.
- Healing.
- Death.

### Sword combat

Implement:

- Basic sword attack.
- Attack animation.
- Hitbox active during appropriate animation frames.
- Short attack cooldown.
- Enemy knockback.
- Directional attacks.
- Hit feedback.

The attack system must not damage an enemy multiple times accidentally during one sword swing.

### Combat feedback

Add:

- Small impact particles.
- Enemy hit flash.
- Sword-swing sound.
- Damage sound.
- Brief screen shake for significant impacts.

Keep feedback satisfying without overwhelming the screen.

### Acceptance criteria

- Player can damage enemies.
- Enemies can damage the player.
- Invulnerability prevents immediate repeated damage.
- Damage cannot be applied indefinitely during a single collision.
- Combat animations and hitboxes remain synchronized.

---

## Phase 4 — Enemies

**Objective:** Implement three enemy types with distinct behavior.

### Enemy 1 — Draugr

A slow undead Norse warrior.

Behavior:

- Patrol between boundaries.
- Detect a nearby player.
- Approach the player.
- Perform a melee attack.
- Receive damage.
- Play a death animation.

Use a simple finite-state machine.

States:

- Idle.
- Patrol.
- Chase.
- Attack.
- Hurt.
- Dead.

### Enemy 2 — Raven

A flying enemy.

Behavior:

- Move along a defined patrol route.
- Detect the player.
- Dive toward the player.
- Return to the patrol route.
- Receive damage and be defeated.

Keep the flight motion readable and avoid unpredictable unavoidable attacks.

### Enemy 3 — Bridge Troll

A large boss enemy.

The troll must feel substantially different from ordinary enemies.

Initial attacks:

1. Ground slam.
2. Horizontal club swing.
3. Powerful charged smash that damages part of the bridge.

Each attack must have:

- Telegraph/wind-up.
- Active damage window.
- Recovery period.
- Clear player counterplay.

### Boss health

Display a boss health bar during the encounter.

### Boss behavior

Implement:

- Intro trigger.
- Arena boundaries.
- Multiple attack patterns.
- Recovery windows.
- Damage reactions.
- Defeat sequence.
- Reward or exit unlock.

The boss must be beatable using the standard player abilities available in Level 1.

Do not require divine abilities unlocked in later levels.

### Acceptance criteria

- All enemy types can damage and receive damage.
- Enemies stop acting after death.
- The troll does not use impossible-to-dodge attack combinations.
- The boss encounter can be completed without cheats.
- Defeating the troll triggers the level-completion sequence.

---

## Phase 5 — Collectibles and Rune Mechanics

**Objective:** Introduce the main collection and progression system.

### Rune collectibles

The first level contains seven collectible runes.

Each rune:

- Floats or pulses visually.
- Emits a subtle glow.
- Disappears when collected.
- Plays a sound.
- Updates the rune counter.
- Cannot be collected twice.

### Rune gate

Create a gate controlled by an ancient rune mechanism.

The initial level may use a rune switch or collection threshold, but the logic must be clearly communicated to the player.

Avoid locking the player permanently out of progression.

### Hidden secrets

Include:

- One hidden cave.
- Extra rune pickups or an optional reward.
- A destructible or concealed entrance.
- A visual clue pointing toward the secret.

### Future scalability

Implement the collection system so that other types of collectibles can be added later without rewriting the core logic.

### Acceptance criteria

- Rune counter is accurate.
- Collectibles do not duplicate.
- Gate state updates correctly.
- Optional secrets do not soft-lock the player.
- Collection state behaves consistently after respawning.

---

# 6. The First Complete Level — The Troll Bridge

This is the primary vertical slice.

## Environment

**Realm:** Midgard  
**Location:** Norwegian fjord countryside  
**Duration target:** 5–10 minutes for a first-time player  
**Theme:** A forgotten bridge guarded by a troll

### Visual identity

The environment must include:

- Large Norwegian mountains.
- Snow-capped distant peaks.
- Pine and spruce forests.
- A deep fjord.
- Waterfalls.
- Wooden cabins.
- A distant stave church.
- Rune stones.
- Weathered wooden bridges.
- Mossy stone ruins.
- Occasional ravens.
- Subtle Bifröst-like light in the sky.

Avoid making the level look like a generic medieval fantasy environment.

### Level layout

#### Section A — Starting forest

Purpose: Introduce basic movement.

Include:

- Safe starting area.
- Introductory rune stone.
- Basic jumps.
- First collectible rune.
- Norwegian wooden cabin.
- Gentle rising terrain.

#### Section B — Forest cliffs

Purpose: Introduce vertical movement and hazards.

Include:

- Gaps.
- Elevated platforms.
- A patrolling draugr.
- A flying raven.
- A waterfall.
- Several collectible runes.

#### Section C — Hidden cave

Purpose: Reward exploration.

Include:

- Concealed entrance.
- Dark cave interior.
- Glowing runes.
- Environmental puzzle.
- Optional treasure or collectible.

#### Section D — Stave church vista

Purpose: Create a memorable pause before the boss.

Include:

- Scenic viewpoint.
- Large fjord panorama.
- Distant stave church.
- Checkpoint.
- Boss foreshadowing.

#### Section E — The Troll Bridge

Purpose: Deliver the climax.

Include:

- Long, weathered bridge.
- Boss trigger.
- Troll arena.
- Destructible bridge elements.
- Boss health bar.
- Three attack patterns.
- Victory animation.

### Level completion

After defeating the troll:

- Unlock the exit.
- Play a short victory sequence.
- Show a level-completion screen.
- Display runes collected.
- Allow restarting or returning to the main menu.

Optionally introduce a hint that Thor will play a role in the next level.

---

# 7. Visual Art Direction

The supplied concept artwork defines the target visual identity.

Do not interpret the concept images as finished, game-ready assets.

Create actual gameplay assets with consistent resolution, palette, proportions, and animation.

## Style

- 16-bit-inspired pixel art.
- Strong readable silhouettes.
- Detailed environments.
- Atmospheric background layers.
- Vibrant but natural colors.
- Expressive character animations.
- Carefully controlled lighting and effects.

## Core palette

Suggested colors:

- Deep fjord blue.
- Alpine blue.
- Forest green.
- Moss green.
- Stone gray.
- Warm wood brown.
- Rune cyan.
- Hero cape red.

Use palette variation between foreground, middle ground, and background to maintain depth and readability.

## Hero animation requirements

At minimum:

- Idle.
- Walk.
- Run.
- Jump.
- Fall.
- Double-jump.
- Sword attack.
- Hurt.
- Death.
- Victory.

The animation system must be expandable.

## Enemy animations

At minimum:

- Idle.
- Movement.
- Attack.
- Hurt.
- Death.

The troll also needs distinct telegraph and recovery animations for each attack.

## Environmental assets

Produce reusable assets for:

- Grass-topped platforms.
- Stone platforms.
- Wooden platforms.
- Rope bridges.
- Rune stones.
- Pine trees.
- Spruce trees.
- Rocks.
- Waterfalls.
- Torches.
- Flags.
- Nordic architectural elements.

## Parallax backgrounds

Separate environment layers:

1. Foreground vegetation.
2. Active gameplay terrain.
3. Nearby forests.
4. Fjord and villages.
5. Distant mountains.
6. Sky and clouds.

Movement speeds must differ enough to create depth without distracting the player.

## Asset quality requirements

- Use consistent sprite scaling.
- Maintain transparent backgrounds where needed.
- Avoid blurry image resizing.
- Avoid inconsistent lighting directions.
- Avoid mixing incompatible art styles.
- Validate that animation frames align correctly.
- Document the palette and grid conventions.

When custom sprite generation is not available, create coherent temporary pixel-art assets programmatically or use appropriately licensed placeholders.

Track all external asset sources and licenses.

Do not use copyrighted Mario, Donkey Kong, or other commercial game sprites, music, or level designs.

---

# 8. UI and Menus

## Main menu

Include:

- RUNEBOUND title.
- Start Game.
- Settings.
- Quit where applicable.

Use a beautiful background based on the Norwegian fjord aesthetic.

## HUD

Display:

- Player health.
- Rune collection count.
- Available divine ability when unlocked.
- Boss health during encounters.

Keep the HUD compact and readable.

## Pause menu

Include:

- Resume.
- Restart from checkpoint.
- Settings.
- Return to menu.

## Settings

Initial settings:

- Master volume.
- Music volume.
- Sound effects volume.
- Fullscreen where supported.
- Basic control reference.

## Level-completion screen

Display:

- Level completed.
- Runes collected.
- Death count.
- Completion time.
- Restart / menu options.

---

# 9. Audio and Atmosphere

Create an audio system supporting:

- Background music.
- Environmental ambience.
- Combat effects.
- Jump and landing sounds.
- Rune collection sounds.
- Enemy sounds.
- Boss music.

## Music direction

Nordic folk-inspired melodies blended with atmospheric retro-game sound design.

Possible instruments:

- Strings.
- Flutes.
- Frame drums.
- Low drones.
- Subtle synthesized elements.

Use original or properly licensed compositions.

Do not copy existing copyrighted game soundtracks.

## Ambient audio

Include:

- Flowing water.
- Wind.
- Birds.
- Forest ambience.
- Wooden bridge creaks.
- Cave atmosphere.

Balance ambience so it does not obscure important gameplay feedback.

---

# 10. Architecture Requirements

Create reusable systems with clear responsibilities.

## Recommended components

**PlayerController**

Movement, jumping, physics, and player state.

**HealthComponent**

Health management, damage, healing, and death signals.

**HitboxComponent**

Attack detection and outgoing damage.

**HurtboxComponent**

Incoming damage detection.

**EnemyController**

Common enemy behavior.

**EnemyStateMachine**

Behavior-state transitions.

**CollectibleComponent**

Collection and reward logic.

**CheckpointSystem**

Respawn position and checkpoint state.

**LevelManager**

Level state and completion.

**GameManager**

High-level game state.

**AudioManager**

Centralized audio playback.

**SaveManager**

Persisted progress and settings.

**UIManager**

Menus and relevant HUD coordination.

These are suggested boundaries, not a demand to create unnecessary singleton classes.

## Engineering principles

- Favor composition over deep inheritance trees.
- Use typed GDScript where beneficial.
- Avoid global mutable state unless justified.
- Keep scenes reusable.
- Expose gameplay tuning parameters.
- Use signals instead of tight coupling where appropriate.
- Avoid overly complex dependency injection frameworks.
- Keep gameplay logic separate from presentation.
- Add comments explaining non-obvious behavior.

---

# 11. Testing and Quality Assurance

Testing is mandatory.

## Automated validation

Where possible, run:

- Godot headless project import.
- Script parse checks.
- Scene loading checks.
- Unit tests for standalone logic.
- Integration tests for collection and checkpoint mechanics.
- Export validation.

A successful script parse is not sufficient to claim that the game is fully tested.

## Manual gameplay testing

Verify:

### Player

- Movement.
- Jumping.
- Double-jumping.
- Collision.
- Death and respawn.
- Sword attacks.

### Enemies

- Patrol behavior.
- Attack behavior.
- Damage.
- Death.
- State transitions.

### Collectibles

- Rune pickup.
- Counter updates.
- Persistent collection behavior.
- Gate activation.

### Boss

- Intro trigger.
- All attack patterns.
- Damage handling.
- Player death and retry.
- Boss defeat.
- Level completion.

### UI

- Menus.
- Pause/resume.
- Health display.
- Rune counter.
- Settings.
- Completion screen.

### Browser compatibility

Test:

- Chrome or Chromium.
- Firefox.
- Safari where available.

Document untested browser combinations explicitly.

## Bug policy

Fix all known progression-blocking bugs before completing a milestone.

Classify issues as:

- Critical: crash, corrupted save, impossible progression.
- High: major gameplay failure.
- Medium: noticeable non-blocking gameplay problem.
- Low: cosmetic issue.

Do not proceed to commercial-release preparation while critical issues remain unresolved.

---

# 12. Build and Distribution

## Browser

Generate a proper Godot HTML5 export.

The exported game must be served through an appropriate web server or game-hosting service.

Do not assume users can run a Godot web export correctly by opening index.html directly from the filesystem.

Preferred hosting options:

- itch.io.
- GitHub Pages, if compatible with the export configuration.
- Another simple static hosting provider.

If deployment credentials or permissions are unavailable, provide deployment-ready files and exact instructions.

## Desktop

Generate builds for supported platforms where build infrastructure allows:

- Windows.
- macOS.
- Linux.

Validate actual startup behavior on platforms available to the development environment.

Do not claim cross-platform testing based only on successful export.

## Release artifacts

Every major milestone should produce:

1. Source code.
2. Runnable project.
3. Build artifacts where supported.
4. Release notes.
5. Known issues.
6. Instructions for running and testing.
7. Screenshots or gameplay recordings when capture tools are available.

Avoid distributing excessively large or unnecessary development assets with playable builds.

---

# 13. Milestones and Delivery Gates

## Milestone M0 — Project initialization

Deliver:

- Clean Godot project.
- Valid main scene.
- Repository structure.
- Input configuration.

Gate: Project runs without errors.

## Milestone M1 — Player movement

Deliver:

- Movement.
- Jumping.
- Double-jump.
- Camera.
- Collision playground.

Gate: Movement works reliably and feels responsive.

## Milestone M2 — Gameplay systems

Deliver:

- Player health.
- Sword combat.
- Checkpoints.
- Runes.
- Basic UI.

Gate: Player can traverse a small test area and interact with gameplay objects.

## Milestone M3 — Enemies and boss

Deliver:

- Draugr.
- Raven.
- Bridge Troll.
- Enemy AI.
- Damage and death flow.

Gate: All enemies operate correctly, and the boss can be defeated.

## Milestone M4 — Complete level

Deliver:

- Full Troll Bridge level.
- Hidden cave.
- Collectibles.
- Checkpoint.
- Boss encounter.
- Completion screen.

Gate: The entire level is playable from beginning to end.

## Milestone M5 — Visual polish

Deliver:

- Improved hero sprites.
- Animated enemies.
- Norwegian scenery.
- Parallax backgrounds.
- Visual effects.
- Music and sound effects.

Gate: Game appearance is coherent and substantially reflects the supplied concept art.

## Milestone M6 — Public demo

Deliver:

- Browser build.
- Desktop builds where possible.
- Setup instructions.
- Tested gameplay.
- Release notes.

Gate: Another person can access and play the demo without development assistance.

---

# 14. Future Game Expansion

Do not implement these systems before the first vertical slice is stable.

The wider game may include additional realms.

## Midgard

Norwegian forests, villages, fjords, and trolls.

## Alfheim

Magical forests, elves, glowing plants, and illusion-based puzzles.

## Jotunheim

Snow-covered mountains, giants, ice platforms, and dangerous weather.

## Asgard

Golden halls, divine architecture, celestial bridges, and encounters with gods.

Other realms may be added later after narrative and scope review.

## Divine abilities

**Thor — Thunder Smash**

Break obstacles and activate mechanisms.

**Loki — Illusion**

Create temporary duplicates for puzzles and combat.

**Odin — Raven Sight**

Reveal hidden paths and concealed runes.

These abilities should change level exploration, not merely increase combat damage.

Build reusable ability interfaces when implementing these systems later.

---

# 15. Scope and Prioritization

Use the following priorities.

## P0 — Essential

- Project runs.
- Player movement works.
- Collisions work.
- Level can be completed.
- Enemies function.
- Boss can be defeated.
- No progression-blocking bugs.

## P1 — Important

- Good animations.
- Attractive environments.
- Sound effects.
- Parallax scenery.
- Checkpoints.
- Consistent UI.
- Browser compatibility.

## P2 — Optional

- Advanced weather effects.
- Elaborate environmental interactions.
- Additional combat combos.
- Extra secrets.
- Complex cinematic sequences.

## Explicitly out of scope for the first demo

- Multiplayer.
- Online accounts.
- Backend services.
- Microtransactions.
- Mobile app-store publishing.
- Procedural world generation.
- Open-world systems.
- All Nine Realms.
- Complex RPG skill trees.
- Large inventories.

Do not spend time on these unless separately authorized.

---

# 16. Progress Reporting

At the completion of every milestone, provide a concise report containing:

**Milestone:** Name and status.

**Implemented:** What has been completed.

**Verified:** Exact tests performed and outcomes.

**Playable:** How to launch and test the current version.

**Artifacts:** Source, builds, screenshots, or links.

**Known issues:** Outstanding problems.

**Next step:** The next concrete implementation milestone.

When source control is available, include the relevant commit hash.

Do not report estimated completion percentages without a meaningful basis.

Do not mark a milestone as completed just because the source files exist.

---

# 17. Definition of Done

The first RUNEBOUND vertical slice is complete when:

1. The player can start the game from the main menu.
2. The Viking character can run, jump, double-jump, and attack.
3. The camera follows naturally.
4. The Norwegian fjord level contains distinct sections.
5. Runes can be collected.
6. Enemies behave correctly.
7. The hidden cave can be discovered.
8. Checkpoints and respawning work.
9. The Bridge Troll can be fought and defeated.
10. The player can complete the level and return to the menu.
11. The game includes cohesive pixel-art graphics.
12. The game includes suitable audio feedback.
13. A browser build runs successfully in a tested browser.
14. Source code and setup instructions are available.
15. No known critical bugs prevent normal play.

---

# 18. Immediate Instructions

Begin work now.

Execute the following in order:

1. Inspect the existing RUNEBOUND assets and prototype, if accessible.
2. Initialize the Godot project.
3. Configure display, renderer, and inputs.
4. Create the main game scene.
5. Implement the reusable player controller.
6. Create a small movement-testing level.
7. Validate that the project runs.
8. Report the first working milestone with reproducible evidence.
9. Continue into collision, camera, and gameplay systems.

**Do not spend the first milestone generating additional concept art.**

Focus on building a functional game foundation.

The ultimate quality goal is a charming, polished Norwegian mythology platformer that feels satisfying to play and retains the identity of the supplied RUNEBOUND visual concepts.

**Start implementation, not another planning exercise.**
