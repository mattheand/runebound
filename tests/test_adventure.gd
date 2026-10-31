extends "res://tests/test_gameplay.gd"


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ticks="):
			tick_rate = int(arg.trim_prefix("--ticks="))
	Engine.physics_ticks_per_second = tick_rate
	check(ResourceLoader.exists("res://scripts/components/adventure_progress.gd"), "M4 progress component exists")
	if failures == 0:
		await test_adventure_progress()
		await test_level_interactions()
		check(ResourceLoader.exists("res://scenes/levels/troll_bridge.tscn"), "complete Troll Bridge scene exists")
		if ResourceLoader.exists("res://scenes/levels/troll_bridge.tscn"):
			await test_adventure_lifecycle()
			await test_surface_fall_above_cave()
	await cleanup()
	OS.delay_msec(100)
	await process_frame
	print("ADVENTURE RESULT: ", checks, " checks, ", failures, " failures at ", tick_rate, " Hz")
	quit(1 if failures else 0)


func test_adventure_progress() -> void:
	await fixture()
	var progress = load("res://scripts/components/adventure_progress.gd").new()
	world.add_child(progress)
	for index in 7:
		progress.register_rune(StringName("rune_%d" % index))
	for index in 4:
		progress.collect_rune(StringName("rune_%d" % index))
	check(not progress.bridge_gate_ready(), "four runes cannot open the bridge gate")
	progress.collect_rune(&"rune_4")
	check(progress.bridge_gate_ready() and progress.rune_count == 5, "any five unique runes open the bridge gate")
	progress.open_cave()
	progress.activate_cave_switch()
	progress.activate_checkpoint(&"cave", Vector2(18560, 992))
	progress.record_death()
	check(progress.rune_count == 5 and progress.cave_open and progress.cave_switch_active, "death preserves runes and permanent cave progress")
	check(progress.deaths == 1 and progress.checkpoint_in_cave, "cave checkpoint records respawn context and death count")
	check(not progress.finish_level(), "completion is rejected before boss defeat")
	progress.mark_boss_defeated()
	await seconds(0.2)
	check(progress.finish_level() and not progress.finish_level(), "boss defeat permits one completion only")
	var completed_time: float = progress.elapsed_seconds
	await seconds(0.2)
	check(progress.elapsed_seconds == completed_time, "completion freezes the level timer")
	var fresh = load("res://scripts/components/adventure_progress.gd").new()
	world.add_child(fresh)
	check(fresh.rune_count == 0 and fresh.deaths == 0 and not fresh.cave_open and not fresh.boss_defeated, "fresh session starts without carried world flags")


func test_level_interactions() -> void:
	await fixture()
	var actor := make_player()
	var gate: StaticBody2D = load("res://scenes/interactables/rune_gate.tscn").instantiate()
	gate.position = Vector2(180, 300)
	world.add_child(gate)
	await seconds(0.3)
	Input.action_press("move_right")
	await seconds(0.6)
	check(actor.position.x < 165, "closed rune gate physically blocks passage")
	gate.set_open(true)
	await seconds(0.4)
	check(actor.position.x > 190, "opened rune gate permits passage")
	Input.action_release("move_right")
	await fixture()
	actor = make_player()
	var stone = load("res://scenes/interactables/breakable_stone.tscn").instantiate()
	stone.position = Vector2(138, 300)
	world.add_child(stone)
	await seconds(0.3)
	for index in 2:
		Input.action_press("attack")
		await seconds(0.45)
		Input.action_release("attack")
		await frames(1)
	check(stone.broken and stone.get_node("CollisionShape2D").disabled, "normal sword swings open the breakable cave entrance")
	var zone = load("res://scenes/interactables/interact_zone.tscn").instantiate()
	zone.position = actor.position
	zone.action_id = &"cave_switch"
	world.add_child(zone)
	var actions: Array[StringName] = []
	zone.requested.connect(func(id: StringName) -> void: actions.append(id))
	await frames(3)
	check(actions.is_empty(), "interaction zones do not activate just by overlap")
	Input.action_press("interact")
	await frames(1)
	Input.action_release("interact")
	check(actions == [&"cave_switch"], "E activates the nearby interaction zone once")
	actor.health.kill()
	await frames(1)
	Input.action_press("interact")
	await frames(1)
	Input.action_release("interact")
	check(actions.size() == 1, "dead players cannot operate world switches")


