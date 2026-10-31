extends SceneTree

var checks: int = 0
var failures: int = 0


func check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		printerr("FAIL: ", message)


func texture_contract(path: String, dimensions: Vector2i, transparent: bool) -> void:
	var texture := load(path) as Texture2D
	check(texture != null and Vector2i(texture.get_size()) == dimensions, "asset dimensions: " + path)
	if transparent and texture != null:
		check(texture.get_image().detect_alpha() != Image.ALPHA_NONE, "asset transparency: " + path)


func _initialize() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/hero/manifest.json"))
	# Godot's JSON parser represents JSON numbers as floats, including arrays.
	check(manifest.frame_size == [32.0, 48.0] and manifest.feet_reference_pixel == [16.0, 46.0], "hero frame and feet-anchor contract")
	for animation in manifest.animations.values():
		check(animation.frames > 0 and animation.fps > 0, "animation metadata: " + animation.file)
		texture_contract("res://" + animation.file, Vector2i(32 * int(animation.frames), 48), true)
	var pack: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://asset_manifest.json"))
	for layer in pack.environment.layers_back_to_front:
		texture_contract("res://assets/environments/midgard/" + layer, Vector2i(640, 360), layer != "sky_640x360.png")
	texture_contract("res://" + pack.environment.tile_atlas, Vector2i(128, 16), false)
	texture_contract("res://" + pack.rune_pickup.sheet, Vector2i(96, 16), true)
	texture_contract("res://" + pack.checkpoint.sheet, Vector2i(128, 48), true)
	print("ART IMPORT RESULT: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)
