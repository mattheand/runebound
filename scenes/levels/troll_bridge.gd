extends Node2D

const Layout = preload("res://scripts/resources/troll_bridge_layout.gd")
const RuneScene = preload("res://scenes/collectibles/rune.tscn")
const CheckpointScene = preload("res://scenes/interactables/checkpoint.tscn")
const GateScene = preload("res://scenes/interactables/rune_gate.tscn")
const ZoneScene = preload("res://scenes/interactables/interact_zone.tscn")
const StoneScene = preload("res://scenes/interactables/breakable_stone.tscn")
const Landmark = preload("res://scenes/levels/adventure_landmark.gd")
const EnemyScenes := {&"draugr": preload("res://scenes/enemies/draugr.tscn"), &"raven": preload("res://scenes/enemies/raven.tscn")}

@onready var player = $Player
@onready var progress = $LevelProgress
@onready var hud = $AdventureHUD
@onready var boss = $Boss
@onready var camera: Camera2D = $Player/Camera2D

var in_cave: bool = false
var current_section: String = ""
var visited_sections: Dictionary = {}
var arena_active: bool = false
var bridge_broken: bool = false
var _respawn_left: float = 0.0
var _victory_left: float = 0.0


func _ready() -> void:
	Layout.build($Terrain)
	_spawn_structures()
	_spawn_content()
	_spawn_landmarks()
	boss.tuning = boss.tuning.duplicate()
	boss.tuning.arena_left = Layout.ARENA_X + 120
	boss.tuning.arena_right = Layout.ARENA_X + 540
	boss.encounter_started.connect(_on_boss_intro)
	boss.bridge_smashed.connect(_on_bridge_smashed)
	boss.defeated.connect(_on_boss_defeated)
	$BossTrigger.body_entered.connect(_on_boss_trigger)
	progress.runes_changed.connect(_on_runes_changed)
	progress.world_state_changed.connect(_sync_world_state)
	player.health.died.connect(_on_player_died)
	hud.bind_state(player.health, progress, boss)
	hud.pause_requested.connect(_toggle_pause)
	hud.retry_requested.connect(_retry_from_pause)
	hud.restart_requested.connect(_restart_adventure)
	hud.menu_requested.connect(_return_to_menu)
	_set_camera_context()
	player.reset_to(progress.spawn_position)
	_sync_world_state()
	_update_section()
	hud.show_message("Restore five runes to cross the ancient bridge. Explore for all seven.", 6.0)


func _add_gate(node_name: String, at: Vector2, text: String) -> void:
	var gate: Node2D = GateScene.instantiate()
	gate.name = node_name
	gate.position = at
	gate.label_text = text
	add_child(gate)


func _add_zone(node_name: String, at: Vector2, action: StringName, hint: String) -> void:
	var zone: Node2D = ZoneScene.instantiate()
	zone.name = node_name
	zone.position = at
	zone.action_id = action
	zone.hint = hint
	$Interactions.add_child(zone)
	zone.requested.connect(_on_interaction)


func _spawn_structures() -> void:
	_add_gate("BridgeGate", Vector2(30600, 480), "5 RUNES")
	_add_gate("CaveGate", Vector2(20736, 1024), "RUNE SWITCH")
	_add_gate("ArenaGate", Vector2(Layout.ARENA_X, 480), "TROLL ARENA")
	_add_gate("ExitGate", Vector2(Layout.ARENA_X + 640, 480), "DEFEAT TROLL")
	var stone: Node2D = StoneScene.instantiate()
	stone.name = "CaveEntrance"
	stone.position = Vector2(18704, 480)
	add_child(stone)
	stone.shattered.connect(progress.open_cave)
	_add_zone("CaveEntry", Vector2(18704, 480), &"enter_cave", "[E] Inspect cracked stone")
	_add_zone("CaveReturn", Vector2(18480, 1024), &"return_cave", "[E] Return to the forest")
	_add_zone("CaveSwitch", Vector2(19968, 1024), &"cave_switch", "[E] Awaken the rune switch")
	_add_zone("CaveExit", Vector2(21376, 1024), &"leave_cave", "[E] Follow the light outside")
	_add_zone("LevelExit", Vector2(39808, 480), &"level_exit", "[E] Leave the Troll Bridge")


