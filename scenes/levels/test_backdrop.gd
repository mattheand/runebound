extends Node2D
## Muted original placeholder scenery; deliberately quiet behind the course.


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("8cbbc5"))
	draw_rect(Rect2(0, 214, 640, 146), Color("558c9d"))
	_peak(Vector2(-70, 238), Vector2(109, 63), Vector2(272, 238), Color("6b92a6"))
	_peak(Vector2(130, 238), Vector2(342, 37), Vector2(531, 238), Color("739aab"))
	_peak(Vector2(370, 238), Vector2(543, 84), Vector2(736, 238), Color("628ba0"))
	for y in range(243, 356, 17):
		draw_rect(Rect2((y * 17) % 110, y, 430, 1), Color("76a4ae"))
	# Forest silhouettes keep the fjord visible in the center.
	for index in 10:
		var x := float(index * 19 - 18)
		_pine(Vector2(x, 301 + index % 3 * 6), 36 + index % 4 * 10)
	for index in 8:
		_pine(Vector2(506 + index * 22, 286 + index % 3 * 8), 40 + index % 4 * 8)
	draw_rect(Rect2(0, 336, 640, 24), Color("315b60"))


func _peak(left: Vector2, top: Vector2, right: Vector2, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([left, top, right]), color)
	draw_colored_polygon(PackedVector2Array([
		left.lerp(top, 0.72), top, top.lerp(right, 0.26),
		top + Vector2(4, 34), top + Vector2(-14, 26)
	]), Color("d1e1de"))


func _pine(base: Vector2, height: float) -> void:
	draw_rect(Rect2(base.x - 2, base.y - height, 4, height), Color("365862"))
	for tier in 3:
		var y := base.y - height + tier * height * 0.22
		var width := height * (0.15 + tier * 0.06)
		draw_colored_polygon(PackedVector2Array([
			Vector2(base.x, y), Vector2(base.x + width, y + height * 0.45),
			Vector2(base.x - width, y + height * 0.45)
		]), Color("39646a"))
