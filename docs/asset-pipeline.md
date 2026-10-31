# Asset pipeline — M4 and both art handoffs

## Source direction

Read `design/RUNEBOUND_Visual_References/ART_DIRECTION.md` and its `contact_sheet.webp` before replacing visuals. The art-direction file was supplied inside that folder, rather than directly in `docs/design/` as referenced by `AGENTS.md`.

The additional handoff now also supplies `design/ART_DIRECTION.md`, `design/hero_reference_approved.png`, the canonical concept files and `handoff/M5_VISUAL_GATE_AGENT_PROMPT.md`. Its extracted prototype assets and manifests are available under `assets/` and `asset_manifest.json`. See `handoff/ART_HANDOFF_INTEGRATION.md` for exact placement, provenance and import validation. The original reference directory remains intact.

Art Handoff 2 supplies enemy source animation sheets and reference sheets for the Draugr, Raven and Bridge Troll. Both full/compact archives and original PNGs are preserved. See `handoff/ART_HANDOFF_2_INTAKE.md` for placement/hashes and `handoff/ART_HANDOFF_2_INTEGRATION.md` for required segmentation, alignment, normalization and timing. Its manifests are stored separately under `docs/handoff/` so the first root manifest remains intact.

The supplied four concept images and contact sheet remain intact. No HTML/JavaScript prototype or production sprite sheets were present in the initial workspace.

## Temporary gameplay assets

All current gameplay visuals are original programmatic placeholders:

| Asset | Source | Grid / anchor |
|---|---|---|
| Hero | `scenes/player/hero_visual.gd` | ~26 × 38 logical pixels, centered at feet |
| Moss / stone tiles | `scenes/levels/test_terrain.gd` | 16 × 16, full-tile collision |
| Fjord / mountains / pines | `scenes/levels/test_backdrop.gd` | 640 × 360 canvas |
| Menu landscape | `scenes/main/main.gd` | 640 × 360 canvas |
| Sword / impact feedback | `scenes/player/sword_combat.gd` | Player-relative; same clock as hitbox |
| Checkpoint / rune / dummy / spikes | Their scripts under `scenes/interactables/` and `scenes/collectibles/` | Independently drawn placeholders |
| HUD hearts | `scenes/ui/heart_display.gd` | 16 × 15 polygon icon, 23px spacing |
| Short SFX | `scripts/components/sound_cue.gd` | Original 22,050 Hz, 16-bit mono generated cues |
| Draugr / Raven / Troll | `scenes/enemies/enemy_visual.gd` | Separate temporary silhouettes; profile rectangles visualize actual attack regions |
| Combat-room bridge | `scenes/levels/combat_floor.gd` | 16px planks over independent TileMapLayer collision |
| M4 cabin / church / pine / waterfall / decks | `scenes/levels/adventure_landmark.gd` | Collision-free provisional landmarks |
| M4 cave backdrop | `scenes/levels/adventure_backdrop.gd` | Fixed 640×360 provisional cave palette/silhouettes |

Hero identity: blond `#e9be62`, blue tunic `#367ea8`, red cape `#d44a4f`, brown leather and a small shield. Terrain uses dark slate `#263b44` / `#3d5055` and moss `#648850` / `#a4b56a`. Pale mountain silhouettes contrast with solid playable surfaces. Air-jump feedback uses cyan.

Godot's default UI font and engine-generated web icons are used. Hearts are geometry rather than Unicode glyphs because the Web runtime lacks the native fallback font that supplied them. No third-party gameplay sprites or audio were imported. The game export omits concept references and development captures.

Production visual assets are being developed separately. Keep these implementations as functional placeholders until those assets are ready; preserve component signal interfaces and sword hit timing when swapping presentation.

The imported handoff is also provisional. The current M3 enemies and active player/background presentation still use temporary draws. No final-quality claim follows from import. During M5, produce actual Godot screenshots and a recording, compare side by side to approved concepts using all ten criteria in `specs.md`, fix significant differences and obtain human visual acceptance. Animation art must respect existing attack timing; parallax layers require seam verification before repeating.

Handoff 2's source poses are **not equal-grid atlases**. The 48×48/96×96 canvas sizes and frame counts are targets, not verified slicing instructions. The source directories `assets/characters/enemies/` and `assets/enemies/` carry `.gdignore` markers so original sheets stay out of automatic runtime imports/exports. Future validated derivatives should go in a runtime-visible directory, with source files preserved and documented. No frame processing or scene replacement was performed during M4 intake, and M3 combat timings were not changed.

## Replacing placeholders later

Use transparent sprite sheets with a consistent pixel grid and foot anchor. Keep the collision shape independent from animated silhouettes. Replace the Visual node without moving jump, collision or input logic into presentation. Use AnimatedSprite2D / AnimationPlayer for the production animation set. Author terrain and parallax layers independently from concepts; never crop a concept composition into gameplay collision artwork.

Record the creator, source and license for every external asset before integration. A project-wide distribution license is not yet assigned.
