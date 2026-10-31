class_name HitboxComponent
extends Area2D
## Overlap tracking stays enabled; only active attack frames may apply damage.

signal hit(target: Node)

@export var team_id: int = 1
@export var damage: int = 1
@export var knockback: Vector2 = Vector2(210, -140)

var active: bool = false
var _direction: int = 1
var _hit_owners: Dictionary = {}


func begin_swing(direction: int) -> void:
	_direction = direction
	_hit_owners.clear()
	active = true


func end_swing() -> void:
	active = false
	_hit_owners.clear()


func sample_hits() -> void:
	if not active:
		return
	for area in get_overlapping_areas():
		if not area.has_method("receive_hit") or area.team_id == team_id:
			continue
		var health: Node = area.get_health()
		var key := health.get_instance_id()
		if _hit_owners.has(key):
			continue
		# Deduplicate by health owner, including multiple hurtboxes and blocked hits.
		_hit_owners[key] = true
		if area.receive_hit(damage, Vector2(knockback.x * _direction, knockback.y)):
			hit.emit(area.get_parent())
