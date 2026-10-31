extends Node2D
## Lightweight provisional landmarks, without collision or gameplay logic.

@export var kind: StringName = &"pine"
@export var span: float = 128.0


func _draw() -> void:
	match kind:
		&"cabin":
			draw_rect(Rect2(-52, -68, 104, 68), Color("715746"))
			for y in range(-64, 0, 10):
				draw_line(Vector2(-50, y), Vector2(50, y), Color("4d4740"), 2)
			draw_colored_polygon(PackedVector2Array([Vector2(-65, -66), Vector2(0, -110), Vector2(65, -66)]), Color("38594f"))
			draw_rect(Rect2(-11, -45, 22, 45), Color("263b3f"))
			draw_rect(Rect2(25, -49, 17, 17), Color("c7b47a"))
		&"church":
			draw_colored_polygon(PackedVector2Array([
				Vector2(-150, 64), Vector2(-90, 12), Vector2(-50, -22),
				Vector2(50, -22), Vector2(90, 12), Vector2(150, 64)
			]), Color("3f675d"))
			for tier in 4:
				var width := 80.0 - tier * 15
				var y := -24.0 - tier * 33
				draw_rect(Rect2(-width * 0.6, y - 28, width * 1.2, 34), Color("594c43"))
				draw_colored_polygon(PackedVector2Array([Vector2(-width, y - 24), Vector2(0, y - 57), Vector2(width, y - 24)]), Color("354947"))
			draw_line(Vector2(0, -204), Vector2(0, -164), Color("746851"), 4)
			draw_line(Vector2(-10, -192), Vector2(10, -192), Color("746851"), 3)
		&"waterfall":
			draw_rect(Rect2(-24, -280, 48, 410), Color(0.6, 0.83, 0.89, 0.6))
			for x in [-18, -8, 6, 18]:
				draw_line(Vector2(x, -280), Vector2(x, 130), Color(0.84, 0.96, 0.96, 0.7), 3)
		&"bridge":
			for x in range(0, int(span), 16):
				draw_rect(Rect2(x, 0, 15, 10), Color("92714e"))
				draw_line(Vector2(x, 0), Vector2(x + 14, 0), Color("bca078"), 2)
			draw_line(Vector2(0, 24), Vector2(span, 24), Color("5e5948"), 3)
		&"pine":
			draw_rect(Rect2(-4, -110, 8, 110), Color("4a5548"))
			for tier in 3:
				var y := -150.0 + tier * 34
				var width := 26.0 + tier * 10
				draw_colored_polygon(PackedVector2Array([Vector2(0, y), Vector2(-width, y + 66), Vector2(width, y + 66)]), Color("315a51"))
