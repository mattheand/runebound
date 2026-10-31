extends SceneTree
## Validate preserved source images, not unverified animation-frame grids.

var checks: int = 0
var failures: int = 0


func check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		printerr("FAIL: ", message)


func _initialize() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/handoff/art_handoff_2_manifest.json"))
	var compact: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/handoff/art_handoff_2_compact_manifest.json"))
	for kind in manifest.entries:
		var entry: Dictionary = manifest.entries[kind]
		var path: String = "res://" + entry.sheet
		var image := Image.load_from_file(path)
		check(image != null and image.get_size() == Vector2i(1448, 1086), "original sheet dimensions: " + kind)
		check(image != null and image.detect_alpha() != Image.ALPHA_NONE, "original sheet transparency: " + kind)
		var alias: String = "res://assets/enemies/" + kind + "/" + kind + "_sprite_sheet_v1.png"
		check(FileAccess.get_sha256(path) == FileAccess.get_sha256(alias), "source alias preserves original bytes: " + kind)
		check(FileAccess.file_exists("res://" + entry.reference), "original reference available: " + kind)
		check(FileAccess.file_exists("res://" + compact.entries[kind].reference), "compact reference available: " + kind)
	print("ENEMY ART SOURCE RESULT: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)
