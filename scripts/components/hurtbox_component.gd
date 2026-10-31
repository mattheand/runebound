class_name HurtboxComponent
extends Area2D

@export_node_path("Node") var health_path: NodePath = ^"../HealthComponent"
@export var team_id: int = 2


func get_health() -> Node:
	return get_node(health_path)


func receive_hit(amount: int, impulse: Vector2) -> bool:
	return get_health().take_damage(amount, impulse)
