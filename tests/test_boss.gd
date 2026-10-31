extends "res://tests/test_enemies.gd"

var bridge_events: Array[Vector2] = []


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ticks="):
			tick_rate = int(arg.trim_prefix("--ticks="))
	Engine.physics_ticks_per_second = tick_rate
	check(ResourceLoader.exists("res://scenes/bosses/bridge_troll.tscn"), "Bridge Troll scene exists")
	if failures == 0:
		await test_troll_lifecycle()
		await test_troll_patterns()
	await cleanup()
	OS.delay_msec(100)
	await process_frame
	print("BOSS RESULT: ", checks, " checks, ", failures, " failures at ", tick_rate, " Hz")
	quit(1 if failures else 0)


func wait_phase(enemy: Node, desired: StringName, timeout_seconds: float = 3.0) -> bool:
	for index in ceili(tick_rate * timeout_seconds):
		await frames(1)
		if enemy.attack.phase == desired:
			return true
	return false


func test_troll_lifecycle() -> void:
	await fixture()
	var actor := make_player()
	actor.position = Vector2(340, 300)
	actor.set_physics_process(false)
	var troll := spawn_enemy("res://scenes/bosses/bridge_troll.tscn", Vector2(400, 300))
	await seconds(0.3)
	check(troll.state == &"dormant" and not troll.attack.is_running(), "Troll stays dormant before its encounter trigger")
	check(not troll.health.take_damage(1), "dormant Troll cannot be damaged before introduction")
	check(troll.start_encounter() and not troll.start_encounter(), "Troll introduction starts once")
	await seconds(0.5)
	check(troll.state == &"intro" and not troll.attack.is_running() and actor.health.current_health == 3, "Troll intro has no active attacks")
	check(not troll.health.take_damage(1), "Troll intro protection lasts through the introduction")
	check(await wait_phase(troll, &"windup"), "Troll becomes active after its introduction")
	check(troll.health.take_damage(1, Vector2(-999, -999)) and troll.health.current_health == 11, "active Troll takes standard damage")
	check(troll.state != &"hurt" and troll.velocity.length() < 100, "Troll hit feedback does not permit knockback stun-lock")
	defeated_count = 0
	troll.defeated.connect(func(_actor: Node2D) -> void: defeated_count += 1)
	troll.health.kill()
	var death_position := troll.position
	await seconds(1.5)
	check(troll.state == &"dead" and troll.position == death_position and not troll.attack.is_running(), "defeated Troll stops movement and all attacks")
	check(defeated_count == 1 and not troll.visible, "Troll defeat is emitted once and its death sequence completes")
	troll.reset_enemy()
	check(troll.state == &"dormant" and troll.health.current_health == 12 and not troll.health.take_damage(1), "retry fully resets Troll health and encounter state")


func test_troll_patterns() -> void:
	await fixture()
	var actor := make_player()
	actor.position = Vector2(340, 300)
	actor.set_physics_process(false)
	var troll := spawn_enemy("res://scenes/bosses/bridge_troll.tscn", Vector2(400, 300))
	bridge_events.clear()
	troll.bridge_smashed.connect(func(at: Vector2) -> void: bridge_events.append(at))
	troll.start_encounter()
	for expected in [&"ground_slam", &"club_swing", &"charged_smash"]:
		check(await wait_phase(troll, &"windup"), "Troll telegraphs " + String(expected))
		check(troll.attack.profile.attack_name == expected, "Troll uses predictable attack order: " + String(expected))
		var hearts: int = actor.health.current_health
		await seconds(0.15)
		check(actor.health.current_health == hearts, "no early damage during " + String(expected))
		check(await wait_phase(troll, &"active"), "Troll opens the active window for " + String(expected))
		await frames(1)
		check(actor.health.current_health == hearts - 1, "Troll attack deals one hit: " + String(expected))
		check(await wait_phase(troll, &"recovery"), "Troll exposes recovery after " + String(expected))
		check(not troll.attack.get_node("Hitbox").active, "recovery disables Troll damage")
		actor.health.heal(3)
		check(await wait_state(troll, &"chase", 2.0), "Troll finishes recovery before choosing the next pattern")
	check(bridge_events.size() == 1, "only the charged smash emits a bridge-damage event")
	actor.health.kill()
	await seconds(0.2)
	check(not troll.attack.is_running(), "Troll stops attacking a dead player")
