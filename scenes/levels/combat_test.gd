extends Node2D

const ENEMIES := {
	&"draugr": preload("res://scenes/enemies/draugr.tscn"),
	&"raven": preload("res://scenes/enemies/raven.tscn"),
	&"troll": preload("res://scenes/bosses/bridge_troll.tscn")
}
const PLAYER_SPAWN := Vector2(80, 288)

@onready var player = $Player
@onready var hud = $CombatHUD
var enemy: CharacterBody2D
var current_kind: StringName = &"draugr"
var bridge_broken: bool = false
var exit_unlocked: bool = false
var trial_complete: bool = false
var death_count: int = 0
var _respawn_left: float = 0.0
var _victory_left: float = 0.0


func _ready() -> void:
	$Terrain.fill_platform(Rect2i(0, 20, 40, 4))
	$Terrain.fill_platform(Rect2i(-1, -4, 1, 28))
	$Terrain.fill_platform(Rect2i(40, -4, 1, 28))
	var camera: Camera2D = $Player/Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 640
	camera.limit_bottom = 360
	player.health.died.connect(_on_player_died)
	hud.bind_player(player.health)
	hud.selection_requested.connect(select_enemy)
	$BossTrigger.body_entered.connect(_on_intro_trigger)
	$Exit.body_entered.connect(_on_exit)
	select_enemy(&"draugr")


func select_enemy(kind: StringName) -> void:
	if not ENEMIES.has(kind):
		return
	death_count = 0
	current_kind = kind
	retry()


func retry() -> void:
	if is_instance_valid(enemy):
		enemy.attack.cancel()
		enemy.queue_free()
	bridge_broken = false
	$BridgeVisual.broken = false
	$Terrain.fill_platform(Rect2i(20, 20, 2, 4))
	exit_unlocked = false
	trial_complete = false
	_respawn_left = 0
	_victory_left = 0
	player.reset_to(PLAYER_SPAWN)
	enemy = ENEMIES[current_kind].instantiate()
	enemy.position = Vector2(410, 196) if current_kind == &"raven" else Vector2(440 if current_kind == &"troll" else 410, 320)
	add_child(enemy)
	enemy.defeated.connect(_on_enemy_defeated)
	hud.bind_enemy(enemy, current_kind)
	if current_kind == &"troll":
		enemy.encounter_started.connect(_on_boss_intro)
		enemy.bridge_smashed.connect(_on_bridge_smashed)
		hud.announce("Walk past the yellow banner to introduce the Bridge Troll.", 6.0)
	else:
		hud.announce("Amber = warning. Red = danger. Strike during recovery.", 6.0)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file("res://scenes/main/main.tscn")
		return
	for kind in ENEMIES:
		if Input.is_action_just_pressed("trial_" + String(kind)):
			select_enemy(kind)
			return
	if player.health.is_dead():
		_respawn_left = maxf(0, _respawn_left - delta)
		if _respawn_left <= 0:
			retry()
		return
	if Input.is_action_just_pressed("restart"):
		retry()
		return
	if player.position.y > 420:
		player.health.kill()
	if _victory_left > 0:
		_victory_left = maxf(0, _victory_left - delta)
		if _victory_left <= 0:
			trial_complete = true
			hud.announce("COMBAT TRIAL COMPLETE — R to replay, or choose another opponent.", 60.0)


func _on_player_died() -> void:
	death_count += 1
	_respawn_left = 0.65
	hud.announce("You fell — resetting this encounter...", 0.65)


func _on_intro_trigger(body: Node2D) -> void:
	if body == player and current_kind == &"troll" and not player.health.is_dead():
		enemy.start_encounter()


func _on_boss_intro() -> void:
	hud.announce("THE BRIDGE TROLL — jump the slam; punish recovery.", 3.0)


func _on_bridge_smashed(at: Vector2) -> void:
	# One bounded patch only, and only if the smash reaches it.
	if bridge_broken or absf(at.x - 336) > 92:
		return
	bridge_broken = true
	$BridgeVisual.broken = true
	for x in [20, 21]:
		for y in range(20, 24):
			$Terrain.erase_cell(Vector2i(x, y))
	hud.announce("Bridge planks shattered! Jump the marked gap.")


func _on_enemy_defeated(actor: Node2D) -> void:
	if actor != enemy:
		return
	exit_unlocked = current_kind == &"troll"
	_victory_left = 0.8
	hud.announce(String(current_kind).to_upper() + " DEFEATED!", 0.8)
	queue_redraw()


func _on_exit(body: Node2D) -> void:
	if body == player and exit_unlocked and not player.health.is_dead():
		trial_complete = true
		hud.announce("TROLL TRIAL COMPLETE — the exit is open. R to replay.", 60.0)


func _draw() -> void:
	if current_kind == &"troll":
		draw_line(Vector2(180, 246), Vector2(180, 320), Color("785b47"), 3)
		draw_rect(Rect2(181, 248, 19, 24), Color("eabb5b"))
		draw_rect(Rect2(606, 260, 7, 60), Color("85e1e7") if exit_unlocked else Color("a55252"))
