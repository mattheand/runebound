extends Control
## Font-independent temporary hearts: identical on native and Web builds.

var current: int = 3
var maximum: int = 3


func update_health(value: int, total: int) -> void:
	current = value
	maximum = total
	queue_redraw()


func _draw() -> void:
	var heart := PackedVector2Array([
		Vector2(0, 3), Vector2(3, 0), Vector2(6, 0), Vector2(8, 2),
		Vector2(10, 0), Vector2(13, 0), Vector2(16, 3), Vector2(16, 7),
		Vector2(8, 15), Vector2(0, 7)
	])
	for index in maximum:
		draw_set_transform(Vector2(index * 23, 0))
		draw_colored_polygon(heart, Color("ef8b7d") if index < current else Color("415763"))
	draw_set_transform(Vector2.ZERO)
