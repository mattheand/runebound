extends "res://tests/test_combat_victory.gd"
## Render the same input-only boss victory used by the automated suite.


func _run() -> void:
	Engine.physics_ticks_per_second = 60
	tick_rate = 60
	await fight(&"troll")
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://build/screenshots")
	var error := root.get_texture().get_image().save_png("res://build/screenshots/native-m3-victory.png")
	check(error == OK, "save rendered Troll victory capture")
	await cleanup()
	OS.delay_msec(100)
	await process_frame
	quit(1 if failures else 0)