func _spawn_content() -> void:
	for index in Layout.RUNES.size():
		var data: Array = Layout.RUNES[index]
		var rune: Node2D = RuneScene.instantiate()
		rune.name = "Rune%d" % (index + 1)
		rune.rune_id = data[0]
		rune.position = data[1]
		$Runes.add_child(rune)
		rune.bind_progress(progress)
	for data in Layout.CHECKPOINTS:
		var checkpoint: Node2D = CheckpointScene.instantiate()
		checkpoint.name = data[0]
		checkpoint.checkpoint_id = data[1]
		checkpoint.position = data[2]
		$Checkpoints.add_child(checkpoint)
		checkpoint.activated.connect(_on_checkpoint)
	for index in Layout.ENEMIES.size():
		var data: Array = Layout.ENEMIES[index]
		var actor: Node2D = EnemyScenes[data[0]].instantiate()
		actor.name = "Enemy%d" % index
		actor.position = data[1]
		$Enemies.add_child(actor)


func _landmark(kind: StringName, at: Vector2, span: float = 128) -> void:
	var visual := Landmark.new()
	visual.kind = kind
	visual.position = at
	visual.span = span
	if kind == &"church":
		visual.scale = Vector2(0.75, 0.75)
	visual.z_index = 1 if kind == &"bridge" else -1
	$Scenery.add_child(visual)


