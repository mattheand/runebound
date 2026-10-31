extends SceneTree

var failures: int = 0
var checks: int = 0
var tick_rate: int = 60
var world: Node2D
var damage_events: int = 0
var death_events: int = 0


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		printerr("FAIL: ", message)


func frames(count: int) -> void:
	for index in count:
		await physics_frame
		await process_frame


func seconds(duration: float) -> void:
	await frames(maxi(1, ceili(duration * tick_rate)))


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ticks="):
			tick_rate = int(arg.trim_prefix("--ticks="))
	Engine.physics_ticks_per_second = tick_rate
	check(ResourceLoader.exists("res://scripts/components/health_component.gd"), "reusable health component exists")
	if failures == 0:
		await test_health()
		await test_player_damage()
		check(ResourceLoader.exists("res://scenes/interactables/training_dummy.tscn"), "combat training fixture exists")
		if ResourceLoader.exists("res://scenes/interactables/training_dummy.tscn"):
			await test_sword_timing()
			await test_sword_direction_and_cancel()
			await test_hazard()
		check(ResourceLoader.exists("res://scenes/levels/gameplay_test.tscn"), "M2 playable scene exists")
		if ResourceLoader.exists("res://scenes/levels/gameplay_test.tscn"):
			await test_progress()
			await test_gameplay_flow()
	await cleanup()
	# --fixed-fps can finish faster than the audio mixing thread's next tick.
	# Let it release stopped WAV playbacks before SceneTree shutdown.
	OS.delay_msec(100)
	await process_frame
	print("M2 RESULT: ", checks, " checks, ", failures, " failures at ", tick_rate, " Hz")
	quit(1 if failures else 0)


func cleanup() -> void:
	for action in ["move_left", "move_right", "jump", "attack", "restart", "pause"]:
		Input.action_release(action)
	if is_instance_valid(world):
		world.queue_free()
		await process_frame
	damage_events = 0
	death_events = 0


func fixture() -> void:
	await cleanup()
	world = Node2D.new()
	root.add_child(world)
	var floor_body := StaticBody2D.new()
	floor_body.position = Vector2(300, 332)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(2000, 64)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	floor_body.add_child(collision)
	world.add_child(floor_body)


func make_player() -> CharacterBody2D:
	var actor: CharacterBody2D = load("res://scenes/player/player.tscn").instantiate()
	actor.position = Vector2(100, 280)
	actor.get_node("Camera2D").enabled = false
	world.add_child(actor)
	return actor


# Catches repeated damage during grace, invalid changes and duplicate death.
func test_health() -> void:
	await fixture()
	var health = load("res://scripts/components/health_component.gd").new()
	world.add_child(health)
	health.damaged.connect(func(_amount: int, _impulse: Vector2) -> void: damage_events += 1)
	health.died.connect(func() -> void: death_events += 1)
	check(health.current_health == 3 and not health.is_dead(), "health starts with three hearts")
	check(not health.take_damage(0) and not health.take_damage(-2), "nonpositive damage cannot alter health")
	check(health.take_damage(1) and health.current_health == 2, "damage removes one heart")
	check(not health.take_damage(1) and damage_events == 1, "invulnerability rejects repeated damage and feedback")
	health.heal(20)
	check(health.current_health == 3, "healing clamps to maximum hearts")
	health.heal(-1)
	check(health.current_health == 3, "negative healing cannot cause damage")
	await seconds(0.9)
	check(health.take_damage(1) and health.current_health == 2, "damage resumes after invulnerability expires")
	health.kill()
	health.kill()
	check(health.is_dead() and health.current_health == 0 and death_events == 1, "fatal damage emits death once, even during invulnerability")
	health.heal(3)
	check(not health.take_damage(1) and health.current_health == 0, "dead health cannot be healed or damaged")
	health.reset_health(0.2)
	check(health.current_health == 3 and not health.is_dead(), "respawn restores full health")
	check(not health.take_damage(1), "respawn grace prevents immediate repeat death")
	await seconds(0.25)
	check(health.take_damage(1), "respawn grace expires")


# Catches input cancelling knockback, retained motion after death or stale stun.
func test_player_damage() -> void:
	await fixture()
	var actor := make_player()
	await seconds(0.3)
	check(actor.has_node("HealthComponent"), "player owns reusable health")
	if not actor.has_node("HealthComponent"):
		return
	var health = actor.get_node("HealthComponent")
	Input.action_press("move_right")
	health.take_damage(1, Vector2(-220, -180))
	await frames(1)
	check(actor.velocity.x < -100 and actor.velocity.y < 0, "accepted damage applies knockback despite held movement input")
	await seconds(0.3)
	check(actor.velocity.x > 0, "player regains steering after short damage stun")
	health.kill()
	var death_position := actor.position
	Input.action_press("jump")
	Input.action_press("attack")
	await seconds(0.2)
	check(actor.position.distance_to(death_position) < 1 and actor.velocity == Vector2.ZERO, "death suppresses movement and jump input")
	actor.reset_to(Vector2(100, 280))
	check(not health.is_dead() and health.current_health == 3 and actor.velocity == Vector2.ZERO, "reset restores player health and clears momentum")


