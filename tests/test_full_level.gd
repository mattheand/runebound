extends "res://tests/test_gameplay.gd"
## Known player-input route through the authored level. No teleports or cheats.

const ROUTE: Array[StringName] = [
	&"trail", &"steps", &"gap", &"trail", &"hops", &"trail",
	&"trail", &"steps", &"high", &"gap", &"ceiling", &"hops",
	&"high", &"gap", &"steps", &"hops", &"high", &"trail",
	&"trail", &"hops", &"gap", &"trail",
	&"trail", &"steps", &"gap", &"trail", &"hops", &"high", &"ceiling", &"trail",
	&"bridge", &"gap", &"bridge", &"hops", &"bridge", &"gap", &"bridge", &"trail"
]

var actor: CharacterBody2D
var route_failed: bool = false


func _run() -> void:
	var cave_only := false
	var main_only := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ticks="):
			tick_rate = int(arg.trim_prefix("--ticks="))
		cave_only = cave_only or arg == "--cave-only"
		main_only = main_only or arg == "--main-only"
	Engine.physics_ticks_per_second = tick_rate
	if not main_only:
		await traverse(true)
	if not cave_only:
		await traverse(false)
	await cleanup()
	OS.delay_msec(100)
	await process_frame
	print("FULL LEVEL RESULT: ", checks, " checks, ", failures, " failures at ", tick_rate, " Hz")
	quit(1 if failures else 0)


func traverse(visit_cave: bool) -> void:
	await cleanup()
	route_failed = false
	world = load("res://scenes/levels/troll_bridge.tscn").instantiate()
	root.add_child(world)
	actor = world.get_node("Player")
	await seconds(0.9)
	var index := 0
	while index < ROUTE.size() and not route_failed:
		if index == 18:
			if visit_cave:
				await visit_hidden_cave()
				index = 22
				continue
			else:
				await travel_to(18648, 480)
				await travel_to(18848, 480, true)
				await travel_to(19412, 480)
		else:
			await terrain_beat(index * 1024, 480, ROUTE[index])
		print("ROUTE BEAT: ", index, " cave_route=", visit_cave, " position=", actor.position,
			" hearts=", actor.health.current_health, " runes=", world.progress.rune_count,
			" time=", world.progress.elapsed_seconds)
		index += 1
	if not route_failed:
		check(world.progress.rune_count == (7 if visit_cave else 5), "input route collects the expected unique runes")
		check(world.get_node("BridgeGate").is_open, "input route opens the five-rune bridge gate")
		await fight_boss()
	if not route_failed:
		await travel_to(39808, 480)
		await press_interact()
		check(world.progress.completed and world.get_node("AdventureHUD").completion_panel.visible, "input route reaches the real exit and completion screen")
		check(world.progress.deaths == 0, "full-level input route succeeds without deaths or retries")
		check(world.visited_sections.has("Hidden Cave") == visit_cave, "optional cave route is tracked without being mandatory")
		check(world.visited_sections.has("Starting Forest") and world.visited_sections.has("Forest Cliffs") and world.visited_sections.has("Stave Church Vista") and world.visited_sections.has("Troll Bridge"), "input route traverses all main sections")
	print("FULL ROUTE METRIC: cave=", visit_cave, " seconds=", world.progress.elapsed_seconds,
		" runes=", world.progress.rune_count, " deaths=", world.progress.deaths, " completed=", world.progress.completed)


func terrain_beat(origin: float, floor_y: float, kind: StringName) -> void:
	if route_failed:
		return
	match kind:
		&"steps":
			await travel_to(origin + 210, floor_y)
			await travel_to(origin + 320, floor_y - 48, true)
			await travel_to(origin + 512, floor_y - 96, true)
			await travel_to(origin + 736, floor_y - 48, true)
		&"gap":
			await travel_to(origin + 400, floor_y)
			await travel_to(origin + 592, floor_y, true)
		&"high":
			await travel_to(origin + 380, floor_y)
			await travel_to(origin + 544, floor_y - 144, true, true)
			await travel_to(origin + 624, floor_y - 144)
			await travel_to(origin + 832, floor_y - 64, true)
		&"hops":
			await travel_to(origin + 270, floor_y)
			await travel_to(origin + 432, floor_y - 48, true)
			await travel_to(origin + 616, floor_y - 96, true)
			await dodge_guarding_raven()
			await travel_to(origin + 832, floor_y, true)
	await travel_to(origin + 980, floor_y)


func attack_if_close() -> void:
	if Input.is_action_pressed("attack"):
		Input.action_release("attack")
		return
	if actor.get_node("SwordCombat").is_attacking():
		return
	for enemy in world.get_node("Enemies").get_children():
		if not enemy.health.is_dead() and absf(enemy.position.x - actor.position.x) < 74 and absf(enemy.position.y - actor.position.y) < 100:
			Input.action_press("attack")
			return


