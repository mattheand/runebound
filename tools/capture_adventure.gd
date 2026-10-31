extends "res://tests/test_full_level.gd"
## Capture the actual input-driven M4 route; no game-state shortcuts.

var _captured: Dictionary = {}


func _run() -> void:
	tick_rate = 60
	Engine.physics_ticks_per_second = 60
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	await traverse(true)
	await capture("completion")
	await cleanup()
	OS.delay_msec(100)
	await process_frame
	print("M4 NATIVE CAPTURE: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)


func terrain_beat(origin: float, floor_y: float, kind: StringName) -> void:
	if origin == 0:
		await capture("forest")
	await super.terrain_beat(origin, floor_y, kind)
	if floor_y > 800:
		await capture("cave")


func travel_to(destination: float, floor_y: float, jump: bool = false, double_jump: bool = false) -> void:
	if destination == 29 * 1024 + 980:
		await super.travel_to(30200, floor_y)
		await capture("vista")
	if destination == 32 * 1024 + 980:
		await super.travel_to(33280, floor_y)
		await capture("bridge")
	await super.travel_to(destination, floor_y, jump, double_jump)
	if destination == 9616:
		await capture("cliffs")


func fight_boss() -> void:
	await super.fight_boss()
	await capture("boss-victory")


func capture(label: String) -> void:
	if _captured.has(label) or route_failed:
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://build/screenshots")
	var error := root.get_texture().get_image().save_png("res://build/screenshots/m4-" + label + ".png")
	check(error == OK, "capture actual M4 " + label)
	_captured[label] = true
