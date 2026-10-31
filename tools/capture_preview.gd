extends SceneTree
## Run with a display: bash tools/godot.sh --script tools/capture_preview.gd


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var scene_path := "res://scenes/levels/gameplay_test.tscn"
	if OS.get_cmdline_user_args().has("--movement"):
		scene_path = "res://scenes/levels/movement_test.tscn"
	var scene: Node = load(scene_path).instantiate()
	root.add_child(scene)
	for index in 60:
		await physics_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://build/screenshots")
	var error := root.get_texture().get_image().save_png("res://build/screenshots/native-gameplay.png")
	print("Native gameplay capture: ", error_string(error))
	quit(0 if error == OK else 1)
