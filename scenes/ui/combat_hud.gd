extends CanvasLayer

signal selection_requested(kind: StringName)

const Hearts = preload("res://scenes/ui/heart_display.gd")
var hearts: Control
var health_label: Label
var state_label: Label
var message_label: Label
var boss_bar: ProgressBar
var _enemy: Node2D
var _kind: StringName
var _message_left: float = 0.0


func _ready() -> void:
	var bar := ColorRect.new()
	bar.size = Vector2(640, 86)
	bar.color = Color(0.06, 0.13, 0.18, 0.96)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)
	_label(Vector2(14, 5), "RUNEBOUND / M3 COMBAT TRIAL", 14, Color("e9d8a6"))
	hearts = Hearts.new()
	hearts.position = Vector2(445, 10)
	add_child(hearts)
	health_label = _label(Vector2(530, 9), "", 12, Color("ef8b7d"))
	state_label = _label(Vector2(14, 28), "", 12, Color("85e1e7"))
	var index := 0
	for pair in [[&"draugr", "1  Draugr"], [&"raven", "2  Raven"], [&"troll", "3  Troll"]]:
		var button := Button.new()
		button.text = pair[1]
		button.position = Vector2(14 + index * 118, 53)
		button.size = Vector2(110, 26)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_select.bind(pair[0]))
		add_child(button)
		index += 1
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(14, 91)
	boss_bar.show_percentage = false
	var background := StyleBoxFlat.new()
	background.bg_color = Color("263b44")
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("d44a4f")
	boss_bar.add_theme_stylebox_override("background", background)
	boss_bar.add_theme_stylebox_override("fill", fill)
	add_child(boss_bar)
	# Size after theme/percentage setup; the default themed minimum is taller.
	boss_bar.size = Vector2(340, 13)
	message_label = _label(Vector2(14, 111), "", 12, Color("f5ead3"))
	_label(Vector2(14, 340), "A/D: move  Space: jump twice  J: sword  R: retry  Esc: menu", 11, Color("e2e8df"))


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


func _select(kind: StringName) -> void:
	selection_requested.emit(kind)


func bind_player(health: Node) -> void:
	health.health_changed.connect(_update_player_health)
	_update_player_health(health.current_health, health.max_health)


func bind_enemy(enemy: Node2D, kind: StringName) -> void:
	_enemy = enemy
	_kind = kind
	enemy.health.health_changed.connect(_update_enemy_health)
	enemy.state_changed.connect(_on_enemy_state_changed)
	_update_enemy_health(enemy.health.current_health, enemy.health.max_health)
	_on_enemy_state_changed(&"", enemy.state)


func _on_enemy_state_changed(_previous: StringName, current: StringName) -> void:
	boss_bar.visible = _kind == &"troll" and current != &"dormant" and current != &"dead"


func _update_player_health(current: int, maximum: int) -> void:
	hearts.update_health(current, maximum)
	health_label.text = "%d / %d" % [current, maximum]


func _update_enemy_health(current: int, maximum: int) -> void:
	boss_bar.max_value = maximum
	boss_bar.value = current


func announce(message: String, duration: float = 3.0) -> void:
	message_label.text = message
	_message_left = duration


func _process(delta: float) -> void:
	_message_left = maxf(0, _message_left - delta)
	message_label.visible = _message_left > 0
	if not is_instance_valid(_enemy):
		return
	var description: String = String(_enemy.state).to_upper()
	var color := Color("85e1e7")
	if _enemy.attack.is_running():
		description = String(_enemy.attack.profile.attack_name).replace("_", " ").to_upper() + " / " + String(_enemy.attack.phase).to_upper()
		color = Color("eabb5b") if _enemy.attack.phase == &"windup" else Color("ef8b7d") if _enemy.attack.phase == &"active" else Color("85e1e7")
	state_label.text = "%s  /  %s  /  HP %d" % [String(_kind).to_upper(), description, _enemy.health.current_health]
	state_label.add_theme_color_override("font_color", color)
