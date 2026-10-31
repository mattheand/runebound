# RUNEBOUND — Art handoff v1

**This is an implementation-support pack, not a finished game or a final-quality production art release.** It combines the existing approved concept direction, an original transparent hero animation prototype, and new original procedural environment/gameplay assets.

## Start here
1. Read `docs/handoff/M5_VISUAL_GATE_AGENT_PROMPT.md`, and add its M5 gate to the existing agent brief. Do **not** interrupt M3.
2. Inspect `docs/design/hero_reference_approved.png` and `docs/design/contact_sheet.webp` for the target look.
3. Read `asset_manifest.json` for dimensions, frame counts, layer order and caveats.
4. Review `environment_preview.png` and `docs/design/hero_sprite_preview.png` before integration.
5. Integrate assets incrementally on a feature branch. Validate them in the running Godot project.

## What is ready to test in engine
- `assets/characters/hero/*.png`: transparent horizontally arranged 32×48 hero animation frames. Import based on `assets/characters/hero/manifest.json`, which records FPS and frame counts. Side-on, right-facing, bottom-center foot anchor. The current hero is a **simple procedural first pass**, not detailed reference-quality pixel art.
- `assets/environments/midgard/sky_640x360.png`, `mountains_640x360.png`, `fjord_640x360.png`, `forest_640x360.png`: transparent 640×360 original parallax source layers, back-to-front. **Not proven seamless or tileable**. Can be used as a static background for immediate evaluation. For scrolling, extend/repeat artistically and check seams.
- `assets/environments/midgard/terrain_tiles_16.png`: one-row atlas, 8 tiles of 16×16 pixels; visual-only, collision remains defined separately by Godot TileSet.
- `assets/collectibles/rune_pickup_16x16_6f.png`: 6 frames, 16×16, 8fps.
- `assets/interactables/checkpoint_flag_32x48_4f.png`: 4 frames, 32×48, 5fps.

## Import requirements
Use nearest-neighbor texture filtering, do not apply texture smoothing; preserve feet anchors. Keep `AnimatedSprite2D` (or other art presentation) separate from physics and combat. Validate the sword slash/hurt timing against M2's gameplay behavior. The asset package does not contain a Godot scene, enemy animation set, or final art.

## License / provenance
Procedural art source and newly generated PNGs were created for this handoff. Concept images are generated RUNEBOUND references from the conversation. Keep author/source records and assign an explicit project distribution license before public release. No third-party commercial sprites were imported.

## To add to the repository
Place this pack's `assets/` contents in the project `assets/`, and copy `docs/design/` and `docs/handoff/` into your repository's `docs/`. Put `asset_manifest.json` at the project root or under `docs/design/` and update any references accordingly. Do not overwrite working implementation without tests.
