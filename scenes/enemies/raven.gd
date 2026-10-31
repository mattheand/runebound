extends "res://scenes/enemies/enemy_actor.gd"

const Tuning = preload("res://scripts/resources/raven_tuning.gd")
@export var tuning: Resource = Tuning.new()
@export var dive: Resource = preload("res://scripts/resources/raven_dive.tres")

var aim_point: Vector2
var dive_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	health.max_health = tuning.health
	super._ready()
	attack.phase_changed.connect(_on_attack_phase)
	attack.finished.connect(_on_attack_finished)
	change_state(&"patrol")


func _physics_process(delta: float) -> void:
	if not advance_lifecycle(delta):
		return
	if attack.is_running() and not target_alive():
		attack.cancel()
		change_state(&"return")
	match state:
		&"patrol":
			if sees_target(tuning.detection_radius):
				aim_point = target.global_position + Vector2(0, -16)
				dive_direction = (aim_point - global_position).normalized()
				facing = 1 if dive_direction.x >= 0 else -1
				velocity = Vector2.ZERO
				attack.start(dive, facing)
			else:
				if absf(global_position.x - home.x) >= tuning.patrol_radius or is_on_wall():
					facing = -1 if global_position.x >= home.x else 1
				velocity = Vector2(facing * tuning.patrol_speed, 0)
		&"telegraph":
			velocity = Vector2.ZERO
		&"dive":
			velocity = dive_direction * tuning.dive_speed
		&"recovery":
			velocity = (home - global_position).normalized() * tuning.recovery_speed
		&"return":
			if global_position.distance_to(home) < tuning.return_speed * delta + 1:
				global_position = home
				velocity = Vector2.ZERO
				change_state(&"patrol")
			else:
				velocity = (home - global_position).normalized() * tuning.return_speed
		&"hurt":
			velocity = velocity.move_toward(Vector2.ZERO, 240 * delta)
			if state_time >= hurt_seconds:
				change_state(&"return")
	move_and_slide()
	if state == &"dive" and (is_on_floor() or is_on_wall() or (aim_point - global_position).dot(dive_direction) < 0):
		attack.begin_recovery()


func _on_attack_phase(phase: StringName) -> void:
	match phase:
		&"windup": change_state(&"telegraph")
		&"active": change_state(&"dive")
		&"recovery": change_state(&"recovery")


func _on_attack_finished() -> void:
	if not health.is_dead():
		change_state(&"return")


func reset_enemy() -> void:
	super.reset_enemy()
	change_state(&"patrol")
