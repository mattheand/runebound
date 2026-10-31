# RUNEBOUND — Visual Direction Pack

This package contains 4 original concept images generated during game ideation. They are **references**, not production-ready sprite sheets, tilesets or game levels.

## Source-of-truth priorities
1. Protagonist: blond young Viking, blue wool tunic, flowing bright red cape, small round shield, short sword, readable at gameplay scale.
2. Tone: adventurous, welcoming, colorful Nordic fantasy; more approachable platformer than grim survival game.
3. Environment: real Norwegian fjord geography (high cliffs, mountains, pine/spruce forests, waterfall, cabins, distant stave church) mixed with magical Norse motifs (runestones, ravens, Thor shrines, Bifröst).
4. Playable style: sharp, coherent pixel art with consistent pixel size, a limited palette per scene, unobstructed traversable surfaces, parallax depth.
5. Troll boss: mossy gray stone-skinned giant with a large club on a breakable wooden bridge; telegraphed attacks, room to dodge.

## Images
- `01_hero_character.webp`: Main character — blue tunic, red cape, blond hair, shield, small sword; reference for sprite silhouette and animation.
- `02_fjord_environment.webp`: World look — fjords, pine trees, runestones, waterfall, stave church, multilayer parallax; not a directly usable level background.
- `03_level_layout.webp`: Level 1 layout — start, platforms, hidden cave, checkpoint, troll boss. Conceptual flow, not collision geometry.
- `04_boss_encounter.webp`: Boss composition — bridge troll, dramatic bridge, HUD and player size/readability. Illustrative only.

## Implementation directions
- Do not extract the full composite images as sprites, tilesets or platform colliders; design assets separately at a unified resolution and pixel grid.
- Establish a sprite specification (e.g., 32x48 or 48x64 hero, depending on game camera) and use test compositions at 640x360.
- Generate/paint modular terrain tiles, then separately paint 3–5 parallax landscape layers, with clean silhouette separation.
- Generate hero animations (idle, run, jump, fall, sword, hurt, death) on transparent backgrounds using consistent anchor points.
- Prefer legibility and responsiveness over fidelity to every background detail.
- Preserve source/asset licenses and do not imitate Mario copyrighted assets.
- Use the accompanying `contact_sheet.webp` to quickly understand the four concepts.

## Agent handoff
Treat these images as the visual design source of truth, and the separate RUNEBOUND development spec as the functional source of truth. Start with a playable Godot project, then iteratively integrate original assets matching these references.