func _sign(at: Vector2, text: String) -> void:
	var label := Label.new()
	label.position = at
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color("eee5c9"))
	label.add_theme_color_override("font_shadow_color", Color("17333e"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	$Scenery.add_child(label)


func _spawn_landmarks() -> void:
	for index in Layout.BEATS.size():
		_landmark(&"pine", Vector2(index * 1024 + 112, 480))
		if Layout.BEATS[index] == &"bridge":
			_landmark(&"bridge", Vector2(index * 1024 + 256, 480), 512)
	_landmark(&"cabin", Vector2(480, 480))
	_landmark(&"cabin", Vector2(5376, 480))
	_landmark(&"waterfall", Vector2(9712, 480))
	_landmark(&"waterfall", Vector2(17808, 480))
	_landmark(&"church", Vector2(25856, 430))
	_landmark(&"church", Vector2(30272, 440))
	_sign(Vector2(64, 354), "STARTING FOREST\nHold Space for height; press again for an air jump.")
	_sign(Vector2(3000, 360), "A RESTING STONE\nCheckpoints restore hearts. R returns here.")
	_sign(Vector2(6192, 350), "FOREST CLIFFS\nRead the enemy warnings. High stones need two jumps.")
	_sign(Vector2(18272, 360), "A cyan light leaks through the moss...\nTry your sword on the cracked stone.")
	_sign(Vector2(18504, 840), "HIDDEN CAVE\nFollow the runes. E operates the ancient mechanism.")
	_sign(Vector2(19904, 894), "A SEALED VAULT\nAwaken the nearby rune switch to open the way.")
	_sign(Vector2(22560, 350), "STAVE CHURCH VISTA\nThe old bridge lies beyond the valley.")
	_sign(Vector2(30336, 350), "THE RUNE GATE\nAny 5 of 7 runes open it. Two are hidden in the cave.")
	_sign(Vector2(30760, 354), "THE TROLL BRIDGE\nKeep your footing. Something heavy waits ahead.")
	_sign(Vector2(38512, 350), "THE FINAL REST\nTouch the checkpoint before facing the Troll.")


func _physics_process(delta: float) -> void:
	if progress.completed:
		return
	_update_section()
	_victory_left = maxf(0, _victory_left - delta)
	if player.health.is_dead():
		_respawn_left = maxf(0, _respawn_left - delta)
		if _respawn_left <= 0:
			_respawn()
		return
	# Surface falls must reset before they can land on the cave roof at y=784.
	if player.position.y > (1280 if in_cave else 720):
		player.health.kill()
	elif Input.is_action_just_pressed("restart"):
		_respawn()


func _update_section() -> void:
	var next := Layout.section_at(player.position.x, in_cave)
	if next != current_section:
		current_section = next
		visited_sections[next] = true
		hud.section_label.text = next


func _set_camera_context() -> void:
	camera.limit_left = Layout.ARENA_X if arena_active else Layout.CAVE_X if in_cave else 0
	camera.limit_right = Layout.ARENA_X + 640 if arena_active else Layout.CAVE_X + 3072 if in_cave else Layout.WORLD_WIDTH
	camera.limit_top = 160 if arena_active else 740 if in_cave else 0
	camera.limit_bottom = 520 if arena_active else 1280
	$Background/Landscape.cave = in_cave
	camera.reset_smoothing()


func _travel(at: Vector2, cave: bool) -> void:
	in_cave = cave
	player.global_position = at
	player.velocity = Vector2.ZERO
	player.get_node("SwordCombat").cancel()
	player.reset_physics_interpolation()
	_set_camera_context()
	_update_section()


func _on_interaction(action: StringName) -> void:
	if player.health.is_dead() or progress.completed:
		return
	match action:
		&"enter_cave":
			if progress.cave_open:
				_travel(Vector2(18528, 992), true)
			else:
				hud.show_message("The cracked entrance can be broken with your sword.")
		&"return_cave":
			_travel(Vector2(18768, 448), false)
		&"cave_switch":
			progress.activate_cave_switch()
			hud.show_message("The vault opens. The switch remains active after death.")
		&"leave_cave":
			if progress.cave_switch_active:
				_travel(Vector2(21888, 448), false)
		&"level_exit":
			if _victory_left <= 0 and progress.finish_level():
				_complete_level()


func _on_runes_changed(_current: int, _total: int) -> void:
	_sync_world_state()


func _sync_world_state() -> void:
	$BridgeGate.set_open(progress.bridge_gate_ready())
	$BridgeGate/Label.text = "RUNES %d / 5" % mini(progress.rune_count, 5)
	$CaveGate.set_open(progress.cave_switch_active)
	$CaveGate/Label.text = "VAULT OPEN" if progress.cave_switch_active else "RUNE SWITCH"
	$ExitGate.set_open(progress.boss_defeated)
	$ExitGate/Label.text = "EXIT OPEN" if progress.boss_defeated else "DEFEAT TROLL"
	$ArenaGate.set_open(not arena_active or progress.boss_defeated)
	$Interactions/CaveEntry.hint = "[E] Enter the hidden cave" if progress.cave_open else "Cracked stone: use J"


func _on_checkpoint(checkpoint: Area2D) -> void:
	if progress.activate_checkpoint(checkpoint.checkpoint_id, checkpoint.global_position + checkpoint.spawn_offset):
		for marker in $Checkpoints.get_children():
			marker.set_active(marker == checkpoint)
		player.health.heal(player.health.max_health)
		hud.show_message("Checkpoint saved — hearts restored; collected runes stay yours.")


func _on_player_died() -> void:
	progress.record_death()
	_respawn_left = 0.65
	hud.show_message("You fell — returning to " + String(progress.checkpoint_id) + ".", 0.65)


func _repair_bridge() -> void:
	bridge_broken = false
	$BossBridgeVisual.broken = false
	$Terrain.fill_platform(Rect2i(Layout.ARENA_X / 16 + 20, 30, 2, 12))


func _respawn() -> void:
	_respawn_left = 0
	arena_active = false
	in_cave = progress.checkpoint_in_cave
	for enemy in $Enemies.get_children():
		enemy.reset_enemy()
	if not progress.boss_defeated:
		boss.reset_enemy()
	hud.boss_bar.visible = false
	_repair_bridge()
	_sync_world_state()
	_set_camera_context()
	player.reset_to(progress.spawn_position)
	_update_section()
	hud.show_message("Back at " + String(progress.checkpoint_id) + " — runes and passages preserved.")


func _on_boss_trigger(body: Node2D) -> void:
	if body == player and not in_cave and not player.health.is_dead() and progress.bridge_gate_ready() and not progress.boss_defeated:
		boss.start_encounter()


func _on_boss_intro() -> void:
	arena_active = true
	_set_camera_context()
	_sync_world_state()
	hud.boss_bar.visible = true
	hud.show_message("THE BRIDGE TROLL — jump the slam, punish recovery.", 3.0)


func _on_bridge_smashed(at: Vector2) -> void:
	if bridge_broken or absf(at.x - (Layout.ARENA_X + 336)) > 92:
		return
	bridge_broken = true
	$BossBridgeVisual.broken = true
	for x in [Layout.ARENA_X / 16 + 20, Layout.ARENA_X / 16 + 21]:
		for y in range(30, 42):
			$Terrain.erase_cell(Vector2i(x, y))
	hud.show_message("The bridge is breaking — jump the gap!")


func _on_boss_defeated(_actor: Node2D) -> void:
	progress.mark_boss_defeated()
	arena_active = false
	_victory_left = 0.8
	hud.boss_bar.visible = false
	_set_camera_context()
	_sync_world_state()
	hud.objective_label.text = "The crossing is restored. Follow the light right and press E at the exit."
	hud.show_message("THE TROLL IS DEFEATED — the road beyond Midgard is open.", 6.0)


func _complete_level() -> void:
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.get_node("SwordCombat").cancel()
	for enemy in $Enemies.get_children():
		enemy.attack.cancel()
		enemy.set_physics_process(false)
	hud.show_completion(progress)


func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	hud.show_pause(get_tree().paused)


func _retry_from_pause() -> void:
	get_tree().paused = false
	hud.show_pause(false)
	_respawn()


func _restart_adventure() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _return_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
