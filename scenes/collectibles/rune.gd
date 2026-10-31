extends Area2D

@export var rune_id: StringName = &""
var _progress: Node
var _time: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func bind_progress(progress: Node) -> void:
	if is_instance_valid(_progress):
		_progress.runes_changed.disconnect(_on_runes_changed)
	_progress = progress
	_progress.register_rune(rune_id)
	_progress.runes_changed.connect(_on_runes_changed)
	_on_runes_changed(_progress.rune_count, _progress.rune_total)


func _on_runes_changed(_current: int, _total: int) -> void:
	visible = not _progress.has_rune(rune_id)
	set_deferred("monitoring", visible)


func _on_body_entered(body: Node2D) -> void:
	if not is_instance_valid(_progress) or not body.is_in_group("players") or body.health.is_dead():
		return
	if _progress.collect_rune(rune_id):
		$Sound.play()


func _process(delta: float) -> void:
	if visible:
		_time += delta
		queue_redraw()


func _draw() -> void:
	var bob := Vector2(0, sin(_time * 3) * 3)
	draw_set_transform(bob)
	draw_circle(Vector2.ZERO, 13, Color(0.4, 0.9, 1, 0.13))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -10), Vector2(7, 0), Vector2(0, 10), Vector2(-7, 0)
	]), Color("3aa6b4"))
	draw_line(Vector2(0, -7), Vector2(0, 7), Color("d9ffff"), 2)
	draw_line(Vector2(0, -5), Vector2(4, -1), Color("d9ffff"), 2)
	draw_line(Vector2(4, -1), Vector2(0, 2), Color("d9ffff"), 2)
	draw_set_transform(Vector2.ZERO)