func interact() -> void:
	Input.action_release("interact")
	await frames(1)
	Input.action_press("interact")
	await frames(1)
	Input.action_release("interact")
	await frames(2)


func test_adventure_lifecycle() -> void:
	await cleanup()
	var menu: Control = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	menu.find_child("StartAdventure", true, false).pressed.emit()
	await frames(2)
	world = current_scene
	var actor: CharacterBody2D = world.get_node("Player")
	var progress = world.get_node("LevelProgress")
	var hud = world.get_node("AdventureHUD")
	await seconds(1.0)
	check(world.name == "TrollBridge" and actor.is_on_floor() and progress.rune_total == 7, "M4 starts safely and registers exactly seven runes")
	Input.action_press("pause")
	await frames(2)
	Input.action_release("pause")
	var paused_time: float = progress.elapsed_seconds
	var paused_position := actor.position
	Input.action_press("move_right")
	await seconds(0.2)
	check(paused and progress.elapsed_seconds == paused_time and actor.position == paused_position, "pause freezes level time and player movement")
	Input.action_release("move_right")
	Input.action_press("pause")
	await frames(2)
	Input.action_release("pause")
	check(not paused and not hud.pause_panel.visible, "Escape resumes the same adventure")
	check(not world.get_node("BridgeGate").is_open and not world.get_node("ExitGate").is_open, "bridge and exit progression gates start locked")
	var rune: Area2D = world.get_node("Runes/Rune1")
	actor.reset_to(rune.global_position + Vector2(0, 16))
	await seconds(0.3)
	check(progress.rune_count == 1 and not rune.visible, "M4 rune pickup updates session progress")
	var checkpoint: Area2D = world.get_node("Checkpoints/Forest")
	await seconds(0.9)
	actor.health.take_damage(1)
	actor.position = checkpoint.global_position
	await frames(3)
	check(progress.checkpoint_id == &"forest" and actor.health.current_health == 3, "first checkpoint activation restores health and records a spawn")
	actor.health.kill()
	await seconds(0.9)
	check(progress.deaths == 1 and absf(actor.position.x - checkpoint.position.x) < 1 and progress.rune_count == 1,
		"death returns to a checkpoint without losing runes")
	var entry = world.get_node("Interactions/CaveEntry")
	actor.reset_to(entry.global_position + Vector2(-30, 0))
	await frames(3)
	await interact()
	check(not world.in_cave, "closed cracked entrance prevents cave travel")
	world.get_node("CaveEntrance/HealthComponent").kill()
	await frames(2)
	await seconds(0.9)
	actor.health.take_damage(1)
	await interact()
	check(world.in_cave and progress.cave_open and actor.health.current_health == 2, "opened cave passage travels without healing or losing progress")
	checkpoint = world.get_node("Checkpoints/Cave")
	actor.position = checkpoint.global_position
	await frames(3)
	check(progress.checkpoint_in_cave and world.current_section == "Hidden Cave", "cave checkpoint saves the lower-route context")
	actor.position = world.get_node("Interactions/CaveSwitch").global_position
	await frames(3)
	await interact()
	check(progress.cave_switch_active and world.get_node("CaveGate").is_open, "cave rune switch opens its puzzle gate")
	actor.health.kill()
	await seconds(0.9)
	check(world.in_cave and world.get_node("CaveGate").is_open and progress.cave_open, "cave death restores camera context and preserves opened passages")
	actor.position = world.get_node("Interactions/CaveExit").global_position
	await frames(3)
	await interact()
	check(not world.in_cave and actor.position.y < 800, "cave exit reconnects to the main route")
	for pickup in world.get_node("Runes").get_children():
		progress.collect_rune(pickup.rune_id)
	await frames(2)
	check(progress.rune_count == 7 and world.get_node("BridgeGate").is_open, "rune threshold opens the bridge without losing optional rewards")
	checkpoint = world.get_node("Checkpoints/Bridge")
	actor.position = checkpoint.global_position
	await frames(3)
	actor.position = Vector2(39102, 480)
	await frames(3)
	check(world.get_node("Boss").state == &"intro" and not world.get_node("ArenaGate").is_open, "boss trigger starts the introduction and closes the arena")
	check(hud.boss_bar.visible and actor.get_node("Camera2D").limit_left == 38912, "boss intro switches camera bounds and displays boss health")
	world.get_node("Boss").bridge_smashed.emit(Vector2(39248, 480))
	await frames(2)
	check(world.bridge_broken and world.get_node("Terrain").get_cell_source_id(Vector2i(2452, 30)) == -1 and world.get_node("Terrain").get_cell_source_id(Vector2i(2452, 41)) == -1,
		"boss smash removes the full-depth adventure bridge columns")
	actor.health.kill()
	await seconds(0.9)
	check(world.get_node("Boss").state == &"dormant" and world.get_node("ArenaGate").is_open and progress.rune_count == 7,
		"boss retry resets arena state while preserving adventure progress")
	check(not world.bridge_broken and world.get_node("Terrain").get_cell_source_id(Vector2i(2452, 30)) != -1 and world.get_node("Terrain").get_cell_source_id(Vector2i(2452, 41)) != -1,
		"boss retry repairs both top and bottom of the adventure bridge")
	world.get_node("Boss").start_encounter()
	world.get_node("Boss/HealthComponent").kill()
	await seconds(1.0)
	check(progress.boss_defeated and world.get_node("ExitGate").is_open, "Troll defeat unlocks the level exit")
	actor.health.kill()
	await seconds(0.9)
	check(world.get_node("Boss/HealthComponent").is_dead() and world.get_node("ExitGate").is_open and progress.rune_count == 7,
		"death after victory preserves boss defeat, exit access and runes")
	actor.position = world.get_node("Interactions/LevelExit").global_position
	await frames(3)
	await interact()
	check(progress.completed and hud.completion_panel.visible, "unlocked exit opens the completion screen")
	check(hud.results_label.text.contains("7 / 7") and hud.results_label.text.contains("Deaths: 4"), "completion shows rune count and actual deaths")
	var time: float = progress.elapsed_seconds
	await seconds(0.2)
	check(progress.elapsed_seconds == time, "completion leaves the elapsed time frozen")
	hud.restart_requested.emit()
	await frames(3)
	world = current_scene
	check(world.get_node("LevelProgress").rune_count == 0 and not world.get_node("LevelProgress").boss_defeated, "completion restart begins a fresh adventure")
	world.get_node("AdventureHUD").menu_requested.emit()
	await frames(3)
	check(current_scene.name == "MainMenu", "adventure UI can return to the main menu")
	current_scene.queue_free()
	await process_frame


func test_surface_fall_above_cave() -> void:
	await cleanup()
	world = load("res://scenes/levels/troll_bridge.tscn").instantiate()
	root.add_child(world)
	var actor: CharacterBody2D = world.get_node("Player")
	var checkpoint: Area2D = world.get_node("Checkpoints/Falls")
	actor.position = checkpoint.global_position
	await frames(3)
	world.progress.collect_rune(&"forest_bough")
	actor.position = Vector2(20976, 480)
	actor.velocity = Vector2.ZERO
	await seconds(1.7)
	check(world.progress.deaths == 1 and absf(actor.position.x - checkpoint.position.x) < 1 and actor.is_on_floor(),
		"surface pit above cave roof automatically respawns instead of stranding the player")
	check(not world.in_cave and world.progress.rune_count == 1, "surface fall recovery preserves rune progress and main-route context")
