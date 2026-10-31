# Asset pipeline — through M2

## Source direction

Read `design/RUNEBOUND_Visual_References/ART_DIRECTION.md` and its `contact_sheet.webp` before replacing visuals. The art-direction file was supplied inside that folder, rather than directly in `docs/design/` as referenced by `AGENTS.md`.

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

Hero identity: blond `#e9be62`, blue tunic `#367ea8`, red cape `#d44a4f`, brown leather and a small shield. Terrain uses dark slate `#263b44` / `#3d5055` and moss `#648850` / `#a4b56a`. Pale mountain silhouettes contrast with solid playable surfaces. Air-jump feedback uses cyan.

Godot's default UI font and engine-generated web icons are used. Hearts are geometry rather than Unicode glyphs because the Web runtime lacks the native fallback font that supplied them. No third-party gameplay sprites or audio were imported. The game export omits concept references and development captures.

Production visual assets are being developed separately. Keep these implementations as functional placeholders until those assets are ready; preserve component signal interfaces and sword hit timing when swapping presentation.

## Replacing placeholders later

Use transparent sprite sheets with a consistent pixel grid and foot anchor. Keep the collision shape independent from animated silhouettes. Replace the Visual node without moving jump, collision or input logic into presentation. Use AnimatedSprite2D / AnimationPlayer for the production animation set. Author terrain and parallax layers independently from concepts; never crop a concept composition into gameplay collision artwork.

Record the creator, source and license for every external asset before integration. A project-wide distribution license is not yet assigned.
