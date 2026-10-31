extends "res://tests/test_boss.gd"


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ticks="):
			tick_rate = int(arg.trim_prefix("--ticks="))
	Engine.physics_ticks_per_second = tick_rate
	check(ResourceLoader.exists("res://scenes/levels/combat_test.tscn"), "M3 combat room exists")
	if failures == 0:
		await test_room_lifecycle()
	await cleanup()
	OS.delay_msec(100)
	await process_frame
	print("COMBAT ROOM RESULT: ", checks, " checks, ", failures, " failures at ", tick_rate, " Hz")
	quit(1 if failures else 0)


func test_room_lifecycle() -> void:
	await cleanup()
	var menu: Control = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	menu.find_child("StartCombat", true, false).pressed.emit()
	await frames(2)
	var room := current_scene
	var actor: CharacterBody2D = room.get_node("Player")
	var hud = room.get_node("CombatHUD")
	await seconds(0.5)
	check(room.name == "CombatTest" and room.current_kind == &"draugr", "menu opens the Draugr combat trial")
	check(actor.is_on_floor() and actor.health.current_health == 3, "combat room starts with a safe full-health spawn")
	Input.action_press("trial_raven")
	await frames(2)
	Input.action_release("trial_raven")
	check(room.current_kind == &"raven" and room.enemy.health.current_health == 2, "selector switches to the Raven trial")
	Input.action_press("trial_troll")
	await frames(2)
	Input.action_release("trial_troll")
	check(room.current_kind == &"troll" and not hud.boss_bar.visible, "Troll selector starts before the boss intro")
	actor.position = Vector2(190, 320)
	await frames(3)
	check(room.enemy.state == &"intro" and hud.boss_bar.visible,
		"real intro trigger opens the boss health bar (state=%s visible=%s)" % [room.enemy.state, hud.boss_bar.visible])
	check(hud.boss_bar.max_value == 12 and hud.boss_bar.value == 12, "boss bar displays full Troll health")
	actor.position = Vector2(360, 320)
	actor.set_physics_process(false)
	check(await wait_phase(room.enemy, &"windup"), "combat-room Troll starts its patterns")
	room.enemy.health.take_damage(1)
	check(hud.boss_bar.value == 11, "boss health bar responds to actual damage")
	for index in tick_rate * 10:
		await frames(1)
		if room.bridge_broken:
			break
	check(room.bridge_broken and room.get_node("Terrain").get_cell_source_id(Vector2i(20, 20)) == -1,
		"charged smash removes the bounded bridge collision patch")
	actor.set_physics_process(true)
	Input.action_press("restart")
	await seconds(0.9)
	Input.action_release("restart")
	check(not room.bridge_broken and room.get_node("Terrain").get_cell_source_id(Vector2i(20, 20)) != -1,
		"retry restores the damaged bridge")
	check(room.enemy.state == &"dormant" and room.enemy.health.current_health == 12 and actor.health.current_health == 3,
		"retry resets boss, player health and introduction")
	room.enemy.start_encounter()
	room.enemy.health.kill()
	await seconds(1.0)
	check(room.exit_unlocked and room.trial_complete, "boss defeat unlocks the exit and completes the combat trial")
	check(not hud.boss_bar.visible and not room.enemy.attack.is_running(), "completion hides the boss bar and ends attacks")
	room.retry()
	await frames(2)
	check(not room.exit_unlocked and not room.trial_complete, "retry relocks the exit and clears victory state")
	actor.position = Vector2(80, 460)
	await seconds(0.9)
	check(not actor.health.is_dead() and absf(actor.position.x - 80) < 1 and room.death_count > 0,
		"falling in the combat room resets the current encounter")
	Input.action_press("pause")
	await frames(2)
	Input.action_release("pause")
	check(current_scene.name == "MainMenu", "M3 can return to the main menu")
	current_scene.queue_free()
	await process_frame
