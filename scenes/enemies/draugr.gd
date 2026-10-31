extends "res://scenes/enemies/enemy_actor.gd"

const Tuning = preload("res://scripts/resources/draugr_tuning.gd")
const AttackProfile = preload("res://scripts/resources/enemy_attack_profile.gd")
@export var tuning: Resource = Tuning.new()
@export var melee: Resource = AttackProfile.new()


func _ready() -> void:
	health.max_health = tuning.health
	super._ready()
	attack.finished.connect(_attack_finished)


func _physics_process(delta: float) -> void:
	if not advance_lifecycle(delta):
		return
	velocity.y = minf(velocity.y + tuning.gravity * delta, 900.0)
	if state == &"hurt":
		velocity.x = move_toward(velocity.x, 0, 250 * delta)
		if state_time >= hurt_seconds:
			change_state(&"idle")
	elif state == &"attack":
		velocity.x = 0
		if not target_alive():
			attack.cancel()
			change_state(&"idle")
	else:
		_update_movement()
	move_and_slide()


func _update_movement() -> void:
	var detected := sees_target(tuning.forget_radius if state == &"chase" else tuning.detection_radius)
	if detected and (state != &"idle" or state_time >= tuning.idle_seconds):
		change_state(&"chase")
		facing = 1 if target.global_position.x > global_position.x else -1
		if absf(target.global_position.x - global_position.x) <= tuning.attack_range and absf(target.global_position.y - global_position.y) < 42:
			velocity.x = 0
			change_state(&"attack")
			attack.start(melee, facing)
		else:
			velocity.x = facing * tuning.chase_speed if ground_ahead(facing) else 0.0
	elif state == &"idle":
		velocity.x = 0
		if state_time >= tuning.idle_seconds:
			change_state(&"patrol")
	else:
		change_state(&"patrol")
		if (facing < 0 and global_position.x <= home.x - tuning.patrol_radius) or (facing > 0 and global_position.x >= home.x + tuning.patrol_radius) or not ground_ahead(facing) or is_on_wall():
			facing *= -1
			change_state(&"idle")
			velocity.x = 0
		else:
			velocity.x = facing * tuning.patrol_speed


func _attack_finished() -> void:
	if not health.is_dead():
		change_state(&"idle")
