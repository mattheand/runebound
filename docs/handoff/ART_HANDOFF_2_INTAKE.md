# Art Handoff 2 intake — during M4

## Source packages

The request referred to `handoff-2.zip`; the supplied files are:

- `RUNEBOUND_Art_Handoff_2.zip`, SHA-256 `613d47e28cdb6cee8ec0e644af2a49e333484cd4ff226d33808296b606ff5fd2`.
- `RUNEBOUND_Art_Handoff_2_Compact.zip`, SHA-256 `78a96d0acac75b334bcde8fed3944fedb3610bab1e6a756ebc87cde682cd42e1`.

Both user-staged archives are preserved as provenance. The full and compact packages contain identical source animation PNGs and original reference sheets; the compact pack adds WebP reference variants and a manifest pointing to those variants. Extraction preserved 23 distinct files, checking conflicts before writing. No differing existing project file was overwritten.

## Placement / preservation

- Original pack README: `docs/handoff/ART_HANDOFF_2_README.md`; root project README preserved.
- Full manifest: `docs/handoff/art_handoff_2_manifest.json`.
- Compact manifest: `docs/handoff/art_handoff_2_compact_manifest.json`.
- Existing root `asset_manifest.json` remains the first handoff's contract.
- Canonical source sheets: `assets/characters/enemies/{bridge_troll,draugr,raven}/source_animation_sheet.png`.
- Supplied aliases preserved: `assets/enemies/<kind>/<kind>_sprite_sheet_v1.png`.
- Original concepts: `docs/references/` and `docs/design/enemies/`; compact WebP variants also preserved.
- Supplied `ART_HANDOFF_2_AGENT_PROMPT.md` and `ART_HANDOFF_2_INTEGRATION.md` remain verbatim under `docs/handoff/`.

Both source-sheet directories have `.gdignore` markers: these unprocessed images are archived for future visual work, not silently imported as runtime atlases or bundled in current Web builds. Documentation/reference images remain excluded by the existing docs policy. Nothing is wired into the active enemy scenes during M4.

## Inspection and deferred processing

The README, manifests, integration directions, all three source sheets, individual enemy references and cast reference were inspected. The source sheets have artistically arranged poses with variable widths, spacing and alignment. The suggested 48×48 Draugr/Raven and 96×96 Troll canvases are targets, not valid fixed-column slicing dimensions. No segmentation, rescaling, cropping, retiming or derivative atlas was performed during intake.

Follow `ART_HANDOFF_2_INTEGRATION.md` during the appropriate visual milestone: identify/crop poses from alpha bounds, preserve effects/debris, normalize facing and anchors, use larger canvases where needed, inspect frame order/playback and validate at logical gameplay scale before scene integration. Preserve these original files and document every derivative.

**Combat contracts stay authoritative:** Draugr 350/120/650 ms; Raven 550/up-to-750/650 ms with locked aim; Troll slam 800/120/1000 ms, club 650/160/1100 ms, charged smash 1100/150/1350 ms. Future animation adapts to these phases; AI, collision shapes, damage rules and player mechanics do not change to fit artwork.

The existing ten-criterion M5 visual gate remains unchanged and mandatory. These are approved visual directions and provisional source art, not M5 production acceptance. M4 continues with its established temporary combat presentation.

## Validation

```bash
bash tools/godot.sh --headless --script tests/test_enemy_art_sources.gd
```

This loads original PNGs directly without importing them into gameplay. It checks actual dimensions/transparency, byte-identical aliases and full/compact reference paths. It deliberately does not certify frame counts, alignment, atlas suitability or final visual quality. The existing full regression suite remains the gameplay contract.

**Verified intake result:** all 15 source checks passed. The existing 700 assertions also passed after extraction (715 total with the new source checks), with no engine/script errors or warnings. Source checks are included in `tools/check.sh`. Both current M4 input routes also reached completion: the optional cave route collected 7/7 runes and the main-only route 5/7, with no deaths; no enemy timing or combat code was changed for this intake.
