extends Area2D

signal requested(action_id: StringName)

@export var action_id: StringName = &"interact"
@export var hint: String = "[E] Interact"


func _physics_process(_delta: float) -> void:
	var nearby := false
	for body in get_overlapping_bodies():
		if body.is_in_group("players") and not body.health.is_dead():
			nearby = true
			if Input.is_action_just_pressed("interact"):
				requested.emit(action_id)
	$Hint.visible = nearby
	$Hint.text = hint


func _draw() -> void:
	draw_rect(Rect2(-9, -30, 18, 30), Color("2d5963"))
	draw_line(Vector2(0, -25), Vector2(0, -5), Color("85e1e7"), 2)
	draw_line(Vector2(0, -25), Vector2(6, -15), Color("85e1e7"), 2)
	draw_line(Vector2(6, -15), Vector2(0, -10), Color("85e1e7"), 2)
