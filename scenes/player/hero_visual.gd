extends Node2D
## Original grid-aligned placeholder, separate from movement/collision.

var facing: int = 1
var stride: float = 0.0
var burst_time: float = 0.0
var hurt_time: float = 0.0
var death_time: float = 0.0


func _process(delta: float) -> void:
	var body := get_parent() as CharacterBody2D
	var health = body.get_node("HealthComponent")
	if health.is_dead():
		death_time += delta
		rotation = minf(death_time * 4.0, PI / 2.0)
		modulate.a = maxf(0.2, 1.0 - death_time)
		return
	facing = body.facing
	if absf(body.velocity.x) > 1.0:
		stride += delta * absf(body.velocity.x) * 0.08
	else:
		stride = 0.0
	burst_time = maxf(0.0, burst_time - delta)
	hurt_time = maxf(0.0, hurt_time - delta)
	modulate = Color(2, 1, 1) if hurt_time > 0.0 else Color.WHITE
	if health.invulnerability_left > 0.0:
		modulate.a = 0.45 if int(health.invulnerability_left * 16) % 2 == 0 else 1.0
	queue_redraw()


func on_damaged() -> void:
	hurt_time = 0.12


func reset_pose() -> void:
	death_time = 0.0
	hurt_time = 0.0
	burst_time = 0.0
	rotation = 0.0
	modulate = Color.WHITE


func on_jumped(is_double: bool) -> void:
	if is_double:
		burst_time = 0.25


func _draw() -> void:
	if burst_time > 0.0:
		var radius := 9.0 + (0.25 - burst_time) * 80.0
		draw_arc(Vector2(0, -8), radius, 0, TAU, 16,
			Color(0.4, 0.9, 1.0, burst_time * 4.0), 2.0)
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing, 1))
	var step := roundf(sin(stride) * 2.0)
	# Red cape, blue tunic, blond hair and shield read at gameplay scale.
	draw_rect(Rect2(-13, -26, 9, 22), Color("722838"))
	draw_rect(Rect2(-11, -26, 8, 19), Color("d44a4f"))
	draw_rect(Rect2(-8, -22, 16, 15), Color("182b3b"))
	draw_rect(Rect2(-6, -22, 12, 14), Color("367ea8"))
	draw_rect(Rect2(-6, -9, 13, 3), Color("654333"))
	draw_rect(Rect2(0, -9, 3, 3), Color("e1b960"))
	draw_rect(Rect2(-6, -6, 5, 5 + step), Color("40313a"))
	draw_rect(Rect2(2, -6, 5, 5 - step), Color("40313a"))
	draw_rect(Rect2(-7, -3 + step, 7, 3), Color("8f6041"))
	draw_rect(Rect2(2, -3 - step, 8, 3), Color("8f6041"))
	draw_rect(Rect2(-6, -33, 13, 12), Color("e3ab78"))
	draw_rect(Rect2(-7, -35, 14, 5), Color("e9be62"))
	draw_rect(Rect2(-8, -31, 4, 5), Color("c88c46"))
	draw_rect(Rect2(4, -29, 2, 2), Color("152d3f"))
	draw_rect(Rect2(6, -25, 3, 3), Color("e3ab78"))
	draw_rect(Rect2(-7, -23, 15, 3), Color("d44a4f"))
	draw_rect(Rect2(-11, -19, 9, 12), Color("b7c7c1"))
	draw_rect(Rect2(-10, -18, 7, 10), Color("80573f"))
	draw_rect(Rect2(-7, -17, 1, 8), Color("d6a669"))
	draw_rect(Rect2(-8, -14, 3, 3), Color("b7c7c1"))
	draw_set_transform(Vector2.ZERO)
