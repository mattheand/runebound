extends "res://scenes/levels/test_backdrop.gd"

var cave: bool = false:
	set(value):
		cave = value
		queue_redraw()


func _draw() -> void:
	if not cave:
		super._draw()
		# Provisional Bifrost-like accent; production scenery belongs to M5.
		draw_line(Vector2(380, 104), Vector2(600, 34), Color(0.6, 0.9, 0.9, 0.24), 3)
	else:
		draw_rect(Rect2(0, 0, 640, 360), Color("102831"))
		for index in 14:
			var x := index * 50.0
			draw_colored_polygon(PackedVector2Array([
				Vector2(x, 0), Vector2(x + 25, 80 + index % 3 * 24), Vector2(x + 50, 0)
			]), Color("1a3741"))
		draw_rect(Rect2(0, 284, 640, 76), Color("193b44"))
