extends Area2D

@export var damage: int = 1
@export var knockback: Vector2 = Vector2(220, -220)


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("players"):
			var direction := -1.0 if body.global_position.x < global_position.x else 1.0
			body.health.take_damage(damage, Vector2(knockback.x * direction, knockback.y))


func _draw() -> void:
	draw_rect(Rect2(-24, -3, 48, 3), Color("723943"))
	for index in 4:
		var x := float(-24 + index * 12)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, 0), Vector2(x + 6, -12), Vector2(x + 12, 0)
		]), Color("d5b9ad"))
