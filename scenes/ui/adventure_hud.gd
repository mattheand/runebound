extends CanvasLayer

signal pause_requested
signal retry_requested
signal restart_requested
signal menu_requested

const Hearts = preload("res://scenes/ui/heart_display.gd")
var hearts: Control
var runes_label: Label
var checkpoint_label: Label
var section_label: Label
var message_label: Label
var objective_label: Label
var results_label: Label
var boss_bar: ProgressBar
var completion_panel: Control
var pause_panel: Control
var _message_left: float = 0.0
var _enemy: Node2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var bar := ColorRect.new()
	bar.size = Vector2(640, 54)
	bar.color = Color(0.05, 0.12, 0.17, 0.97)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)
	hearts = Hearts.new()
	hearts.position = Vector2(14, 10)
	add_child(hearts)
	runes_label = _label(Vector2(170, 8), "RUNES 0 / 7", 14, Color("85e1e7"))
	checkpoint_label = _label(Vector2(340, 10), "CHECKPOINT START", 12, Color("e9d8a6"))
	_label(Vector2(14, 32), "A/D move  Space jump twice  J sword  E interact  R checkpoint  Esc pause", 11, Color("bbced6"))
	section_label = _label(Vector2(14, 61), "Starting Forest", 14, Color("e9d8a6"))
	message_label = _label(Vector2(14, 81), "", 12, Color("e0ece4"))
	objective_label = _label(Vector2(14, 340), "Find 5 runes to open the bridge. Hidden cave rewards are optional.", 11, Color("e0ece4"))
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(14, 105)
	boss_bar.show_percentage = false
	var background := StyleBoxFlat.new()
	background.bg_color = Color("263b44")
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("d44a4f")
	boss_bar.add_theme_stylebox_override("background", background)
	boss_bar.add_theme_stylebox_override("fill", fill)
	add_child(boss_bar)
	boss_bar.size = Vector2(340, 12)
	boss_bar.visible = false
	_build_panels()


func _label(at: Vector2, text: String, size: int, color: Color, parent: Node = null) -> Label:
	var label := Label.new()
	label.position = at
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("132d39"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	if parent == null:
		add_child(label)
	else:
		parent.add_child(label)
	return label


func _panel() -> Control:
	var panel := ColorRect.new()
	panel.size = Vector2(640, 360)
	panel.color = Color(0.04, 0.1, 0.14, 0.97)
	add_child(panel)
	panel.hide()
	return panel


func _button(parent: Control, at: Vector2, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.position = at
	button.size = Vector2(240, 34)
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _build_panels() -> void:
	completion_panel = _panel()
	_label(Vector2(125, 55), "THE TROLL BRIDGE", 28, Color("e9d8a6"), completion_panel)
	_label(Vector2(180, 97), "Light returns to Midgard", 18, Color("85e1e7"), completion_panel)
	results_label = _label(Vector2(205, 140), "", 16, Color("e0ece4"), completion_panel)
	_button(completion_panel, Vector2(200, 240), "Play again", func() -> void: restart_requested.emit()).name = "PlayAgain"
	_button(completion_panel, Vector2(200, 283), "Return to menu", func() -> void: menu_requested.emit())
	pause_panel = _panel()
	_label(Vector2(235, 65), "PAUSED", 28, Color("e9d8a6"), pause_panel)
	_button(pause_panel, Vector2(200, 135), "Resume", func() -> void: pause_requested.emit()).name = "Resume"
	_button(pause_panel, Vector2(200, 181), "Return to checkpoint", func() -> void: retry_requested.emit())
	_button(pause_panel, Vector2(200, 227), "Return to menu", func() -> void: menu_requested.emit())


func bind_state(health: Node, progress: Node, boss: Node2D) -> void:
	health.health_changed.connect(_update_health)
	progress.runes_changed.connect(_update_runes)
	progress.checkpoint_changed.connect(_update_checkpoint)
	boss.health.health_changed.connect(_update_boss_health)
	_enemy = boss
	_update_health(health.current_health, health.max_health)
	_update_runes(progress.rune_count, progress.rune_total)
	_update_boss_health(boss.health.current_health, boss.health.max_health)


func _update_health(current: int, maximum: int) -> void:
	hearts.update_health(current, maximum)


func _update_runes(current: int, total: int) -> void:
	runes_label.text = "RUNES %d / %d" % [current, total]
	objective_label.text = "Bridge gate open. Reach the Troll; find all 7 runes to complete the collection." if current >= 5 else "Find 5 runes to open the bridge. The hidden cave holds 2 optional runes."


func _update_checkpoint(id: StringName, _spawn: Vector2) -> void:
	checkpoint_label.text = "CHECKPOINT " + String(id).to_upper()


func _update_boss_health(current: int, maximum: int) -> void:
	boss_bar.max_value = maximum
	boss_bar.value = current


func show_message(text: String, duration: float = 3.0) -> void:
	message_label.text = text
	_message_left = duration


func show_completion(progress: Node) -> void:
	var time := int(progress.elapsed_seconds)
	results_label.text = "Runes: %d / %d\nDeaths: %d\nTime: %02d:%02d" % [progress.rune_count, progress.rune_total, progress.deaths, time / 60, time % 60]
	pause_panel.hide()
	completion_panel.show()
	completion_panel.get_node("PlayAgain").grab_focus()


func show_pause(value: bool) -> void:
	pause_panel.visible = value
	if value:
		pause_panel.get_node("Resume").grab_focus()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and not completion_panel.visible:
		pause_requested.emit()
	_message_left = maxf(0, _message_left - delta)
	message_label.visible = _message_left > 0
	if is_instance_valid(_enemy) and _enemy.attack.is_running() and boss_bar.visible:
		message_label.text = "TROLL / " + String(_enemy.attack.profile.attack_name).replace("_", " ").to_upper() + " / " + String(_enemy.attack.phase).to_upper()
		message_label.visible = true
