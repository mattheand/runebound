# Agent instruction — M5 visual fidelity gate (add to existing roadmap)

Continue the currently authorized milestone; **do not start M5 early**. Add the following acceptance gate to `specs.md`, `docs/roadmap.md`, and future M5 planning.

## Source of truth
The art target is `docs/design/` in this handoff pack, especially `hero_reference_approved.png`, `01_hero_character.webp`, `02_fjord_environment.webp`, `03_level_layout.webp`, and `04_boss_encounter.webp`. These are **style references**, not sprites, tiles, collision maps or guaranteed compositable backgrounds. Never crop a whole promotional composition and present it as authentic gameplay scenery.

## M5 acceptance gate: playable visual fidelity
M5 cannot be declared complete solely because placeholders were replaced. Demonstrate an actual running Godot level with screenshots and a short recording at gameplay resolution. Assess each criterion using a pass/fail table and side-by-side reference comparison:

1. **Hero identity:** recognizably blond, blue tunic, red cape, small shield and seax; silhouette readable at 640×360; foot anchor and collisions unaffected.
2. **Consistent pixel language:** grid, pixel scale, palette and shading harmonized across player, terrain, enemies, particles and UI; no accidental blurred scaling or inconsistent resolutions.
3. **Norwegian specificity:** legible fjord, steep mountains, spruce/pines, waterfalls, wood bridges and traditional architecture; not generic fantasy grassland.
4. **Layered world depth:** separate sky, distant mountains, water/fjord, forest and foreground/gameplay terrain; verified parallax in motion without seams or camera jitter.
5. **Animation & interactions:** real frame-based hero idle/run/jump/fall/attack/hurt, enemy and boss animations, rune and checkpoint feedback; no placeholder motion passed off as final animation.
6. **Foreground readability:** collision terrain, platforms, hazards, enemies and interactive elements remain distinguishable from intricate backgrounds in gameplay.
7. **Atmosphere:** visual effects and color palette support a cozy Nordic world with mythic rune accents, matching reference mood without sacrificing clarity.
8. **Asset provenance:** all external assets have creator/source/license records; no copyrighted commercial game assets or unlicensed music.
9. **Quality evidence:** produce reference-vs-runtime comparison images, document remaining gaps, and fix significant gaps before requesting sign-off.
10. **No regressions:** run the existing Godot suite, test browser build and gameplay traversal; document exact environments and any unsupported tests.

### Gate result
`PASS` requires all ten criteria evidenced and no significant visual gap judged unresolved. If gaps remain, report `NEEDS ART ITERATION`, continue with prioritized fixes, and request visual approval only after a demonstrated gameplay capture. Artistic similarity is a human review gate; do not invent objective fidelity percentages.

## Integration of handoff assets
This package contains `assets/characters/hero/` (transparent 32×48 prototype animation frames), `assets/environments/midgard/` (independent 640×360 RGBA backdrop layers, plus 16×16 tiles), `assets/collectibles/`, and `assets/interactables/`. A machine-readable `asset_manifest.json` documents dimensions and frames. These are **provisional integration assets**. Import them into Godot without changing movement, physics, damage hitboxes, or checkpoints. Keep the concept references out of production export. Replace/update the sprites as visual quality improves, maintaining the manifest contract.

Do not claim the visuals achieve concept quality simply because these provisional sprites have been integrated. Validate asset scaling and scene layout in a playable Godot build.
