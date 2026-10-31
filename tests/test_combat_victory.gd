extends "res://tests/test_gameplay.gd"
## Input-only fights using the shipped player, tuning, health and sword.


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ticks="):
			tick_rate = int(arg.trim_prefix("--ticks="))
	Engine.physics_ticks_per_second = tick_rate
	for kind in [&"draugr", &"raven", &"troll"]:
		await fight(kind)
	await cleanup()
	OS.delay_msec(100)
	await process_frame
	print("COMBAT VICTORY RESULT: ", checks, " checks, ", failures, " failures at ", tick_rate, " Hz")
	quit(1 if failures else 0)


func fight(kind: StringName) -> void:
	await cleanup()
	world = load("res://scenes/levels/combat_test.tscn").instantiate()
	root.add_child(world)
	world.select_enemy(kind)
	await seconds(0.9)
	var actor: CharacterBody2D = world.get_node("Player")
	var opponent: CharacterBody2D = world.enemy
	var elapsed := 0.0
	for index in tick_rate * 40:
		if opponent.health.is_dead() or actor.health.is_dead():
			break
		elapsed = float(index) / tick_rate
		var desired_x := opponent.position.x - (52 if kind == &"troll" else 30)
		var direction := desired_x - actor.position.x
		Input.action_release("move_left")
		Input.action_release("move_right")
		if absf(direction) > 12:
			Input.action_press("move_right" if direction > 0 else "move_left")
		elif actor.facing != (1 if opponent.position.x > actor.position.x else -1):
			# Tap toward the opponent to face the sword correctly after braking.
			Input.action_press("move_right" if opponent.position.x > actor.position.x else "move_left")
		if kind == &"raven" and actor.is_on_floor() and absf(direction) < 160:
			Input.action_press("jump")
		elif kind == &"troll" and opponent.attack.phase == &"windup" and opponent.attack.elapsed >= opponent.attack.profile.windup - 0.32 and actor.is_on_floor():
			Input.action_press("jump")
		elif actor.velocity.y >= 0:
			Input.action_release("jump")
		# Fresh presses only; the normal sword enforces wind-up and cooldown.
		if Input.is_action_pressed("attack"):
			Input.action_release("attack")
		elif not actor.get_node("SwordCombat").is_attacking() and absf(opponent.position.x - actor.position.x) < 74 and opponent.state not in [&"dormant", &"intro"]:
			Input.action_press("attack")
		await frames(1)
	for action in ["move_left", "move_right", "jump", "attack"]:
		Input.action_release(action)
	print("FIGHT: ", kind, " time=", elapsed, " player_hp=", actor.health.current_health,
		" enemy_hp=", opponent.health.current_health, " player=", actor.position, " enemy=", opponent.position, " state=", opponent.state)
	check(opponent.health.is_dead(), String(kind) + " can be defeated using ordinary movement, jump and sword input")
	check(not actor.health.is_dead() and world.death_count == 0 and actor.health.max_health == 3,
		String(kind) + " fight succeeds with standard three-heart health and no retries")
	await seconds(1.0)
	check(world.trial_complete, String(kind) + " input-only victory completes the trial")
	if kind == &"troll":
		check(world.exit_unlocked, "standard-ability Troll victory unlocks the exit")
