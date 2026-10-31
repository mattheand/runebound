extends Node2D

const SPAWN := Vector2(96, 416)
const COURSE_WIDTH: int = 2560
const COURSE_HEIGHT: int = 720

@onready var player: CharacterBody2D = $Player
@onready var terrain: TileMapLayer = $Terrain
@onready var camera: Camera2D = $Player/Camera2D
@onready var status: Label = $HUD/Status


func _ready() -> void:
	# Safe run-up, low steps, small gaps, headroom, double-jump ledge, finish.
	for rect in [
		Rect2i(0, 28, 30, 12), Rect2i(16, 25, 5, 3),
		Rect2i(33, 28, 23, 12), Rect2i(38, 25, 5, 3), Rect2i(46, 22, 6, 6),
		Rect2i(61, 28, 23, 12), Rect2i(64, 24, 8, 1), Rect2i(78, 24, 6, 4),
		Rect2i(87, 24, 17, 2), Rect2i(87, 32, 43, 8),
		Rect2i(106, 16, 15, 2), Rect2i(124, 25, 6, 7),
		Rect2i(134, 28, 26, 12), Rect2i(147, 24, 6, 4),
		Rect2i(-1, 0, 1, 45), Rect2i(160, 0, 1, 45)
	]:
		terrain.fill_platform(rect)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = COURSE_WIDTH
	camera.limit_bottom = COURSE_HEIGHT
	player.reset_to(SPAWN)
	_add_sign(Vector2(44, 345), "01  FIND YOUR FEET", "Run • jump • hold for height")
	_add_sign(Vector2(550, 293), "02  KEEP CLIMBING", "Tap for a short jump")
	_add_sign(Vector2(995, 326), "03  MIND YOUR HEAD", "Try a jump under the ceiling")
	_add_sign(Vector2(1400, 293), "04  A SECOND WIND", "Press jump again in the air")
	_add_sign(Vector2(1700, 182), "NICE JUMP!", "Cyan flash = air jump used")
	_add_sign(Vector2(2200, 308), "05  THE LOOKOUT", "Course complete • R to try again")


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file("res://scenes/main/main.tscn")
		return
	if player.position.y > COURSE_HEIGHT + 64 or Input.is_action_just_pressed("restart"):
		player.reset_to(SPAWN)
	var movement_state := "GROUNDED" if player.is_on_floor() else "AIRBORNE"
	status.text = "%s  ·  speed %03d  ·  air jump %s" % [
		movement_state, absi(roundi(player.velocity.x)),
		"ready" if player.air_jump_available else "used"
	]


func _add_sign(at: Vector2, heading: String, hint: String) -> void:
	var label := Label.new()
	label.position = at
	label.text = heading + "\n" + hint
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color("f5ead3"))
	label.add_theme_color_override("font_shadow_color", Color("183844"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(label)