func make_target(at: Vector2, stationary: bool = true) -> CharacterBody2D:
	var target: CharacterBody2D = load("res://scenes/interactables/training_dummy.tscn").instantiate()
	target.position = at
	world.add_child(target)
	if stationary:
		target.set_physics_process(false)
	return target


# Catches always-on hitboxes, multiple hurtbox damage and held-button repeats.
func test_sword_timing() -> void:
	await fixture()
	var actor := make_player()
	var target := make_target(Vector2(132, 300))
	var extra: Area2D = target.get_node("Hurtbox").duplicate()
	target.add_child(extra)
	await seconds(0.3)
	var health = target.get_node("HealthComponent")
	check(health.current_health == 3, "idle sword overlap does no damage")
	Input.action_press("attack")
	await frames(1)
	check(health.current_health == 3, "sword wind-up does no damage")
	await seconds(0.12)
	check(health.current_health == 2, "active sword window hits once even with multiple hurtboxes")
	check(target.velocity.x > 0 and target.velocity.y < 0, "sword hit delivers directional knockback")
	check(actor.health.current_health == 3, "sword ignores the wielder's hurtbox")
	Input.action_release("attack")
	await frames(1)
	Input.action_press("attack")
	await seconds(0.1)
	check(health.current_health == 2, "recovery prevents an immediate second swing")
	await seconds(0.7)
	check(health.current_health == 2, "holding attack does not repeatedly swing")
	Input.action_release("attack")
	await frames(1)
	Input.action_press("attack")
	await seconds(0.15)
	check(health.current_health == 1, "next fresh swing can damage the same target again")
	await seconds(0.4)
	Input.action_release("attack")
	await frames(1)
	Input.action_press("attack")
	await seconds(0.15)
	check(health.is_dead() and not target.visible, "three sword hits defeat a training target")
	target.reset_target()
	check(health.current_health == 3 and target.visible, "training target resets for another attempt")


func test_sword_direction_and_cancel() -> void:
	await fixture()
	var actor := make_player()
	var left := make_target(Vector2(68, 300))
	var right := make_target(Vector2(132, 300))
	await seconds(0.3)
	actor.facing = -1
	Input.action_press("attack")
	await frames(1)
	actor.facing = 1
	await seconds(0.12)
	check(left.get_node("HealthComponent").current_health == 2 and right.get_node("HealthComponent").current_health == 3,
		"swing facing is locked at start and cannot hit behind the player")
	await fixture()
	actor = make_player()
	right = make_target(Vector2(200, 300))
	await seconds(0.3)
	Input.action_press("attack")
	await frames(1)
	actor.health.kill()
	right.position.x = 132
	await seconds(0.3)
	check(right.get_node("HealthComponent").current_health == 3, "death cancels a pending sword hit")
	check(not actor.get_node("SwordCombat").is_attacking(), "death clears attack state")


func test_hazard() -> void:
	await fixture()
	var actor := make_player()
	var hazard: Area2D = load("res://scenes/interactables/damage_hazard.tscn").instantiate()
	hazard.position = Vector2(100, 300)
	world.add_child(hazard)
	# Hold the actor over the hazard to test sustained contact, not re-entry.
	actor.set_physics_process(false)
	actor.position.y = 300
	await seconds(0.15)
	check(actor.health.current_health == 2, "real hazard overlap damages the player")
	await seconds(0.3)
	check(actor.health.current_health == 2, "continuous hazard overlap respects invulnerability")
	await seconds(0.6)
	check(actor.health.current_health == 1, "hazard contact can damage again when grace expires")


# Catches ID duplicates, unregistered pickups and lost checkpoint positions.
func test_progress() -> void:
	await fixture()
	var progress = load("res://scripts/components/level_progress.gd").new()
	world.add_child(progress)
	check(not progress.register_rune(&""), "empty rune IDs cannot register")
	check(progress.register_rune(&"a") and not progress.register_rune(&"a"), "duplicate rune IDs cannot inflate the total")
	progress.register_rune(&"b")
	check(not progress.collect_rune(&"unknown") and progress.rune_count == 0, "unregistered runes cannot increment the counter")
	check(progress.collect_rune(&"a") and not progress.collect_rune(&"a"), "a rune can only be collected once")
	check(progress.rune_count == 1 and progress.rune_total == 2, "rune counters reflect unique IDs")
	check(progress.activate_checkpoint(&"bridge", Vector2(200, 100)), "first checkpoint stores a new respawn")
	check(not progress.activate_checkpoint(&"bridge", Vector2(900, 900)) and progress.spawn_position == Vector2(200, 100),
		"repeat checkpoint activation is idempotent")
	check(progress.activate_checkpoint(&"lookout", Vector2(400, 100)) and progress.spawn_position == Vector2(400, 100),
		"later checkpoint replaces the respawn position")
	check(progress.rune_count == 1, "changing checkpoints preserves collected runes")


