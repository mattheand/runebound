extends "res://scenes/enemies/enemy_actor.gd"

signal encounter_started
signal bridge_smashed(at: Vector2)

const Tuning = preload("res://scripts/resources/troll_tuning.gd")
@export var tuning: Resource = Tuning.new()
@export var slam: Resource = preload("res://scripts/resources/troll_slam.tres")
@export var club: Resource = preload("res://scripts/resources/troll_club.tres")
@export var smash: Resource = preload("res://scripts/resources/troll_smash.tres")

var _pattern_index: int = 0


func _ready() -> void:
	health.max_health = tuning.health
	super._ready()
	attack.finished.connect(_on_attack_finished)
	attack.active_started.connect(_on_active_started)
	_lock_dormant()


func _lock_dormant() -> void:
	_pattern_index = 0
	health.invulnerability_left = 9999.0
	$Hurtbox.set_deferred("monitorable", false)
	change_state(&"dormant")


func start_encounter() -> bool:
	if state != &"dormant":
		return false
	change_state(&"intro")
	encounter_started.emit()
	return true


func _physics_process(delta: float) -> void:
	if not advance_lifecycle(delta):
		return
	velocity.y = minf(velocity.y + tuning.gravity * delta, 900.0)
	velocity.x = 0
	match state:
		&"intro":
			if state_time >= tuning.intro_seconds:
				health.invulnerability_left = 0.0
				$Hurtbox.set_deferred("monitorable", true)
				change_state(&"chase")
		&"chase":
			if target_alive():
				facing = 1 if target.global_position.x > global_position.x else -1
				if absf(target.global_position.x - global_position.x) <= tuning.attack_range:
					_start_next_attack()
				elif ground_ahead(facing, 36):
					var next_x: float = global_position.x + facing * tuning.approach_speed * delta
					if next_x >= tuning.arena_left and next_x <= tuning.arena_right:
						velocity.x = facing * tuning.approach_speed
		&"attack":
			if not target_alive():
				attack.cancel()
				change_state(&"chase")
	move_and_slide()


func _start_next_attack() -> void:
	var patterns: Array[Resource] = [slam, club, smash]
	change_state(&"attack")
	attack.start(patterns[_pattern_index], facing)
	_pattern_index = (_pattern_index + 1) % patterns.size()


func _on_attack_finished() -> void:
	if not health.is_dead():
		change_state(&"chase")


func _on_active_started() -> void:
	if attack.profile.attack_name == &"charged_smash":
		bridge_smashed.emit(global_position + Vector2(attack.profile.offset.x * attack.facing, 0))


func reset_enemy() -> void:
	super.reset_enemy()
	_lock_dormant()
