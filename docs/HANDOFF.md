# Coordinator handoff — M4 Complete Troll Bridge Level

## Status / source control

- **M0–M3 approved.** `feat/m3-enemies-boss` was fast-forward merged into `main` at **`410b3ba`**, all **700 existing assertions passed on merged main**, and main was pushed.
- **M4 implemented, playable and verified; awaiting hands-on level-flow/pacing acceptance.** Published branch: `feat/m4-troll-bridge-level`; implementation commit **`171070a`**. Main retains the accepted M3 version until M4 is accepted.
- **M5 has not started.** Current presentation is provisional. Both art handoffs remain preserved for later visual integration under the existing ten-criterion gate.
- **Art Handoff 2 intake:** committed separately as **`eee7fc2`**, preserving both supplied full/compact archives, original images, manifests and instructions. No enemy attack timing or combat mechanics were changed for that intake.

## Play now

```bash
bash tools/godot.sh
```

Choose **The Troll Bridge (M4)** or press Enter. M3 combat trials, M2 gameplay training and M1 movement playground remain selectable.

| Action | Keyboard | Gamepad mapping |
|---|---|---|
| Move | A/D or arrows | Stick/D-pad |
| Jump / double-jump | Space | A |
| Sword | J | X |
| Passage / rune switch / level exit | E | B |
| Return to checkpoint | R | LB |
| Pause / resume | Escape | Start |

In M4, Esc opens a pause menu with Resume, Return to checkpoint and Return to menu. Earlier trials retain their own controls. The completion screen offers Play again and Return to menu.

**Browser:** open **http://localhost:8765** while the local preview server runs; refresh to load M4. Rebuild/serve with:

```bash
mkdir -p build/web
bash tools/godot.sh --headless --editor --export-release Web build/web/index.html
python3.13 -m http.server 8765 --bind 127.0.0.1 --directory build/web
```

Godot **4.7.2 stable** is installed at `~/Applications/Godot.app`; the launcher supports PATH or `GODOT`. Use another installed Python 3 executable when appropriate. The Web export is single-threaded Compatibility/WebGL 2.

## Level flow

The level uses a fixed authored sequence of **38 1,024px terrain beats**, then the boss arena/exit, spanning **39,936 logical pixels**. It is content assembly, not random world generation. Steps, gaps, high double-jump routes, hopping shelves, low ceilings and wooden decks vary the rhythm. There are **15 ordinary enemies, nine checkpoints, seven runes and the accepted Bridge Troll**.

| Section | Route / purpose |
|---|---|
| Starting Forest | Safe opening, cabin/rune-stone cues, first jumps and two main-route runes; x=0–6,144. |
| Forest Cliffs | Elevated shelves, gaps, high routes, Draugr/Raven encounters, waterfalls and two more main-route runes; x=6,144–22,528. |
| Hidden Cave | Optional lower branch at x=18,432–21,504, floor y=1,024. Sword-opened cyan-cracked entrance, cave checkpoint, E-operated rune switch/vault and two optional runes. |
| Stave Church Vista | Scenic recovery, checkpoint rests, final high-route rune and the five-rune gate; x=22,528–30,720. |
| Troll Bridge | Long decks/gaps, final checkpoint, boss approach, locked arena and exit; x=30,720–39,936. Arena x=38,912–39,552. |

### Progression instructions

1. Collect runes along the route. **Any five of seven** open the gate at the end of the vista. Five are available on the main route, so the cave is optional.
2. To explore the cave, look for cyan cracks in the stone on the mossy ledge. Break it with J and press E at the passage. E activates the interior rune switch and opens the vault gate. The entrance-side passage permits returning early; the far passage reconnects to the main route after solving the switch.
3. Touch checkpoint stones to save a return point and restore hearts. R or death preserves collected runes and opened cave mechanisms.
4. Touch the final checkpoint before the Troll. Its introduction closes the arena back gate and displays boss health. Jump the slam, read directional warnings and punish recovery. The charged smash can remove the marked bridge columns.
5. Defeat the Troll, continue right through the unlocked exit gate and press E at the final rune stone. Completion shows **runes, deaths and elapsed time**.

## Implementation boundaries

- `scripts/resources/troll_bridge_layout.gd`: authored terrain sequence and explicit rune/checkpoint/enemy placements.
- `scenes/levels/troll_bridge.*`: content assembly, section/camera context, passage routing, retries, boss locks/bridge and completion.
- `scripts/components/adventure_progress.gd`: extends LevelProgress with cave flags, checkpoint cave context, boss defeat, deaths, timer and idempotent completion.
- `scenes/interactables/breakable_stone.*`: two sword hits open the entrance using the accepted HealthComponent/HurtboxComponent.
- `scenes/interactables/interact_zone.*`: living-player overlap plus fresh E input emits an action; passages/switch/exit share this reusable mechanism.
- `scenes/interactables/rune_gate.*`: physically blocking gates with artwork matching their full collision height and clear open/closed feedback.
- `scenes/ui/adventure_hud.gd`: health/runes/checkpoint/section/objective, boss bar, pause menu and completion results. SceneTree pause freezes gameplay and elapsed time while the HUD remains interactive.
- `adventure_backdrop.gd` / `adventure_landmark.gd`: provisional cave mood, cabins, pines, waterfalls, church silhouettes and bridge decks; no production-fidelity claim.

The accepted player controller, health/damage rules, enemy AI and M3 attack profiles are reused. The Troll receives an instance-local tuning copy with translated arena bounds; its health and attack timings are unchanged.

## State and retry rules

