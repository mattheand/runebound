extends CharacterBody2D
## Shared lifecycle and sensing; each enemy owns its own state transitions.

signal state_changed(previous: StringName, current: StringName)
signal defeated(actor: Node2D)

@export var hurt_seconds: float = 0.25
@export var death_seconds: float = 0.65
@export var stagger_on_hit: bool = true
@export var senses_offset: Vector2 = Vector2(0, -18)

@onready var health = $HealthComponent
@onready var attack = $Attack
var state: StringName = &"idle"
var state_time: float = 0.0
var facing: int = -1
var target: Node2D
var home: Vector2
var flash_left: float = 0.0


func _ready() -> void:
	home = global_position
	health.reset_health()
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	_refresh_target()


func _refresh_target() -> void:
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("players")


func target_alive() -> bool:
	_refresh_target()
	return is_instance_valid(target) and target.is_inside_tree() and not target.health.is_dead()


func sees_target(radius: float) -> bool:
	if not target_alive() or global_position.distance_to(target.global_position) > radius:
		return false
	var ray := PhysicsRayQueryParameters2D.create(global_position + senses_offset,
		target.global_position + Vector2(0, -16), 1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()


func ground_ahead(direction: int, distance: float = 18.0) -> bool:
	var start := global_position + Vector2(direction * distance, -6)
	var ray := PhysicsRayQueryParameters2D.create(start, start + Vector2(0, 26), 1)
	return not get_world_2d().direct_space_state.intersect_ray(ray).is_empty()


func change_state(next: StringName) -> void:
	if next == state:
		return
	var previous := state
	state = next
	state_time = 0.0
	state_changed.emit(previous, state)


func advance_lifecycle(delta: float) -> bool:
	state_time += delta
	flash_left = maxf(0.0, flash_left - delta)
	if state == &"dead":
		if state_time >= death_seconds:
			visible = false
		return false
	return true


func reset_enemy() -> void:
	global_position = home
	velocity = Vector2.ZERO
	flash_left = 0.0
	visible = true
	attack.cancel()
	health.reset_health()
	$Hurtbox.set_deferred("monitorable", true)
	$CollisionShape2D.set_deferred("disabled", false)
	change_state(&"idle")
	state_time = 0.0
	reset_physics_interpolation()


func _on_damaged(_amount: int, impulse: Vector2) -> void:
	flash_left = 0.14
	if stagger_on_hit and not health.is_dead():
		velocity = impulse
		attack.cancel()
		change_state(&"hurt")


func _on_died() -> void:
	velocity = Vector2.ZERO
	attack.cancel()
	change_state(&"dead")
	$Hurtbox.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)
	defeated.emit(self)
