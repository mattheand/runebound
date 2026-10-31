# M0 / M1 architecture

## Scene flow

`main.tscn` → Start → `movement_test.tscn` → Escape → `main.tscn`.

There are no autoloads. Scene ownership handles cleanup. The playground owns restart and fall reset, while the player owns its movement state. Reset is a testing convenience, not a checkpoint/progression system.

## Player

`player.tscn` is reusable: CharacterBody2D, an 18 × 32 solid collision rectangle anchored at the feet, a presentation node and Camera2D. World terrain uses layer 1; the player uses layer 2 and collides with layer 1.

`player.gd` reads named input actions during physics ticks. Horizontal acceleration and deceleration use delta-scaled `move_toward`; gravity has a terminal-velocity cap. Jump release caps remaining upward speed. Physics uses `move_and_slide`, not positional integration or manual collision tests.

- Ground contact restores one air jump.
- Walking off a platform starts the coyote window.
- Jumping during that window preserves the air jump.
- A later jump consumes the air jump.
- Further input can only wait in the short landing buffer.
- Holding a button cannot repeatedly jump.
- `jumped(is_double)` drives visual feedback; `landed` reports contact.
- A buffered jump can fire immediately on contact, even if already released. The next tick checks upward velocity as well as Godot's floor flag to avoid re-granting ground grace.

Movement parameters live in `PlayerTuning`, an exported Resource. Select Player → Tuning in the inspector to adjust speeds and timing. The runtime HUD shows grounded/airborne state, speed and the remaining air jump.

The hero visual is intentionally separate from controller logic. It draws an original grid-aligned placeholder, flips its local draw transform and varies its stride with movement. Production sprite/animation assets are a later art milestone.

## Course and camera

`test_terrain.gd` generates two 16 × 16 moss/stone tiles and attaches solid collision polygons via a TileSet atlas. `movement_test.gd` builds the deterministic course from tile rectangles. Geometry is expressed in tile coordinates, with a safe spawn, low steps, gaps, ceiling test, 128-pixel raised ledge and final lookout.

Camera2D follows the player on both axes with smoothing, bounded to 2,560 × 720. Nearest-neighbor filtering and transform pixel snapping keep the game art sharp. UI uses a CanvasLayer; background scenery uses a separate fixed CanvasLayer.

## Export

All runtime resources are exported, with docs/tests/tools/build excluded. Selecting only scenes was insufficient to include the script-preloaded tuning Resource; the browser test caught that missing dependency. `.gdignore` in docs and build prevents concept art and generated screenshots from being imported into the game.

Single-threaded Compatibility/WebGL 2 export uses matching `web_nothreads` templates. No external runtime packages, C#, GDExtensions or network services are used.
