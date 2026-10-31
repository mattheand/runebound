# RUNEBOUND — Agent Instructions

Read `specs.md` before making architectural or gameplay decisions.

Read `docs/design/RUNEBOUND_Visual_References/ART_DIRECTION.md` and inspect the reference images before implementing visual assets.

## Development rules

- Use Godot 4 and GDScript.
- Keep the project runnable after every milestone.
- Prioritize responsive platforming before visual polish.
- Preserve the visual identity established in `docs/design/`.
- Do not treat concept illustrations as finished gameplay sprites.
- Verify implementations with actual tests.
- Report completed work, test results, and remaining issues.
- Do not implement future phases before the current milestone works.

## Immediate priority

M0–M2 are approved; M2 has been merged into main and revalidated. M3 is implemented and verified, awaiting user review; read `docs/HANDOFF.md`. Preserve prior functionality and tests. Use temporary artwork; the extracted Art Handoff v1 is provisional. Do not start M4 or M5 until M3 is reviewed and accepted. Future M5 work must meet `docs/handoff/M5_VISUAL_GATE_AGENT_PROMPT.md` and the visual gate in `specs.md`, with actual runtime comparisons and human acceptance.
