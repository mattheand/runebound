class_name HealthComponent
extends Node
## Health owns damage acceptance and lifecycle; actors own motion/presentation.

signal health_changed(current: int, maximum: int)
signal damaged(amount: int, impulse: Vector2)
signal died

@export_range(1, 100, 1) var max_health: int = 3
@export_range(0, 5, 0.05) var invulnerability_seconds: float = 0.8

var current_health: int = 3
var invulnerability_left: float = 0.0


func _ready() -> void:
	reset_health()


func _physics_process(delta: float) -> void:
	invulnerability_left = maxf(0.0, invulnerability_left - delta)


func is_dead() -> bool:
	return current_health <= 0


func take_damage(amount: int, impulse: Vector2 = Vector2.ZERO) -> bool:
	if amount <= 0 or is_dead() or invulnerability_left > 0.0:
		return false
	var applied := mini(amount, current_health)
	current_health -= applied
	invulnerability_left = invulnerability_seconds
	health_changed.emit(current_health, max_health)
	damaged.emit(applied, impulse)
	if is_dead():
		died.emit()
	return true


func heal(amount: int) -> void:
	if amount <= 0 or is_dead():
		return
	current_health = mini(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)


func kill() -> void:
	# World kill planes must work even during damage/respawn grace.
	if is_dead():
		return
	current_health = 0
	health_changed.emit(current_health, max_health)
	died.emit()


func reset_health(grace_seconds: float = 0.0) -> void:
	current_health = max_health
	invulnerability_left = maxf(0.0, grace_seconds)
	health_changed.emit(current_health, max_health)
