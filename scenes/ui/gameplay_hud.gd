extends CanvasLayer
## Presentation listens to state changes; it never owns gameplay counters.

const Hearts = preload("res://scenes/ui/heart_display.gd")
var hearts: Control
var health_label: Label
var runes_label: Label
var checkpoint_label: Label
var message_label: Label
var _message_left: float = 0.0


func _ready() -> void:
	var bar := ColorRect.new()
	bar.size = Vector2(640, 54)
	bar.color = Color(0.06, 0.13, 0.18, 0.96)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)
	hearts = Hearts.new()
	hearts.position = Vector2(14, 9)
	hearts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hearts)
	health_label = _label(Vector2(90, 9), "", 12, Color("ef8b7d"))
	runes_label = _label(Vector2(183, 9), "", 14, Color("85e1e7"))
	checkpoint_label = _label(Vector2(348, 9), "", 12, Color("e9d8a6"))
	_label(Vector2(14, 32), "A/D: move   Space: jump twice   J: sword   R: checkpoint   Esc: menu", 12, Color("bbced6"))
	message_label = _label(Vector2(20, 62), "", 14, Color("f5ead3"))
	_label(Vector2(14, 340), "M2 • TRAINING GROUNDS  /  Runes survive respawn  /  Temporary artwork", 11, Color("d4e1df"))


func bind_state(health: Node, progress: Node) -> void:
	health.health_changed.connect(_update_health)
	progress.runes_changed.connect(_update_runes)
	progress.checkpoint_changed.connect(_update_checkpoint)
	_update_health(health.current_health, health.max_health)
	_update_runes(progress.rune_count, progress.rune_total)
	_update_checkpoint(progress.checkpoint_id, progress.spawn_position)


func _label(at: Vector2, text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = at
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("183844"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(label)
	return label


func _update_health(current: int, maximum: int) -> void:
	health_label.text = "%d / %d" % [current, maximum]
	hearts.update_health(current, maximum)


func _update_runes(current: int, total: int) -> void:
	runes_label.text = "RUNES  %d / %d" % [current, total]
	if current > 0:
		show_message("All training runes found!" if current == total else "Rune collected — kept through respawn.")


func _update_checkpoint(id: StringName, _spawn: Vector2) -> void:
	checkpoint_label.text = "CHECKPOINT  " + String(id).to_upper()


func show_message(text: String, duration: float = 2.5) -> void:
	message_label.text = text
	_message_left = duration


func _process(delta: float) -> void:
	_message_left = maxf(0.0, _message_left - delta)
	message_label.visible = _message_left > 0.0