- New checkpoint activation restores three hearts and saves surface/cave context.
- Death/R restores the latest checkpoint, player movement/health state, ordinary enemy states and the destructible boss bridge.
- Rune collection, cave entrance/switch state and a defeated boss persist within the session. An undefeated boss resets to dormant with full health and open approach; a defeated boss stays defeated and the exit remains available.
- Surface and cave camera bounds are restored correctly after passage travel or death. Passage travel preserves health/runes and clears momentum/current sword activity.
- Surface falls trigger death at y=720, **above the cave roof at y=784**. Cave falls use y=1280. A regression verifies surface falls cannot strand the player on the cave roof.
- Completion freezes elapsed time and gameplay input. Replay creates a fresh session; menu return clears pause. Progress is session-local, not saved to disk.

## Test evidence

```bash
bash tools/check.sh
```

| Suite | Checks | Runs |
|---|---:|---|
| Movement regression | 36 | 30/60/120 Hz |
| M2 systems | 62 | 30/60/120 Hz |
| Full M2 route | 22 | 30/60/120 Hz |
| Draugr/Raven | 34 | 30/60/120 Hz |
| Troll mechanics | 38 | 30/60/120 Hz |
| M3 room lifecycle | 17 | 30/60/120 Hz |
| M3 input-only victories | 10 | 30/60/120 Hz |
| M4 world/lifecycle/pause/completion | 44 | 30/60/120 Hz |
| Full M4 cave + main-only routes | 240 total | 60 Hz |
| Art handoff 1 contracts | 43 | Once |
| Art handoff 2 source checks | 15 | Once |

**1,087 assertions passed, zero failures.** Import/startup and the verified suite logs contain no engine/script errors or warnings.

`tests/test_full_level.gd` drives the real player with movement, jumping, sword and interaction inputs. It does not teleport, disable enemies, alter health/tuning, award runes or invoke boss damage. Cave relocation happens through the actual E-operated passage. Both routes defeat the Troll and open the actual completion screen:

- **Cave route:** 122 checks, 7/7 runes, zero deaths, **203.50 seconds**.
- **Main-only route:** 118 checks, 5/7 runes, zero deaths, **203.52 seconds**.

This verifies both complete progression and the cave's optionality. M4 lifecycle tests additionally exercise checkpoint healing, pause/time freeze, cave/surface/boss retries, full-depth bridge destruction/repair, boss defeat surviving a later death, persistent flags, gates, result UI, replay/menu and the cave-roof fall regression.

Read-only review found the cave-roof recovery issue and an invisible gate-height extension. The fall was reproduced with a failing test before correction; both findings were resolved and the complete suite rerun green.

## Runtime/browser evidence

Native macOS (Apple M4 Max) and Google Chrome **156.0.8078.79** / WebGL 2 were checked. Web export succeeds. M4 browser smoke captures show actual rune pickup (1/7), pause/resume, checkpoint retry retaining that rune, and the four-entry menu, with no runtime/resource/HTTP errors. M2/M3 browser regression scripts also pass with their updated menu selection.

```bash
bash tools/godot.sh --fixed-fps 60 --script tools/capture_adventure.gd
```

The native capture tool follows the real cave route and saves all five sections, boss victory and completion. It passed **131 route/capture checks**, completing with 7/7 runes and zero deaths in about 203.7 simulated seconds (two additional scenic stops). Files under `build/screenshots/`: `m4-forest.png`, `m4-cliffs.png`, `m4-cave.png`, `m4-vista.png`, `m4-bridge.png`, `m4-boss-victory.png`, `m4-completion.png`, and `browser-m4-*.png`.

Logs: `build/test-results/m4-final.log`, `m4-native-capture.log`, per-suite logs and `m4-export.log`. Builds/captures/logs remain regenerable and excluded from Git. Allow rendered capture tools to finish; laptop sleep can interrupt them.

## Art Handoff 2 integration

Both `RUNEBOUND_Art_Handoff_2.zip` and `RUNEBOUND_Art_Handoff_2_Compact.zip` were inspected and preserved, with 23 distinct extracted files. Original source sheets/aliases are unchanged. README and both manifests were relocated under `docs/handoff/` to preserve the working project README and first `asset_manifest.json`.

Follow the supplied `docs/handoff/ART_HANDOFF_2_INTEGRATION.md`. These sheets have variable pose spacing/sizes; the suggested 48×48/96×96 canvases are not valid fixed-grid slicing instructions. They require separation, anchor/facing normalization, frame ordering, timing alignment and playback validation. No frame processing or active enemy replacement was performed during M4.

The source directories are marked `.gdignore`, keeping unprocessed sheets out of runtime imports/exports. Fifteen checks verify dimensions, transparency, byte-identical aliases and reference paths, not atlas suitability or final quality. Intake mapping, hashes and provenance are in `docs/handoff/ART_HANDOFF_2_INTAKE.md`. The M3 timing contracts and existing M5 visual gate remain authoritative.

## Known issues / acceptance / next milestone

- **First-time pacing is not yet measured.** The design target is 5–10 minutes; the known-route automated run is about 3:23. Human reading, exploration, combat choices and retries differ. Review timing, repetition/flow, checkpoint spacing and cave discoverability before accepting M4.
- Presentation and sound remain provisional; current captures do not claim concept fidelity or M5 completion.
- Physical gamepads, Firefox/Safari, Windows/Linux, additional window sizes and sustained performance profiling remain untested. Full native/input routes are tested at production 60 Hz; component/lifecycle stress checks also run at 30/120 Hz.
- Session progress is lost on fresh game/browser reload by design; pause/resume preserves the active session.
- No known critical or progression-blocking bug remains in the verified scope.
- **Next: M4 hands-on review and fixes, then M5 only after M4 approval.** M5 must satisfy the existing ten-criterion gate with actual runtime/reference comparisons, resolved visual gaps, regression checks and human visual acceptance.
