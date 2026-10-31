# Supplied art producer scripts

These two Python files are preserved verbatim from Art Handoff v1 as provenance. They require Pillow and contain original producer-environment paths under `/mnt/data/`; they are not portable project build tools and were not executed during intake.

The supplied generated assets are already extracted under `assets/`. Use `asset_manifest.json` and `assets/characters/hero/manifest.json` as their integration contracts. If regeneration is later needed, first adapt the producer paths on a separate art task and review generated diffs; do not run these scripts over accepted gameplay files.
