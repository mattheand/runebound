extends Control


func _ready() -> void:
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	column.position = Vector2(-170, -157)
	column.size = Vector2(340, 314)
	column.add_theme_constant_override("separation", 8)
	add_child(column)
	_add_label(column, "R U N E B O U N D", 30, Color("e9d8a6"))
	_add_label(column, "THE NINE REALMS", 14, Color("72c7d0"))
	_add_label(column, "M3  •  Enemies & boss combat trials", 14, Color("bbced6"))
	var combat := Button.new()
	combat.name = "StartCombat"
	combat.text = "Combat trials (M3)"
	combat.custom_minimum_size.y = 34
	combat.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/levels/combat_test.tscn"))
	column.add_child(combat)
	combat.grab_focus()
	var start := Button.new()
	start.name = "StartGameplay"
	start.text = "Gameplay training (M2)"
	start.custom_minimum_size.y = 32
	start.pressed.connect(_start)
	column.add_child(start)
	var movement := Button.new()
	movement.name = "MovementButton"
	movement.text = "Movement playground (M1)"
	movement.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/levels/movement_test.tscn"))
	column.add_child(movement)
	_add_label(column, "A / D · Space to jump twice · J for sword", 13, Color("bbced6"))
	if not OS.has_feature("web"):
		var quit_button := Button.new()
		quit_button.text = "Quit"
		quit_button.pressed.connect(get_tree().quit)
		column.add_child(quit_button)


func _add_label(parent: Node, text: String, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)


func _start() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/gameplay_test.tscn")


func _draw() -> void:
	draw_rect(Rect2(0, 0, size.x, size.y), Color("132c3c"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 300), Vector2(100, 122), Vector2(195, 278),
		Vector2(325, 82), Vector2(490, 270), Vector2(565, 150),
		Vector2(640, 265), Vector2(640, 360), Vector2(0, 360)
	]), Color("25475a"))
	draw_rect(Rect2(0, 328, 640, 32), Color("193c47"))
