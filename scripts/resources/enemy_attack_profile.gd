class_name EnemyAttackProfile
extends Resource

@export var attack_name: StringName = &"melee"
@export_range(0.1, 3, 0.05) var windup: float = 0.35
@export_range(0.05, 2, 0.01) var active: float = 0.12
@export_range(0.1, 3, 0.05) var recovery: float = 0.65
@export var size: Vector2 = Vector2(44, 32)
@export var offset: Vector2 = Vector2(30, -18)
@export var damage: int = 1
@export var knockback: Vector2 = Vector2(180, -140)
