# RUNEBOUND — Art Handoff 2: Enemies and Bridge Troll

**Contents:** Original transparent source sprite sheets for Draugr, Raven and Bridge Troll; individual approved concept sheets and group cast reference; machine-readable manifest; M3/M4/M5 integration directions.

**Important quality disclaimer:** These source sheets are generated artwork, **not** verified grid-aligned production atlases. Their pose cells vary in width/position, and the intended frame sizes in the manifest are targets, not verified source dimensions. Do not import directly as fixed-column SpriteFrames. An art-processing pass is required to isolate frames, register anchors, pad frames on consistent canvases, and inspect playback. Do not silently crop or stretch arbitrary sheet cells.

**Gameplay contracts:** Preserve existing player movement, damage rules, enemy AI, attack phases and collision geometry. All collisions/hitboxes remain authoritative in Godot. Frame timings and attack cues must match M3 profiles, not vice versa. Do not begin M5 during M4.

**Install:** Extract ZIP at the repository root. If files already exist, inspect conflicts rather than overwriting. Use a dedicated art-intake commit. See `docs/handoff/ART_HANDOFF_2_INTEGRATION.md`.
