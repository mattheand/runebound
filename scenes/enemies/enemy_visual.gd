extends Node2D
## Readable temporary enemy silhouettes and exact attack-region telegraphs.

@export var kind: StringName = &"draugr"


func _process(_delta: float) -> void:
	var actor := get_parent()
	rotation = minf(actor.state_time * 3, PI / 2) if actor.state == &"dead" else 0.0
	modulate = Color(2, 1.5, 1.5) if actor.flash_left > 0 else Color.WHITE
	modulate.a = maxf(0.0, 1.0 - actor.state_time / actor.death_seconds) if actor.state == &"dead" else 1.0
	queue_redraw()


func _draw() -> void:
	var actor := get_parent()
	if kind == &"raven" and actor.state == &"telegraph":
		draw_line(Vector2.ZERO, actor.aim_point - actor.global_position, Color(1, 0.8, 0.3, 0.5), 1)
	if actor.attack.is_running() and actor.state != &"dead":
		draw_set_transform(Vector2.ZERO, 0, Vector2(actor.attack.facing, 1))
		var rect: Rect2 = Rect2(actor.attack.profile.offset - actor.attack.profile.size / 2, actor.attack.profile.size)
		if actor.attack.phase == &"windup":
			draw_rect(rect, Color("eabb5b"), false, 2)
		elif actor.attack.phase == &"active":
			draw_rect(rect, Color(1, 0.3, 0.25, 0.5))
	draw_set_transform(Vector2.ZERO, 0, Vector2(actor.facing, 1))
	if kind == &"troll":
		draw_rect(Rect2(-30, -62, 60, 48), Color("69766e"))
		draw_rect(Rect2(-24, -82, 48, 31), Color("829084"))
		draw_rect(Rect2(-25, -83, 32, 7), Color("506b47"))
		draw_rect(Rect2(-34, -62, 20, 11), Color("506b47"))
		draw_rect(Rect2(10, -72, 8, 4), Color("e8bd6e"))
		draw_rect(Rect2(12, -58, 16, 5), Color("35463f"))
		draw_rect(Rect2(-28, -18, 19, 18), Color("43504b"))
		draw_rect(Rect2(9, -18, 21, 18), Color("43504b"))
		var club_y := -94.0 if actor.attack.phase == &"windup" else -40.0
		draw_line(Vector2(28, -38), Vector2(48, club_y + 12), Color("866246"), 9)
		draw_rect(Rect2(35, club_y, 29, 23), Color("a18358"))
		draw_rect(Rect2(35, club_y + 6, 29, 5), Color("56616a"))
		draw_set_transform(Vector2.ZERO)
		return
	if kind == &"raven":
		var wing := -8.0 - absf(sin(actor.state_time * 12)) * 12
		draw_colored_polygon(PackedVector2Array([
			Vector2(-5, 0), Vector2(-23, wing), Vector2(-16, 5), Vector2(5, 8),
			Vector2(12, -3), Vector2(7, -8)
		]), Color("242e49"))
		draw_rect(Rect2(6, -9, 10, 10), Color("35415d"))
		draw_rect(Rect2(15, -5, 7, 3), Color("beaa77"))
		draw_rect(Rect2(11, -7, 2, 2), Color("e5b764"))
		draw_set_transform(Vector2.ZERO)
		return
	draw_rect(Rect2(-10, -27, 20, 23), Color("516665"))
	draw_rect(Rect2(-8, -38, 16, 14), Color("8ba993"))
	draw_rect(Rect2(-10, -39, 20, 5), Color("566271"))
	draw_rect(Rect2(2, -32, 5, 2), Color("9af1db"))
	draw_rect(Rect2(-11, -5, 8, 5), Color("463d3e"))
	draw_rect(Rect2(3, -5, 8, 5), Color("463d3e"))
	draw_rect(Rect2(12, -22, 3, 22), Color("b9c8bd"))
	draw_rect(Rect2(8, -8, 11, 3), Color("8d7152"))
	draw_set_transform(Vector2.ZERO)
	for index in actor.health.max_health:
		draw_rect(Rect2(-10 + index * 7, -47, 5, 3), Color("d44a4f") if index < actor.health.current_health else Color("263b44"))
