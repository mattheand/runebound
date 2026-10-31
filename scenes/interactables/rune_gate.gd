extends StaticBody2D

@export var label_text: String = "RUNES"
var is_open: bool = false


func _ready() -> void:
	$Label.text = label_text


func set_open(value: bool) -> void:
	is_open = value
	$CollisionShape2D.set_deferred("disabled", value)
	queue_redraw()


func _draw() -> void:
	var color := Color("76daca") if is_open else Color("ab8258")
	if is_open:
		draw_rect(Rect2(-12, -320, 24, 320), Color("344d56"), false, 2)
	else:
		draw_rect(Rect2(-12, -320, 24, 320), Color("344d56"))
	for y in range(-312, 0, 24):
		draw_line(Vector2(-8, y), Vector2(8, y + 12), color, 2)
		draw_line(Vector2(8, y), Vector2(-8, y + 12), color, 2)