# The actual menu/scene exercises pickup, checkpoint, death and HUD wiring.
func test_gameplay_flow() -> void:
	await cleanup()
	var menu: Control = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	menu.find_child("StartGameplay", true, false).pressed.emit()
	await frames(2)
	var course := current_scene
	check(course.name == "GameplayTest", "menu opens M2 gameplay")
	var actor: CharacterBody2D = course.get_node("Player")
	var progress = course.get_node("LevelProgress")
	var hud = course.get_node("GameplayHUD")
	await seconds(0.9)
	check(actor.is_on_floor() and actor.health.current_health == 3, "M2 spawns safely with three hearts")
	check(progress.rune_total == 5 and hud.runes_label.text.ends_with("0 / 5"), "HUD initializes with scene rune total")
	var rune: Area2D = course.get_node("Runes/Rune1")
	actor.position = rune.position + Vector2(0, 16)
	await frames(3)
	check(progress.rune_count == 1 and not rune.visible and hud.runes_label.text.ends_with("1 / 5"), "real rune overlap consumes pickup and updates HUD")
	var duplicate: Area2D = load("res://scenes/collectibles/rune.tscn").instantiate()
	duplicate.rune_id = rune.rune_id
	duplicate.position = actor.position
	course.add_child(duplicate)
	duplicate.bind_progress(progress)
	await frames(2)
	check(progress.rune_count == 1 and progress.rune_total == 5 and not duplicate.visible, "duplicate pickup instance stays consumed without adding progress")
	var first: Area2D = course.get_node("Checkpoints/Checkpoint1")
	actor.position = first.position
	await frames(3)
	check(progress.checkpoint_id == &"bridge" and first.active, "checkpoint activates through player contact")
	var saved: Vector2 = progress.spawn_position
	actor.health.take_damage(1, Vector2(-200, -100))
	check(hud.health_label.text == "2 / 3" and hud.hearts.current == 2, "HUD updates when a heart is lost")
	actor.health.kill()
	Input.action_press("attack")
	await seconds(0.2)
	check(actor.health.is_dead() and not actor.get_node("SwordCombat").is_attacking(), "death feedback delay prevents attacks before respawn")
	await seconds(0.65)
	Input.action_release("attack")
	check(not actor.health.is_dead() and actor.health.current_health == 3 and absf(actor.position.x - saved.x) < 1,
		"death respawns at the active checkpoint with full health")
	check(progress.rune_count == 1 and not rune.visible and hud.runes_label.text.ends_with("1 / 5"), "runes and HUD persist correctly through death")
	check(hud.health_label.text == "3 / 3" and hud.hearts.current == 3, "respawn restores the HUD hearts")
	var second: Area2D = course.get_node("Checkpoints/Checkpoint2")
	actor.position = second.position
	await frames(3)
	check(progress.checkpoint_id == &"lookout" and second.active and not first.active, "new checkpoint deactivates old marker")
	var dummy = course.get_node("TrainingTargets/Dummy1")
	dummy.get_node("HealthComponent").kill()
	actor.position.x += 80
	Input.action_press("restart")
	await frames(1)
	Input.action_release("restart")
	check(absf(actor.position.x - second.position.x) < 1 and actor.velocity.length() < 80,
		"R clears momentum and returns to the latest checkpoint")
	check(dummy.visible and dummy.get_node("HealthComponent").current_health == 3, "respawn resets defeated training props")
	actor.position.y = 900
	await seconds(0.9)
	check(not actor.health.is_dead() and absf(actor.position.x - second.position.x) < 1, "falling uses the same checkpoint death and respawn flow")
	Input.action_press("pause")
	await frames(2)
	Input.action_release("pause")
	check(current_scene.name == "MainMenu", "M2 Escape returns to the main menu")
	current_scene.find_child("StartGameplay", true, false).pressed.emit()
	await frames(2)
	check(current_scene.get_node("LevelProgress").rune_count == 0 and current_scene.get_node("LevelProgress").checkpoint_id == &"start",
		"a new session clears rune and checkpoint progress")
	current_scene.queue_free()
	await process_frame
