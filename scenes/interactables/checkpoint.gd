extends Area2D

signal activated(checkpoint: Area2D)

@export var checkpoint_id: StringName = &"checkpoint"
@export var spawn_offset: Vector2 = Vector2(0, -32)
var active: bool = false
var _pulse_left: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not active and body.is_in_group("players") and not body.health.is_dead():
		activated.emit(self)


func set_active(value: bool) -> void:
	if value and not active:
		_pulse_left = 0.5
		$Sound.play()
	active = value
	queue_redraw()


func _process(delta: float) -> void:
	_pulse_left = maxf(0.0, _pulse_left - delta)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-12, -40, 24, 40), Color("3d5055"))
	draw_rect(Rect2(-9, -37, 18, 33), Color("607074"))
	var color := Color("86f1e8") if active else Color("b0bbb2")
	draw_line(Vector2(0, -32), Vector2(0, -9), color, 2)
	draw_line(Vector2(0, -32), Vector2(7, -24), color, 2)
	draw_line(Vector2(7, -24), Vector2(0, -20), color, 2)
	draw_line(Vector2(0, -20), Vector2(7, -11), color, 2)
	if active:
		draw_rect(Rect2(-15, -3, 30, 3), Color("86f1e8"))
	if _pulse_left > 0.0:
		draw_arc(Vector2(0, -20), 20 + (0.5 - _pulse_left) * 40, 0, TAU, 24,
			Color(0.5, 1.0, 0.9, _pulse_left * 2), 2)