func dodge_guarding_raven() -> void:
	if route_failed:
		return
	for enemy in world.get_node("Enemies").get_children():
		if not enemy.get_script().resource_path.ends_with("/raven.gd") or enemy.health.is_dead() or absf(enemy.position.x - actor.position.x) > 240:
			continue
		var jumped := false
		var used_air_jump := false
		for index in tick_rate * 3:
			if enemy.health.is_dead() or (enemy.state in [&"recovery", &"return", &"patrol"] and actor.is_on_floor()):
				break
			if not jumped and (enemy.state == &"dive" or (enemy.state == &"telegraph" and enemy.state_time >= 0.18)):
				Input.action_press("jump")
				jumped = true
			elif actor.velocity.y >= 0:
				if Input.is_action_pressed("jump"):
					Input.action_release("jump")
				elif jumped and not used_air_jump and enemy.state == &"dive":
					Input.action_press("jump")
					used_air_jump = true
			attack_if_close()
			await frames(1)
		Input.action_release("jump")
		await frames(1)


func travel_to(destination: float, floor_y: float, jump: bool = false, double_jump: bool = false) -> void:
	if route_failed:
		return
	var release_x := destination - (20.0 if jump else 0.0)
	Input.action_press("move_right")
	if jump:
		Input.action_press("jump")
	var did_release := false
	var did_double := false
	for index in tick_rate * 9:
		if double_jump and float(index) / tick_rate >= 0.24 and not did_release:
			Input.action_release("jump")
			did_release = true
		elif did_release and not did_double:
			Input.action_press("jump")
			did_double = true
		attack_if_close()
		await frames(1)
		if actor.position.x >= release_x or actor.health.is_dead():
			break
	Input.action_release("move_right")
	Input.action_release("jump")
	for index in ceili(tick_rate * 0.8):
		attack_if_close()
		await frames(1)
		if actor.is_on_floor() and absf(actor.velocity.x) < 1:
			break
	var arrived: bool = absf(actor.position.x - destination) < 48 and absf(actor.position.y - floor_y) < 3 and actor.is_on_floor() and world.progress.deaths == 0
	check(arrived, "route landing %s reached (actual %s)" % [Vector2(destination, floor_y), actor.position])
	route_failed = not arrived


func press_interact() -> void:
	Input.action_release("interact")
	await frames(1)
	Input.action_press("interact")
	await frames(1)
	Input.action_release("interact")
	await seconds(0.3)


func visit_hidden_cave() -> void:
	await travel_to(18664, 480)
	if route_failed:
		return
	for index in tick_rate * 3:
		if world.progress.cave_open:
			break
		if Input.is_action_pressed("attack"):
			Input.action_release("attack")
		elif not actor.get_node("SwordCombat").is_attacking():
			Input.action_press("attack")
		await frames(1)
	check(world.progress.cave_open, "input sword opens the concealed cave entrance")
	await travel_to(18704, 480)
	await press_interact()
	check(world.in_cave, "E takes the real cave passage")
	await terrain_beat(18432, 1024, &"steps")
	await travel_to(19968, 1024)
	await press_interact()
	check(world.progress.cave_switch_active, "input activates the cave puzzle switch")
	await travel_to(20436, 1024)
	await travel_to(21040, 1024)
	await travel_to(21376, 1024)
	await press_interact()
	check(not world.in_cave, "input cave exit returns to the main route")
	await travel_to(22508, 480)


func fight_boss() -> void:
	var opponent: CharacterBody2D = world.get_node("Boss")
	for index in tick_rate * 45:
		if opponent.health.is_dead() or actor.health.is_dead():
			break
		var direction := opponent.position.x - 52 - actor.position.x
		Input.action_release("move_left")
		Input.action_release("move_right")
		if absf(direction) > 12:
			Input.action_press("move_right" if direction > 0 else "move_left")
		elif actor.facing != 1:
			Input.action_press("move_right")
		if opponent.attack.phase == &"windup" and opponent.attack.elapsed >= opponent.attack.profile.windup - 0.32 and actor.is_on_floor():
			Input.action_press("jump")
		elif actor.velocity.y >= 0:
			Input.action_release("jump")
		if Input.is_action_pressed("attack"):
			Input.action_release("attack")
		elif not actor.get_node("SwordCombat").is_attacking() and absf(opponent.position.x - actor.position.x) < 74 and opponent.state not in [&"dormant", &"intro"]:
			Input.action_press("attack")
		await frames(1)
	for action in ["move_left", "move_right", "jump", "attack"]:
		Input.action_release(action)
	check(opponent.health.is_dead() and not actor.health.is_dead(), "full-level boss can be defeated with the standard sword and jumps")
	route_failed = not opponent.health.is_dead() or actor.health.is_dead()
	await seconds(1.0)
