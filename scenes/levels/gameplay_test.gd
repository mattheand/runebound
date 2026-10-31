extends Node2D

@export_range(0.1, 3, 0.05) var respawn_delay: float = 0.65
@onready var player = $Player
@onready var progress = $LevelProgress
@onready var hud = $GameplayHUD
var _respawn_left: float = 0.0


func _ready() -> void:
	for rect in [
		Rect2i(0, 28, 54, 12), Rect2i(59, 28, 61, 12),
		Rect2i(28, 25, 6, 3), Rect2i(35, 22, 5, 6),
		Rect2i(78, 24, 8, 4), Rect2i(89, 20, 8, 2),
		Rect2i(-1, 0, 1, 45), Rect2i(120, 0, 1, 45)
	]:
		$Terrain.fill_platform(rect)
	var camera: Camera2D = $Player/Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1920
	camera.limit_bottom = 720
	player.reset_to(progress.spawn_position)
	player.health.died.connect(_on_player_died)
	hud.bind_state(player.health, progress)
	for rune in $Runes.get_children():
		rune.bind_progress(progress)
	for checkpoint in $Checkpoints.get_children():
		checkpoint.activated.connect(_on_checkpoint_activated)
	_add_sign(Vector2(44, 344), "01  SWORD PRACTICE", "J / gamepad X • one hit per swing")
	_add_sign(Vector2(420, 296), "02  COLLECT & CLIMB", "Find the floating cyan runes")
	_add_sign(Vector2(667, 341), "03  A SAFE RETURN", "Touch the stone to save your spawn")
	_add_sign(Vector2(996, 335), "04  MIND THE SPIKES", "Three hearts • brief protection on hit")
	_add_sign(Vector2(1400, 233), "05  THE HIGH RUNE", "Jump again to reach the upper ledge")
	_add_sign(Vector2(1630, 332), "THE LOOKOUT", "A second checkpoint • R to retry")


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file("res://scenes/main/main.tscn")
		return
	if player.health.is_dead():
		_respawn_left = maxf(0.0, _respawn_left - delta)
		if _respawn_left <= 0.0:
			_respawn()
		return
	if player.position.y > 784:
		player.health.kill()
	elif Input.is_action_just_pressed("restart"):
		_respawn()


func _on_player_died() -> void:
	_respawn_left = respawn_delay
	hud.show_message("You fell — returning to your checkpoint...", respawn_delay)


func _respawn() -> void:
	_respawn_left = 0.0
	player.reset_to(progress.spawn_position)
	for target in $TrainingTargets.get_children():
		target.reset_target()
	hud.show_message("Back at " + String(progress.checkpoint_id) + " • runes preserved.")


func _on_checkpoint_activated(checkpoint: Area2D) -> void:
	if progress.activate_checkpoint(checkpoint.checkpoint_id, checkpoint.global_position + checkpoint.spawn_offset):
		for marker in $Checkpoints.get_children():
			marker.set_active(marker == checkpoint)
		hud.show_message("Checkpoint activated — R returns here.")


func _add_sign(at: Vector2, title: String, hint: String) -> void:
	var label := Label.new()
	label.position = at
	label.text = title + "\n" + hint
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color("f5ead3"))
	label.add_theme_color_override("font_shadow_color", Color("183844"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(label)
