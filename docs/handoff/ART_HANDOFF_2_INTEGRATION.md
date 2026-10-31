# Art Handoff 2 — Integration instructions

## Timing / scope
- During M4, archive the images and preserve existing temporary combat presentation unless integration is isolated and regression-safe.
- At M5, replace enemy visuals in dedicated visual child nodes; do not change AI scripts or engine collisions to fit sprites.
- Compare Godot captures against the approved references and keep the visual gate from Art Handoff 1.

## Enemy-specific visual contracts
- **Draugr:** compact shield-and-sword undead fighter, gray-blue skin, blue eyes, faded red cloth. Ground foot anchor bottom-center. Target normalized frame canvas 48x48 logical pixels (may need revision after silhouette review). M3 melee wind-up 350 ms, active 120 ms, recovery 650 ms.
- **Raven:** dark navy/indigo with red eye, legible dive silhouette. Target 48x48 canvas initially, anchor center-body rather than feet. M3 dive telegraph 550 ms, active up to 750 ms, recovery 650 ms. Aim locked on warning.
- **Bridge Troll:** large rocky boss, moss green beard, massive log, readable attacks. Target 96x96 frame initially; larger attack/collapse canvases may be needed to avoid clipping. Anchor at bottom-center of feet. M3 ground slam 800/120/1000 ms, club swing 650/160/1100 ms, charged smash 1100/150/1350 ms (wind-up/active/recovery).

## Required processing before production integration
1. Inspect transparent original PNGs and identify individual frames by animation sequence. These source sheets are **not equal-grid atlases**; sequence-to-frame mapping is provisional.
2. Separate/crop each pose using alpha bounds, preserving weapon effects and loose debris as required; remove accidental overlapping graphics.
3. Normalize sprite positioning and facing on consistent transparent canvas with a documented anchor and collision-independent visual offset. Choose larger canvas if club/wings extend outside the nominal size.
4. At native logical resolution, evaluate readability against the player (~26x38 px), terrain (16x16 px), and backgrounds. Rework if details disappear or proportions conflict.
5. Build AnimatedSprite2D SpriteFrames with deterministic frame order and visual playback previews. Synchronize frame state to existing combat signals and timing.
6. Verify there is no telegraph obscuration, attack hitbox drift, resource leakage, or new regressions, and capture Godot screenshots for acceptance.

## Source/art provenance
Artwork was generated for this RUNEBOUND project. Preserve original concept sheets and source sheets. Track any future third-party editing, derivative work, licensing or additional source assets separately.

## Acceptance
These assets are approved visual directions, **not** final M5 production acceptance. M5 must pass its documented ten-criterion gate and user visual approval.
