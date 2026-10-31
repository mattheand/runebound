extends SceneTree
## Run with a display: bash tools/godot.sh --script tools/capture_preview.gd


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var scene_path := "res://scenes/levels/troll_bridge.tscn"
	for argument in OS.get_cmdline_user_args():
		if argument == "--combat" or argument.begins_with("--opponent="):
			scene_path = "res://scenes/levels/combat_test.tscn"
	if OS.get_cmdline_user_args().has("--gameplay"):
		scene_path = "res://scenes/levels/gameplay_test.tscn"
	if OS.get_cmdline_user_args().has("--movement"):
		scene_path = "res://scenes/levels/movement_test.tscn"
	var scene: Node = load(scene_path).instantiate()
	root.add_child(scene)
	var opponent := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--opponent="):
			opponent = argument.trim_prefix("--opponent=")
	if not opponent.is_empty() and scene.has_method("select_enemy"):
		scene.select_enemy(StringName(opponent))
		Input.action_press("move_right")
		for index in 84:
			await physics_frame
		Input.action_release("move_right")
	for index in 60:
		await physics_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://build/screenshots")
	var filename := "native-gameplay.png" if opponent.is_empty() else "native-m3-" + opponent + ".png"
	var error := root.get_texture().get_image().save_png("res://build/screenshots/" + filename)
	print("Native gameplay capture: ", error_string(error))
	quit(0 if error == OK else 1)
