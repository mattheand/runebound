class_name LevelProgress
extends Node
## Session-local progress. Respawning never recreates this node.

signal runes_changed(current: int, total: int)
signal checkpoint_changed(id: StringName, spawn: Vector2)

@export var spawn_position: Vector2 = Vector2(96, 416)
var checkpoint_id: StringName = &"start"
var _registered: Dictionary = {}
var _collected: Dictionary = {}

var rune_count: int:
	get:
		return _collected.size()
var rune_total: int:
	get:
		return _registered.size()


func register_rune(id: StringName) -> bool:
	if id == &"" or _registered.has(id):
		return false
	_registered[id] = true
	runes_changed.emit(rune_count, rune_total)
	return true


func has_rune(id: StringName) -> bool:
	return _collected.has(id)


func collect_rune(id: StringName) -> bool:
	if not _registered.has(id) or _collected.has(id):
		return false
	_collected[id] = true
	runes_changed.emit(rune_count, rune_total)
	return true


func activate_checkpoint(id: StringName, spawn: Vector2) -> bool:
	if id == &"" or id == checkpoint_id:
		return false
	checkpoint_id = id
	spawn_position = spawn
	checkpoint_changed.emit(id, spawn)
	return true
