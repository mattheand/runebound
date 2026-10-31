extends "res://scripts/components/level_progress.gd"
## Persistent within one level session; attempts never recreate this node.

signal world_state_changed

var cave_open: bool = false
var cave_switch_active: bool = false
var boss_defeated: bool = false
var checkpoint_in_cave: bool = false
var completed: bool = false
var deaths: int = 0
var elapsed_seconds: float = 0.0


func _physics_process(delta: float) -> void:
	if not completed:
		elapsed_seconds += delta


func bridge_gate_ready() -> bool:
	return rune_count >= 5


func open_cave() -> void:
	if not cave_open:
		cave_open = true
		world_state_changed.emit()


func activate_cave_switch() -> void:
	if not cave_switch_active:
		cave_switch_active = true
		world_state_changed.emit()


func mark_boss_defeated() -> void:
	if not boss_defeated:
		boss_defeated = true
		world_state_changed.emit()


func activate_checkpoint(id: StringName, spawn: Vector2) -> bool:
	if not super.activate_checkpoint(id, spawn):
		return false
	checkpoint_in_cave = spawn.y > 800
	return true


func record_death() -> void:
	if not completed:
		deaths += 1


func finish_level() -> bool:
	if not boss_defeated or completed:
		return false
	completed = true
	world_state_changed.emit()
	return true
