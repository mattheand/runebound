# Agent prompt — RUNEBOUND Art Handoff 2

A new art handoff package has been added for enemy visuals.

## Your tasks
1. Inspect all files in this handoff.
2. Preserve the current gameplay implementation and M4 progress.
3. Extract and place the assets in the appropriate repository locations.
4. Do not replace accepted mechanics or timings to force-fit the art.
5. Use the reference sheets as the visual identity source of truth.
6. Treat the gameplay sprite sheets as **provisional v1 assets** suitable for integration and later refinement.

## Integration guidance
- Draugr, Raven, and Bridge Troll sprite sheets are transparent PNGs.
- Keep collisions, hitboxes, and attack timing separate from visuals.
- If the frame count or spacing is imperfect, create imported atlases or derived sheets as needed, but preserve the supplied originals.
- Keep any cleanup or derivative atlases documented.
- Preserve the approved M5 visual gate already documented in the project.

## What not to do
- Do not interrupt M4 to rebuild unrelated systems.
- Do not change combat timing merely to match art.
- Do not claim M5-quality art has been reached.
- Do not flatten the concept references into static backgrounds or non-reusable assets.

## Suggested mapping
- Draugr → common melee enemy visual set
- Raven → flying dive enemy visual set
- Bridge Troll → boss visual set for Troll Bridge

## Deliverable expectation
When you decide to integrate these assets, do so on a branch, keep the game playable, and document:
- which files were integrated,
- what cleanup was required,
- whether any atlas slicing or retiming was necessary,
- and what remains provisional.
