extends Node2D
## Visual-only planks over separately owned TileMapLayer collision.

var broken: bool = false:
	set(value):
		broken = value
		queue_redraw()


func _draw() -> void:
	for x in 40:
		if broken and x in [20, 21]:
			continue
		draw_rect(Rect2(x * 16, 320, 15, 12), Color("80654a"))
		draw_rect(Rect2(x * 16, 320, 15, 2), Color("b29b6f"))
		draw_rect(Rect2(x * 16 + 3, 325, 2, 2), Color("41484a"))
	if not broken:
		draw_line(Vector2(322, 323), Vector2(332, 330), Color("d1b777"), 2)
		draw_line(Vector2(339, 327), Vector2(348, 322), Color("d1b777"), 2)
