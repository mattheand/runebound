class_name CombatTuning
extends Resource

@export_range(0.04, 1, 0.01) var windup_seconds: float = 0.08
@export_range(0.04, 1, 0.01) var active_seconds: float = 0.1
@export_range(0.04, 1, 0.01) var recovery_seconds: float = 0.22
@export_range(1, 20, 1) var damage: int = 1
@export var knockback: Vector2 = Vector2(210, -140)
