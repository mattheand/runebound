# Art handoff v1 intake — during M3

## Received and inspected

The supplied root archive is named `RUNEBOUND_Art_Handoff_v1.zip` (referred to as `handoff-1.zip` in the request). SHA-256:

`b04ece1f6c294869dd726923e57c80e8a984643ebfdb1a22db8caf83ab52b4a7`

All 32 archive files were inspected/extracted without overwriting differing existing content. The archive README, both manifests, art direction, visual-gate prompt, approved hero, contact sheet and both art previews were reviewed. The root `M5_VISUAL_GATE_AGENT_PROMPT.md` exactly matches the canonical extracted `docs/handoff/M5_VISUAL_GATE_AGENT_PROMPT.md`.

## Placement

- `assets/characters/hero/`: ten provisional animation strips and hero manifest.
- `assets/environments/midgard/`: four separate backdrop layers and an eight-tile atlas.
- `assets/collectibles/`, `assets/interactables/`: animated rune/checkpoint strips.
- `asset_manifest.json`: original pack metadata, preserving its project-relative paths.
- `docs/design/`: supplied references, approved hero, sprite preview and `environment_preview.png`. Existing `docs/design/RUNEBOUND_Visual_References/` was preserved.
- `docs/handoff/ART_HANDOFF_V1_README.md`: original pack README, relocated to preserve the working root README.
- `docs/handoff/M5_VISUAL_GATE_AGENT_PROMPT.md`: canonical visual acceptance requirements; the identical supplied root copy is retained.
- `tools/art_handoff/`: original producer scripts retained as provenance, not executed during intake.

The original ZIP was already staged with the supplied files and is preserved in Git as the source-package provenance, alongside the extracted assets, metadata, producer scripts and documentation. It is not used as a runtime resource. Concept references remain under `docs/.gdignore` and the existing docs export exclusion.

## Status and integration constraints

**This is asset intake and import validation, not the start of M5.** Current M3 development and the accepted movement/combat/checkpoint systems remain authoritative. The new textures are imported by Godot and available for later scene integration; active player/environment presentation continues to use the current temporary visuals.

- Hero frames are 32×48, right-facing; feet reference is pixel `[16, 46]`, not blindly the bottom of the texture. Maintain that anchor when replacing presentation.
- The attack strip has six frames at 10 FPS (600 ms), while accepted M2 sword timing totals 400 ms. Future integration must retime presentation to the existing wind-up/active/recovery clock, not alter hitboxes or gameplay duration to fit the sheet.
- Backgrounds are independent 640×360 RGBA layers, not proven seamless. The preview is a study, not evidence of running Godot parallax or final visual fidelity.
- Terrain artwork is visual-only; keep collision definitions separate.
- The procedural first-pass hero/environment remain much simpler than the detailed approved references. M5 must close those gaps, add production-quality expressive animation and richer Norwegian scenery, and obtain human visual acceptance.
- Provenance: newly generated PNGs and producer scripts are described by the pack README as original for this handoff; concept art is supplied RUNEBOUND reference material. Project-wide distribution licensing remains unassigned.

The complete ten-criterion gate has been added to `specs.md` and `docs/roadmap.md`. M5 requires actual runtime screenshots, short recording, side-by-side comparisons, an explicit pass/fail/gap table, regression checks and human sign-off. Until then, no final-quality claim is made.

## Reproducible import validation

```bash
bash tools/godot.sh --headless --editor --import
bash tools/godot.sh --headless --script tests/test_art_import.gd
```

The asset contract test loads the actual imported textures and checks dimensions, transparency where required, frame counts/FPS and the documented foot anchor against the supplied manifests. This validates the provisional asset format, not animation quality, seamlessness or concept fidelity. Full gameplay tests remain under `bash tools/check.sh`.

**Verified intake result:** Godot import completed without errors or warnings; all **43 asset-contract checks passed**. The accepted M0–M2 regression suites were rerun after extraction: **360 assertions passed** across 30/60/120 Hz. The art-contract test is now included once in `tools/check.sh`. Intake did not change accepted movement, damage, checkpoint or collection logic.
